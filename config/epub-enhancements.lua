-- epub-enhancements.lua — Pandoc Lua filter for ePub output
-- Generates a Table of Figures and a comprehensive Index as HTML sections

local figure_entries = {}
local index_terms = {}
local seen_terms = {}
local current_chapter = ""
local chapter_id = ""
local figure_counter = 0

-- Key terms for the index
local terms = {
  { pattern = "sovereign zone",            index = "sovereign zone" },
  { pattern = "operational sovereignty",   index = "operational sovereignty" },
  { pattern = "digital sovereignty",       index = "digital sovereignty" },
  { pattern = "data sovereignty",          index = "data sovereignty" },
  { pattern = "data residency",            index = "data residency" },
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

-- Track chapter headings
function Header(el)
  if el.level == 1 then
    current_chapter = pandoc.utils.stringify(el)
    chapter_id = el.identifier or ""
    seen_terms = {}
  end
  return el
end

-- Collect figure references from images with captions
function Figure(el)
  local caption = pandoc.utils.stringify(el.caption)
  if caption and caption ~= "" then
    figure_counter = figure_counter + 1
    table.insert(figure_entries, {
      number = figure_counter,
      caption = caption,
      chapter = current_chapter
    })
  end
  return el
end

-- Also catch images with alt text (older pandoc or inline images)
function Image(el)
  if el.caption and #el.caption > 0 then
    local caption = pandoc.utils.stringify(el.caption)
    if caption and caption ~= "" and caption ~= el.src then
      figure_counter = figure_counter + 1
      table.insert(figure_entries, {
        number = figure_counter,
        caption = caption,
        chapter = current_chapter
      })
    end
  end
  return el
end

-- Scan paragraphs for index terms
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
        -- Avoid duplicate chapter refs
        local dominated = false
        for _, ch in ipairs(index_terms[term.index]) do
          if ch == current_chapter then dominated = true; break end
        end
        if not dominated then
          table.insert(index_terms[term.index], current_chapter)
        end
      end
    end
  end
  return el
end

-- At the end, append Table of Figures and Index
function Pandoc(doc)
  local blocks = doc.blocks
  local new_blocks = {}

  -- Find glossary position
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

  -- Build Table of Figures
  local tof_html = '<section class="table-of-figures">\n<h1>Table of Figures</h1>\n<ol>\n'
  for _, fig in ipairs(figure_entries) do
    tof_html = tof_html .. string.format('<li><strong>Figure %d.</strong> %s</li>\n',
      fig.number, fig.caption)
  end
  tof_html = tof_html .. '</ol>\n</section>\n'

  -- Build Index
  local sorted_terms = {}
  for term, _ in pairs(index_terms) do
    table.insert(sorted_terms, term)
  end
  table.sort(sorted_terms, function(a, b) return a:lower() < b:lower() end)

  local index_html = '<section class="book-index">\n<h1>Index</h1>\n'
  local current_letter = ""
  for _, term in ipairs(sorted_terms) do
    local first = term:sub(1,1):upper()
    if first ~= current_letter then
      if current_letter ~= "" then
        index_html = index_html .. '</ul>\n'
      end
      current_letter = first
      index_html = index_html .. string.format('<h2>%s</h2>\n<ul>\n', current_letter)
    end
    local chapters = index_terms[term]
    local refs = table.concat(chapters, "; ")
    index_html = index_html .. string.format('<li><strong>%s</strong> &mdash; %s</li>\n', term, refs)
  end
  if current_letter ~= "" then
    index_html = index_html .. '</ul>\n'
  end
  index_html = index_html .. '</section>\n'

  -- Assemble: chapters, then TOF, then glossary, then index
  if glossary_idx then
    for i = 1, glossary_idx - 1 do
      table.insert(new_blocks, blocks[i])
    end
    table.insert(new_blocks, pandoc.RawBlock("html", tof_html))
    for i = glossary_idx, #blocks do
      table.insert(new_blocks, blocks[i])
    end
  else
    for _, b in ipairs(blocks) do
      table.insert(new_blocks, b)
    end
    table.insert(new_blocks, pandoc.RawBlock("html", tof_html))
  end

  table.insert(new_blocks, pandoc.RawBlock("html", index_html))

  doc.blocks = new_blocks
  return doc
end
