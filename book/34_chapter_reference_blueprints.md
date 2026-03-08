# Chapter 34 — Reference Blueprints for Sovereign Estates

***

## Summary

This chapter translates the book's architectural principles into four concrete, reusable reference blueprints that cover the most common sovereign deployment patterns: a single-sovereign-zone estate, a multi-zone multi-cloud estate, an air-gapped sovereign environment, and a hybrid sovereign-commercial topology. Each blueprint is presented with a consistent structure covering topology, networking, observability, automation, agentic operations and key trade-offs, enabling architects to select and adapt the pattern closest to their regulatory and operational context. The chapter also identifies the common platform layer shared across all blueprints — including infrastructure-as-code, policy-as-code, observability and the Concert reasoning layer — and provides a decision framework for customising blueprints through zone boundary adjustment, provider selection and graduated agent autonomy.

***

## 34.1 From principles to blueprints

Throughout this book we have developed a set of principles: sovereign zones with explicit boundaries, zero-copy integration, policy-as-code enforcement, rich observability planes, agentic operations within guardrails, and continuous compliance as an operational property rather than a periodic achievement. These principles are, by design, abstract. They describe what a well-governed sovereign estate ought to look like without prescribing how any particular organisation should build one. That abstraction is valuable—it lets the ideas travel across industries and jurisdictions—but it creates a gap. Principles do not deploy themselves. Between "we believe in sovereign zones" and a running, compliant, observable multi-cloud estate lies a great deal of architectural decision-making, and much of it is not obvious from first principles alone.

Reference blueprints bridge that gap. A blueprint is a reusable architectural pattern—a topology, a set of integration decisions, an observability layout, an automation model—that has been designed to satisfy a coherent set of sovereignty requirements. It is not a product specification or a vendor deployment guide. It is a structural template that an organisation can study, adapt, and instantiate using whatever platforms, tools, and providers are appropriate to its context. The four blueprints presented in this chapter cover the most common sovereign deployment patterns encountered in regulated industries and public-sector environments: single-zone, multi-zone multi-cloud, air-gapped, and hybrid sovereign-commercial estates.

A word of caution before we begin. These blueprints are patterns, not prescriptions. No two organisations share exactly the same regulatory obligations, existing estate, organisational structure, risk appetite, or budget. Treating a blueprint as a turnkey solution—adopting it wholesale without adaptation—is a reliable path to an architecture that fits its documentation but not its operational reality. The correct approach is to select the blueprint closest to your requirements, study its structural decisions and the trade-offs behind them, and then adapt it: adjusting zone boundaries, swapping components, tightening or relaxing controls, and composing elements from multiple blueprints where your situation demands it. Section 34.7 provides a decision framework for that adaptation process.

Each blueprint is presented with a consistent structure: a description of the target scenario, a topology overview, networking and connectivity patterns, the observability and compliance architecture, the automation and agentic operations model, and the key trade-offs that distinguish it from alternatives. Cross-references to earlier chapters indicate where detailed treatments of specific components can be found.

![Blueprint selection decision tree](images/figure-34-1.png)

***

## 34.2 Blueprint 1: Single-sovereign-zone estate

### 34.2.1 When this blueprint applies

The single-sovereign-zone estate is the simplest pattern and the natural starting point for organisations whose regulatory obligations are confined to a single jurisdiction and whose workloads share a common data classification. National public-sector agencies are the archetypical example: a tax authority, a social security administration, or a national health records system whose data must remain within the country and whose operational control must rest with nationally authorised personnel. Single-country regulated entities in financial services—a domestic bank operating under one regulator—may also fit this pattern, as may defence-adjacent organisations handling a single classification tier.

Simplicity, in this context, is relative. A single zone does not mean a single server or even a single cloud region. It means that all workloads share a common set of sovereignty constraints—jurisdiction, data residency, operational authority, key management—and that those constraints can be expressed and enforced as a single, coherent policy set. The architectural benefit is that every component in the estate operates under the same rules, which eliminates the cross-zone orchestration complexity that dominates the multi-zone blueprints.

### 34.2.2 Topology

The single-zone topology comprises one or more cloud regions within the approved jurisdiction, connected by private network paths. In an IBM Cloud implementation, this might be two or three multi-zone regions within a single country or economic area, each hosting Red Hat OpenShift clusters that run the organisation's containerised workloads [1]. In a multi-cloud variant—permitted where the regulatory regime allows it—the topology might include an IBM Cloud region for core platform services and an approved hyperscaler region for specific workloads, with both regions operating under the same sovereign zone policy. The key constraint is that no workload, data store, or observability backend resides outside the defined zone boundary.

Compute clusters are organised by workload tier: a platform tier hosting shared services (identity, secrets management, observability backends, policy engines), an application tier hosting business workloads, and a data tier hosting databases, object stores, and event streaming infrastructure. Each tier runs on dedicated OpenShift clusters or dedicated namespaces within shared clusters, depending on the organisation's isolation requirements. Namespace-level isolation is often sufficient for workloads at the same classification level; cluster-level isolation is appropriate where regulatory or contractual obligations demand stronger separation [2].

![Single-sovereign-zone topology](images/figure-34-2.png)

### 34.2.3 Networking

Network design within a single zone follows a hub-and-spoke model. A central transit network—implemented as an IBM Cloud Transit Gateway, an AWS Transit Gateway, or an Azure Virtual WAN hub—provides connectivity between regions and between the platform, application, and data tiers. Ingress from the public internet is handled by edge services (load balancers, web application firewalls, API gateways) deployed in a dedicated ingress segment. Egress is tightly controlled: only explicitly approved destinations are reachable, and all outbound traffic passes through inspection points that log and, where configured, filter traffic.

East-west traffic between services is governed by network policies enforced at the Kubernetes network layer and, for cross-cluster traffic, by service mesh configurations. Calico or Cilium network policies, expressed as Kubernetes-native resources and managed through infrastructure as code ([Chapter 11](11_chapter_infrastructure_as_code.html)), define which namespaces and services may communicate. The service mesh—Istio or a comparable implementation—provides mutual TLS for in-transit encryption, traffic management, and fine-grained access control between services [3]. In a single-zone estate, the service mesh configuration is straightforward: there is one trust domain, one certificate authority hierarchy, and one set of authorisation policies. This simplicity is one of the blueprint's chief advantages.

### 34.2.4 Observability

The observability architecture follows the sovereignty-aware model described in [Chapter 7](07_chapter_observability_architecture.html). All telemetry—metrics, logs, traces, and events—is collected by agents running within the zone and forwarded to observability backends that also reside within the zone. IBM Instana provides automatic discovery and instrumentation of applications and infrastructure, producing the topology-aware telemetry that feeds IBM Concert's operational intelligence layer [4]. Because the entire estate is within a single zone, there is no need for the federated observability patterns required in multi-zone deployments. A single Instana backend, or a small number of backends with straightforward data replication for resilience, can serve the entire estate.

Concert operates as the unified topology and intelligence layer, maintaining a live dependency graph of all services, infrastructure components, and their relationships ([Chapter 14](14_chapter_concert_architecture.html)). In a single-zone estate, Concert's entity model is comprehensive: every entity it discovers is within the same zone, and every recommendation it generates can be executed without cross-zone policy checks. This makes the recommendation-to-action path shorter and reduces the governance overhead associated with each operational decision.

Compliance signals—configuration drift, policy evaluation results, vulnerability scan outcomes—flow into the governance and audit plane described in [Chapter 10](10_chapter_continuous_compliance.html). OpenPages serves as the system of record for policies, controls, and audit findings [5]. In a single-zone estate, the compliance signal fabric is unified: there is one policy set, one set of controls, and one audit trail, which simplifies both continuous monitoring and periodic reporting.

### 34.2.5 Automation and agentic operations

Infrastructure is managed entirely through code. Terraform modules define the cloud infrastructure—networks, clusters, storage, identity configurations—with sovereign zone constraints encoded as module preconditions and validated by Open Policy Agent (OPA) policies in the deployment pipeline ([Chapter 11](11_chapter_infrastructure_as_code.html)). Ansible playbooks handle node-level configuration, hardening baselines, and day-two operations tasks. GitOps controllers (ArgoCD or Flux) manage the deployment of application workloads to OpenShift clusters, ensuring that the desired state declared in version control is continuously reconciled with the running state of the cluster [6].

Agentic operations in a single-zone estate begin with the patterns described in [Chapter 19](19_chapter_itsm_multi_agent_workflows.html): read-only assistants that summarise incidents and surface relevant context, progressing to bounded actors that execute pre-approved remediation actions within guardrails. watsonx Orchestrate provides the conversational interface through which operators interact with agents and approve or reject proposed actions ([Chapter 17](17_chapter_orchestrate_conversational_interface.html)). Because all workloads and all agents operate within a single zone, the guardrail framework is simpler than in multi-zone deployments: agents do not need to reason about which zone a proposed action affects or whether cross-zone data movement would result. Their scope is bounded by the single zone's policy set, and their audit trail is captured in the zone's unified compliance fabric.

### 34.2.6 Key trade-offs

The single-zone blueprint trades flexibility for simplicity. It cannot accommodate workloads that must reside in different jurisdictions, and it offers limited options for cost optimisation through workload placement across providers with different pricing models. Its strength is operational clarity: one set of rules, one observability plane, one compliance posture. For organisations whose regulatory obligations genuinely fit within a single zone, this clarity translates directly into lower operational overhead, faster incident resolution, and simpler audit preparation.

***

## 34.3 Blueprint 2: Multi-zone, multi-cloud sovereign estate

### 34.3.1 When this blueprint applies

The multi-zone blueprint is the enterprise pattern. It applies to organisations that operate across multiple jurisdictions with materially different regulatory requirements, or that must segregate workloads by data classification into distinct zones even within a single jurisdiction. A pan-European bank subject to both EU-wide regulations (GDPR, DORA) and national supervisory requirements in several member states is a canonical example. So is a global pharmaceutical company that must keep clinical trial data in one zone, commercial operations in another, and research data in a third, each with different access controls and retention rules. Government entities operating federated services across provinces or states—where each sub-national entity retains data sovereignty—also fit this pattern.

The defining characteristic is heterogeneity of constraints. Different zones have different rules, and those differences must be architecturally enforced, not merely documented. At the same time, the organisation needs a unified operational view: it cannot afford to run entirely separate operations for each zone, because the cost, staffing, and coordination overhead would be prohibitive.

### 34.3.2 Topology

The multi-zone topology comprises two or more sovereign zones, each implemented as a set of cloud regions and accounts with distinct policy sets. Each zone has its own compute clusters, data stores, observability backends, and identity infrastructure. Zones may span different cloud providers: a European zone on IBM Cloud, a North American zone on AWS, an Asian zone on a local sovereign cloud provider. The choice of provider for each zone is driven by regulatory requirements (some jurisdictions mandate the use of nationally certified providers), existing contractual relationships, and the availability of required platform services in the relevant regions [7].

Within each zone, the internal topology follows the single-zone pattern described in section 34.2: hub-and-spoke networking, tiered compute, zone-local observability, and zone-local policy enforcement. The architectural novelty of the multi-zone blueprint lies in the inter-zone layer: how zones connect, what crosses zone boundaries, and how the organisation maintains a unified operational picture without violating the sovereignty constraints of any individual zone.

![Multi-zone, multi-cloud topology](images/figure-34-3.png)

### 34.3.3 Inter-zone connectivity

Zones are connected by dedicated, encrypted network paths—typically private interconnects (IBM Cloud Direct Link, AWS Direct Connect, Azure ExpressRoute) or site-to-site VPN tunnels—that terminate at zone boundary gateways. These gateways are the architectural enforcement point for cross-zone policy. Every data flow that crosses a zone boundary must pass through the gateway, where it is subject to inspection, logging, and policy evaluation.

The default posture is deny-all: zones do not communicate unless an explicit policy permits a specific flow between specific services for a specific purpose. This is the opposite of a flat corporate network where connectivity is assumed and restrictions are layered on. In the multi-zone blueprint, isolation is the default and connectivity is the exception, which aligns with the principle of least privilege applied at the network level.

Cross-zone flows fall into three categories. The first is operational metadata: aggregated, non-sensitive information about system health and topology that is shared with the central operations layer to maintain a unified view. This includes aggregated metrics (not raw telemetry), topology summaries (not raw entity data), and situation notifications from Concert. The second is business data flows that have been explicitly approved and architecturally governed: for example, anonymised analytics data flowing from a regulated zone to a research zone, or settlement instructions flowing between zones under specific contractual and regulatory authorisations. The third is management plane traffic: the commands and configurations that flow from central platform teams to zone-local infrastructure, subject to approval workflows and audit.

Zero-copy integration ([Chapter 5](05_chapter_multi_cloud_topology_network.html)) is particularly important in the multi-zone context. Rather than copying regulated data from one zone to another for processing, the architecture provides governed query interfaces that allow authorised consumers to access data in place, with the access mediated by the data owner zone's policy engine. This approach ensures that data residency constraints are satisfied by construction rather than by convention, and it reduces the proliferation of data copies that are difficult to track, govern, and eventually delete [8].

### 34.3.4 Federated observability

Each zone runs its own observability stack: Instana agents collect telemetry from the zone's infrastructure and applications, and a zone-local Instana backend stores and processes that telemetry. Raw telemetry does not leave the zone. This is a firm architectural constraint, not a preference, because observability data in regulated environments often contains information—IP addresses, user identifiers, transaction details—that is subject to the same residency and access controls as the business data it describes ([Chapter 7](07_chapter_observability_architecture.html)).

The federated observability model reconciles zone-local storage with the need for a unified operational view. Each zone's Instana backend produces aggregated summaries—service health scores, SLO compliance percentages, alert counts by severity—that are exported to the central Concert instance. Concert assembles these summaries into a cross-estate view that shows the health and topology of the entire organisation without requiring access to raw telemetry from any zone. When an operator needs to drill into zone-specific detail—to investigate a particular incident or trace a specific transaction—they access the zone-local Instana backend directly, subject to the zone's access controls and audit requirements.

Concert's role in the multi-zone blueprint is elevated compared to the single-zone case. It becomes the unified topology layer that holds the cross-zone dependency graph: which services in zone A depend on APIs provided by services in zone B, which business capabilities span multiple zones, and which zones are affected when a shared dependency degrades ([Chapter 14](14_chapter_concert_architecture.html)). This cross-zone topology is assembled from the zone-level topology exports that each zone's discovery agents produce, and it enables Concert to generate cross-zone situation analysis and impact assessment without accessing zone-internal data.

### 34.3.5 Cross-zone orchestration with zone-local execution

A critical architectural principle in the multi-zone blueprint is the separation of orchestration from execution. The central operations layer—Concert for intelligence, watsonx Orchestrate for workflow—can reason about the entire estate and coordinate responses that span multiple zones. But execution—the actual changes to infrastructure, configurations, and workloads—always happens locally within each zone, performed by zone-local automation (Terraform, Ansible, GitOps controllers, zone-local agents) under the zone's own policy controls.

This separation ensures that no central system has direct write access to zone-internal resources, which would violate the operational sovereignty of the zone. When Concert identifies a situation that spans two zones and recommends a coordinated response, the recommendation is decomposed into zone-specific actions. Each action is dispatched to the appropriate zone's automation layer, where it is subject to local policy evaluation, local approval workflows (if required), and local audit capture. The central layer tracks the overall progress and outcome of the coordinated response but does not bypass zone-local governance at any point.

watsonx Orchestrate supports this pattern through its multi-skill architecture ([Chapter 17](17_chapter_orchestrate_conversational_interface.html)). Skills that interact with zone-specific resources are registered with zone-specific credentials and permissions, and their execution is routed to the appropriate zone's infrastructure. An operator using the conversational interface can request an action that spans zones—"show me the status of all payment services across all zones" or "initiate the cross-zone failover runbook"—and Orchestrate decomposes it into zone-appropriate queries and actions, each executed with zone-appropriate authorisation [9].

### 34.3.6 Key trade-offs

The multi-zone blueprint is substantially more complex to build and operate than the single-zone pattern. It requires federated observability infrastructure, cross-zone policy frameworks, zone boundary gateways, and operational processes that respect zone sovereignty while maintaining organisational coherence. The staffing model is also more demanding: each zone needs locally authorised operators, and the central operations team needs skills in cross-zone coordination that do not arise in simpler topologies.

The benefit is architectural honesty. Organisations that operate across jurisdictions with genuinely different regulatory requirements cannot pretend those differences away. Attempting to run a single flat estate across multiple jurisdictions leads either to the most restrictive jurisdiction's rules being applied everywhere—which is operationally expensive and often commercially unacceptable—or to quiet non-compliance in the zones where the rules are strictest. The multi-zone blueprint makes the differences explicit, enforceable, and auditable.

***

## 34.4 Blueprint 3: Air-gapped sovereign operations

### 34.4.1 When this blueprint applies

Some environments cannot be connected to the public internet at all, or can be connected only through severely restricted, unidirectional data paths. Defence and intelligence agencies, certain critical national infrastructure operators (nuclear facilities, air traffic control), and some government systems handling the highest classification tiers operate in air-gapped or near-air-gapped conditions. The air-gapped blueprint addresses these environments.

Air-gapping is not merely an extreme version of network restriction. It introduces qualitatively different operational challenges. Software updates cannot be pulled from public registries. Vulnerability databases cannot be queried in real time. AI models cannot call external APIs for inference. Observability data cannot be streamed to cloud-hosted backends. Every operational pattern that assumes internet connectivity—and most modern cloud-native patterns do—must be re-examined and adapted.

### 34.4.2 Topology

The air-gapped topology runs entirely on infrastructure within the organisation's physical or logical perimeter. This may be on-premises data centres, sovereign cloud regions operated by nationally certified providers, or IBM Cloud Satellite locations that extend the IBM Cloud control plane into customer-controlled environments while keeping data and workloads within the customer's physical boundary [10]. OpenShift provides the container platform, offering the same Kubernetes-native abstractions available in connected environments but deployed and operated without dependency on external services.

The topology is self-contained: compute, storage, networking, identity, observability, and automation all reside within the air-gapped perimeter. External dependencies are eliminated or replaced with locally hosted equivalents. Container images are pulled from an internal registry that is populated through a controlled import process (see section 34.4.3). DNS resolution uses internal servers. Certificate authorities are locally operated. Time synchronisation uses internal NTP servers or GPS-derived sources rather than public NTP pools.

![Air-gapped topology](images/figure-34-4.png)

### 34.4.3 The controlled transfer boundary

The defining architectural element of the air-gapped blueprint is the controlled transfer boundary: the mechanism by which approved data, software, and configuration updates enter and leave the air-gapped environment. This boundary is typically implemented as a combination of physical media transfer (removable storage devices that are scanned and verified before introduction), data diodes (hardware-enforced unidirectional network links that allow data to flow in one direction only), and staging environments where imported artefacts are validated before promotion into the production perimeter.

Software supply chain integrity is paramount. Every container image, Terraform module, Ansible playbook, OPA policy bundle, and AI model artefact that enters the environment must be verified against a known-good signature before it is admitted. Sigstore and Notary provide cryptographic signing and verification for container images and other software artefacts [11]. The import process includes not just signature verification but also vulnerability scanning (using locally maintained vulnerability databases that are themselves imported through the controlled boundary) and policy evaluation (ensuring that the artefact's metadata—base image, dependencies, licence—complies with organisational policy).

Updates follow a cadence rather than a continuous flow. Where a connected environment might pull vulnerability database updates hourly, the air-gapped environment receives them on a defined schedule—daily, weekly, or as operational conditions permit—through the controlled transfer boundary. This introduces a latency in threat intelligence that must be compensated for by other means: stronger perimeter controls, more restrictive default policies, and operational procedures that assume the vulnerability picture is never fully current.

### 34.4.4 Offline model deployment and local agent hosting

Agentic operations in air-gapped environments require locally hosted AI models. Large language models and specialised operational models cannot call external inference endpoints. Instead, models are packaged as container images, imported through the controlled transfer boundary, deployed to GPU-equipped nodes within the air-gapped perimeter, and served through local inference endpoints that the organisation's agents call [12].

The model lifecycle is managed through the same infrastructure-as-code and GitOps patterns used for application workloads, adapted for the air-gapped context. Model artefacts are versioned and stored in the internal registry. Deployment is managed by GitOps controllers that reconcile the desired model version (declared in version control) with the running version on inference nodes. Model updates follow the controlled import process: a new model version is imported, validated, deployed to a staging environment for evaluation, and promoted to production through an approval workflow.

Agent guardrails ([Chapter 19](19_chapter_itsm_multi_agent_workflows.html)) are, if anything, more important in air-gapped environments than in connected ones. The consequences of an agent taking an incorrect action in a disconnected environment may be harder to remediate—there is no calling for external support, no pulling an emergency patch from a public registry. Guardrails must be locally enforced, locally audited, and locally overridable by authorised operators. The policy engine that evaluates agent actions must run within the perimeter and must not depend on external policy feeds.

### 34.4.5 Key trade-offs

The air-gapped blueprint maximises security and control at the cost of operational agility. Everything takes longer: software updates, vulnerability remediation, model refreshes, even the introduction of new observability dashboards. The organisation must invest heavily in the controlled transfer boundary and in the internal capabilities—registries, scanning infrastructure, model hosting, locally maintained databases—that replace the external services available to connected environments.

The staffing model is also distinctive. Air-gapped operations require personnel with deep platform skills who can diagnose and resolve problems without consulting external knowledge bases or support channels in real time. Knowledge management—internal wikis, locally hosted documentation, pre-imported reference materials—becomes a critical operational function rather than a convenience.

***

## 34.5 Blueprint 4: Hybrid sovereign-commercial estate

### 34.5.1 When this blueprint applies

Most large organisations do not need every workload to run in a sovereign zone. A bank's core banking system and customer data stores require the strongest sovereignty controls, but its corporate website, internal collaboration tools, and development environments may not. A hospital's electronic health records demand sovereign treatment, but its facilities management system and staff training platform do not. The hybrid blueprint addresses this reality: sovereign zones for regulated workloads coexisting with commercial cloud for everything else.

This is the pragmatic pattern. It acknowledges that sovereignty controls carry cost—in infrastructure, in operational complexity, in deployment velocity—and that applying those costs uniformly across the entire estate is wasteful. The architectural challenge is boundary management: ensuring that regulated workloads genuinely stay within sovereign zones, that data does not leak from sovereign to commercial tiers, and that the cost savings of the commercial tier do not erode the integrity of the sovereign tier.

### 34.5.2 Topology

The hybrid topology comprises one or more sovereign zones (which may follow the single-zone or multi-zone patterns described earlier) alongside one or more commercial cloud environments that operate under standard cloud provider terms without sovereign-specific controls. The sovereign zones are architecturally identical to those described in sections 34.2 and 34.3: dedicated infrastructure, zone-local observability, policy-as-code enforcement, and controlled connectivity. The commercial environments use standard cloud services—managed Kubernetes, managed databases, SaaS observability tools—with conventional security controls but without the additional sovereignty constraints.

![Hybrid sovereign-commercial topology](images/figure-34-5.png)

### 34.5.3 Boundary management

The boundary between sovereign and commercial tiers is the most critical architectural element of the hybrid blueprint. It must enforce three properties. First, data classification integrity: data classified as sovereign must not flow to the commercial tier, whether through application data paths, observability telemetry, log exports, backup replication, or any other mechanism. Second, workload placement correctness: workloads classified as sovereign must deploy only to sovereign zone infrastructure, and the deployment pipeline must prevent mis-placement. Third, access control asymmetry: personnel and systems in the commercial tier must not have access to sovereign zone resources unless explicitly authorised through the sovereign zone's access control framework.

These properties are enforced through a combination of mechanisms. Network-level controls (firewall rules, security groups, network policies) prevent direct connectivity from commercial to sovereign tier except through approved boundary gateways. Pipeline-level controls (OPA policies evaluated in CI/CD) prevent sovereign-classified workloads from being deployed to commercial tier infrastructure and prevent commercial-tier workloads from being granted access to sovereign data stores. Tag-based controls ensure that every resource carries a classification tag and that policy engines can evaluate classification compliance continuously, not just at deployment time ([Chapter 11](11_chapter_infrastructure_as_code.html)).

The boundary gateway mediates the limited, approved flows that do cross the boundary. These flows typically include aggregated, non-sensitive operational data flowing from sovereign to commercial for consolidated reporting; reference data flowing from commercial to sovereign for business processing; and management plane traffic flowing from a unified platform team to both tiers. Each flow is explicitly defined, policy-evaluated, logged, and auditable.

### 34.5.4 Workload placement policies

Deciding which workloads belong in the sovereign tier and which in the commercial tier is a governance exercise, not a purely technical one. The organisation needs a workload classification framework that maps each workload to a tier based on the data it processes, the regulations it is subject to, and the business consequences of a sovereignty breach. [Chapter 10](10_chapter_continuous_compliance.html) describes the compliance monitoring framework that underpins this classification.

In practice, the classification framework often uses three tiers. The first tier—sovereign-critical—includes workloads that process regulated personal data, financial transaction data, classified government data, or other categories that are subject to explicit residency and control requirements. These workloads must run in sovereign zones. The second tier—sovereign-adjacent—includes workloads that do not themselves process regulated data but that have dependencies on sovereign-critical workloads or that could, through misconfiguration, gain access to regulated data. These workloads may run in either tier but require additional controls if placed in the commercial tier. The third tier—commercial—includes workloads with no regulatory sensitivity: development environments, internal tools, public-facing marketing sites, and similar applications. These workloads run in the commercial tier.

The classification framework must be operationalised through automation. Labels applied to workload definitions in version control drive pipeline routing: a workload labelled `sovereignty-tier: critical` is deployed only to sovereign zone clusters; a workload labelled `sovereignty-tier: commercial` is deployed only to commercial tier clusters. OPA policies validate the consistency of labels with the workload's declared data dependencies, flagging mismatches for human review before deployment proceeds.

### 34.5.5 Cost optimisation

One of the primary motivations for the hybrid blueprint is cost. Sovereign zone infrastructure is typically more expensive than equivalent commercial cloud resources, because it involves dedicated infrastructure, restricted provider regions, additional compliance controls, and specialised operational staff. By placing only the workloads that genuinely require sovereign treatment in sovereign zones, the organisation avoids paying the sovereignty premium for workloads that do not need it.

Cost optimisation in the hybrid blueprint goes beyond simple tier placement. Within the commercial tier, the organisation can take full advantage of commercial cloud economics: reserved instances, spot or preemptible compute for batch workloads, managed services that eliminate operational overhead, and multi-region architectures optimised for cost and performance rather than for sovereignty. Within the sovereign tier, cost optimisation focuses on efficient use of the more constrained resource pool: right-sizing clusters, using auto-scaling where the sovereign provider supports it, and consolidating workloads onto shared infrastructure where the classification framework permits it.

The financial model should account for the total cost of boundary management. The gateways, policy engines, classification processes, and additional operational overhead associated with maintaining a clean boundary between tiers are real costs that partially offset the savings from placing workloads in the commercial tier. For very small estates, the boundary management overhead may exceed the savings, making the single-zone blueprint more cost-effective despite its higher per-workload cost.

### 34.5.6 Key trade-offs

The hybrid blueprint optimises cost and flexibility at the expense of boundary complexity. The organisation must maintain robust classification, placement, and boundary management processes, and it must continuously monitor for classification drift—workloads that were correctly placed at deployment time but whose data dependencies have since changed. The operational team must be skilled in both sovereign and commercial cloud operations, which broadens the required competency base.

The benefit is proportionality. Not every workload carries the same risk, and the hybrid blueprint allows the organisation to apply controls proportionate to that risk. This is not merely a cost argument; it is also an operational velocity argument. Workloads in the commercial tier can move faster—shorter deployment cycles, more available managed services, fewer approval gates—which can be a significant competitive advantage for non-regulated parts of the business.

***

## 34.6 The common platform layer

### 34.6.1 The sovereignty platform concept

Beneath the differences among the four blueprints lies a common platform layer—a set of capabilities, patterns, and shared services that every sovereign estate requires regardless of its zone topology, connectivity model, or cloud provider mix. We call this the sovereignty platform. It is not a product; it is an architectural pattern for the shared foundation on which sovereign workloads run.

The sovereignty platform is the domain of the platform engineering function described in [Chapter 12](12_chapter_configuration_runbook_automation.html). It provides the reusable building blocks—modules, policies, pipelines, observability configurations, identity integrations—that application teams consume when they deploy workloads into sovereign zones. Without it, each application team would need to solve sovereignty problems independently, leading to inconsistent implementations, duplicated effort, and gaps that auditors will eventually find.

### 34.6.2 Shared module libraries

The platform team maintains a library of infrastructure-as-code modules that encode sovereignty patterns. These modules are the Terraform modules and Ansible roles described in [Chapter 11](11_chapter_infrastructure_as_code.html), but curated and governed as organisational assets rather than team-level conveniences. A sovereign network module creates a VPC with the organisation's standard subnet layout, encryption requirements, flow logging configuration, and zone boundary controls. A sovereign cluster module provisions an OpenShift cluster with the organisation's standard hardening baseline, admission controllers, network policies, and observability agent deployment. A sovereign database module provisions a database instance with encryption at rest, audit logging, backup to zone-local storage, and access controls that enforce the zone's identity framework.

Each module encodes the organisation's sovereignty decisions as preconditions, validations, and defaults. An engineer using the sovereign network module does not need to remember which regions are approved for the EU zone, or which encryption configuration meets the relevant regulatory standard, or how flow logs should be routed. The module knows. This is the operationalisation of policy: converting written policies into executable code that prevents non-compliant configurations from being created in the first place [6].

The module library is version-controlled, tested, and released through the same CI/CD processes used for application code. Modules have semantic versions; breaking changes are communicated through release notes and migration guides. Consuming teams pin to specific module versions and upgrade on a managed cadence, ensuring that platform improvements propagate through the estate without forcing simultaneous updates across all consumers.

### 34.6.3 Common policy frameworks

Policy-as-code is a cross-cutting concern that spans all blueprints. The sovereignty platform provides a common policy framework—a set of OPA policies, Kyverno cluster policies, or equivalent policy-as-code artefacts—that encodes the organisation's sovereignty rules in machine-evaluable form. These policies are evaluated at multiple points: in CI/CD pipelines (preventing non-compliant configurations from being deployed), at admission time in Kubernetes clusters (preventing non-compliant resources from being created), and continuously at runtime (detecting drift from compliant state).

The policy framework is hierarchical. Organisation-wide policies—data residency constraints, encryption requirements, tagging standards—apply to all zones and all tiers. Zone-specific policies—approved regions, approved providers, zone-specific access controls—apply within individual zones. Application-specific policies—custom compliance requirements for particular regulatory regimes—apply to specific workloads. The hierarchy is enforced by the policy engine: zone-specific policies cannot weaken organisation-wide policies, and application-specific policies cannot weaken zone-specific policies. [Chapter 10](10_chapter_continuous_compliance.html) describes the continuous compliance monitoring that validates this hierarchy at runtime.

### 34.6.4 Standardised observability

The observability plane is standardised across the sovereignty platform. Every workload, regardless of which blueprint or zone it operates in, is instrumented using the same conventions: OpenTelemetry for trace and metric collection [13], structured logging with a common schema, and Instana agents for automatic discovery and topology mapping. The observability configuration is delivered through the shared module library: the sovereign cluster module deploys Instana agents as part of cluster provisioning, and the sovereign application deployment template includes sidecar configurations for OpenTelemetry collectors.

Standardisation ensures that Concert can build a complete topology model across the estate and that operators can use consistent query patterns and dashboard layouts regardless of which zone they are investigating. It also ensures that compliance evidence—the structured records of system behaviour that auditors require—is produced in a uniform format that the governance and audit plane can ingest and analyse without per-zone customisation.

### 34.6.5 Unified identity

Identity is the final pillar of the common platform layer. Every blueprint requires a coherent identity model that answers three questions: who (or what) is this entity, what are they authorised to do, and how can we verify that authorisation? The sovereignty platform provides a unified identity framework—typically built on an enterprise identity provider federated with zone-local identity services—that supports single sign-on for human operators, service account management for workloads, and machine identity (certificates and tokens) for infrastructure components.

In multi-zone deployments, identity federation must respect zone boundaries. A human operator authenticated in zone A does not automatically have access to zone B; they must be separately authorised under zone B's access policies. Service accounts in one zone do not have credentials valid in another zone unless an explicit cross-zone trust relationship has been established and approved. The identity framework enforces these boundaries while providing a unified directory that allows the central operations team to manage identity lifecycle—onboarding, role changes, offboarding—through a single process that propagates to all zones ([Chapter 13](13_chapter_secrets_identity_access.html)).

***

## 34.7 Customising blueprints for your context

### 34.7.1 The selection decision

No blueprint applies perfectly to any organisation. The first step in using these blueprints is selecting the one closest to your requirements, and that selection is driven by five factors.

The first factor is regulatory requirements. How many distinct regulatory regimes must the organisation satisfy? If the answer is one, the single-zone blueprint is the starting point. If multiple, the multi-zone blueprint is indicated. If the most stringent regime prohibits internet connectivity, the air-gapped blueprint applies to that portion of the estate. If some workloads are unregulated, the hybrid blueprint offers cost and velocity advantages for those workloads.

Regulatory requirements extend beyond the question of how many jurisdictions are involved; the sector-specific content of those requirements shapes how a blueprint is customised once selected. A healthcare organisation must define HIPAA-compliant zones that enforce ePHI segmentation, access logging and breach notification workflows — constraints that alter the observability and identity layers of any blueprint it adopts. A manufacturer subject to IEC 62443 must map industrial automation zones and conduits onto the blueprint's networking model, ensuring that OT/IT boundary controls are expressed in policy-as-code and monitored by the observability plane. A government agency operating under FedRAMP must maintain a continuous monitoring boundary that aligns with its Authorisation to Operate (ATO), defining which components fall within the FedRAMP boundary and which do not. [Chapter 3](03_chapter_regulatory_drivers.html) provides the full regulatory landscape across sectors; architects should use it as a checklist when adapting any of the blueprints below to their specific context.

The second factor is scale. The single-zone blueprint is well suited to organisations running hundreds of workloads in a single jurisdiction. The multi-zone blueprint is necessary for organisations with thousands of workloads across jurisdictions. The air-gapped blueprint applies regardless of scale when connectivity restrictions demand it. The hybrid blueprint is most valuable at scales where the cost differential between sovereign and commercial tiers is material.

The third factor is the existing estate. Organisations with a substantial existing cloud presence may find it easier to adopt the hybrid blueprint, treating their current commercial cloud deployment as the commercial tier and building sovereign zones alongside it. Organisations building from scratch—a new government agency, a corporate spin-off—have more freedom to choose a single-zone or multi-zone blueprint without the constraints of an existing estate.

The fourth factor is organisational maturity. The maturity model in [Chapter 33](33_chapter_maturity_model.html) provides a framework for assessing an organisation's readiness for each blueprint. The single-zone and hybrid blueprints are achievable at lower maturity levels; the multi-zone blueprint requires more mature platform engineering, policy-as-code, and operational practices; the air-gapped blueprint requires the highest maturity in self-sufficient operations.

The fifth factor is budget. Sovereign infrastructure is more expensive than commercial cloud, and the more sovereign zones an organisation operates, the higher the cost. The hybrid blueprint explicitly addresses cost optimisation. The air-gapped blueprint is the most expensive to operate, due to the overhead of the controlled transfer boundary and the need for self-sufficient internal capabilities.

### 34.7.2 Composing blueprints

Complex organisations often need to compose elements from multiple blueprints. A defence ministry, for example, might operate an air-gapped zone for classified workloads, a sovereign zone for official-sensitive workloads, and a commercial tier for unclassified administrative systems. This composition produces a three-tier estate that draws the air-gapped blueprint for the classified tier, the single-zone or multi-zone blueprint for the official-sensitive tier, and the hybrid blueprint's boundary management patterns for the interfaces between tiers.

Composition is not mechanical assembly. Each interface between tiers introduces boundary management complexity, and the total complexity grows faster than linearly with the number of tiers. The organisation must design each boundary deliberately, with explicit policies for what crosses it and how. The controlled transfer boundary from the air-gapped blueprint applies at the classified-to-sensitive interface. The boundary gateway from the hybrid blueprint applies at the sensitive-to-commercial interface. Each boundary has its own policy set, its own audit trail, and its own operational procedures.

The common platform layer (section 34.6) is the principal tool for managing composition complexity. By standardising modules, policies, observability, and identity across all tiers, the platform team reduces the per-tier overhead and ensures that boundaries are implemented consistently. Without this standardisation, a three-tier composition can easily devolve into three separate estates that happen to share a corporate identity, defeating the purpose of architectural coherence.

### 34.7.3 Iterative adaptation

Blueprints are starting points, not destinations. The organisation should expect to adapt its chosen blueprint iteratively as it gains operational experience, as regulatory requirements evolve, and as the estate grows. The maturity model in [Chapter 33](33_chapter_maturity_model.html) provides the framework for this iterative progression: an organisation might begin with a basic implementation of the single-zone blueprint, progressively adding more sophisticated observability, policy enforcement, and agentic operations as its maturity increases.

The adaptation process should be governed by the same infrastructure-as-code and policy-as-code disciplines described throughout this book. Changes to the blueprint—adding a new zone, tightening a boundary policy, introducing a new observability capability—should be expressed as code changes, reviewed through pull requests, tested in non-production environments, and promoted through a controlled release process. The blueprint is not a static document; it is a living codebase that evolves with the organisation.

***

## Key Takeaways

- Reference blueprints bridge the gap between architectural principles and implementable designs; they should be adapted to context, not adopted wholesale.
- The single-sovereign-zone blueprint suits organisations with one jurisdiction and one policy set; its strength is operational simplicity and a unified observability and compliance posture.
- The multi-zone, multi-cloud blueprint addresses enterprises operating across jurisdictions; it separates orchestration from execution, using Concert as the unified topology layer and zone-local automation for all changes.
- The air-gapped blueprint serves the highest-security environments; it replaces internet-dependent patterns with locally hosted equivalents and manages external dependencies through a controlled transfer boundary.
- The hybrid sovereign-commercial blueprint optimises cost and velocity by placing only regulated workloads in sovereign zones; boundary management and workload classification are its critical challenges.
- The common platform layer—shared modules, policy frameworks, standardised observability, and unified identity—reduces complexity and ensures consistency across all blueprints.
- Complex organisations compose elements from multiple blueprints; the common platform layer is the primary tool for managing the resulting boundary complexity.
- Blueprint selection is driven by regulatory requirements, scale, existing estate, organisational maturity, and budget; most organisations will iterate through progressive refinements rather than implementing a final-state blueprint in one step.

***

## Bridge to Chapter 35 — Industry Patterns

These blueprints describe structural patterns—topologies, connectivity models, platform layers—without specifying the industry context in which they are deployed. A sovereign zone in a bank is not the same as a sovereign zone in a hospital, even if both follow the same structural blueprint. The next chapter examines how these architectural patterns manifest in specific industries—financial services, public sector, healthcare, energy, and telecommunications—where the interplay of sector-specific regulation, operational culture, and business requirements shapes the way blueprints are instantiated and operated.

***

## References

[1] IBM, "IBM Cloud for Financial Services," IBM Cloud Documentation, 2025. [Online]. Available: https://cloud.ibm.com/docs/framework-financial-services

[2] A. Khan, R. Zurawski, and J. Hjelm, "Container Isolation in Multi-Tenant Kubernetes Environments," *IEEE Transactions on Cloud Computing*, vol. 11, no. 2, pp. 1245–1260, 2023. [Online]. Available: https://doi.org/10.1109/TCC.2023.3245126

[3] W. Morgan and O. Gould, "The Service Mesh: What Every Software Engineer Needs to Know about the World's Most Over-Hyped Technology," 2020. [Online]. Available: https://servicemesh.io

[4] IBM, "IBM Instana Observability," IBM Documentation, 2025. [Online]. Available: https://www.ibm.com/docs/en/instana-observability

[5] IBM, "IBM OpenPages with Watson," IBM Documentation, 2025. [Online]. Available: https://www.ibm.com/docs/en/openpages

[6] K. Morris, *Infrastructure as Code: Dynamic Systems for the Cloud Age*, 2nd ed. Sebastopol, CA: O'Reilly Media, 2021. [Online]. Available: https://www.oreilly.com/library/view/infrastructure-as-code/9781098114664/

[7] European Commission, "EU Cloud Rulebook," Shaping Europe's Digital Future, 2024. [Online]. Available: https://digital-strategy.ec.europa.eu/en/library/eu-cloud-rulebook

[8] M. Stonebraker and U. Cetintemel, "One Size Fits All: An Idea Whose Time Has Come and Gone," in *Proc. 21st Int. Conf. on Data Engineering (ICDE)*, IEEE, 2005, pp. 2–11. [Online]. Available: https://doi.org/10.1109/ICDE.2005.1

[9] IBM, "IBM watsonx Orchestrate," IBM Documentation, 2025. [Online]. Available: https://www.ibm.com/docs/en/watsonx-orchestrate

[10] IBM, "IBM Cloud Satellite," IBM Documentation, 2025. [Online]. Available: https://cloud.ibm.com/docs/satellite

[11] The Linux Foundation, "Sigstore: A New Standard for Signing, Verifying and Protecting Software," 2023. [Online]. Available: https://www.sigstore.dev

[12] S. Gugger et al., "Efficient Inference of Large Language Models in Resource-Constrained Environments," *arXiv preprint arXiv:2312.11514*, 2023. [Online]. Available: https://arxiv.org/abs/2312.11514

[13] OpenTelemetry Authors, "OpenTelemetry Specification," Cloud Native Computing Foundation, 2024. [Online]. Available: https://opentelemetry.io/docs/specs/otel/
