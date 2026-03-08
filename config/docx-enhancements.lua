-- docx-enhancements.lua — Pandoc Lua filter for DOCX output
-- Adds Table of Figures field and Index field codes for Word
-- Also collects index terms from text (mirroring index-filter.lua logic)

local index_terms = {}
local figure_count = 0
local seen_terms = {}
local current_chapter = ""

-- Subset of key terms for the index (same as index-filter.lua)
local terms = {
  { pattern = "sovereign zone",            index = "sovereign zone" },
  { pattern = "operational sovereignty",   index = "operational sovereignty" },
  { pattern = "digital sovereignty",       index = "digital sovereignty" },
  { pattern = "data sovereignty",          index = "data sovereignty" },
  { pattern = "zero%-copy",               index = "zero-copy integration" },
  { pattern = "control plane",             index = "control plane" },
  { pattern = "observability plane",       index = "observability plane" },
  { pattern = "agentic intelligence plane", index = "agentic intelligence plane" },
  { pattern = "multi%-cloud",             index = "multi-cloud" },
  { pattern = "hybrid cloud",              index = "hybrid cloud" },
  { pattern = "agentic operations",        index = "agentic operations" },
  { pattern = "shift%-left",              index = "shift-left operations" },
  { pattern = "policy%-as%-code",          index = "policy-as-code" },
  { pattern = "canary deploy",             index = "canary deployment" },
  { pattern = "progressive delivery",      index = "progressive delivery" },
  { pattern = "microservice",              index = "microservices" },
  { pattern = "immutable infrastructure",  index = "immutable infrastructure" },
  { pattern = "declarative",               index = "declarative configuration" },
  { pattern = "OpenTelemetry",             index = "OpenTelemetry" },
  { pattern = "Prometheus",                index = "Prometheus" },
  { pattern = "Grafana",                   index = "Grafana" },
  { pattern = "Instana",                   index = "Instana" },
  { pattern = "SLO",                       index = "SLO (service level objective)" },
  { pattern = "SLI",                       index = "SLI (service level indicator)" },
  { pattern = "Kubernetes",                index = "Kubernetes" },
  { pattern = "Terraform",                 index = "Terraform" },
  { pattern = "Ansible",                   index = "Ansible" },
  { pattern = "Argo CD",                   index = "Argo CD" },
  { pattern = "IBM Concert",              index = "IBM Concert" },
  { pattern = "watsonx",                   index = "watsonx" },
  { pattern = "Orchestrate",              index = "watsonx Orchestrate" },
  { pattern = "HashiCorp Vault",           index = "HashiCorp Vault" },
  { pattern = "GDPR",                      index = "GDPR" },
  { pattern = "NIS ?2",                    index = "NIS 2 Directive" },
  { pattern = "DORA",                      index = "DORA (Digital Operational Resilience Act)" },
  { pattern = "ISO 27001",                 index = "ISO 27001" },
  { pattern = "SOC 2",                     index = "SOC 2" },
  { pattern = "FedRAMP",                   index = "FedRAMP" },
  { pattern = "FinOps",                    index = "FinOps" },
  { pattern = "ITSM",                      index = "ITSM" },
  { pattern = "CMDB",                      index = "CMDB" },
  { pattern = "incident management",       index = "incident management" },
  { pattern = "change management",         index = "change management" },
  { pattern = "runbook",                   index = "runbook automation" },
  { pattern = "chaos engineering",         index = "chaos engineering" },
  { pattern = "self%-healing",             index = "self-healing" },
  { pattern = "CI/CD",                     index = "CI/CD pipeline" },
  { pattern = "GitOps",                    index = "GitOps" },
  { pattern = "DevOps",                    index = "DevOps" },
  { pattern = "SRE",                       index = "SRE (site reliability engineering)" },
  { pattern = "toil",                      index = "toil" },
  { pattern = "blast radius",              index = "blast radius" },
  { pattern = "confidential computing",    index = "confidential computing" },
  { pattern = "mutual TLS",               index = "mutual TLS (mTLS)" },
  { pattern = "service mesh",              index = "service mesh" },
  { pattern = "RAG",                       index = "RAG (retrieval-augmented generation)" },
  { pattern = "large language model",      index = "large language model (LLM)" },
  { pattern = "LLM",                       index = "large language model (LLM)" },
  { pattern = "prompt engineering",        index = "prompt engineering" },
  { pattern = "hallucination",             index = "hallucination (AI)" },
  { pattern = "explainability",            index = "explainability" },
  { pattern = "audit trail",              index = "audit trail" },
  { pattern = "maturity model",            index = "maturity model" },
  { pattern = "operating model",           index = "operating model" },
  { pattern = "platform engineering",      index = "platform engineering" },
  { pattern = "golden path",              index = "golden path" },
  { pattern = "inner source",             index = "inner source" },
  { pattern = "eBPF",                      index = "eBPF" },
  { pattern = "Cilium",                    index = "Cilium" },
  { pattern = "Open Policy Agent",         index = "Open Policy Agent (OPA)" },
  { pattern = "OPA",                       index = "Open Policy Agent (OPA)" },
  { pattern = "Gatekeeper",               index = "Gatekeeper" },
  { pattern = "Crossplane",               index = "Crossplane" },
  { pattern = "Tekton",                   index = "Tekton" },
  { pattern = "Red Hat OpenShift",         index = "Red Hat OpenShift" },
  { pattern = "OpenShift",                index = "Red Hat OpenShift" },
}

-- Scan Str elements for index terms
function Str(el)
  -- not used for docx; we scan at Para level
  return el
end

-- Track chapters
function Header(el)
  if el.level == 1 then
    current_chapter = pandoc.utils.stringify(el)
    seen_terms = {}
  end
  return el
end

-- Scan paragraphs for terms and collect them
function Para(el)
  local text = pandoc.utils.stringify(el)
  for _, term in ipairs(terms) do
    if text:find(term.pattern) then
      local key = term.index .. "|" .. current_chapter
      if not seen_terms[key] then
        seen_terms[key] = true
        if not index_terms[term.index] then
          index_terms[term.index] = {}
        end
        table.insert(index_terms[term.index], current_chapter)
      end
    end
  end
  return el
end

-- At the end, append Table of Figures instruction and Index
function Pandoc(doc)
  local blocks = doc.blocks
  local new_blocks = {}

  -- Find where the glossary starts to insert TOF before it
  local glossary_idx = nil
  for i, block in ipairs(blocks) do
    if block.t == "Header" and block.level == 1 then
      local text = pandoc.utils.stringify(block)
      if text:find("Glossary") then
        glossary_idx = i
        break
      end
    end
  end

  -- Build Table of Figures section
  local tof_blocks = {}
  table.insert(tof_blocks, pandoc.Header(1, pandoc.Str("Table of Figures")))
  table.insert(tof_blocks, pandoc.Para({
    pandoc.Str("[Update this field in Word: select the text below, then press F9, or Insert > Index and Tables > Table of Figures]")
  }))
  -- Add a raw OOXML field for TOF
  table.insert(tof_blocks, pandoc.RawBlock("openxml",
    '<w:p><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> TOC \\c "Figure" </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>Right-click and choose Update Field</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>'
  ))

  -- Build Index section
  local index_blocks = {}
  table.insert(index_blocks, pandoc.Header(1, pandoc.Str("Index")))

  -- Sort terms alphabetically
  local sorted_terms = {}
  for term, _ in pairs(index_terms) do
    table.insert(sorted_terms, term)
  end
  table.sort(sorted_terms, function(a, b) return a:lower() < b:lower() end)

  -- Group by first letter
  local current_letter = ""
  local items = {}
  for _, term in ipairs(sorted_terms) do
    local first = term:sub(1,1):upper()
    if first ~= current_letter then
      if #items > 0 then
        table.insert(index_blocks, pandoc.BulletList(items))
        items = {}
      end
      current_letter = first
      table.insert(index_blocks, pandoc.Header(2, pandoc.Str(current_letter)))
    end
    local chapters = index_terms[term]
    local chapter_list = table.concat(chapters, "; ")
    table.insert(items, {pandoc.Para({
      pandoc.Strong(pandoc.Str(term)),
      pandoc.Str(" — "),
      pandoc.Str(chapter_list)
    })})
  end
  if #items > 0 then
    table.insert(index_blocks, pandoc.BulletList(items))
  end

  -- Reassemble: all content, then TOF, then rest (glossary+index at end)
  if glossary_idx then
    for i = 1, glossary_idx - 1 do
      table.insert(new_blocks, blocks[i])
    end
    -- Insert Table of Figures before glossary
    for _, b in ipairs(tof_blocks) do
      table.insert(new_blocks, b)
    end
    -- Glossary and remaining content
    for i = glossary_idx, #blocks do
      table.insert(new_blocks, blocks[i])
    end
  else
    for _, b in ipairs(blocks) do
      table.insert(new_blocks, b)
    end
    for _, b in ipairs(tof_blocks) do
      table.insert(new_blocks, b)
    end
  end

  -- Append index at the very end
  for _, b in ipairs(index_blocks) do
    table.insert(new_blocks, b)
  end

  doc.blocks = new_blocks
  return doc
end
