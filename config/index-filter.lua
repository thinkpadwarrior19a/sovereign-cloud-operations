-- index-filter.lua — Pandoc Lua filter for automatic index generation
-- Scans text for key terms and inserts \index{} commands on first
-- occurrence per chapter.

-- Key terms grouped by category.
-- Each entry: { pattern = "...", index = "..." }
-- pattern: Lua pattern to match in text (case-sensitive)
-- index:   the index entry string passed to \index{}
-- The ! character creates sub-entries in makeindex.

local terms = {
  -- =====================================================================
  -- SOVEREIGNTY AND ARCHITECTURE
  -- =====================================================================
  { pattern = "sovereign zone",            index = "sovereign zone" },
  { pattern = "operational sovereignty",   index = "operational sovereignty" },
  { pattern = "digital sovereignty",       index = "digital sovereignty" },
  { pattern = "data sovereignty",          index = "data sovereignty" },
  { pattern = "data residency",            index = "data residency" },
  { pattern = "data localisation",         index = "data localisation" },
  { pattern = "data classification",       index = "data classification" },
  { pattern = "data gravity",              index = "data gravity" },
  { pattern = "zero%-copy integration",    index = "zero-copy integration" },
  { pattern = "zero%-copy",               index = "zero-copy integration" },
  { pattern = "control plane",             index = "control plane" },
  { pattern = "observability plane",       index = "observability plane" },
  { pattern = "automation plane",          index = "automation and orchestration plane" },
  { pattern = "governance plane",          index = "governance and audit plane" },
  { pattern = "agentic intelligence plane", index = "agentic intelligence plane" },
  { pattern = "reference model",           index = "architecture reference model" },
  { pattern = "air%-gapped",              index = "air-gapped operations" },
  { pattern = "multi%-cloud",             index = "multi-cloud" },
  { pattern = "hybrid cloud",              index = "hybrid cloud" },
  { pattern = "availability zone",         index = "availability zone" },
  { pattern = "landing zone",              index = "landing zone" },
  { pattern = "cross%-cloud",             index = "cross-cloud operations" },
  { pattern = "federated",                 index = "federation" },
  { pattern = "tenant",                    index = "multi-tenancy" },
  { pattern = "blast radius",              index = "blast radius" },
  { pattern = "defence in depth",          index = "defence in depth" },
  { pattern = "defense in depth",          index = "defence in depth" },
  { pattern = "single pane of glass",      index = "single pane of glass" },

  -- =====================================================================
  -- ARCHITECTURAL PATTERNS
  -- =====================================================================
  { pattern = "agentic operations",        index = "agentic operations" },
  { pattern = "shift%-left",              index = "shift-left operations" },
  { pattern = "policy%-as%-code",          index = "policy-as-code" },
  { pattern = "guardrail",                 index = "guardrails" },
  { pattern = "sidecar",                   index = "sidecar pattern" },
  { pattern = "canary deploy",             index = "canary deployment" },
  { pattern = "canary release",            index = "canary deployment" },
  { pattern = "blue%-green",              index = "blue-green deployment" },
  { pattern = "progressive delivery",      index = "progressive delivery" },
  { pattern = "rolling update",            index = "rolling update" },
  { pattern = "event%-driven architecture", index = "event-driven architecture" },
  { pattern = "event%-driven",            index = "event-driven architecture" },
  { pattern = "microservice",              index = "microservices" },
  { pattern = "monolith",                  index = "monolith" },
  { pattern = "strangler fig",             index = "strangler fig pattern" },
  { pattern = "fan%-out",                 index = "fan-out pattern" },
  { pattern = "saga pattern",              index = "saga pattern" },
  { pattern = "bulkhead",                  index = "bulkhead pattern" },
  { pattern = "retry pattern",             index = "retry pattern" },
  { pattern = "backpressure",              index = "backpressure" },
  { pattern = "idempoten",                 index = "idempotency" },
  { pattern = "eventual consistency",      index = "eventual consistency" },
  { pattern = "CQRS",                      index = "CQRS (command query responsibility segregation)" },
  { pattern = "twelve%-factor",           index = "twelve-factor application" },
  { pattern = "immutable infrastructure",  index = "immutable infrastructure" },
  { pattern = "desired state",             index = "desired state configuration" },
  { pattern = "declarative",               index = "declarative configuration" },
  { pattern = "reconciliation loop",       index = "reconciliation loop" },
  { pattern = "control loop",              index = "control loop" },
  { pattern = "operator pattern",          index = "operator pattern (Kubernetes)" },
  { pattern = "custom resource",           index = "custom resource definition (CRD)" },

  -- =====================================================================
  -- OBSERVABILITY
  -- =====================================================================
  { pattern = "observability",             index = "observability" },
  { pattern = "telemetry",                 index = "telemetry" },
  { pattern = "OpenTelemetry",             index = "OpenTelemetry" },
  { pattern = "OTLP",                      index = "OTLP (OpenTelemetry Protocol)" },
  { pattern = "Instana",                   index = "Instana" },
  { pattern = "MTTD",                      index = "MTTD (mean time to detect)" },
  { pattern = "MTTR",                      index = "MTTR (mean time to resolve)" },
  { pattern = "MTBF",                      index = "MTBF (mean time between failures)" },
  { pattern = "service level objective",   index = "SLO (service level objective)" },
  { pattern = "SLO[s]?[^A-Z]",           index = "SLO (service level objective)" },
  { pattern = "service level indicator",   index = "SLI (service level indicator)" },
  { pattern = "SLI[s]?[^A-Z]",           index = "SLI (service level indicator)" },
  { pattern = "service level agreement",   index = "SLA (service level agreement)" },
  { pattern = "error budget",              index = "error budget" },
  { pattern = "golden signal",             index = "golden signals" },
  { pattern = "distributed tracing",       index = "distributed tracing" },
  { pattern = "log aggregation",           index = "log aggregation" },
  { pattern = "network observability",     index = "network observability" },
  { pattern = "Prometheus",                index = "Prometheus" },
  { pattern = "Grafana",                   index = "Grafana" },
  { pattern = "Elasticsearch",             index = "Elasticsearch" },
  { pattern = "Fluentd",                   index = "Fluentd" },
  { pattern = "Fluent Bit",                index = "Fluent Bit" },
  { pattern = "Jaeger",                    index = "Jaeger" },
  { pattern = "Zipkin",                    index = "Zipkin" },
  { pattern = "Thanos",                    index = "Thanos" },
  { pattern = "synthetic monitoring",      index = "synthetic monitoring" },
  { pattern = "synthetic prob",            index = "synthetic monitoring" },
  { pattern = "anomaly detection",         index = "anomaly detection" },
  { pattern = "baseline",                  index = "baseline (observability)" },
  { pattern = "alert fatigue",             index = "alert fatigue" },
  { pattern = "alert storm",               index = "alert storm" },
  { pattern = "noise reduction",           index = "noise reduction (alerting)" },
  { pattern = "correlation engine",        index = "correlation engine" },
  { pattern = "causal inference",          index = "causal inference" },
  { pattern = "root cause analysis",       index = "root cause analysis" },
  { pattern = "root cause",                index = "root cause analysis" },
  { pattern = "topology discovery",        index = "topology discovery" },
  { pattern = "entity graph",              index = "entity graph" },
  { pattern = "health score",              index = "health scoring" },
  { pattern = "situation",                 index = "situation (Concert)" },
  { pattern = "IPFIX",                     index = "IPFIX" },
  { pattern = "NetFlow",                   index = "NetFlow" },
  { pattern = "sFlow",                     index = "sFlow" },
  { pattern = "Hubble",                    index = "Hubble (Cilium)" },
  { pattern = "PUE",                       index = "PUE (power usage effectiveness)" },
  { pattern = "power usage effectiveness", index = "PUE (power usage effectiveness)" },
  { pattern = "carbon intensity",          index = "carbon intensity" },
  { pattern = "Scope 1",                   index = "emissions!Scope 1" },
  { pattern = "Scope 2",                   index = "emissions!Scope 2" },
  { pattern = "Scope 3",                   index = "emissions!Scope 3" },

  -- =====================================================================
  -- IBM PRODUCTS AND TECHNOLOGIES
  -- =====================================================================
  { pattern = "IBM Concert",               index = "IBM Concert" },
  { pattern = "watsonx Orchestrate",       index = "watsonx Orchestrate" },
  { pattern = "watsonx%.governance",       index = "watsonx.governance" },
  { pattern = "watsonx Code Assistant",    index = "watsonx Code Assistant" },
  { pattern = "watsonx%.ai",              index = "watsonx.ai" },
  { pattern = "watsonx%.data",            index = "watsonx.data" },
  { pattern = "Granite",                   index = "Granite models" },
  { pattern = "IBM Cloud Satellite",       index = "IBM Cloud Satellite" },
  { pattern = "Cloud Pak",                 index = "IBM Cloud Pak" },
  { pattern = "Turbonomic",               index = "Turbonomic" },
  { pattern = "DataStage",                index = "IBM DataStage" },
  { pattern = "OpenPages",                index = "IBM OpenPages" },
  { pattern = "IBM Cloud",                 index = "IBM Cloud" },
  { pattern = "Data Fabric",              index = "IBM Data Fabric" },
  { pattern = "Guardium",                 index = "IBM Guardium" },
  { pattern = "QRadar",                   index = "IBM QRadar" },
  { pattern = "Maximo",                   index = "IBM Maximo" },
  { pattern = "Envizi",                   index = "IBM Envizi" },

  -- =====================================================================
  -- CLOUD PROVIDERS
  -- =====================================================================
  { pattern = "Amazon Web Services",       index = "AWS (Amazon Web Services)" },
  { pattern = "AWS[^A-Za-z]",            index = "AWS (Amazon Web Services)" },
  { pattern = "Microsoft Azure",           index = "Microsoft Azure" },
  { pattern = "Azure[^A-Za-z]",          index = "Microsoft Azure" },
  { pattern = "Google Cloud",              index = "Google Cloud Platform" },
  { pattern = "GCP[^A-Za-z]",            index = "Google Cloud Platform" },
  { pattern = "hyperscaler",               index = "hyperscaler" },

  -- =====================================================================
  -- INFRASTRUCTURE AND AUTOMATION
  -- =====================================================================
  { pattern = "OpenShift",                 index = "Red Hat OpenShift" },
  { pattern = "Kubernetes",                index = "Kubernetes" },
  { pattern = "Terraform",                 index = "Terraform" },
  { pattern = "OpenTofu",                  index = "OpenTofu" },
  { pattern = "Pulumi",                    index = "Pulumi" },
  { pattern = "Crossplane",               index = "Crossplane" },
  { pattern = "Ansible",                   index = "Ansible" },
  { pattern = "Ansible Automation Platform", index = "Ansible Automation Platform" },
  { pattern = "Ansible Lightspeed",        index = "Ansible Lightspeed" },
  { pattern = "Argo CD",                   index = "Argo CD" },
  { pattern = "Flux[^A-Za-z]",           index = "Flux" },
  { pattern = "Tekton",                    index = "Tekton" },
  { pattern = "GitOps",                    index = "GitOps" },
  { pattern = "infrastructure as code",    index = "infrastructure as code" },
  { pattern = "IaC[^A-Za-z]",            index = "infrastructure as code" },
  { pattern = "CI/CD",                     index = "CI/CD" },
  { pattern = "continuous integration",    index = "CI/CD!continuous integration" },
  { pattern = "continuous delivery",       index = "CI/CD!continuous delivery" },
  { pattern = "continuous deployment",     index = "CI/CD!continuous deployment" },
  { pattern = "RHACM",                     index = "RHACM (Red Hat Advanced Cluster Management)" },
  { pattern = "Helm",                      index = "Helm" },
  { pattern = "Kustomize",                index = "Kustomize" },
  { pattern = "container",                 index = "containers" },
  { pattern = "Docker",                    index = "Docker" },
  { pattern = "Podman",                    index = "Podman" },
  { pattern = "namespace",                 index = "namespace (Kubernetes)" },
  { pattern = "etcd",                      index = "etcd" },
  { pattern = "admission controller",      index = "admission controller" },
  { pattern = "webhook",                   index = "webhook" },
  { pattern = "Kyverno",                  index = "Kyverno" },
  { pattern = "Jenkins",                   index = "Jenkins" },
  { pattern = "GitHub Actions",            index = "GitHub Actions" },
  { pattern = "GitLab",                    index = "GitLab" },
  { pattern = "pull request",              index = "pull request" },
  { pattern = "merge request",             index = "merge request" },
  { pattern = "feature flag",              index = "feature flags" },
  { pattern = "config map",               index = "ConfigMap (Kubernetes)" },
  { pattern = "ConfigMap",                index = "ConfigMap (Kubernetes)" },
  { pattern = "CronJob",                  index = "CronJob (Kubernetes)" },
  { pattern = "DaemonSet",                index = "DaemonSet (Kubernetes)" },
  { pattern = "StatefulSet",              index = "StatefulSet (Kubernetes)" },
  { pattern = "Ingress",                  index = "Ingress (Kubernetes)" },

  -- =====================================================================
  -- SECURITY AND IDENTITY
  -- =====================================================================
  { pattern = "SPIFFE",                    index = "SPIFFE" },
  { pattern = "SPIRE",                     index = "SPIRE" },
  { pattern = "HashiCorp Vault",           index = "HashiCorp Vault" },
  { pattern = "Vault[^A-Za-z]",          index = "HashiCorp Vault" },
  { pattern = "mTLS",                      index = "mTLS (mutual TLS)" },
  { pattern = "mutual TLS",               index = "mTLS (mutual TLS)" },
  { pattern = "TLS[^A-Za-z]",            index = "TLS (Transport Layer Security)" },
  { pattern = "service mesh",              index = "service mesh" },
  { pattern = "Istio",                     index = "Istio" },
  { pattern = "Cilium",                    index = "Cilium" },
  { pattern = "Envoy",                     index = "Envoy proxy" },
  { pattern = "eBPF",                      index = "eBPF" },
  { pattern = "SBOM",                      index = "SBOM (software bill of materials)" },
  { pattern = "software bill of materials", index = "SBOM (software bill of materials)" },
  { pattern = "Sigstore",                  index = "Sigstore" },
  { pattern = "Cosign",                    index = "Cosign" },
  { pattern = "in%-toto",                 index = "in-toto" },
  { pattern = "SLSA",                      index = "SLSA (Supply-chain Levels for Software Artifacts)" },
  { pattern = "zero trust",                index = "zero trust" },
  { pattern = "least privilege",           index = "least privilege" },
  { pattern = "role%-based access control", index = "RBAC (role-based access control)" },
  { pattern = "RBAC",                      index = "RBAC (role-based access control)" },
  { pattern = "attribute%-based access control", index = "ABAC (attribute-based access control)" },
  { pattern = "ABAC",                      index = "ABAC (attribute-based access control)" },
  { pattern = "privileged access management", index = "privileged access management" },
  { pattern = "PAM[^A-Za-z]",            index = "privileged access management" },
  { pattern = "multi%-factor authentication", index = "MFA (multi-factor authentication)" },
  { pattern = "MFA[^A-Za-z]",            index = "MFA (multi-factor authentication)" },
  { pattern = "single sign%-on",          index = "SSO (single sign-on)" },
  { pattern = "SSO[^A-Za-z]",            index = "SSO (single sign-on)" },
  { pattern = "OIDC",                      index = "OIDC (OpenID Connect)" },
  { pattern = "OpenID Connect",            index = "OIDC (OpenID Connect)" },
  { pattern = "SAML",                      index = "SAML" },
  { pattern = "LDAP",                      index = "LDAP" },
  { pattern = "Active Directory",          index = "Active Directory" },
  { pattern = "encryption at rest",        index = "encryption!at rest" },
  { pattern = "encryption in transit",     index = "encryption!in transit" },
  { pattern = "key management",            index = "key management" },
  { pattern = "KMS[^A-Za-z]",            index = "KMS (key management service)" },
  { pattern = "HSM[^A-Za-z]",            index = "HSM (hardware security module)" },
  { pattern = "hardware security module",  index = "HSM (hardware security module)" },
  { pattern = "certificate rotation",      index = "certificate rotation" },
  { pattern = "certificate lifecycle",     index = "certificate lifecycle" },
  { pattern = "cert%-manager",            index = "cert-manager" },
  { pattern = "secrets rotation",          index = "secrets rotation" },
  { pattern = "workload identity",         index = "workload identity" },
  { pattern = "data masking",              index = "data masking" },
  { pattern = "pseudonymisation",          index = "pseudonymisation" },
  { pattern = "pseudonymization",          index = "pseudonymisation" },
  { pattern = "tokenisation",              index = "tokenisation" },
  { pattern = "tokenization",              index = "tokenisation" },
  { pattern = "data redaction",            index = "data redaction" },
  { pattern = "vulnerability scan",        index = "vulnerability scanning" },
  { pattern = "penetration test",          index = "penetration testing" },
  { pattern = "TLPT",                      index = "TLPT (Threat-Led Penetration Testing)" },
  { pattern = "TIBER",                     index = "TIBER-EU" },
  { pattern = "supply chain security",     index = "supply chain security" },
  { pattern = "software supply chain",     index = "supply chain security" },
  { pattern = "CVE[^A-Za-z]",            index = "CVE (Common Vulnerabilities and Exposures)" },
  { pattern = "network segmentation",      index = "network segmentation" },
  { pattern = "microsegmentation",         index = "microsegmentation" },
  { pattern = "firewall",                  index = "firewall" },
  { pattern = "intrusion detection",       index = "intrusion detection" },
  { pattern = "SIEM",                      index = "SIEM" },
  { pattern = "SOAR",                      index = "SOAR" },

  -- =====================================================================
  -- AI AND AGENTS
  -- =====================================================================
  { pattern = "agentic AI",               index = "agentic AI" },
  { pattern = "multi%-agent",             index = "multi-agent orchestration" },
  { pattern = "large language model",      index = "large language models" },
  { pattern = "LLM[s]?[^A-Za-z]",        index = "large language models" },
  { pattern = "foundation model",          index = "foundation models" },
  { pattern = "open%-weight",             index = "open-weight models" },
  { pattern = "retrieval%-augmented generation", index = "RAG (retrieval-augmented generation)" },
  { pattern = "RAG[^A-Za-z]",            index = "RAG (retrieval-augmented generation)" },
  { pattern = "fine%-tuning",             index = "fine-tuning" },
  { pattern = "prompt engineering",        index = "prompt engineering" },
  { pattern = "chain%-of%-thought",       index = "chain-of-thought" },
  { pattern = "human%-in%-the%-loop",     index = "human-in-the-loop" },
  { pattern = "human oversight",           index = "human oversight" },
  { pattern = "confidence threshold",      index = "confidence thresholds" },
  { pattern = "confidence score",          index = "confidence thresholds" },
  { pattern = "circuit breaker",           index = "circuit breaker" },
  { pattern = "self%-healing",            index = "self-healing" },
  { pattern = "autonomous remediation",    index = "autonomous remediation" },
  { pattern = "closed%-loop",             index = "closed-loop remediation" },
  { pattern = "approval gate",             index = "approval gate" },
  { pattern = "escalation",                index = "escalation" },
  { pattern = "tool calling",              index = "tool calling (agents)" },
  { pattern = "function calling",          index = "tool calling (agents)" },
  { pattern = "agent supervisor",          index = "agent supervisor" },
  { pattern = "planner agent",             index = "agents!planner" },
  { pattern = "executor agent",            index = "agents!executor" },
  { pattern = "reviewer agent",            index = "agents!reviewer" },
  { pattern = "guardrail agent",           index = "agents!guardrail" },
  { pattern = "synthesiser agent",         index = "agents!synthesiser" },
  { pattern = "agent apprentice",          index = "agent apprentice model" },
  { pattern = "model drift",               index = "model drift" },
  { pattern = "model registry",            index = "model registry" },
  { pattern = "model lineage",             index = "model lineage" },
  { pattern = "model card",                index = "model card" },
  { pattern = "bias detection",            index = "bias detection" },
  { pattern = "fairness metric",           index = "fairness metrics" },
  { pattern = "explainability",            index = "explainability" },
  { pattern = "interpretability",          index = "explainability" },
  { pattern = "auditability",              index = "auditability" },
  { pattern = "AI risk",                   index = "AI risk management" },
  { pattern = "AI governance",             index = "AI governance" },
  { pattern = "sovereign AI record",       index = "sovereign AI record" },
  { pattern = "hallucination",             index = "hallucination (AI)" },
  { pattern = "grounding",                 index = "grounding (AI)" },
  { pattern = "embedding",                 index = "embeddings" },
  { pattern = "vector database",           index = "vector database" },
  { pattern = "vector store",              index = "vector database" },
  { pattern = "chunking",                  index = "chunking (RAG)" },
  { pattern = "token limit",               index = "token limits" },
  { pattern = "context window",            index = "context window" },
  { pattern = "inference",                 index = "inference (AI)" },
  { pattern = "natural language",          index = "natural language processing" },
  { pattern = "intent classification",     index = "intent classification" },
  { pattern = "entity extraction",         index = "entity extraction" },
  { pattern = "slot filling",              index = "slot filling" },
  { pattern = "conversational interface",  index = "conversational interface" },
  { pattern = "chat%-first",              index = "chat-first UX" },
  { pattern = "recommendation engine",     index = "recommendation engine" },
  { pattern = "recommendation%-driven",   index = "recommendation-driven operations" },
  { pattern = "operational autonomy",      index = "operational autonomy levels" },
  { pattern = "autonomy level",            index = "operational autonomy levels" },

  -- =====================================================================
  -- COMPLIANCE AND GOVERNANCE
  -- =====================================================================
  { pattern = "OPA[^A-Za-z]",            index = "OPA (Open Policy Agent)" },
  { pattern = "Open Policy Agent",         index = "OPA (Open Policy Agent)" },
  { pattern = "Rego[^A-Za-z]",           index = "Rego" },
  { pattern = "Gatekeeper",               index = "Gatekeeper" },
  { pattern = "Conftest",                  index = "Conftest" },
  { pattern = "audit trail",               index = "audit trail" },
  { pattern = "immutable log",             index = "immutable logging" },
  { pattern = "compliance signal",         index = "compliance signal fabric" },
  { pattern = "drift detection",           index = "drift detection" },
  { pattern = "configuration drift",       index = "drift detection" },
  { pattern = "evidence collection",       index = "evidence collection (compliance)" },
  { pattern = "attestation",               index = "attestation" },
  { pattern = "SOC 2",                     index = "SOC 2" },
  { pattern = "Common Criteria",           index = "Common Criteria (ISO/IEC 15408)" },
  { pattern = "risk register",             index = "risk register" },
  { pattern = "risk appetite",             index = "risk appetite" },
  { pattern = "impact tolerance",          index = "impact tolerance" },
  { pattern = "control mapping",           index = "control mapping" },
  { pattern = "regulatory mapping",        index = "control mapping" },
  { pattern = "governance body",           index = "governance bodies" },
  { pattern = "governance board",          index = "governance bodies" },
  { pattern = "three lines",               index = "three lines model" },
  { pattern = "worm storage",              index = "WORM storage" },
  { pattern = "WORM",                      index = "WORM storage" },
  { pattern = "tamper%-evident",          index = "tamper-evident logging" },
  { pattern = "cryptographic chain",       index = "tamper-evident logging" },

  -- =====================================================================
  -- REGULATIONS — FINANCIAL SERVICES
  -- =====================================================================
  { pattern = "DORA[^A-Za-z]",           index = "DORA (Digital Operational Resilience Act)" },
  { pattern = "Digital Operational Resilience Act", index = "DORA (Digital Operational Resilience Act)" },
  { pattern = "PSD2",                      index = "PSD2 (Payment Services Directive)" },
  { pattern = "PSD3",                      index = "PSD3" },
  { pattern = "MiCA",                      index = "MiCA (Markets in Crypto-Assets)" },
  { pattern = "Basel III",                 index = "Basel III/IV" },
  { pattern = "Basel IV",                  index = "Basel III/IV" },
  { pattern = "SOX[^A-Za-z]",            index = "SOX (Sarbanes-Oxley Act)" },
  { pattern = "Sarbanes%-Oxley",          index = "SOX (Sarbanes-Oxley Act)" },
  { pattern = "PCI DSS",                   index = "PCI DSS" },
  { pattern = "EBA[^A-Za-z]",            index = "EBA (European Banking Authority)" },
  { pattern = "European Banking Authority", index = "EBA (European Banking Authority)" },
  { pattern = "FCA[^A-Za-z]",            index = "FCA (Financial Conduct Authority)" },
  { pattern = "Financial Conduct Authority", index = "FCA (Financial Conduct Authority)" },
  { pattern = "PRA[^A-Za-z]",            index = "PRA (Prudential Regulation Authority)" },
  { pattern = "Prudential Regulation Authority", index = "PRA (Prudential Regulation Authority)" },

  -- =====================================================================
  -- REGULATIONS — EU CROSS-CUTTING
  -- =====================================================================
  { pattern = "NIS2",                      index = "NIS2 Directive" },
  { pattern = "NIS 2",                     index = "NIS2 Directive" },
  { pattern = "GDPR",                      index = "GDPR (General Data Protection Regulation)" },
  { pattern = "Article 32",                index = "GDPR (General Data Protection Regulation)!Article 32" },
  { pattern = "EU AI Act",                 index = "EU AI Act" },
  { pattern = "Artificial Intelligence Act", index = "EU AI Act" },
  { pattern = "Article 9[^0-9]",          index = "EU AI Act!Article 9 (risk management)" },
  { pattern = "Article 13",                index = "EU AI Act!Article 13 (transparency)" },
  { pattern = "Article 14",                index = "EU AI Act!Article 14 (human oversight)" },
  { pattern = "Annex III",                 index = "EU AI Act!Annex III (high-risk)" },
  { pattern = "high%-risk AI",            index = "high-risk AI systems" },
  { pattern = "eIDAS",                     index = "eIDAS" },
  { pattern = "EU Data Act",               index = "EU Data Act" },
  { pattern = "Data Act",                  index = "EU Data Act" },
  { pattern = "Digital Markets Act",       index = "Digital Markets Act" },
  { pattern = "Cyber Resilience Act",      index = "EU Cyber Resilience Act" },
  { pattern = "CRA[^A-Za-z]",            index = "EU Cyber Resilience Act" },
  { pattern = "EU Taxonomy",               index = "EU Taxonomy Regulation" },

  -- =====================================================================
  -- REGULATIONS — SUSTAINABILITY
  -- =====================================================================
  { pattern = "CSRD",                      index = "CSRD (Corporate Sustainability Reporting Directive)" },
  { pattern = "Corporate Sustainability Reporting", index = "CSRD (Corporate Sustainability Reporting Directive)" },
  { pattern = "CSDDD",                     index = "CSDDD (Corporate Sustainability Due Diligence Directive)" },
  { pattern = "ISSB",                      index = "ISSB (International Sustainability Standards Board)" },
  { pattern = "IFRS S1",                   index = "ISSB (International Sustainability Standards Board)" },
  { pattern = "TCFD",                      index = "TCFD" },
  { pattern = "double materiality",        index = "double materiality" },
  { pattern = "ESG[^A-Za-z]",            index = "ESG (environmental, social, governance)" },

  -- =====================================================================
  -- REGULATIONS — HEALTHCARE
  -- =====================================================================
  { pattern = "HIPAA",                     index = "HIPAA" },
  { pattern = "ePHI",                      index = "ePHI (electronic protected health information)" },
  { pattern = "protected health information", index = "ePHI (electronic protected health information)" },
  { pattern = "Medical Device Regulation", index = "EU Medical Device Regulation (MDR)" },
  { pattern = "MDR[^A-Za-z]",            index = "EU Medical Device Regulation (MDR)" },
  { pattern = "Software as a Medical Device", index = "SaMD (Software as a Medical Device)" },
  { pattern = "SaMD",                      index = "SaMD (Software as a Medical Device)" },
  { pattern = "21 CFR Part 11",            index = "FDA 21 CFR Part 11" },
  { pattern = "FDA[^A-Za-z]",            index = "FDA" },
  { pattern = "GxP[^A-Za-z]",            index = "GxP" },
  { pattern = "EUDAMED",                   index = "EUDAMED" },
  { pattern = "HDS[^A-Za-z]",            index = "HDS (H\\'{e}bergeur de Donn\\'{e}es de Sant\\'{e})" },

  -- =====================================================================
  -- REGULATIONS — MANUFACTURING AND INDUSTRIAL
  -- =====================================================================
  { pattern = "IEC 62443",                 index = "IEC 62443" },
  { pattern = "Machinery Regulation",      index = "EU Machinery Regulation" },
  { pattern = "OT/IT convergence",         index = "OT/IT convergence" },
  { pattern = "operational technology",     index = "operational technology (OT)" },
  { pattern = "SCADA",                     index = "SCADA" },
  { pattern = "industrial control",        index = "industrial control systems (ICS)" },
  { pattern = "ICS[^A-Za-z]",            index = "industrial control systems (ICS)" },
  { pattern = "safety%-instrumented",     index = "safety-instrumented systems" },

  -- =====================================================================
  -- REGULATIONS — TRANSPORT
  -- =====================================================================
  { pattern = "TSA[^A-Za-z]",            index = "TSA Security Directives" },
  { pattern = "EASA",                      index = "EASA" },
  { pattern = "IMO[^A-Za-z]",            index = "IMO (International Maritime Organization)" },
  { pattern = "PNR[^A-Za-z]",            index = "PNR (Passenger Name Record)" },

  -- =====================================================================
  -- REGULATIONS — TELECOMS
  -- =====================================================================
  { pattern = "EECC",                      index = "EECC (European Electronic Communications Code)" },
  { pattern = "Telecommunications.*Security.*Act", index = "UK Telecommunications (Security) Act 2021" },

  -- =====================================================================
  -- REGULATIONS — GOVERNMENT AND STANDARDS
  -- =====================================================================
  { pattern = "FedRAMP",                   index = "FedRAMP" },
  { pattern = "EUCS",                      index = "EUCS (EU Cloud Certification Scheme)" },
  { pattern = "ISO/IEC 27001",             index = "ISO/IEC 27001" },
  { pattern = "ISO 27001",                 index = "ISO/IEC 27001" },
  { pattern = "ISO 27002",                 index = "ISO/IEC 27002" },
  { pattern = "ISO 27701",                 index = "ISO 27701" },
  { pattern = "ISO 22301",                 index = "ISO 22301" },
  { pattern = "NIST Cybersecurity Framework", index = "NIST!Cybersecurity Framework" },
  { pattern = "NIST AI RMF",              index = "NIST!AI Risk Management Framework" },
  { pattern = "NIST SP 800%-53",          index = "NIST!SP 800-53" },
  { pattern = "NIST SP 800%-218",         index = "NIST!SP 800-218 (SSDF)" },
  { pattern = "NIST[^A-Za-z]",           index = "NIST" },
  { pattern = "ENISA",                     index = "ENISA" },
  { pattern = "BSI[^A-Za-z]",            index = "BSI (Bundesamt f\\\"ur Sicherheit)" },
  { pattern = "Cyber Essentials",          index = "Cyber Essentials (UK)" },
  { pattern = "ConMon",                    index = "ConMon (continuous monitoring)" },
  { pattern = "POA&M",                    index = "POA\\&M (plan of action and milestones)" },

  -- =====================================================================
  -- EVENTS AND INTEGRATION
  -- =====================================================================
  { pattern = "CloudEvents",               index = "CloudEvents" },
  { pattern = "OpenLineage",               index = "OpenLineage" },
  { pattern = "Kafka",                     index = "Apache Kafka" },
  { pattern = "event sourcing",            index = "event sourcing" },
  { pattern = "data lineage",              index = "data lineage" },
  { pattern = "schema registry",           index = "schema registry" },
  { pattern = "Avro",                      index = "Apache Avro" },
  { pattern = "Protobuf",                  index = "Protocol Buffers" },
  { pattern = "gRPC",                      index = "gRPC" },
  { pattern = "REST API",                  index = "REST API" },
  { pattern = "GraphQL",                   index = "GraphQL" },
  { pattern = "webhook",                   index = "webhook" },
  { pattern = "message queue",             index = "message queue" },
  { pattern = "dead letter",               index = "dead letter queue" },
  { pattern = "event fabric",              index = "event fabric" },
  { pattern = "Apache Atlas",              index = "Apache Atlas" },
  { pattern = "Marquez",                   index = "Marquez" },
  { pattern = "Apicurio",                 index = "Apicurio Registry" },
  { pattern = "Confluent",                index = "Confluent" },

  -- =====================================================================
  -- PROCESSES AND PRACTICES
  -- =====================================================================
  { pattern = "ITSM",                      index = "ITSM" },
  { pattern = "ITIL",                      index = "ITIL" },
  { pattern = "incident management",       index = "incident management" },
  { pattern = "change management",         index = "change management" },
  { pattern = "change advisory board",     index = "CAB (change advisory board)" },
  { pattern = "CAB[^A-Za-z]",            index = "CAB (change advisory board)" },
  { pattern = "standard change",           index = "change management!standard change" },
  { pattern = "emergency change",          index = "change management!emergency change" },
  { pattern = "normal change",             index = "change management!normal change" },
  { pattern = "change risk",               index = "change risk scoring" },
  { pattern = "runbook",                   index = "runbooks" },
  { pattern = "playbook",                  index = "playbooks" },
  { pattern = "war room",                  index = "war room" },
  { pattern = "post%-incident review",    index = "post-incident review" },
  { pattern = "blameless",                index = "blameless culture" },
  { pattern = "toil",                      index = "toil" },
  { pattern = "site reliability engineering", index = "SRE (site reliability engineering)" },
  { pattern = "SRE[^A-Za-z]",            index = "SRE (site reliability engineering)" },
  { pattern = "DevOps",                    index = "DevOps" },
  { pattern = "DevSecOps",                 index = "DevSecOps" },
  { pattern = "platform engineering",      index = "platform engineering" },
  { pattern = "platform team",             index = "platform engineering" },
  { pattern = "FinOps",                    index = "FinOps" },
  { pattern = "chaos engineering",         index = "chaos engineering" },
  { pattern = "game day",                  index = "game day exercise" },
  { pattern = "tabletop exercise",         index = "tabletop exercise" },
  { pattern = "on%-call",                 index = "on-call" },
  { pattern = "pager",                     index = "on-call" },
  { pattern = "disaster recovery",         index = "disaster recovery" },
  { pattern = "business continuity",       index = "business continuity" },
  { pattern = "RTO[^A-Za-z]",            index = "RTO (recovery time objective)" },
  { pattern = "recovery time objective",   index = "RTO (recovery time objective)" },
  { pattern = "RPO[^A-Za-z]",            index = "RPO (recovery point objective)" },
  { pattern = "recovery point objective",  index = "RPO (recovery point objective)" },
  { pattern = "failover",                  index = "failover" },
  { pattern = "rollback",                  index = "rollback" },
  { pattern = "DORA metrics",              index = "DORA metrics (DevOps)" },
  { pattern = "deployment frequency",      index = "DORA metrics (DevOps)!deployment frequency" },
  { pattern = "lead time for changes",     index = "DORA metrics (DevOps)!lead time for changes" },
  { pattern = "change failure rate",       index = "DORA metrics (DevOps)!change failure rate" },
  { pattern = "four key metrics",          index = "DORA metrics (DevOps)" },
  { pattern = "quality gate",              index = "quality gates" },
  { pattern = "safe%-to%-automate",       index = "safe-to-automate test" },

  -- =====================================================================
  -- PEOPLE, SKILLS, AND CULTURE
  -- =====================================================================
  { pattern = "maturity model",            index = "maturity model" },
  { pattern = "operating model",           index = "operating model" },
  { pattern = "T%-shaped engineer",       index = "T-shaped engineer" },
  { pattern = "cognitive load",            index = "cognitive load" },
  { pattern = "skills atrophy",            index = "skills atrophy" },
  { pattern = "knowledge silo",            index = "knowledge silos" },
  { pattern = "tribal knowledge",          index = "tribal knowledge" },
  { pattern = "institutional memory",      index = "institutional memory" },
  { pattern = "trust calibration",         index = "trust calibration" },
  { pattern = "automation bias",           index = "automation bias" },
  { pattern = "complacency",              index = "automation complacency" },
  { pattern = "sovereign zone owner",      index = "roles!sovereign zone owner" },
  { pattern = "policy engineer",           index = "roles!policy engineer" },
  { pattern = "AI operations engineer",    index = "roles!AI operations engineer" },
  { pattern = "cultural shift",            index = "cultural transformation" },
  { pattern = "centre of excellence",      index = "centre of excellence" },
  { pattern = "center of excellence",      index = "centre of excellence" },
  { pattern = "community of practice",     index = "community of practice" },
  { pattern = "training",                  index = "training and skills development" },
  { pattern = "certification",             index = "certification (professional)" },

  -- =====================================================================
  -- NETWORKING
  -- =====================================================================
  { pattern = "private connectivity",      index = "private connectivity" },
  { pattern = "Direct Link",               index = "IBM Direct Link" },
  { pattern = "ExpressRoute",              index = "Azure ExpressRoute" },
  { pattern = "Direct Connect",            index = "AWS Direct Connect" },
  { pattern = "VPN[^A-Za-z]",            index = "VPN" },
  { pattern = "BGP[^A-Za-z]",            index = "BGP (Border Gateway Protocol)" },
  { pattern = "DNS[^A-Za-z]",            index = "DNS" },
  { pattern = "load balancer",             index = "load balancing" },
  { pattern = "content delivery network",  index = "CDN (content delivery network)" },
  { pattern = "CDN[^A-Za-z]",            index = "CDN (content delivery network)" },
  { pattern = "latency",                   index = "latency" },
  { pattern = "bandwidth",                 index = "bandwidth" },
  { pattern = "packet loss",               index = "packet loss" },
  { pattern = "jitter",                    index = "jitter" },
  { pattern = "network policy",            index = "network policy" },
  { pattern = "Calico",                    index = "Calico" },

  -- =====================================================================
  -- QUANTUM, CRYPTOGRAPHY, AND CYBER RESILIENCE
  -- =====================================================================
  { pattern = "post%-quantum",            index = "post-quantum cryptography" },
  { pattern = "quantum%-safe",            index = "post-quantum cryptography" },
  { pattern = "quantum computing",         index = "quantum computing" },
  { pattern = "IBM Quantum",               index = "IBM Quantum" },
  { pattern = "Qiskit",                    index = "Qiskit" },
  { pattern = "ML%-KEM",                  index = "ML-KEM (CRYSTALS-Kyber)" },
  { pattern = "CRYSTALS%-Kyber",          index = "ML-KEM (CRYSTALS-Kyber)" },
  { pattern = "ML%-DSA",                  index = "ML-DSA (CRYSTALS-Dilithium)" },
  { pattern = "CRYSTALS%-Dilithium",      index = "ML-DSA (CRYSTALS-Dilithium)" },
  { pattern = "SLH%-DSA",                index = "SLH-DSA (SPHINCS+)" },
  { pattern = "SPHINCS",                   index = "SLH-DSA (SPHINCS+)" },
  { pattern = "cryptographic agility",     index = "cryptographic agility" },
  { pattern = "cryptographic inventory",   index = "cryptographic inventory" },
  { pattern = "harvest now",               index = "harvest now, decrypt later" },
  { pattern = "lattice%-based",           index = "lattice-based cryptography" },
  { pattern = "homomorphic encryption",    index = "homomorphic encryption" },
  { pattern = "HElib",                     index = "HElib" },
  { pattern = "confidential computing",    index = "confidential computing" },
  { pattern = "secure enclave",            index = "secure enclave" },
  { pattern = "trusted execution",         index = "trusted execution environment" },
  { pattern = "Intel SGX",                 index = "Intel SGX" },
  { pattern = "AMD SEV",                   index = "AMD SEV-SNP" },
  { pattern = "Hyper Protect",             index = "IBM Hyper Protect" },
  { pattern = "KYOK",                      index = "KYOK (Keep Your Own Key)" },
  { pattern = "Safeguarded Copy",          index = "Safeguarded Copy (IBM)" },
  { pattern = "safeguarded cop",           index = "Safeguarded Copy (IBM)" },
  { pattern = "cyber vault",               index = "cyber vault" },
  { pattern = "clean room recovery",       index = "clean room recovery" },
  { pattern = "clean%-room",              index = "clean room recovery" },
  { pattern = "immutable storage",         index = "immutable storage" },
  { pattern = "immutable backup",          index = "immutable storage" },
  { pattern = "WORM storage",              index = "WORM storage" },
  { pattern = "WORM[^A-Za-z]",           index = "WORM storage" },
  { pattern = "append%-only",             index = "append-only storage" },
  { pattern = "tamper%-evident",          index = "tamper-evident logging" },
  { pattern = "Merkle tree",               index = "Merkle tree" },
  { pattern = "hash chain",                index = "hash chain" },
  { pattern = "cryptographic chain",       index = "hash chain" },
  { pattern = "ransomware",                index = "ransomware" },
  { pattern = "Storage Defender",          index = "IBM Storage Defender" },
  { pattern = "data minimisation",         index = "data minimisation" },
  { pattern = "data minimization",         index = "data minimisation" },
  { pattern = "cyber resilien",            index = "cyber resilience" },

  -- =====================================================================
  -- DATA AND STORAGE
  -- =====================================================================
  { pattern = "object storage",            index = "object storage" },
  { pattern = "block storage",             index = "block storage" },
  { pattern = "persistent volume",         index = "persistent volume (Kubernetes)" },
  { pattern = "S3[^A-Za-z]",             index = "S3 (object storage)" },
  { pattern = "backup",                    index = "backup" },
  { pattern = "replication",               index = "replication" },
  { pattern = "data lake",                 index = "data lake" },
  { pattern = "data warehouse",            index = "data warehouse" },
  { pattern = "ETL[^A-Za-z]",            index = "ETL (extract, transform, load)" },
  { pattern = "data pipeline",             index = "data pipeline" },
  { pattern = "data catalog",              index = "data catalogue" },
  { pattern = "data catalogue",            index = "data catalogue" },
  { pattern = "metadata management",       index = "metadata management" },
}

-- Track which terms have been indexed in the current chapter
local indexed_in_chapter = {}

-- Reset tracking on each new chapter heading
function Header(el)
  if el.level == 1 then
    indexed_in_chapter = {}
  end
  return nil
end

-- Process text nodes: look for terms and insert \index{} on first occurrence per chapter
function Str(el)
  -- We need to process at the Inline list level, not individual Str nodes
  return nil
end

function Inlines(inlines)
  -- Build the full text for matching
  local full_text = pandoc.utils.stringify(pandoc.Inlines(inlines))

  local new_inlines = pandoc.List()
  local pending_indices = {}

  -- Check which terms appear in this inline sequence
  for _, term in ipairs(terms) do
    if not indexed_in_chapter[term.index] then
      if full_text:find(term.pattern) then
        indexed_in_chapter[term.index] = true
        table.insert(pending_indices, term.index)
      end
    end
  end

  -- If we found terms to index, prepend the \index commands
  if #pending_indices > 0 then
    for _, idx in ipairs(pending_indices) do
      new_inlines:insert(pandoc.RawInline('latex', '\\index{' .. idx .. '}'))
    end
    new_inlines:extend(inlines)
    return new_inlines
  end

  return nil
end

return {
  { Header = Header },
  { Inlines = Inlines },
}
