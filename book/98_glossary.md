---
title: "Glossary"
nav_order: 39
---

# Glossary

**Accountability gap.** A structural problem in traditional IT operating models where separate functional teams (development, operations, security, compliance) each optimise locally, with no single team owning the end-to-end outcome of a service running reliably, securely, and in compliance with sovereignty obligations.

**Action risk classification.** The mechanism by which IBM Concert assigns each recommendation to a risk tier based on blast radius, reversibility, historical failure rate, current component health, and whether the action falls within a pre-approved change category. The classification determines which of the three response modes (human-initiated, agent-assisted, or automated) applies.

**Admission controller.** A Kubernetes mechanism that intercepts requests to the API server before resources are persisted, evaluating them against policy rules. In sovereign estates, admission controllers enforce zone-level invariants such as permitted image sources, namespace isolation, and data classification requirements.

**Agent apprentice model.** A progression model for operational AI agents in which the agent begins by observing human activity, advances to proposing actions for human review, then executes approved actions within bounded contexts, and eventually operates autonomously within defined limits for narrow, validated categories of action.

**Agent skill.** In the watsonx Orchestrate architecture, a self-contained description of a specialised agent's capabilities, expressed in the same format as a tool definition. From Orchestrate's perspective, a specialised agent looks like a callable tool, enabling uniform indirection between direct tool calls and agent delegations.

**Agentic intelligence plane.** One of the four planes in the sovereign operations reference model. It provides AI-driven correlation, reasoning, and conversational interfaces that bridge observation to action, using technologies such as IBM Concert and watsonx Orchestrate.

**Agentic operations.** An operating model in which AI-driven agents and automation play a central role in operations -- correlating signals, proposing remediations, and executing approved changes -- with humans acting as designers, supervisors, and final decision-makers rather than performing repetitive correlation and execution work.

**AI Ethics Committee.** A governance body within the AI governance operating model, responsible for evaluating the ethical implications of AI deployment decisions, including fairness, bias, and the societal impact of operational AI agents.

**AI Governance Board.** A standing governance body that reviews agent performance, adjusts autonomy boundaries based on evidence, and makes explicit decisions about which capabilities to grant autonomy and which to retain at human-approval-required status.

**AI risk register.** A structured record of identified AI risks in operational contexts, integrated with enterprise risk management, cataloguing failure modes such as hallucination, prompt injection, scope creep, cross-zone data leakage, knowledge base corruption, and model drift, alongside targeted controls for each.

**AIOps (AI for IT Operations).** The application of artificial intelligence techniques -- including machine learning, natural language processing, and pattern recognition -- to IT operations, enabling automated correlation of heterogeneous telemetry, anomaly detection across complex topologies, and generation of actionable recommendations at scale.

**Alert fatigue.** A condition in which operations teams are overwhelmed by the volume of monitoring alerts, many of them redundant, noisy, or misleading, leading to reduced speed and accuracy of incident response.

**AMD SEV-SNP (Secure Encrypted Virtualisation -- Secure Nested Paging).** AMD's confidential computing technology that provides hardware-based memory encryption and integrity protection for virtual machines, preventing the host and hypervisor from accessing guest memory.

**Ansible.** An open-source, agentless automation platform that uses human-readable YAML playbook syntax to define and execute operational procedures. It serves as the primary bridge between human-readable runbook steps and machine-executable automation in sovereign operations.

**Ansible Automation Platform (IBM/Red Hat).** The enterprise distribution of Ansible providing execution environments, centralised credential management, role-based access control, and comprehensive audit trails for playbook execution in regulated environments.

**Apptio (IBM).** A technology business management platform that maps infrastructure spend to business services, cost centres, and value streams, enabling finance leaders to evaluate whether sovereign operations spending delivers proportionate business value.

**Argo CD.** A CNCF graduated project providing declarative, GitOps-based continuous delivery for Kubernetes. In sovereign estates, Argo CD instances are deployed within each sovereign zone to manage only zone-local clusters, preserving operational sovereignty.

**Argo Rollouts.** An extension to Argo CD that provides Kubernetes-native progressive delivery automation with configurable traffic splitting, analysis templates, and automated promotion or rollback decisions for canary and blue-green deployment strategies.

**Authorised-copy pattern.** A governed exception to the zero-copy principle, used where data gravity makes in-place access impractical (typically for multi-petabyte analytical workloads). The copy is explicitly sanctioned, catalogued, and subject to the same governance controls as the source data.

**Automation coverage ratio.** A metric measuring the proportion of operational tasks that are fully or partially automated, segmented by task category, used to track progress in reducing manual operational toil.

**Automation maturity ladder.** A four-rung progression model for runbook automation: fully manual, tool-assisted, partially automated, and fully automated within bounds. Each rung requires demonstrating safety at the previous level before ascending.

**Autonomous action boundary.** The explicit, policy-defined specification of what agents may do without human approval. It defines the scope, conditions, and constraints within which an agent may act autonomously, and is encoded as policy-as-code.

**Autonomy levels.** A spectrum from Level 0 (fully manual) through Level 5 (fully autonomous) describing the degree of independence granted to AI agents in operational contexts. Responsible sovereign operations architectures target Levels 3 and 4 for regulated workloads, not Level 5.

**BGP (Border Gateway Protocol).** The inter-domain routing protocol used to exchange routing information between autonomous systems on the internet. In sovereign operations, BGP routing policy is used to enforce network-level sovereignty constraints.

**Blast radius.** The scope of potential harm if an operational action executes incorrectly, measured by the number of dependent services, consumers, and transactions that would be affected. Blast radius is a primary factor in action risk classification and change risk scoring.

**Bounded autonomy.** The principle that AI agents operate within explicitly defined, policy-governed limits rather than with unconstrained authority. The bounds are zone-specific, role-specific, and runbook-specific, defined by humans, encoded in policy, and enforced at the tool-call authorisation level.

**CAB (Change Advisory Board).** A governance body in ITSM that reviews and approves proposed changes to IT services. In Concert-integrated environments, CAB approval can be automated for low-risk changes that fall below configurable risk thresholds.

**Canary deployment.** A progressive delivery pattern in which a new version is deployed alongside the existing version, with a small fraction of traffic routed to the new version. The deployment is promoted or rolled back based on observed behaviour against defined success criteria.

**cert-manager.** A Kubernetes-native certificate management controller that automates the issuance, renewal, and lifecycle management of TLS certificates from various certificate authorities.

**Change failure rate.** One of the four DORA key metrics, measuring the proportion of deployments that result in a service degradation requiring remediation such as a rollback, hotfix, or corrective patch.

**Change risk score.** A composite metric calculated by Concert from historical change failure rate, blast radius, current component health, and time-of-day/calendar context. It reflects the estimated probability that a specific proposed change will cause a production degradation.

**Chaos engineering.** The discipline of proactively injecting controlled failures into systems to verify that services degrade gracefully, that runbooks are accurate, and that observability instrumentation provides sufficient signal for diagnosis.

**Chef InSpec.** An open-source compliance testing framework that expresses compliance requirements as machine-readable code and evaluates infrastructure against CIS Benchmarks and other security baselines.

**CI/CD (Continuous Integration / Continuous Delivery).** A set of practices and tools that automate the building, testing, and deployment of software, enabling frequent, reliable releases. In sovereign pipelines, CI/CD stages must satisfy jurisdictional residency, provenance, and policy constraints.

**Cilium.** An open-source Kubernetes CNI (Container Network Interface) plugin that uses eBPF (extended Berkeley Packet Filter) for high-performance network observability, security enforcement, and load balancing.

**CIS Benchmark.** A set of consensus-based security configuration standards published by the Centre for Internet Security, providing prescriptive guidance for hardening operating systems, cloud services, and application stacks.

**CloudEvents.** A CNCF specification for describing event data in a common format, making events machine-readable and interoperable across providers and platforms in event-driven architectures.

**CMMI (Capability Maturity Model Integration).** A process-level improvement framework for evaluating and improving an organisation's software engineering and project management processes. Referenced as a predecessor to the Sovereign Operations Maturity Model.

**CNCF (Cloud Native Computing Foundation).** An open-source foundation hosting projects such as Kubernetes, Argo CD, Flux, OPA, and OpenTelemetry that form the infrastructure substrate for cloud-native sovereign operations.

**Cognitive load.** The subjective and objective burden placed on operations teams by the complexity of their environment. In sovereign estates, cognitive load has a sovereignty dimension: teams operating across multiple regulatory regimes carry higher load than those within a single zone.

**Compliance signal fabric.** The set of configuration, access, network, and change signals that Concert aggregates into a unified compliance posture view, enabling continuous compliance monitoring rather than periodic audit exercises.

**Concert (IBM).** IBM's operational intelligence platform that continuously discovers and maintains a typed entity graph of services, deployments, and infrastructure components, ingests telemetry from multiple sources, correlates signals against a live topology model, and generates prioritised recommendations for operators and agents.

**Concert health score.** A continuously calculated metric reflecting the operational health of a component in the Concert entity model, derived from SLO attainment, error rates, latency, resource consumption, and other telemetry signals.

**Confidential computing.** A set of hardware-based technologies (Intel SGX, AMD SEV-SNP, IBM Hyper Protect) that protect data in use by performing computation within hardware-attested trusted execution environments, preventing even the infrastructure operator from accessing the data being processed.

**Configuration drift.** The divergence between the declared desired state of infrastructure (as defined in code) and the actual state of running systems. Drift detection is a core function of GitOps controllers and IaC pipelines.

**Conftest.** A tool for writing tests against structured configuration data, commonly used to evaluate Terraform plans and Kubernetes manifests against OPA/Rego policies before deployment.

**Context decay.** The phenomenon in dashboard-centric operations where monitoring views rarely show the full history of how a system arrived in its current state, forcing operators to reconstruct context from multiple disparate sources under time pressure.

**Control plane.** The set of interconnected systems, patterns, and practices that governs a sovereign, multi-cloud, AI-augmented enterprise estate. It encompasses observability, automation, agentic intelligence, and governance capabilities.

**Cost-per-incident.** A value metric connecting operational investment to business outcomes by measuring the total cost of each incident, including engineering time, lost revenue, compliance overhead, and reputational impact.

**CQRS (Command Query Responsibility Segregation).** An architectural pattern that separates read and write operations into different models, enabling independent scaling and optimisation of each. One of the four event patterns examined in the context of zero-copy integration.

**CSRD (Corporate Sustainability Reporting Directive).** An EU directive requiring large companies to report on sustainability matters including environmental, social, and governance (ESG) factors, with implications for operational data collection and reporting infrastructure.

**Cyber Resilience Act (EU).** An EU regulation establishing cybersecurity requirements for products with digital elements throughout their lifecycle, relevant to manufacturing and cyber-physical system operations.

**Cyber vault.** An isolated, hardened backup environment designed for cyber-resilient recovery, providing immutable storage disconnected from the production network to protect against ransomware and destructive cyber attacks.

**CycloneDX.** An OWASP standard for Software Bill of Materials (SBOM) documents, enabling machine-readable enumeration of the components that constitute a software artefact.

**DAST (Dynamic Application Security Testing).** Security testing performed against a running application to identify vulnerabilities such as injection flaws, authentication weaknesses, and configuration errors that are only apparent at runtime.

**Data gravity.** The tendency of applications and processing to be drawn toward data rather than the reverse, creating structural lock-in as the cost and complexity of accessing data from another provider increases with accumulation.

**Data lineage.** The tracked provenance of data as it flows through systems, recording which system used which data, when, and under what policy. In sovereign operations, lineage serves as both an operational debugging tool and a sovereign control mechanism.

**Dead man's switch.** A safety pattern in autonomous systems where the absence of a positive confirmation signal (rather than the presence of an error) triggers a protective action, preventing uncontrolled autonomous operation if monitoring or governance systems fail.

**Deployment frequency.** One of the four DORA key metrics, measuring how often an organisation successfully deploys code or configuration changes to production. Elite performers deploy multiple times per day.

**DevOps.** A cultural and organisational movement that unifies software development and IT operations through shared accountability, continuous delivery, automation, and measurement. The DORA research programme provides the empirical foundation for DevOps practices.

**DevOps Insights (IBM).** An IBM Cloud service that aggregates build, test, and deployment data from CI/CD toolchains, calculates DORA metrics, evaluates quality gates, and feeds delivery performance signals into Concert's risk model.

**DiRT (Disaster Recovery Testing).** A practice pioneered at Google in which disaster recovery procedures and runbooks are tested through scheduled exercises, surfacing procedural gaps before real incidents expose them.

**DORA (Digital Operational Resilience Act).** EU Regulation 2022/2554 requiring financial entities to demonstrate continuous, documented control over their operational processes, including ICT risk management, incident reporting, resilience testing, and third-party risk management.

**DORA key metrics.** Four metrics developed through the DORA (DevOps Research and Assessment) research programme: deployment frequency, lead time for changes, mean time to restore (MTTR), and change failure rate. A fifth metric, reliability (SLO attainment), has been added in recent iterations.

**EBA (European Banking Authority).** An EU authority whose Guidelines on ICT and Security Risk Management (EBA/GL/2019/04) mandate that financial institutions maintain clear governance accountability for their ICT supply chain, including cloud-hosted services.

**eBPF (extended Berkeley Packet Filter).** A Linux kernel technology enabling programmable, high-performance observability and security enforcement at the operating system level without requiring kernel module changes.

**Edge-anchored mesh.** One of three sovereign topology patterns presented in the book, designed for estates with significant edge computing requirements where edge locations anchor the topology and connect to sovereign zones.

**EECC (European Electronic Communications Code).** An EU directive establishing the regulatory framework for telecommunications networks and services, including security obligations relevant to telecoms operators.

**eIDAS 2.0.** The revised EU regulation on electronic identification and trust services, establishing a framework for digital identity wallets and cross-border electronic identification with implications for identity management in sovereign operations.

**ENISA (European Union Agency for Cybersecurity).** The EU agency responsible for cybersecurity guidance, whose publications on cloud security establish that cloud security must encompass operational controls, access management, and jurisdictional governance, not merely data location.

**Entity graph (Concert).** The continuously maintained typed graph within IBM Concert representing services, deployments, infrastructure components, and their dependencies, serving as the foundation for correlation, health scoring, and recommendation generation.

**Error budget.** A concept from SRE practice representing the permissible amount of unreliability over a defined period, calculated as the complement of the SLO target. When the error budget is exhausted, the team prioritises reliability work over feature development.

**EU AI Act.** EU Regulation 2024/1689 establishing harmonised rules on artificial intelligence, classifying AI systems by risk level and imposing obligations including logging, human oversight, and ongoing monitoring for high-risk AI systems such as those used in critical infrastructure operations.

**EU Data Act.** An EU regulation governing fair access to and use of data, with implications for data sharing arrangements and portability requirements in multi-cloud sovereign estates.

**EUCS (EU Cloud Security Certification Scheme).** A proposed EU-wide cloud security certification scheme developed under the Cybersecurity Act, intended to provide a common framework for evaluating the security of cloud services.

**Event-carried state transfer.** An event pattern in which the event message carries sufficient state data for consumers to update their local views without querying the source system, reducing coupling at the cost of increased message size.

**Event sourcing.** An architectural pattern in which all changes to application state are stored as an immutable sequence of events, enabling complete reconstruction of any historical state and providing a natural audit trail.

**External Secrets Operator.** A Kubernetes operator that synchronises secrets from external secrets management systems (HashiCorp Vault, AWS Secrets Manager, Azure Key Vault) into Kubernetes secrets, enabling GitOps flows where only references to secrets are stored in Git.

**False positive rate.** In Concert, the proportion of situations that, on investigation, turn out not to represent genuine operational problems. A rate above roughly 10-15% typically signals that the correlation engine requires tuning.

**FCA (Financial Conduct Authority).** The UK financial regulatory body whose rules (including SYSC requirements) impose operational resilience obligations on financial institutions, including requirements for demonstrable governance of IT operations.

**FedRAMP (Federal Risk and Authorisation Management Programme).** A US government programme providing a standardised approach to security assessment, authorisation, and continuous monitoring for cloud products and services.

**Federated observability.** An architectural pattern in which zone-local backends retain raw telemetry within sovereign boundaries, exporting only filtered aggregates to a central resilience view. This preserves data residency while enabling cross-zone operational visibility.

**FIDO2/WebAuthn.** A set of web authentication standards enabling hardware-based, phishing-resistant authentication. In sovereign operations, FIDO2/WebAuthn hardware keys provide strong authentication for human administrative access to the control plane.

**FinOps.** The practice of bringing financial accountability to cloud spending through cross-functional collaboration between engineering, finance, and business teams. Tools such as IBM Apptio, Kubecost, and Cloudability support FinOps in sovereign estates.

**Five-minute rule.** A heuristic for runbook quality: a runbook that cannot be meaningfully engaged with by a competent engineer within five minutes of arriving at an incident is too complex for operational use and should be restructured.

**Flux.** A CNCF graduated GitOps project that implements continuous delivery for Kubernetes by watching Git repositories and reconciling cluster state against declared configuration.

**Foundation model.** A large AI model pre-trained on broad data that can be adapted for specific tasks. In sovereign operations, foundation model selection considers training data residency, inference location, and model governance requirements.

**Four-planes model.** The architectural reference model for sovereign cloud operations comprising the Observability Plane, the Automation and Orchestration Plane, the Agentic Intelligence Plane, and the Governance and Audit Plane.

**Gatekeeper (OPA).** A Kubernetes admission controller that enforces OPA/Rego policies at the Kubernetes API server, acting as a runtime policy enforcement point complementary to pre-merge policy checks in CI/CD pipelines.

**GDPR (General Data Protection Regulation).** EU Regulation 2016/679 governing the processing of personal data, imposing requirements for data minimisation, purpose limitation, data subject rights, and breach notification that directly affect operational telemetry handling.

**Generative culture.** In Westrum's organisational culture typology, a culture characterised by free flow of information, shared accountability, and willingness to surface problems. Research consistently shows that generative cultures are the enabling condition for high operational performance.

**GitOps.** An operational pattern in which the entire desired state of a system is declared in Git, changes are made exclusively through Git operations, and a software controller continuously reconciles actual state against declared state. Git becomes both the deployment mechanism and the audit trail.

**Golden path.** In platform engineering, a pre-built, opinionated workflow or template that embeds operational best practices, sovereignty constraints, and organisational standards, making it easy for development teams to do the right thing by default.

**Governance and audit plane.** One of the four planes in the sovereign operations reference model, responsible for policy-as-code enforcement, immutable audit trails, the sovereign AI record, and regulatory evidence management.

**Granite code models.** IBM's family of open-source code generation models, deployed as part of watsonx Code Assistant for AI-assisted development in sovereign environments where model inference must remain within zone boundaries.

**Guardrail.** A specialised control that enforces safety, compliance, and ethical boundaries on automation and agent behaviour without blocking legitimate operations. Guardrails are expressed as policy-as-code and enforced at the tool-call authorisation level.

**Guardrail agent.** A specialised AI agent in a multi-agent system whose sole function is to evaluate the actions proposed by other agents against policy constraints, blocking or modifying actions that would violate sovereignty, security, or compliance requirements.

**Hallucination.** A failure mode of AI language models in which the model generates plausible-sounding but factually incorrect information. In operational contexts, hallucination by an agent can lead to incorrect diagnoses or inappropriate remediation actions.

**Handoff tax.** The cumulative cost in time, context loss, and delay created by each boundary between functional teams in traditional IT operating models, where work must queue and transfer between development, operations, security, and compliance functions.

**HashiCorp Vault.** An open-source secrets management platform providing dynamic credential issuance, encryption as a service, and PKI management. In sovereign estates, Vault instances are deployed within each zone for zone-local secrets management.

**Helm.** A package manager for Kubernetes that uses templated chart definitions to manage the deployment and configuration of applications. Helm charts are version-controlled artefacts in GitOps workflows.

**HIPAA (Health Insurance Portability and Accountability Act).** US federal legislation establishing data privacy and security requirements for protected health information, relevant to healthcare sovereign operations patterns.

**Hub-and-spoke topology.** One of three sovereign topology patterns, in which a central management hub connects to multiple spoke zones, providing centralised governance while respecting zone-local autonomy.

**Hubble.** The observability component of the Cilium project, providing network flow visibility and security monitoring using eBPF at the kernel level in Kubernetes environments.

**Human-in-the-loop.** A design pattern in which human approval or oversight is required before an AI agent or automation system executes a consequential action, ensuring accountability and catch errors that automated systems might miss.

**Hyper Protect (IBM).** IBM's confidential computing platform providing hardware-attested trusted execution environments where data is protected even from the infrastructure operator.

**IaC (Infrastructure as Code).** The practice of managing and provisioning infrastructure through machine-readable configuration files rather than interactive configuration tools, enabling version control, review, and automated deployment of infrastructure changes.

**IBM Bob.** IBM's AI development assistant (watsonx Code Assistant) that operates against Git repositories to help encode best practice, sovereignty constraints, and operational knowledge into code, regardless of which cloud the code targets.

**IEC 62443.** An international series of standards addressing cybersecurity for industrial automation and control systems (IACS), relevant to manufacturing and operational technology (OT) environments.

**in-toto.** A framework for securing the integrity of software supply chains by generating and verifying attestations about each step in the build and deployment process.

**Instana (IBM).** IBM's application performance monitoring and observability platform, providing automatic discovery, distributed tracing, and real-time application and infrastructure monitoring across multi-cloud environments.

**Integration tax.** The cumulative cost of building, testing, maintaining, and updating the bespoke integrations required to connect different cloud providers' APIs, event schemas, security models, and native toolsets in a multi-cloud architecture.

**Intel SGX (Software Guard Extensions).** Intel's confidential computing technology providing hardware-based trusted execution environments (enclaves) that protect code and data from the operating system, hypervisor, and other software.

**IPFIX (IP Flow Information Export).** An IETF standard protocol for exporting network flow data from routers, switches, and other network devices, providing visibility into traffic patterns and network behaviour.

**ISO/IEC 27001.** An international standard for information security management systems (ISMS), establishing requirements for implementing, maintaining, and continually improving information security controls.

**Istio.** An open-source service mesh providing traffic management, security (mTLS), and observability for microservices running on Kubernetes. In sovereign estates, Istio enforces network-level sovereignty constraints.

**ITIL 4.** The fourth version of the Information Technology Infrastructure Library, a framework of best practices for IT service management covering incident management, change enablement, problem management, and service request management.

**ITSM (IT Service Management).** The discipline of designing, delivering, managing, and improving the way organisations use information technology, encompassing processes, tools, and governance for incidents, changes, problems, and service requests.

**Jira Service Management.** An Atlassian platform for IT service management providing incident, change, and problem management workflows that integrate with agentic operations through Concert and Orchestrate.

**JIT (Just-in-Time) credentials.** Short-lived, scoped credentials issued at the moment they are needed and revoked immediately after use, eliminating standing privilege and reducing the window of exposure if credentials are compromised.

**Kubecost.** A Kubernetes cost monitoring tool providing container-level cost allocation that attributes cluster spend to individual namespaces, deployments, and labels, enabling accurate chargeback in shared sovereign zone clusters.

**Kubernetes.** An open-source container orchestration platform that automates the deployment, scaling, and management of containerised applications across clusters of machines.

**Kustomize.** A Kubernetes-native configuration management tool that enables declarative customisation of Kubernetes manifests through overlays without modifying the original files.

**Kyverno.** A Kubernetes-native policy engine that uses YAML-based policy definitions (rather than Rego) for admission control, resource mutation, and background policy enforcement.

**Lead time for changes.** One of the four DORA key metrics, measuring the elapsed time from a developer committing code to that code running in production. Elite performers achieve lead times measured in hours.

**Mean time to context (MTTC).** A value metric measuring the interval between an operational event and the point at which the responding team has sufficient shared understanding to begin meaningful remediation, reflecting the quality of correlation and context synthesis.

**Mean time to detect (MTTD).** The elapsed time between the moment a fault begins to affect the environment and the moment operations teams become aware of it.

**Mean time to restore (MTTR).** The elapsed time from awareness of an incident to full restoration of normal service. One of the four DORA key metrics; elite performers achieve MTTR under one hour.

**MELT stack.** The four categories of observability data: metrics, events, logs, and traces. Together they provide the telemetry required for comprehensive operational visibility.

**Meta-lock-in.** The concern that adopting a full IBM sovereign stack merely substitutes one form of vendor dependency for another. The book addresses this by showing how the reference model's reliance on open standards and interface contracts makes each plane's components substitutable.

**ML-DSA (Module-Lattice-Based Digital Signature Algorithm).** One of the NIST post-quantum cryptography standards, designed to resist attacks from quantum computers against digital signature schemes.

**ML-KEM (Module-Lattice-Based Key Encapsulation Mechanism).** One of the NIST post-quantum cryptography standards, providing quantum-resistant key exchange mechanisms for protecting data in transit.

**Model drift.** The gradual degradation of an AI model's performance over time as the real-world data distribution diverges from the data on which the model was trained, requiring ongoing monitoring and periodic retraining.

**mTLS (mutual TLS).** A security protocol in which both parties in a connection authenticate each other using TLS certificates, providing bidirectional identity verification. In sovereign operations, mTLS with SPIFFE/SPIRE provides machine-to-machine authentication.

**NIS2 (Network and Information Security Directive 2).** EU Directive 2022/2555 imposing cybersecurity risk management and incident reporting obligations on essential and important entities, with administrative fines of up to ten million euros or two per cent of global turnover.

**NIST AI RMF (AI Risk Management Framework).** The US National Institute of Standards and Technology's framework (NIST AI 100-1) for identifying, assessing, and mitigating AI risks, providing a sector-neutral complement to the EU AI Act.

**NIST SP 800-53.** A NIST publication providing a catalogue of security and privacy controls for information systems and organisations, used as a reference for mapping regulatory requirements to technical controls.

**NIST SP 800-218 (SSDF).** The Secure Software Development Framework providing recommendations for mitigating software vulnerability risks, referenced for mapping DevOps Insights quality gate configurations to security development practices.

**Notification event pattern.** An event pattern in which the event message signals that something happened but carries minimal state data, requiring the consumer to query the source for details.

**Observability plane.** One of the four planes in the sovereign operations reference model, responsible for federated telemetry collection with zone-local retention, encompassing metrics, events, logs, traces, and topology signals.

**OPA (Open Policy Agent).** A CNCF graduated project providing a general-purpose policy engine that evaluates policies written in the Rego language. Used throughout sovereign operations for admission control, pre-merge policy checks, and runtime policy enforcement.

**OpenLineage.** An open standard for metadata and lineage collection across data pipelines, enabling machine-readable tracking of data provenance and transformations across providers and systems.

**OpenPages (IBM).** IBM's governance, risk, and compliance platform serving as the system of record for regulatory mapping, control documentation, and compliance evidence management in sovereign operations.

**OpenShift (Red Hat).** Red Hat's enterprise Kubernetes platform, distributed by IBM, providing developer and operations tooling, security features, and multi-cluster management for container-based applications.

**OpenShift GitOps (Red Hat).** The enterprise GitOps distribution shipped with OpenShift, built on Argo CD with integration into OpenShift's RBAC model, certificate management, and multi-cluster capabilities.

**OpenTelemetry.** A CNCF observability framework providing vendor-neutral APIs, SDKs, and tools for generating, collecting, and exporting telemetry data (metrics, logs, traces) in a standardised format.

**Operational sovereignty.** A governing principle concerned not merely with where data resides but with who can act on which systems, from which jurisdictions, under which policies, and how those actions are governed in real time.

**Operational tax.** The cumulative burden of duplicated effort, policy uncertainty, delays, and risk that arises when sovereignty and multi-cloud are not matched by an appropriate cross-cutting operations architecture.

**Operator escalation rate.** A Concert metric measuring how often automated or agent-assisted actions are escalated by human operators to a different (typically higher-oversight) response mode, providing insight into the evolution of operator trust.

**Orchestrate (IBM watsonx).** IBM's conversational and workflow engine that translates natural-language operator intent into sequences of authenticated, logged tool calls, serving as both the operational interface and the planner agent in multi-agent architectures.

**OTLP (OpenTelemetry Protocol).** The native protocol of the OpenTelemetry project for transmitting telemetry data between instrumented applications, collectors, and backends in a standardised, efficient format.

**PCI DSS (Payment Card Industry Data Security Standard).** A set of security standards for organisations that handle branded credit cards, requiring specific controls for cardholder data protection and network security.

**Platform engineering.** An organisational discipline in which internal platform teams provide self-service capabilities (golden paths, CI/CD templates, observability libraries, IaC modules) to stream-aligned development teams, reducing cognitive load while maintaining standards.

**Planner agent.** In multi-agent architectures, the agent responsible for decomposing complex tasks into sub-tasks and delegating them to specialised executor agents. watsonx Orchestrate functions as the planner agent in the sovereign operations architecture.

**Policy-as-code.** The practice of expressing governance, compliance, and security policies as machine-readable code (typically in OPA/Rego, Kyverno YAML, or Sentinel) that can be version-controlled, tested, and automatically enforced at multiple points in the operational lifecycle.

**Policy engineer.** A new operational role responsible for authoring, maintaining, and evolving policy-as-code artefacts, sitting at the intersection of compliance, security, and platform engineering.

**Post-quantum cryptography.** Cryptographic algorithms designed to resist attacks from both classical and quantum computers. The NIST post-quantum standards (ML-KEM, ML-DSA, SLH-DSA) are relevant to sovereign operations planning for long-lived data protection.

**PRA (Prudential Regulation Authority).** The UK prudential regulatory body (part of the Bank of England) that sets operational resilience requirements for banks, building societies, and insurers.

**Progressive delivery.** A deployment strategy that exposes changes to increasing fractions of traffic or users while monitoring for regressions, enabling incremental, observable, and reversible rollouts across sovereign zones.

**Progressive disclosure.** A conversational UX design principle in which operational information is presented at the appropriate level of detail for normal operation, with full execution logs and technical details accessible on demand.

**Prompt injection.** An adversarial attack technique in which malicious input is crafted to manipulate an AI language model into executing unintended actions or disclosing information outside its intended scope.

**Provider-aligned ring topology.** One of three sovereign topology patterns, in which each cloud provider's resources form a ring connected to a central governance layer, enabling provider-specific optimisation while maintaining cross-provider coherence.

**Psychological safety.** The organisational condition in which team members feel safe to take interpersonal risks, admit mistakes, and raise concerns without fear of punishment. A prerequisite for blameless post-incident learning and trusted automation adoption.

**Pulumi.** An infrastructure-as-code platform that enables infrastructure definition using general-purpose programming languages (Python, TypeScript, Go, C#) rather than domain-specific configuration languages.

**Quality gate.** A checkpoint in a CI/CD pipeline that evaluates accumulated evidence (test results, scan findings, quality indicators) against defined rules before a build is promoted to the next environment. Quality gates serve as both governance controls and compliance evidence.

**Quality indicator.** In DevOps Insights, a structured assessment result attached to a build or deployment, serving as the extensibility mechanism for introducing custom data (SBOM completeness, licence compliance, sovereignty constraint checks) into the data model.

**RACI model.** A responsibility assignment matrix (Responsible, Accountable, Consulted, Informed) adapted for agentic operations where agents occupy the Responsible column for Tier 1 decisions while humans remain Accountable in all tiers.

**RAG (Retrieval-Augmented Generation).** An AI architecture pattern in which a language model's responses are grounded in information retrieved from an external knowledge base, improving accuracy and reducing hallucination for domain-specific queries.

**RBAC (Role-Based Access Control).** An access control method in which permissions are assigned to defined roles rather than to individual users, enabling systematic management of authorisation across large organisations.

**Recommendation acceptance rate.** The proportion of Concert's recommended actions that are acted on by operators. A leading indicator of both recommendation quality and operator trust in the system.

**Red Hat Advanced Cluster Management.** A Kubernetes multi-cluster management platform that enables governance, observability, and application lifecycle management across multiple clusters and sovereign zones.

**Rego.** The declarative policy language used by Open Policy Agent (OPA) for expressing and evaluating policies. Rego policies are used for admission control, pre-merge checks, and runtime enforcement throughout sovereign operations.

**Runbook.** A structured operational procedure specifying trigger conditions, pre-conditions, step-by-step actions, decision points, rollback steps, escalation paths, and ownership for responding to specific classes of operational events.

**Safe-to-automate test.** A structured assessment evaluating whether a runbook step is suitable for automation, examining four dimensions: reversibility, blast radius, frequency, and false positive risk.

**Safeguarded Copy (IBM).** IBM's technology for creating immutable, zone-local snapshots of data that are isolated from the production environment and protected from modification, providing a last line of defence for cyber-resilient recovery.

**SAST (Static Application Security Testing).** Security testing that analyses source code or compiled binaries for vulnerabilities without executing the application, identifying potential security flaws early in the development lifecycle.

**Satellite (IBM Cloud).** IBM's edge and distributed cloud platform enabling organisations to deploy IBM Cloud services on customer-owned infrastructure in specific locations, providing a practical instantiation of the sovereign zone concept.

**SBOM (Software Bill of Materials).** A formal, machine-readable inventory of all components (libraries, frameworks, base images) that constitute a software artefact, critical for supply chain security and regulatory compliance.

**SCA (Software Composition Analysis).** A security testing practice that identifies known vulnerabilities, licensing issues, and quality risks in open-source and third-party components used in a software application.

**Schema registry.** A centralised service that stores and validates event schemas, enforces compatibility rules for schema evolution, and ensures that producers and consumers of events share a consistent understanding of message formats.

**ServiceNow.** An enterprise IT service management platform widely used for incident, change, and problem management, integrated bidirectionally with Concert for situation-to-incident synchronisation and change risk assessment.

**Shift-left operations.** The practice of moving operational concerns (SLOs, observability instrumentation, policy-as-code evaluation, runbook authorship, resilience testing) into the design and development phases rather than addressing them after deployment.

**Sigstore.** A collection of open-source tools for signing, verifying, and protecting software supply chains, providing keyless signing and transparency logs for artefact provenance verification.

**Situation (Concert).** Concert's primary unit of operational work: a unified representation of what appears to be a single operational problem, created by correlating related signals (alerts, anomaly detections, topology changes, log patterns) regardless of how many raw alerts they have spawned.

**Situation timeline.** A chronologically ordered record of every significant event in a Concert situation's lifecycle, serving as both an operational tool for mid-incident context reconstruction and an audit record for regulatory evidence.

**Skills atrophy.** The risk that as AI agents handle an increasing proportion of routine operational work, human operators lose proficiency in the diagnostic and remediation skills needed for complex, novel incidents that agents cannot handle alone.

**SLH-DSA (Stateless Hash-Based Digital Signature Algorithm).** One of the NIST post-quantum cryptography standards, providing quantum-resistant digital signatures based on hash functions.

**SLI (Service Level Indicator).** A quantitative measure of a specific aspect of service behaviour (such as request latency or error rate) that is used to calculate whether a service is meeting its service level objectives.

**SLO (Service Level Objective).** A target value or range for a service level indicator, defining the acceptable level of service reliability. In shift-left operations, SLOs are defined at design time as architectural constraints rather than retroactive monitoring thresholds.

**SLSA (Supply-chain Levels for Software Artefacts).** A security framework providing a checklist of standards and controls to prevent tampering, improve integrity, and secure software packages and infrastructure, with levels from 1 to 4 indicating increasing assurance.

**SOPS (Secrets OPerationS).** A Mozilla-developed tool for encrypting files with support for multiple key management services (AWS KMS, Azure Key Vault, GCP KMS, HashiCorp Vault), enabling encrypted secrets to be stored safely in Git repositories.

**Sovereign AI record.** A comprehensive, structured evidence artefact capturing every consequential AI agent action -- inputs, reasoning, alternatives considered, policy evaluations, approvals, and outcomes -- satisfying the evidentiary requirements of DORA, the EU AI Act, and sector-specific supervisory frameworks.

**Sovereign cloud.** A cloud deployment model that respects national or regional control over data, operations, and governance. Originally focused on data residency, the concept has expanded to encompass operational sovereignty.

**Sovereign compliance rate.** A metric measuring the proportion of operational actions that comply with the sovereignty constraints of the zone in which they occur, as evaluated by the policy-as-code framework.

**Sovereign core pattern.** A transformation approach in which organisations establish a fully sovereign operating model for a representative subset of workloads first, then progressively extend the model to the broader estate.

**Sovereign Operations Maturity Model.** A five-level maturity model (Ad-hoc and Reactive through Optimised and Autonomous) purpose-built for sovereign, agentic operations, assessing progress across eight dimensions: infrastructure codification, observability depth, automation coverage, sovereignty enforcement, agent adoption, governance maturity, cultural readiness, and knowledge management.

**Sovereign zone.** The fundamental unit of placement and policy enforcement in sovereign operations: a bounded set of compute, network, and storage resources defined by jurisdiction, permitted operators, data classification, and key management boundary.

**Sovereign zone owner.** A cross-functional role accountable for the end-to-end operational integrity of a specific sovereign zone, bridging development, operations, security, and compliance within the zone boundary.

**SOX (Sarbanes-Oxley Act).** US federal legislation establishing requirements for financial reporting and internal controls, with implications for IT systems that support financial processes.

**SPDX (Software Package Data Exchange).** A Linux Foundation standard for communicating the components, licences, and security references of software packages, used in SBOM generation.

**SPIFFE (Secure Production Identity Framework for Everyone).** A set of open-source standards for securely identifying software services in dynamic and heterogeneous environments, providing vendor-neutral workload identity.

**SPIRE.** The reference implementation of the SPIFFE specification, providing a production-ready system for issuing and managing SPIFFE identities (SVIDs) across workloads in sovereign zones.

**SRE (Site Reliability Engineering).** An engineering discipline originated at Google in which software engineers take responsibility for the reliability of production systems, using error budgets, toil budgets, and service level objectives as governance mechanisms.

**Structured Decision Record.** The core provenance artefact for agentic operations, capturing inputs, reasoning chain, alternatives considered, policy evaluations, approvals, and outcomes for every material agent action, enabling post-hoc auditability.

**T-shaped engineer.** A skills development model in which engineers maintain deep expertise in one discipline (the vertical bar of the T) while developing working competence across adjacent disciplines (the horizontal bar), including policy-as-code, agent supervision, and sovereignty engineering.

**Tekton.** A Kubernetes-native CI/CD framework providing reusable, composable pipeline building blocks. The native pipeline mechanism on Red Hat OpenShift and IBM Cloud Kubernetes Service.

**Telemetry.** The automated collection and transmission of measurements and other data from operational systems, encompassing metrics, events, logs, traces, and topology information.

**Terraform.** An infrastructure-as-code tool by HashiCorp that enables declarative definition of infrastructure across multiple cloud providers and services, with state management and plan/apply workflows.

**Toil.** Work tied to running a production service that is manual, repetitive, automatable, tactical, devoid of enduring value, and that scales linearly as a service grows. SRE practice prescribes a ceiling of fifty per cent of operations engineers' time on toil.

**Tool registry (Orchestrate).** A catalogue of callable capabilities in watsonx Orchestrate, where each entry describes a tool by name, natural-language description, typed input schema, and output schema. The registry acts as a policy boundary controlling what actions the system can perform.

**Topology view (Concert).** A live, continuously updated visual representation of the dependency graph of the application estate, with components coloured according to their Concert health scores, used by operators to understand blast radius and contextualise signals.

**Turbonomic (IBM).** IBM's workload optimisation platform that analyses application performance requirements and resource consumption patterns to generate recommendations (or automated actions) for right-sizing virtual machines, containers, and cloud instances across multi-cloud estates.

**UK TSA (Telecommunications Security Act).** UK legislation establishing security obligations for telecommunications providers, requiring specific technical measures and oversight of network infrastructure.

**Unified operational record.** A comprehensive record of operational activity that satisfies the evidence requirements of DORA, NIS2, and ISO 27001 as a natural by-product of correct operation, linking ITSM records, Concert situations, automation logs, and approval trails.

**Vector database.** A database optimised for storing and querying high-dimensional vector embeddings, used in RAG architectures to enable semantic search across operational knowledge bases (runbooks, post-incident reviews, architecture decision records).

**VPA (Vertical Pod Autoscaler).** A Kubernetes component that automatically adjusts the CPU and memory requests and limits for containers based on observed usage, though in GitOps contexts agent-authored pull requests are preferred to maintain Git as the single source of truth.

**War room channel.** A dedicated communication channel established during major incidents for coordinating cross-team response, with agents contributing action tracking, progress summarisation, and multi-audience communication drafting.

**watsonx.ai.** IBM's enterprise studio for AI model training, fine-tuning, and deployment, providing the foundation model capabilities used by watsonx Orchestrate and other agentic components.

**watsonx Code Assistant (IBM).** IBM's AI-assisted development platform (also referred to as IBM Bob) that provides sovereignty-aware code generation for infrastructure as code, Ansible automation, and application development.

**watsonx.governance.** IBM's AI governance platform providing model lifecycle management, approval records, performance monitoring, bias detection, and regulatory evidence management for AI systems deployed in sovereign estates.

**Westrum organisational culture typology.** A classification of organisational cultures into pathological (power-oriented), bureaucratic (rule-oriented), and generative (performance-oriented) types, used to assess cultural readiness for agentic operations adoption.

**Zero-copy integration.** An architectural principle in which systems access data where it resides rather than copying it into new silos, state changes propagate as events rather than batches, and data access is governed through a unified control plane. Zero-copy reduces the failure surface, improves data lineage, and tightens the audit trail.

**Zero trust.** A security model that eliminates implicit trust based on network location, requiring every access request to be authenticated, authorised, and encrypted regardless of where it originates. In sovereign operations, zero trust principles govern both human and non-human (agent, automation) identities.

**Zone-scoped tool registry.** An Orchestrate pattern in which the tool registry is organised by sovereign zone, with each zone's tools carrying zone-appropriate authentication requirements, approval configurations, and scope restrictions, preventing inadvertent cross-zone actions. --- This glossary contains 200 terms drawn systematically from all 39 chapter files. The terms span the book's five major categories: specialist operational concepts (sovereign zone, zero-copy integration, agentic operations, control plane, shift-left operations), acronyms and standards (DORA, NIS2, GDPR, EU AI Act, NIST AI RMF, IEC 62443, SLSA, SBOM), IBM product names (Concert, watsonx Orchestrate, Instana, Turbonomic, OpenPages, watsonx.governance, Bob), open-source and industry technologies (OPA, Rego, Argo CD, Flux, Terraform, Ansible, Kubernetes, OpenTelemetry, SPIFFE/SPIRE, Istio), and operational methodology terms (SRE, toil, error budget, SLO, DORA metrics, runbook, canary deployment, progressive delivery, GitOps).

