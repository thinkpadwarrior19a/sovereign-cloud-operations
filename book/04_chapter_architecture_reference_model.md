# Chapter 4 — An Architectural Reference Model for Sovereign Cloud Operations

***

## Summary

This chapter proposes a four-plane reference model for sovereign cloud operations — the Observability Plane, the Automation and Orchestration Plane, the Agentic Intelligence Plane, and the Governance and Audit Plane — extending the zero-copy integration framework with an operations-specific decomposition that gives each concern a clear architectural home. It details the responsibilities and key technologies within each plane: federated telemetry collection with zone-local retention for observability; infrastructure as code, GitOps and workflow orchestration for automation; AI-driven correlation, reasoning and conversational interfaces for agentic intelligence; and policy-as-code, immutable audit trails and the sovereign AI record for governance. The chapter maps IBM's technology portfolio — Instana, Turbonomic, Concert, watsonx Orchestrate and watsonx.governance — into the model and explains how it complements, rather than replaces, hyperscaler-native tooling. It also directly addresses the meta-lock-in concern — that adopting a full IBM sovereign stack merely substitutes one form of vendor dependency for another — by showing how the model's reliance on open standards and interface contracts makes each plane's components substitutable, and by framing strategic optionality and documented exit paths as explicit architectural requirements. A dedicated section on control plane security confronts the "who watches the watchmen" question — whether the cross-cloud control plane itself becomes a single point of compromise — and sets out the distributed trust architecture, zone-scoped credentials, just-in-time privilege elevation and zone-local enforcement mechanisms that bound the blast radius of any control plane breach. Architects will find practical guidance on using the model as a shared vocabulary for design, gap analysis and evolution of their sovereign operations estate.

***

## 4.1 Why we need a reference model

When systems were fewer and simpler, it was possible for a small group of architects or operators to keep the entire estate in their heads. They knew which applications talked to which databases, which network segments connected which data centres, which monitoring tools covered which components. If you asked them, in a war room, "What happens if we lose this system?", they could sketch a plausible answer on a whiteboard and be roughly right.

In a modern, multi‑cloud, zero‑copy environment, that mental map no longer scales. Services come and go. New regions are added. SaaS platforms appear in critical paths. AI‑based components make decisions whose internal workings are not immediately obvious. The number of dependencies is too large and too dynamic for any one person—or even any one team—to track accurately.

At the same time, the expectations placed on operations have grown. Regulators want evidence of control and resilience. Customers expect continuity and transparency. Boards want assurance that sovereignty commitments are not just marketing language. Operations teams want tools and processes that reduce, rather than increase, cognitive load.

In this context, a reference model is not an academic nicety; it is a survival tool. It gives the organisation a shared vocabulary for talking about operations architecture. It helps separate concerns that are often conflated. It provides a way to reason about where particular technologies fit and how they should interact. Above all, it makes it possible to design and evolve the environment intentionally instead of reactively.

Established enterprise architecture frameworks, most notably TOGAF [1], emphasise precisely this need for shared language and structured decomposition. TOGAF's Architecture Development Method does not prescribe a specific solution architecture, but it insists that architecture work must be grounded in a common set of building blocks and that the concerns of different stakeholders must be separated into coherent domains. The model proposed in this chapter is consistent with that spirit, though it applies TOGAF's decomposition approach specifically to the domain of sovereign cloud operations rather than to enterprise architecture in the general sense.

This chapter proposes such a model for sovereign cloud operations. It does not pretend to be the only valid decomposition, but it is one that aligns well with both the emerging regulatory landscape and the direction of IBM's own sovereign stack, including IBM Sovereign Core, Concert, Instana, Turbonomic and watsonx Orchestrate [2].

***

## 4.2 From three planes to four: extending the Zero‑Copy framework

In *Zero‑Copy Integration*, the architecture is organised around three integration planes—data, application, and event—governed by a control plane that enforces policy and provides observability. That decomposition is still valid in the sovereign operations world. The systems that move and expose data, mediate APIs, and propagate events are the substrate on which operations take place.

However, when we shift focus from integration to operations, a different set of concerns comes to the foreground. We are less interested in the internal details of each integration pattern and more interested in how the whole estate can be observed, controlled and adapted in real time. Questions like "Where does this data flow?" and "Which services consume this event stream?" remain important, but they are joined by questions like:

- "How do we know which business services are at risk right now?"
- "How do we decide what to do next when something goes wrong?"
- "How do we express and enforce sovereignty and resilience policies at runtime?"
- "How do we incorporate AI into those decisions without losing control?"

To answer these, it is helpful to introduce a complementary set of planes, focused not on *what is integrated* but on *how it is operated*. In this book, we will talk about four such planes:

1. The **Observability Plane**: how the estate is instrumented, how signals are collected, stored and made available.
2. The **Automation & Orchestration Plane**: how changes are made, how workflows are represented and executed.
3. The **Agentic Intelligence Plane**: how AI models and agents interpret signals, propose actions and sometimes act.
4. The **Governance & Audit Plane**: how policies, constraints and evidence are expressed and enforced across the others.

These planes are not stacks in the sense of strict layers; they are perspectives on the same underlying systems. A Terraform plan that changes network routing touches automation. The metrics that report the effect of that change live in observability. An Orchestrate agent that suggests the change belongs to agentic intelligence. The policy that says such a change must not move data outside a jurisdiction belongs to governance.

Thinking in planes does not solve the problem by itself. It does, however, provide a way to ensure that each concern is given its due and that the technologies chosen for each are coherent.

![The four-planes sovereign operations reference model](images/figure-4-1.png)

***

## 4.3 The Observability Plane: seeing the sovereign estate

The observability plane is the nervous system of sovereign operations. It is how the organisation senses what is happening across its multi‑cloud, multi‑region, multi‑platform environment. Without it, everything else is guesswork.

### 4.3.1 The signals of observability

The conventional description of observability invokes three pillars: metrics, logs and traces. These categories, now standardised by the OpenTelemetry project [3] under the Cloud Native Computing Foundation [4], capture the dominant forms of operational telemetry. Metrics are numeric measurements sampled over time—CPU utilisation, request rates, error counts—that reveal the quantitative health of a system. Logs are structured or unstructured records of discrete events: service startups, error messages, audit entries. Traces are end‑to‑end records of a request's journey through a distributed system, capturing each span of processing with its timing, metadata and parent–child relationships. The OpenTelemetry specification [3] provides vendor-neutral, language-agnostic APIs and SDKs for emitting all three signal types in a consistent format, and it is rapidly becoming the lingua franca of modern observability instrumentation.

In the model proposed in this book, two further signal types are recognised as first-class members of the observability vocabulary. The fourth is **events**: discrete, semantically rich notifications of state transitions—a deployment completing, a policy violation being detected, a certificate approaching expiry—that differ from logs in that they carry explicit business meaning and are intended to drive downstream reactions, not merely be retained for historical audit. Concert, for example, ingests events from ITSM platforms, cloud APIs and CI/CD pipelines, treating them as first-class inputs to its resilience scoring engine [5]. The fifth is **topology**: a continuously maintained model of the relationships between services, processes, hosts, containers, APIs and the business capabilities they serve. Topology is not a point-in-time document; it is a dynamic signal whose changes—a new dependency appearing, a service endpoint disappearing, a cluster being added to a sovereign zone—carry as much operational meaning as any metric. The CNCF TAG Observability technical advisory group has noted that topology and dependency mapping are increasingly recognised as foundational to meaningful observability in distributed systems [4], and IBM Instana's emphasis on automatic topology discovery reflects precisely this recognition.

Understanding these five signals—metrics, logs, traces, events and topology—as a coherent vocabulary is important. It prevents the trap of treating observability as merely a logging problem, or merely a metrics dashboard problem. A sovereign estate that emits rich metrics but lacks trace context cannot diagnose latency problems across service boundaries. One that captures logs but not topology cannot answer impact questions when a cloud provider reports an incident. The observability plane must accommodate all five.

### 4.3.2 Context and control in sovereign observability

In simple terms, observability is about telemetry: metrics, logs, traces and events. In practice, for sovereign operations it is also about **context** and **control**.

Context means that telemetry is not just raw data points but is tied to an understanding of what those data points represent. A CPU metric means little on its own; it matters when you know which service, on which cluster, in which region, supporting which business capability, under which sovereignty constraints, is experiencing that load. IBM Instana places great emphasis on this contextualisation: it automatically discovers applications, services, processes, hosts, containers and network paths, building a topology that shows how components relate [6]. This automatic instrumentation—covering more than 300 technologies without requiring manual agent configuration—means that the topology model is maintained continuously rather than being an artefact that decays between architecture review cycles [24].

Control means that the organisation can decide where telemetry resides and who can access it. In a sovereign context, this is crucial. Telemetry pipelines must respect the same boundaries as the systems they describe. That may mean running observability backends within specific jurisdictions, or federating them across regions, or keeping certain logs local while allowing aggregated views centrally. It may mean ensuring that AI models used for observability—such as Instana's LLM observability features, which build on the OpenLLMetry standard—operate on data within the right boundaries [7].

### 4.3.3 Federated collection and zone-local retention

The sovereign requirement imposes a specific architectural pattern on observability: federated collection with zone-local retention and aggregate-only cross-boundary export. In practice, this means that each sovereign zone operates its own observability backend capable of ingesting and retaining raw telemetry locally. The zone-local backend satisfies the data residency obligations applicable to that zone: raw logs containing potentially personal data, detailed request traces, and sensitive configuration telemetry do not leave the zone's boundary. At the zone edge, a filtering and aggregation layer extracts summary signals—aggregated metrics, anonymised topology graphs, event counts by category—that can be exported to a central resilience and operations view without exposing the raw data.

This federated model is not merely a data protection nicety. It is also the pattern that allows Concert to build its cross-estate resilience view without requiring every sovereign zone to surrender its raw telemetry. Concert's ingestion architecture is explicitly designed to consume signals from multiple observability backends and ITSM systems [5], which means the zone-local/aggregate-export model aligns naturally with how Concert constructs its dependency graphs and resilience scores. Regulators and data protection authorities in multiple jurisdictions are beginning to scrutinise whether observability pipelines inadvertently route personal or sensitive operational data outside permitted boundaries; the zone-local pattern provides the architectural answer.

### 4.3.4 The OpenTelemetry Collector as the vendor-neutral ingestion layer

A critical architectural component in the observability plane is the OpenTelemetry Collector [3], an open-source, vendor-neutral pipeline that receives, processes and exports telemetry data in standardised formats. The Collector acts as the ingestion gateway for each sovereign zone: applications and infrastructure components emit telemetry using OpenTelemetry SDKs or compatible exporters, the Collector receives it, applies configured processing pipelines—filtering sensitive fields, batching, sampling, enriching with zone metadata—and routes it to one or more backends. Backends within the zone receive full-fidelity data; the cross-boundary export channel receives only what policy permits.

Because the OpenTelemetry Collector is vendor-neutral, it can receive telemetry from AWS CloudWatch exporters, Azure Monitor agents, GCP's operations suite, Kubernetes cluster components, and proprietary middleware, all in a consistent pipeline. Instana's own agent architecture integrates with the OpenTelemetry ecosystem, allowing organisations that have already invested in OpenTelemetry instrumentation to route signals into Instana without re-instrumentation [6]. This interoperability is important in a multi-cloud estate where no single vendor controls all sources of telemetry.

### 4.3.5 AI-aware observability

The observability plane is also increasingly **AI‑aware**. As large language models and other AI components become part of the operational fabric, they generate their own telemetry—prompts, responses, latencies, errors, token usage. Capturing and understanding this is essential for both performance and governance. Instana's support for OpenLLMetry [7] reflects this recognition: without structured telemetry from AI systems, their behaviour cannot be observed or managed effectively, and the transparency obligations of the EU AI Act [8] cannot be met in practice. In this model, AI telemetry is treated as a first-class signal type within the observability plane, not as a secondary concern to be handled by a separate monitoring tool.

In this model, the observability plane is not limited to a single tool. It may include cloud‑native monitors from AWS, Azure and GCP; it may integrate existing logging stacks. But there needs to be a **unifying view**—a place where signals come together with consistent semantics. For the purposes of this book, we will treat Instana, augmented where necessary by other sources and federated through the OpenTelemetry Collector, as the canonical example of such a view [6].

***

## 4.4 The Automation & Orchestration Plane: changing the system safely

If observability tells us what is happening, automation and orchestration are how we change it. In a sovereign estate, change is both necessary and dangerous. Necessary because systems must evolve, scale, heal and adapt; dangerous because every change is a potential incident and a potential compliance breach.

The automation and orchestration plane has three primary responsibilities, and understanding how they differ is important for both design and governance.

### 4.4.1 Deterministic automation: runbooks, scripts and playbooks

The first category of automation in this plane is **deterministic automation**: the execution of predefined, well-understood procedures whose behaviour is entirely specified in advance. This includes traditional runbooks, shell scripts, Ansible playbooks, and Terraform plans. The word "deterministic" does not mean that these artefacts never fail or never produce unexpected results; it means that their logic is explicit and reviewable, and that the same inputs will, under normal conditions, produce the same outputs.

Red Hat Ansible Automation Platform [9] is the primary execution engine for deterministic automation in the IBM sovereign stack. Ansible's agentless architecture, human-readable playbook syntax and idempotent execution model make it well suited to the heterogeneous operational environments—operating systems, middleware, network devices, cloud APIs—that characterise a large enterprise estate. In the sovereign operations model, Ansible is not just a tool for sysadmins performing ad-hoc remediation; it is a general-purpose execution engine that agents can invoke to implement complex, multi-step changes consistently and repeatably. When Concert identifies a remediation action—patching a vulnerable package, rotating a certificate, adjusting a network security group—it may invoke an Ansible playbook as its execution mechanism, ensuring that the action is performed consistently regardless of which engineer, or which agent, initiates it [5].

Red Hat Satellite [10] complements Ansible at the lifecycle management layer, providing subscription management, content synchronisation, patch orchestration and system registration across Red Hat Enterprise Linux and OpenShift estates. In a sovereign context, Satellite is especially important because it allows organisations to maintain a local mirror of validated content within each sovereign zone, ensuring that patch and configuration operations do not require outbound connectivity to external repositories and that the provenance of all installed software can be demonstrated to auditors.

### 4.4.2 AI-directed automation: Concert-driven workflow orchestration

The second category is **AI-directed automation**: workflows that are initiated, sequenced or parameterised on the basis of recommendations produced by the agentic intelligence plane rather than by a human operator reading a runbook. This is where deterministic execution mechanisms—Ansible playbooks, Terraform modules, OpenShift GitOps pipelines—are invoked not from a scheduled job or an incident ticket, but from an agent's decision to act on a signal.

IBM Concert [5] occupies a pivotal position here. Concert does not merely surface recommendations to a dashboard for humans to review; it can initiate and track remediation workflows, calling into automation tooling and tracking the outcome. Watsonx Orchestrate [11] extends this by representing workflows as agent behaviours that can be invoked conversationally—an operator asks "What should we do about the certificate expiry on the payments service cluster?" and an agent assembles the appropriate sequence of actions, invokes the relevant tooling, and reports back. The distinction from purely deterministic automation is that the selection and sequencing of actions is AI-guided, not pre-scripted.

This distinction matters for governance. Deterministic automation can be reviewed statically: an architect can read a playbook and verify that it behaves as intended under the relevant policies. AI-directed automation requires a different form of assurance: that the agent's decision-making is operating within defined boundaries, that its choices are logged, and that a human can inspect and override the reasoning. This is precisely the challenge the governance plane is designed to address.

### 4.4.3 GitOps as the change control mechanism

Across both deterministic and AI-directed automation, **GitOps** is the change control mechanism that keeps the automation plane honest. GitOps—the practice of using a Git repository as the single source of truth for declared system state, with automated reconciliation ensuring that deployed state matches declared state—provides several properties that are essential in a sovereign operations context [12].

First, every change to a deployed configuration must pass through a version-controlled repository, creating an immutable, branching history of what was declared, when, and by whom. This is the foundation of a meaningful audit trail: not merely that a change was applied, but that it was reviewed, approved and committed through a defined process before it reached production. Second, GitOps reconciliation loops continuously verify that deployed state matches declared state, providing automatic detection of drift—a common source of compliance failures in large estates. Third, rollback becomes a first-class operation: reverting to a previous declared state is a Git operation, not a manual procedure.

Red Hat OpenShift GitOps, based on the ArgoCD project, implements these principles in the OpenShift environment. Terraform state management, used alongside tools such as IBM Cloud Schematics, provides equivalent properties for infrastructure provisioning [13]. In a multi-cloud, multi-zone estate, GitOps pipelines must be configured with awareness of sovereign zone boundaries: a pipeline that can push a change to any cluster without authorisation controls is not a sovereign-aware automation plane; it is a risk.

### 4.4.4 Policy-as-code and the automation guardrails

The automation plane is also where **policy-as-code** frameworks are most directly operative. The Open Policy Agent (OPA) [14], using its Rego policy language, can be deployed as an admission controller in Kubernetes environments to evaluate every proposed change—every new deployment, every configuration mutation, every ingress rule—against a set of machine-readable policies before it is permitted. These policies encode sovereignty constraints, security baselines and compliance requirements in a form that is reviewed, versioned and tested like application code.

In a sovereign operations architecture, OPA policies might enforce rules such as: workloads labelled with a specific data classification may only be scheduled to nodes within a designated sovereign zone; container images must originate from an approved internal registry; network policies may not permit egress to addresses outside approved ranges. These are not aspirational rules written in a policy document; they are enforced at admission time, before a non-compliant configuration can ever enter a sovereign environment. Combining OPA with GitOps means that both the policies and the configurations they govern are version-controlled, reviewable, and subject to the same approval workflows.

Crucially, the automation and orchestration plane is where **guardrails** are enforced. Which workflows are allowed to run in which environments? What approvals are required? How are changes rolled back if something goes wrong? How are failures reported and learned from? These questions bridge into the governance plane, but their answers must be encoded here, in the tools that actually execute changes, not merely in policy documents that describe what should happen.

***

## 4.5 The Agentic Intelligence Plane: understanding and deciding

The agentic intelligence plane is where AI comes into operations. It is not a separate "AI system" bolted onto the side; it is a perspective on how models and agents interpret the world and participate in decisions. The emergence of this plane as a discrete architectural concern reflects the maturation of AI capabilities in the operations domain—what Gartner has termed the AIOps market [15]—from simple anomaly detection towards genuine causal reasoning and multi-step workflow execution.

### 4.5.1 Building and maintaining the estate model

Before an agent can reason about the estate, it must have a model of it. IBM Concert builds and maintains this estate model through continuous ingestion of signals from multiple sources [5]. The process begins with topology discovery: Concert uses APIs to query cloud provider resource inventories, Kubernetes cluster state, service registries and ITSM configuration management databases, assembling a dependency graph that represents the relationships between business services, applications, infrastructure components and the ICT third-party services on which they depend. This graph is not a one-time snapshot; it is continuously refreshed as signals indicate that the topology has changed—new pods scheduling, services scaling, APIs being deprecated, cloud provider configurations changing.

On top of the topology graph, Concert ingests the five signal types described in section 4.3: metrics, logs, traces, events and topology changes. Each signal is correlated with the node or edge in the dependency graph that it describes, building a time-series-enriched graph that Concert's reasoning engine can query. The result is what Concert's architecture describes as a "resilience posture" view: not merely a collection of metrics dashboards, but a structured understanding of which business services are healthy, which are degraded, which are at elevated risk due to upstream dependencies, and what the estimated business impact of current conditions is [5].

This estate model is the input to everything else the agentic plane does. An agent that lacks an accurate estate model will make recommendations that are locally plausible but globally wrong—for example, proposing to restart a service without recognising that it is a dependency of three other services currently serving peak traffic. Concert's emphasis on continuous, topology-aware signal ingestion is therefore not a feature differentiator; it is a prerequisite for meaningful agentic operations [23].

### 4.5.2 The recommendation engine: correlation, causal inference and priority scoring

Given an estate model enriched with live signals, Concert's recommendation engine applies signal correlation, causal inference and priority scoring to produce actionable outputs [5]. Signal correlation identifies relationships between events that occur close together in time and share topological proximity in the dependency graph—for example, a sudden increase in database query latency correlating with a spike in connection pool exhaustion on a specific application tier. These correlations are candidates for causal analysis.

Causal inference—distinguishing genuine cause-and-effect relationships from coincidental correlation—is one of the more demanding problems in operational AI. Concert approaches this by combining graph-based reasoning (following the dependency edges in the estate model) with pattern matching against historical incident data and known resolution patterns. The output is not a definitive statement of cause but a ranked set of hypotheses, each with an associated confidence score. This probabilistic framing is important: it sets honest expectations about the nature of AI-assisted diagnosis and creates a natural mechanism for human review of the highest-uncertainty cases.

Priority scoring translates these hypotheses into a ranked remediation agenda. Concert scores potential actions against multiple dimensions: the estimated business impact of the underlying condition if left unresolved, the confidence in the causal hypothesis, the availability and estimated effectiveness of known remediation steps, and the risk of the remediation itself causing collateral disruption. The resulting priority-ordered list is what Concert surfaces to operators and, where bounded autonomy permits, to agents for execution. The prioritisation logic is configurable and auditable, so organisations can align Concert's priority model with their own business service criticality definitions and risk appetite.

Similarly, AI-assisted capabilities in Instana help distinguish noise from signal in performance data [6], reducing the alert fatigue that degrades operator effectiveness in complex estates.

### 4.5.3 watsonx Orchestrate as the conversational and workflow interface

Recommendation is only valuable if it can be acted upon efficiently. IBM watsonx Orchestrate [11] serves as the conversational and workflow interface to the agentic plane, translating Concert's recommendations and Instana's signals into operator interactions and multi-step workflow executions.

Orchestrate is designed explicitly for multi-agent orchestration [11]: individual agents are responsible for specific domains—ITSM integration, infrastructure change, communications, documentation—and Orchestrate coordinates their collaboration on composite tasks. An operator interacting with Orchestrate in natural language—"Show me the highest-priority risks for the payments platform and propose a remediation sequence"—triggers an agent workflow that queries Concert for the current resilience posture, identifies the highest-priority items, assembles a proposed remediation sequence by consulting available runbooks and playbooks, and presents the result with supporting evidence. The operator can approve the sequence, modify it, or ask for further explanation, all within the same conversational interface.

Watsonx Orchestrate also provides the execution bridge between the agentic intelligence plane and the automation plane. When an operator approves a remediation action, Orchestrate invokes the appropriate automation tooling—an Ansible playbook via Ansible Automation Platform, a GitOps pipeline change, a cloud API call—and monitors the execution, reporting outcomes back to both the operator and the Concert estate model. This closed-loop execution is what allows Concert's dependency graph to reflect the effects of remediation actions in near-real time, maintaining the accuracy of the estate model rather than letting it drift after each change.

### 4.5.4 Bounded autonomy: agents acting within policy-defined envelopes

The concept of **bounded autonomy** is central to the safe deployment of agents in operations. Bounded autonomy means that an agent may act—initiate changes, invoke tools, modify configurations—only within a policy-defined envelope: a set of explicitly permitted action types, targets and conditions that the organisation has consciously reviewed and authorised. Outside that envelope, the agent must seek human approval or escalate.

The policy-defined envelope is expressed in the governance plane through policy-as-code and agent configuration. A low-risk, high-confidence action—restarting a crashed container within a non-critical development environment—might be within the autonomous envelope. A change to a network security group within a production sovereign zone would require human approval regardless of the agent's confidence score. An action that would move data across a sovereign boundary would be prohibited absolutely.

This tiered approach—autonomous within envelope, approval-required for higher-risk actions, prohibited for boundary violations—maps directly onto the human oversight requirements of the EU AI Act Article 14 [8], which mandates that high-risk AI systems be designed so that natural persons can effectively oversee, interrupt and override their operation. Bounded autonomy is not merely a prudent operational choice; for organisations deploying agentic operations in regulated environments, it is a legal requirement expressed as an architectural pattern.

The agentic intelligence plane is where the promise and risk of AI in operations are most concentrated. A well‑designed agent can dramatically reduce time to understanding and time to change. A poorly governed one can make mistakes at machine speed. That is why this plane cannot be considered in isolation. It must be tightly linked to governance, and its scope must be designed deliberately: where should AI only advise, where may it act with approval, and where may it act autonomously?

***

## 4.6 The Governance & Audit Plane: embedding control into architecture

The governance and audit plane is the one that most directly reflects the regulatory drivers discussed in [Chapter 3](03_chapter_regulatory_drivers.html). It is where high‑level intents—sovereignty commitments, resilience requirements, security policies, AI governance rules—are translated into enforceable artefacts. The NIST Zero Trust Architecture framework [16] articulates a principle that applies with equal force here: trust is never assumed, it is continuously evaluated against policy. The governance plane is the mechanism by which that evaluation is operationalised across every action taken by human operators and AI agents alike.

### 4.6.1 What the governance plane must record

The governance plane must maintain a complete, queryable record of every consequential action taken within the sovereign operations estate. This encompasses four categories of event.

Every **agent action** must be recorded: which agent initiated an action, on which component, based on which recommendation, at what time, with what outcome. This includes actions that were proposed but rejected by a human approver, and actions that were attempted but failed. The record must include not only the fact of the action but the reasoning chain that led to it—which signals were considered, which model was consulted, what confidence score was produced—so that the action can be audited not merely as a fact but as a reasoned decision.

Every **automation execution** must be recorded: which playbook, script or Terraform plan was run, in which environment, against which targets, triggered by which event or approval, and with what result. For GitOps-managed changes, the commit hash and approver identity must be captured alongside the deployment outcome. For Ansible executions, the task-level results must be retained, not just the top-level success or failure indicator.

Every **policy evaluation** must be recorded: when an OPA policy gate was evaluated, which rule was applied, which resource was assessed, and whether the evaluation resulted in a permit, deny or conditional approval. Policy evaluation logs are particularly important for demonstrating to regulators that the organisation's stated policies are actually operative and that exceptions are controlled and audited rather than routine.

Every **human approval or override** must be recorded: when an operator approved or rejected an agent recommendation, when a change was manually applied outside normal workflow, when an autonomous action was halted by a human. Human decisions are as important to the audit record as automated actions; they establish the chain of accountability that regulators and boards require.

### 4.6.2 Immutability, WORM storage and cryptographic chaining

The integrity of the audit record depends on its immutability. An audit log that can be modified after the fact—whether by an administrator cleaning up an embarrassing incident record or by an adversary covering their tracks—provides no real assurance. The governance plane must therefore enforce write-once, read-many (WORM) storage for all audit artefacts, combined with cryptographic chaining that makes tampering detectable.

WORM storage is available on all major cloud platforms and on-premises storage systems; what matters architecturally is that it is enforced at the storage layer, not merely by operational convention. A policy that says "operators must not delete audit logs" is not an immutability control; an object lock that prevents any principal from modifying or deleting a log object before its retention period expires is. NIST SP 800-53 Rev. 5 [17] specifies audit log protection requirements under control AU-9, requiring protection of audit information and tools from unauthorised access, modification and deletion. The architectural expression of AU-9 in a sovereign operations context is WORM-enforced, zone-local storage for raw audit artefacts.

Cryptographic chaining—where each log entry includes a hash of the previous entry, creating a verifiable sequence—provides tamper evidence that complements storage-layer immutability. If a sequence of log entries is later presented to an auditor, the cryptographic chain can be verified to confirm that no entries have been deleted or reordered. This is particularly important for AI-assisted action records, where the sequence of reasoning steps leading to an action may be scrutinised in a regulatory investigation.

### 4.6.3 watsonx.governance for AI model governance

Watsonx.governance [18] plays a central role for the AI-specific dimensions of the governance plane. It provides a framework for governing models and AI workloads across their entire lifecycle: from registration and lineage tracking through deployment authorisation, runtime monitoring and retirement. In the context of sovereign operations, watsonx.governance provides three critical capabilities.

First, model registration and lineage: every AI model used in the operational environment—whether a Concert recommendation model, an Instana anomaly detector, or an Orchestrate agent—is registered in the watsonx.governance model inventory with its training data provenance, validation results and approved deployment contexts. This registration is the precondition for the "sovereign AI record" concept: only governed, registered models may be invoked in operational workflows.

Second, runtime monitoring: watsonx.governance monitors the behaviour of deployed models over time, tracking metrics such as prediction confidence distributions, override rates and performance against reference datasets. Drift detection—the identification that a model's behaviour is diverging from its expected performance envelope—triggers governance review before the model's recommendations are accepted at face value by operational agents.

Third, policy application and audit: watsonx.governance enforces policies about which models may be used in which contexts—for example, prohibiting the use of a model trained on EU customer data from being invoked in a context where the requester is outside the permitted jurisdiction—and logs every invocation against the registered model version. This logging is the foundation of the EU AI Act Article 13 transparency obligation [8], which requires that the operation of high-risk AI systems be sufficiently transparent that their output can be interpreted and used appropriately.

### 4.6.4 IBM OpenPages for risk and compliance management

IBM OpenPages [19] provides the risk and compliance management layer within the governance plane. Where watsonx.governance focuses specifically on AI model governance, OpenPages provides the broader framework for operational risk management: maintaining the risk register, tracking control effectiveness, managing audit findings and remediation plans, and reporting to senior management and regulators.

In the sovereign operations architecture, OpenPages is the system of record for compliance obligations. The design criteria derived from DORA [20], NIS2 [21], GDPR [22] and the EU AI Act [8]—continuous topology visibility, governed change execution, sovereign telemetry, bounded AI—are represented as controls in OpenPages, each linked to the regulatory instruments that mandate them and to the technical implementation artefacts that satisfy them. When an audit finding is raised—for example, because a policy evaluation log reveals that a configuration change bypassed the normal approval workflow—the finding is managed in OpenPages with a tracked remediation plan and an accountability owner.

### 4.6.5 DORA ICT risk management audit requirements

The Digital Operational Resilience Act [20] imposes specific audit requirements on the governance plane. DORA's Article 6 requires financial entities to maintain a comprehensive ICT risk management framework that is reviewed at least annually and after major incidents. The governance plane must produce, on demand, evidence that this framework is operative: that policy evaluations are occurring, that automation is executing within approved parameters, that agent actions are bounded and recorded, and that human oversight is documented.

DORA's Article 17 requires that incident management processes produce a structured record of detection, classification, escalation, response and resolution. In the sovereign operations model, this record is assembled from the governance plane's audit log: the initial signal correlation that detected the condition, the agent recommendation that proposed a classification, the human approval that authorised a response action, the automation execution that implemented it, and the post-change verification that confirmed resolution. The governance plane does not merely support DORA compliance; it is the technical mechanism by which a dynamic, AI-assisted operations environment can produce the kind of structured, evidenced audit trail that DORA's supervisory authorities will expect to see.

IBM Sovereign Core [2] is the architectural enforcement layer that keeps this governance infrastructure within the sovereign boundary. Built on Red Hat OpenShift and designed to run under customer or local operational authority, Sovereign Core keeps identity, encryption keys, logs, telemetry and audit evidence within the sovereign boundary, and it provides a customer‑operated control plane for AI workloads. Sovereignty is not an overlay; it is a property of the platform's design.

In the broader architecture of this book, the governance and audit plane encompasses policy definition, policy enforcement, evidence collection and AI governance, working as a cross-cutting discipline that operates across all four planes rather than as an isolated compliance function. An important property of this plane is that it should be **provider‑agnostic**. Policies about data residency, access control, approval flows and AI autonomy should not have to be re‑implemented independently for each cloud and tool. They should be expressed once and enforced consistently, using open standards and integrations [3, 14, 18].

***

## 4.7 Mapping IBM technologies into the model

Having outlined the four planes, it is helpful to position key IBM technologies within them. This is not an exercise in branding; it is a way to clarify which tools solve which parts of the problem and how they relate.

In the **Observability Plane**, IBM Instana is the primary example. It provides real‑time, high‑fidelity observability across hybrid and multi‑cloud environments, automatically discovering services and dependencies and offering one-second metric granularity and end‑to‑end tracing [6]. The OpenTelemetry Collector [3] provides the vendor-neutral ingestion layer, receiving telemetry from diverse sources across sovereign zones and routing it to zone-local backends. Instana is complemented by logging and metrics stores as needed, and increasingly by LLM observability via the OpenLLMetry standard [7]. Together, they instrument the five-signal vocabulary—metrics, logs, traces, events and topology—that the observability plane requires.

In the **Automation & Orchestration Plane**, HashiCorp Terraform (and IBM Cloud Schematics where used), Red Hat OpenShift GitOps [12], and Red Hat Ansible Automation Platform [9] provide the core execution mechanisms, with Red Hat Satellite [10] providing lifecycle management and content governance. Open Policy Agent [14] enforces policy-as-code guardrails at the admission layer. Concert's remediation workflows and Orchestrate's multi‑agent orchestration capabilities sit here as well, describing how sequences of actions are triggered and coordinated across tools in response to agentic recommendations [5, 11].

In the **Agentic Intelligence Plane**, IBM Concert and IBM watsonx Orchestrate are central. Concert ingests signals, builds and maintains the estate model, runs the recommendation engine, and surfaces risks and remediation priorities across hybrid and multi‑cloud estates [5]. Orchestrate provides the conversational and multi‑agent interface for executing those remediations through existing systems, with an open, interoperable architecture designed to plug into heterogeneous stacks [11][26]. IBM Turbonomic contributes resource optimisation and workload placement recommendations, feeding its analysis into Concert's resilience view [25].

In the **Governance & Audit Plane**, IBM Sovereign Core [2] represents the architectural enforcement of sovereignty across infrastructure and AI workloads. Watsonx.governance [18] governs AI models and assets across their lifecycle. IBM OpenPages [19] provides risk and compliance management. Policy‑as‑code frameworks, identity providers and key management systems, WORM-enforced audit storage and cryptographic log chaining complete the evidence infrastructure. The combination satisfies the record-keeping requirements of DORA Article 6 [20], NIST SP 800-53 AU-9 [17], and the EU AI Act Articles 13 and 14 [8].

This mapping is not meant to be exhaustive. Many other IBM and non‑IBM components will appear in later chapters. The important point is that each technology should have a clear "home" in the conceptual model, even if it touches multiple planes. That clarity helps prevent both gaps and overlaps.

![IBM technology mapping across the four planes](images/figure-4-2.png)

***

## 4.8 How this model complements hyperscaler architectures

AWS, Azure and Google Cloud each offer their own well‑developed architectural frameworks, reference blueprints and best practices. They have native tools for observability, automation, security and governance. It is natural to ask: why introduce another model? Why not simply follow the guidance of whichever hyperscaler is most important to the organisation?

The answer lies in scope and accountability. Hyperscaler architectures are, understandably, focused on what happens within their own platforms. They do not typically provide a unified view across other clouds, on‑premises environments, mainframe systems and SaaS platforms. Nor do they directly address the socio‑technical dimensions of sovereignty, AI governance and cross‑provider operational resilience.

The model in this chapter is intended to sit **above and across** hyperscaler architectures. It assumes that organisations will continue to use cloud‑native services where appropriate. It does not prescribe which provider to choose for which workload. Instead, it provides a way to ensure that, whatever choices are made, the operations layer remains coherent and sovereign.

IBM's Sovereign Core [2] is a particularly clear example of this approach. It is explicitly designed to decouple sovereignty from dedicated data centre regions and to provide a software stack that can run under customer or local operational authority across cloud platforms. Similarly, IBM Concert [5] is built to ingest signals from multiple observability tools and ITSM systems, including those native to hyperscalers, and to apply AI and workflow automation across them. Watsonx Orchestrate [11] is engineered as an open, interoperable agent platform that plugs into existing workflows and tools rather than demanding wholesale replacement.

By adopting this model, organisations do not reject hyperscaler architectures; they **complement** them with a control plane that reflects their own sovereignty, governance and multi‑cloud needs.

***

## 4.9 Addressing meta-lock-in: strategic optionality as a design criterion

A legitimate concern arises at this point in the argument. If an organisation adopts IBM Concert for operational intelligence, Instana for observability, watsonx Orchestrate for agentic workflows, OpenPages for compliance management and watsonx.governance for AI lifecycle governance, has it not simply replaced hyperscaler lock-in with a different form of lock-in — operational lock-in to IBM? The architecture presented in this chapter would be intellectually dishonest if it did not confront this question directly.

### 4.9.1 The modularity principle

The four-planes reference model is defined by the interfaces and contracts between planes, not by the specific products that instantiate them. Each plane — observability, automation and orchestration, agentic intelligence, governance and audit — communicates with the others through documented APIs, standard data formats and well-understood protocols. The architecture deliberately separates the *what* (the operational capability each plane must provide) from the *how* (the specific product or service that provides it). A well-designed implementation should allow component substitution within any plane without re-architecting the planes above and below it.

This is not an abstract aspiration. The separation of concerns described in sections 4.3 through 4.6 exists precisely to make each plane's internal implementation replaceable. If the observability plane exposes telemetry through OpenTelemetry-compatible APIs, any consumer of that telemetry — Concert, a third-party AIOps platform, or an internally developed correlation engine — can ingest it. If the automation plane accepts work requests through standard API contracts and executes them through Ansible playbooks or Terraform plans, the source of those requests is immaterial to the automation layer's design. The planes are coupled by contracts, not by shared proprietary state.

### 4.9.2 Open standards as the interoperability layer

The interchangeability described above is only credible if the interfaces between planes are grounded in open, vendor-neutral standards rather than proprietary protocols. The reference model rests on a specific set of such standards, and it is worth enumerating them explicitly so that architects can evaluate the claim for themselves.

**OpenTelemetry** [3] provides the data model and wire protocol for metrics, logs and traces across the observability plane. Telemetry emitted in OpenTelemetry format can be consumed by Instana, Datadog, Grafana, Splunk or any other backend that implements the OTLP receiver — and most now do. An organisation that instruments its applications with OpenTelemetry SDKs and deploys OpenTelemetry Collectors as the routing layer is not locked into any particular observability backend. **CloudEvents** [27] standardises the envelope format for event interchange: Concert, Azure Event Grid and AWS EventBridge all produce and consume CloudEvents, making event routing between systems a configuration choice rather than a development project. **OpenLineage** [28] provides a standard for data lineage metadata, enabling lineage information to flow between governance tools without proprietary connectors. **Open Policy Agent** [14] and its Rego policy language provide the policy evaluation engine that sits at the boundary of every plane; OPA policies are portable across any system that can call OPA's decision API, which includes Kubernetes admission controllers, API gateways, CI/CD pipelines and custom applications.

In the automation plane, **Terraform** and its open-source fork **OpenTofu** [29] provide declarative infrastructure-as-code that targets every major cloud provider and hundreds of SaaS platforms through a provider plugin architecture. **Ansible** [9] provides imperative and declarative automation with an open-source core, thousands of community modules, and no requirement to use Red Hat's commercial Ansible Automation Platform. **Kubernetes** [30] provides the container orchestration substrate that abstracts workload placement across clouds and sovereign zones; its API is the most widely implemented infrastructure contract in the industry.

For identity and access, **OIDC** and **SAML** provide federation protocols that allow any compliant identity provider to authenticate users and services across the stack. No component in the reference model requires a proprietary identity system.

These are not incidental technology choices. They are the architectural hinges that make the reference model genuinely modular. An organisation that wants to use Datadog instead of Instana, or ServiceNow GRC instead of OpenPages, can do so — provided the replacement component implements the relevant standard interfaces. The architecture accommodates that substitution because it was designed around the interfaces, not around the products.

### 4.9.3 Concert as aggregator, not gatekeeper

Concert's architectural role deserves specific attention in this context because it sits at the centre of the agentic intelligence plane and touches all four planes. The concern that Concert becomes a proprietary chokepoint is understandable but does not withstand examination of its integration architecture (detailed further in [Chapter 14](14_chapter_concert_architecture.html)).

Concert consumes signals through standard protocols and documented APIs. Its topology discovery draws from Kubernetes APIs, cloud provider resource APIs and CMDB exports — none of which are IBM-proprietary. Its signal ingestion accepts OpenTelemetry-formatted telemetry, CloudEvents-formatted events and REST API payloads from any source that can produce them. An organisation could feed Concert from Datadog, Splunk, Elastic or Prometheus alongside or instead of Instana, and Concert's correlation engine would operate over those signals in the same way. Concert's value lies in its correlation, topology reasoning and recommendation generation — not in proprietary data capture or exclusive signal formats.

This is an important distinction. A product that adds value through proprietary data formats — that can only ingest signals it has captured through its own agents — is a genuine lock-in mechanism. A product that adds value through reasoning over standard-format signals from diverse sources is an aggregation layer, and aggregation layers are replaceable by definition: any competing product that accepts the same standard inputs can be substituted. The cost of that substitution is real — retraining staff, migrating configuration, rebuilding dashboards — but it is operational cost, not architectural cost. No re-instrumentation of the monitored estate is required.

### 4.9.4 Strategic optionality in practice

Component substitutability should be treated as an explicit architectural requirement, not as a theoretical possibility that is never tested. Concretely, a well-designed sovereign operations architecture should support the following scenarios without requiring a fundamental redesign:

Running Instana and a third-party observability tool simultaneously during evaluation or migration. Both can receive OpenTelemetry data from the same collector pipeline; both can feed signals into Concert or a replacement correlation engine. Dual-running is the practical test of whether the open-standards claim is genuine.

Replacing OpenPages with ServiceNow GRC, Archer or another governance, risk and compliance platform without rebuilding the compliance pipeline. The governance plane's contracts — policy evaluation results in, compliance evidence out, audit trail to immutable storage — should be fulfilled by any GRC tool that exposes appropriate APIs.

Using Terraform, OpenTofu, Pulumi or Crossplane for infrastructure-as-code, singly or in combination. The automation plane should be agnostic to the IaC engine; what matters is that the declared state is version-controlled, the plan is policy-evaluated before apply, and the execution result is recorded as a change event.

Adopting individual components of the watsonx stack — watsonx.ai for model serving, watsonx.governance for AI lifecycle management, Orchestrate for agentic workflows — without being required to adopt the entire portfolio. Each component should connect to the rest of the architecture through its documented APIs and standard protocols, not through undocumented internal integration points that only work when all components are present.

### 4.9.5 The honest trade-off

Intellectual honesty requires acknowledging that tighter integration between components from the same vendor does provide deeper capability than a best-of-breed assembly. Concert's integration with Instana, for example, gives it access to Instana's full dependency discovery, one-second metric granularity, and runtime-traced call graphs — a richer signal set than Concert would receive from a third-party tool exporting summary metrics via OpenTelemetry. Orchestrate's integration with watsonx.governance provides inline model governance checks during agent execution that would require custom integration work with a third-party governance tool. These are genuine benefits, not marketing claims.

The decision is therefore not binary — "all IBM" or "no IBM" — but a spectrum. At one end, an organisation adopts the full IBM sovereign stack and benefits from the deepest integration, the most complete out-of-the-box workflows, and the simplest vendor management. At the other end, an organisation uses the reference model as a design scaffold, fills each plane with its preferred best-of-breed tools, and accepts the integration cost of connecting them through standard interfaces. Most organisations will land somewhere in the middle: adopting IBM components where their capabilities are strongest and substituting alternatives where organisational preference, existing investment, or specific technical requirements favour a different choice.

The reference model supports all three positions because it is defined by the contracts between planes, not by the products within them. An architecture that only works with a single vendor's components throughout is not a reference model; it is a product configuration guide. This chapter aims to provide the former.

### 4.9.6 Exit strategy as architectural discipline

Any sovereign operations architecture should include a documented exit path for every major component. This is not a hostile act towards any vendor — it is a sign of architectural maturity. The ability to migrate away from a component is the concrete expression of the modularity principle: if the interfaces are genuinely open and the data formats are genuinely standard, then exit is an operational project, not an architectural crisis.

European regulators have begun to formalise this expectation. DORA Article 28 [20] requires financial entities to ensure that their contractual arrangements with ICT third-party service providers include provisions for exit strategies and transition plans. The European Banking Authority's guidelines on ICT concentration risk [31] further require that critical operational dependencies on any single provider are identified, assessed and mitigated. An architecture that can demonstrate component-level exit paths — documented, tested, and costed — satisfies these requirements more convincingly than one that claims vendor neutrality in principle but has never validated it in practice.

For each major component in the sovereign operations architecture, the exit strategy should document: what data must be exported and in what format; what configuration and policy definitions must be migrated; what integration points must be reconnected; what staff retraining is required; and what the realistic timeline and cost of the transition would be. This documentation should be maintained as a living artefact, reviewed annually, and updated when the component's API surface or data model changes. The exit strategy is not a plan to leave — it is evidence that the architecture is genuinely modular and that the organisation retains strategic optionality over its operational estate.

***

## 4.10 Securing the cross-cloud control plane

Section 4.9 addressed the meta-lock-in concern — whether adopting an IBM-centred operations stack substitutes one form of vendor dependency for another. A related but distinct objection must also be confronted: does a cross-cloud control plane — Concert for operational intelligence, watsonx Orchestrate for agentic workflows, Instana for federated observability — create a single point of failure or, worse, a single point of compromise? If the control plane is breached, an attacker potentially gains a vantage point across the entire multi-cloud estate. This is not a hypothetical worry. It is the same structural risk that any centralised management plane introduces — AWS Organisations, Azure Lighthouse, Google Cloud's resource hierarchy — and it must be addressed with the same rigour.

### 4.10.1 The distributed trust model

The foundational design principle is that the cross-cloud control plane must not be a super-user. It must not hold permanent, broad-scope credentials for each sovereign zone, and it must not be capable of unilateral action across zone boundaries. The architecture enforces this through four complementary mechanisms.

First, **zone-scoped credentials**. Concert and Orchestrate hold only the minimum credentials needed for each sovereign zone, and those credentials are zone-specific. Credentials provisioned for Zone A cannot access Zone B resources. Each zone's identity provider issues scoped tokens to the control plane on a per-request basis, and the token audience, scope and lifetime are constrained by zone-local policy — not by the control plane's own configuration. [Chapter 13](13_chapter_secrets_identity_access.html) details the mechanics: HashiCorp Vault dynamic credentials, cloud-native workload identity federation, and SPIFFE/SPIRE for vendor-neutral service identity.

Second, **no standing privilege**. The control plane uses just-in-time privilege elevation rather than persistent administrative credentials. When Concert generates a remediation recommendation and Orchestrate dispatches it for execution, the automation layer requests a temporary, purpose-scoped token from the target zone's IAM subsystem. That token is valid only for the specific action, the specific resource scope, and a bounded time window. When the action completes, the token is revoked. At no point does the control plane possess a standing administrative role in any sovereign zone.

Third, **zone-local enforcement**. Policy evaluation and enforcement happen within each sovereign zone, not from the central plane. The control plane *recommends*; zone-local controllers — OPA admission policies, Kubernetes RBAC, cloud-native IAM boundary policies — *execute*. If the central plane is compromised, zone-local policy engines still prevent actions that violate sovereignty constraints, compliance boundaries or least-privilege rules. The control plane can request; it cannot compel.

Fourth, **break-glass separation**. Emergency access to the control plane itself — not through the control plane to managed zones, but to the control plane's own administrative functions — requires multi-party authorisation. A two-person rule with hardware security keys, time-bounded approval workflows, and an immutable audit trail of every emergency access event ensure that no single administrator, and no single compromised credential, can reconfigure the control plane's trust relationships or credential scopes.

### 4.10.2 Compromise scenarios and architectural mitigations

Intellectual honesty requires naming the failure modes and evaluating the mitigations.

**Credential theft from the control plane** is mitigated by ensuring there are no long-lived credentials to steal. If Concert's credential store is breached, the attacker obtains short-lived tokens that expire within minutes and dynamic credentials that are rotated continuously. The blast radius is bounded by time.

**Insider threat — including the vendor's own personnel** — is mitigated by deploying the control plane within the customer's sovereign zone rather than consuming it as vendor-hosted SaaS. Customer-managed encryption keys (IBM's Keep Your Own Key model, described in [Chapter 13](13_chapter_secrets_identity_access.html)) ensure that even the platform vendor cannot access the control plane's configuration, topology model, or credential material. Where confidential computing is available, the control plane can run in a hardware-attested enclave whose memory is inaccessible to infrastructure operators.

**Infrastructure compromise of the hosting environment** is mitigated by the same defence-in-depth that protects any critical workload: network segmentation, mTLS between all control plane components, hardware-rooted attestation, and continuous integrity monitoring.

**Supply chain attack on the control plane software** is mitigated by SBOM verification, Sigstore-based artefact signing, and customer-controlled update policies that allow independent verification of every binary before it enters the sovereign zone. [Chapter 11](11_chapter_infrastructure_as_code.html) treats this supply chain discipline in detail.

### 4.10.3 The net risk calculus

No management plane is risk-free. The relevant question is not whether the cross-cloud control plane introduces risk — it does — but whether that risk is greater or less than the alternative: operating multiple cloud estates without a unified control plane, accepting fragmented visibility, inconsistent policy enforcement, slower incident detection, and the human error that arises from managing each environment through separate, uncoordinated tools. For most sovereign operations at scale, a properly secured consolidated control plane — scoped credentials, no standing privilege, zone-local enforcement, customer-managed keys, and hardware-attested execution — reduces net risk compared with the fragmented alternative. The architecture must make this trade-off explicit, document the residual risks, and subject the control plane to the same threat modelling, penetration testing and continuous audit that it applies to the workloads it manages.

***

## 4.11 Using the model in practice

A reference model is only useful if it helps guide actual decisions. In the rest of this book, we will use the four planes to structure our exploration of sovereign cloud operations.

When we discuss observability, we will ask: Does our observability plane provide the context and control we need? Where does Instana fit? How do we handle network observability and AI‑related telemetry? How does the OpenTelemetry Collector enable zone-local retention and aggregate-only cross-boundary export?

When we discuss automation, we will ask: Are changes expressed as code and workflows in a way that agents can safely execute? How do Terraform, Ansible, Concert and Orchestrate interact? How does policy-as-code via OPA translate sovereignty constraints into enforceable admission controls?

When we discuss agentic operations, we will ask: What decisions are we comfortable delegating to AI, and under what conditions? How does Concert's estate model enable meaningful causal reasoning? What does bounded autonomy look like in practice, and how are its boundaries defined and enforced?

When we discuss governance, we will ask: How are sovereignty, resilience and AI policies expressed and enforced? How does Sovereign Core shape the environment? How does watsonx.governance oversee models and agents, and how does OpenPages maintain the compliance management record?

In practical terms, you can use the model as a checklist. For any proposed change—adopting a new tool, designing a new platform, responding to a new regulatory requirement—ask what implications it has for each plane. A decision to centralise logs, for example, has observability and governance implications. A plan to introduce autonomous remediation has ramifications across automation, agentic intelligence and governance.

The model also helps frame conversations between teams. SREs, platform engineers, security architects, data protection officers and AI governance leads do not always share vocabulary. By adopting a shared language of planes and control points, they can more easily locate their concerns within a common map.

Finally, the model is a starting point for **evolution**. As new technologies and regulatory expectations emerge—new forms of AI, new sovereignty requirements, new patterns of workload placement—the planes may accommodate additional sub‑components. The core idea, however, should remain: sovereign cloud operations are not the property of a single tool or team; they are the emergent behaviour of an architecture in which observability, automation, agentic intelligence and governance are designed to work together.

***

## Key Takeaways

- A reference model structured around operational planes—rather than around product categories or organisational silos—provides the shared vocabulary that engineers, architects, risk managers and compliance leads need to reason together about sovereign cloud operations. TOGAF [1] and similar frameworks have long advocated this kind of structured decomposition; the four-planes model applies the same discipline specifically to the operational domain.

- The observability plane must accommodate five signal types: metrics, logs, traces, events and topology. The OpenTelemetry specification [3] standardises the first three; this model elevates events and topology to equivalent first-class status. The sovereign requirement imposes federated collection, zone-local retention and aggregate-only cross-boundary export as the canonical observability architecture.

- The automation and orchestration plane must distinguish deterministic automation—Ansible playbooks, Terraform plans, GitOps pipelines—from AI-directed automation driven by Concert recommendations. Policy-as-code via OPA [14] provides the admission-layer guardrails that ensure both categories of automation remain within sovereignty and compliance constraints.

- The agentic intelligence plane requires an accurate, continuously maintained estate model before meaningful reasoning is possible. Concert's topology discovery and signal ingestion architecture [5] is the mechanism for building and maintaining that model. Bounded autonomy—agents acting only within policy-defined envelopes—is both a prudent operational principle and a legal requirement under EU AI Act Article 14 [8].

- The governance and audit plane must record every agent action, every automation execution, every policy evaluation, and every human approval or override, in a form that is immutable, cryptographically chained, and zone-local. NIST SP 800-53 AU-9 [17] and NIST SP 800-207 zero-trust principles [16] provide the control framework; IBM Sovereign Core [2] provides the architectural enforcement.

- Watsonx.governance [18] and IBM OpenPages [19] together provide the AI model governance and risk management infrastructure that satisfies the EU AI Act's transparency and risk management obligations and DORA's ICT risk management audit requirements [20].

- The four-planes model complements hyperscaler architectures rather than competing with them. It provides a cross-provider, policy-aware control plane that reflects the organisation's own sovereignty commitments, governance obligations and multi-cloud operational needs—properties that no single hyperscaler's native tooling is designed to supply.

- Strategic optionality — the ability to substitute, dual-run, or exit any individual component without re-architecting the whole stack — is an explicit design criterion of the reference model, not a theoretical afterthought. The architecture's reliance on open standards (OpenTelemetry, CloudEvents, OpenLineage, OPA/Rego, Terraform/OpenTofu, Ansible, OIDC/SAML, Kubernetes) makes component substitution an operational project rather than an architectural crisis. Tighter integration between components from the same vendor provides deeper capability, but this is a trade-off decision that each organisation should make deliberately, not a structural requirement of the model. Documented exit paths for every major component satisfy both architectural maturity goals and the regulatory expectations of DORA Article 28 [20] and EBA ICT concentration risk guidelines [31].

- The cross-cloud control plane must not be a super-user. Zone-scoped credentials, just-in-time privilege elevation, zone-local policy enforcement and multi-party break-glass authorisation ensure that no single compromise of the control plane grants an attacker unilateral access across the entire multi-cloud estate. The control plane recommends; zone-local controllers execute. Deploying the control plane within the customer's sovereign zone — with customer-managed encryption keys and, where available, confidential computing enclaves — mitigates the insider threat, including from the platform vendor's own personnel.

***

## Bridge to Chapter 5 — Multi-Cloud Topology and Network Foundations

This chapter has proposed a four-planes reference model for sovereign cloud operations—observability, automation and orchestration, agentic intelligence, and governance and audit—and has shown how this decomposition maps onto both the regulatory design criteria derived in [Chapter 3](03_chapter_regulatory_drivers.html) and the IBM sovereign stack technologies that instantiate each plane. The model is not a prescription but a scaffold: it organises the concerns of sovereign operations into tractable domains, provides a shared vocabulary for cross-functional architectural conversations, and ensures that each element of the technology stack has a clear and deliberate home within the overall architecture. The emphasis throughout has been on the relationships between planes—signals flowing from observability into agentic intelligence, recommendations flowing from agentic intelligence into automation, every action flowing into governance—because it is those relationships, not the individual planes in isolation, that determine whether the architecture actually behaves as a sovereign, governed whole.

[Chapter 5](05_chapter_multi_cloud_topology_network.html) takes the next step: given this conceptual model, how is the underlying multi-cloud infrastructure actually arranged? It introduces sovereign zones as the fundamental placement unit, examines how network topology constrains and enables the architecture, and explores how IBM Sovereign Core, Red Hat OpenShift and IBM Cloud Satellite provide the practical substrate for realising sovereign zones across diverse and heterogeneous environments. The topology decisions made in [Chapter 5](05_chapter_multi_cloud_topology_network.html) determine, concretely, where each plane's components may run, how signals may flow between zones, and which automation actions may be permitted in which contexts—translating the reference model from conceptual framework into deployable architecture.

***

## References

[1] The Open Group, "TOGAF Standard, 10th Edition," The Open Group, Reading, UK, 2022. [Online]. Available: https://www.opengroup.org/togaf

[2] IBM Corporation, "IBM Sovereign Core — Product Overview," IBM, Armonk, NY, USA, 2026. [Online]. Available: https://www.ibm.com/products/sovereign-core

[3] Cloud Native Computing Foundation, "OpenTelemetry Specification," OpenTelemetry Project, 2024. [Online]. Available: https://opentelemetry.io/docs/specs/otel/

[4] Cloud Native Computing Foundation Technical Advisory Group for Observability, "Observability Whitepaper," CNCF TAG Observability, 2023. [Online]. Available: https://github.com/cncf/tag-observability/blob/main/whitepaper.md

[5] IBM Corporation, "IBM Concert — Product Documentation and Architecture Overview," IBM, Armonk, NY, USA, 2025. [Online]. Available: https://www.ibm.com/docs/en/concert

[6] IBM Corporation, "Getting Started with IBM Instana Observability," IBM Documentation, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/instana-observability/1.0.309?topic=references-getting-started-instana

[7] D. Hiraoka, "Instana Introduction to LLM Observability — New Architecture," IBM Community Blog, IBM Corporation, Feb. 2026. [Online]. Available: https://community.ibm.com/community/user/blogs/daisuke-hiraoka2/2026/02/04/instana-introduction-to-llm-observability-new-arch

[8] European Parliament and Council of the European Union, "Regulation (EU) 2024/1689 of the European Parliament and of the Council of 13 June 2024 laying down harmonised rules on artificial intelligence (Artificial Intelligence Act)," *Official Journal of the European Union*, vol. L 2024/1689, Jun. 2024. [Art. 13: Transparency; Art. 14: Human oversight; Art. 9: Risk management system.]

[9] Red Hat, Inc., "Red Hat Ansible Automation Platform — Product Overview," Red Hat, Raleigh, NC, USA, 2024. [Online]. Available: https://www.redhat.com/en/technologies/management/ansible

[10] Red Hat, Inc., "Red Hat Satellite — Product Documentation," Red Hat, Raleigh, NC, USA, 2024. [Online]. Available: https://access.redhat.com/documentation/en-us/red_hat_satellite

[11] IBM Corporation, "IBM watsonx Orchestrate — Product Overview," IBM, Armonk, NY, USA, 2025. [Online]. Available: https://www.ibm.com/products/watsonx-orchestrate

[12] W. Limoncelli, "GitOps: A Path to More Self-service IT," *ACM Queue*, vol. 16, no. 3, May/Jun. 2018. [Online]. Available: https://queue.acm.org/detail.cfm?id=3237207

[13] IBM Corporation, "IBM Cloud Schematics — Infrastructure as Code Documentation," IBM, Armonk, NY, USA, 2024. [Online]. Available: https://cloud.ibm.com/docs/schematics

[14] Styra, Inc. and Open Policy Agent Project, "Open Policy Agent — Policy-as-Code Framework," CNCF Graduated Project, 2024. [Online]. Available: https://www.openpolicyagent.org/

[15] Gartner, Inc., "Market Guide for AIOps Platforms," Gartner, Stamford, CT, USA, 2023.

[16] S. Rose, O. Borchert, S. Mitchell, and S. Connelly, "Zero Trust Architecture," NIST Special Publication 800-207, National Institute of Standards and Technology, Gaithersburg, MD, USA, Aug. 2020. [Online]. Available: https://doi.org/10.6028/NIST.SP.800-207

[17] Joint Task Force, "Security and Privacy Controls for Information Systems and Organizations," NIST Special Publication 800-53, Revision 5, National Institute of Standards and Technology, Gaithersburg, MD, USA, Sep. 2020. [Online]. Available: https://doi.org/10.6028/NIST.SP.800-53r5

[18] IBM Corporation, "IBM watsonx.governance — Product Documentation," IBM, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/watsonx/saas?topic=governing-ai

[19] IBM Corporation, "IBM OpenPages — Risk and Compliance Management," IBM, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/products/openpages

[20] European Parliament and Council of the European Union, "Regulation (EU) 2022/2554 of the European Parliament and of the Council of 14 December 2022 on digital operational resilience for the financial sector (Digital Operational Resilience Act — DORA)," *Official Journal of the European Union*, vol. L 333, pp. 1–79, Dec. 2022. [Art. 6: ICT risk management framework; Art. 17: ICT-related incident management.] [Online]. Available: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32022R2554

[21] European Parliament and Council of the European Union, "Directive (EU) 2022/2555 of the European Parliament and of the Council of 14 December 2022 on measures for a high common level of cybersecurity across the Union (NIS2 Directive)," *Official Journal of the European Union*, vol. L 333, pp. 80–152, Dec. 2022. [Online]. Available: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32022L2555

[22] European Parliament and Council of the European Union, "Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of natural persons with regard to the processing of personal data (General Data Protection Regulation — GDPR)," *Official Journal of the European Union*, vol. L 119, pp. 1–88, Apr. 2016. [Online]. Available: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32016R0679

[23] NAND Research, "Research Note: IBM Updates Concert Platform," NAND Research, 2025. [Online]. Available: https://nand-research.com/research-note-ibm-updates-concert-platform/

[24] Grant Thornton India, "Observability and APM Services with IBM Instana," Grant Thornton, 2024. [Online]. Available: https://www.grantthornton.in/globalassets/1.-member-firms/india/assets/pdfs/observability_and_apm_services_with_ibm_instana.pdf

[25] IBM Corporation, "IBM Instana and IBM Turbonomic Integration," IBM, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/products/turbonomic/integrations/instana-observability

[26] Amazon Web Services and IBM Red Hat, "Building Agentic Workflows with IBM watsonx Orchestrate on AWS," AWS and IBM Blog, 2025. [Online]. Available: https://aws.amazon.com/blogs/ibm-redhat/building-agentic-workflows-with-ibm-watsonx-orchestrate-on-aws/

[27] Cloud Native Computing Foundation, "CloudEvents Specification, v1.0.2," CNCF Serverless Working Group, 2024. [Online]. Available: https://cloudevents.io

[28] OpenLineage Project, "OpenLineage Specification," Linux Foundation AI & Data, 2024. [Online]. Available: https://openlineage.io

[29] The OpenTofu Project, "OpenTofu — The Open Source Terraform Alternative," Linux Foundation, 2024. [Online]. Available: https://opentofu.org

[30] Cloud Native Computing Foundation, "Kubernetes Documentation," CNCF, 2024. [Online]. Available: https://kubernetes.io/docs/

[31] European Banking Authority, "Guidelines on ICT and security risk management," EBA/GL/2019/04 (revised 2024), Frankfurt, Germany. [Online]. Available: https://www.eba.europa.eu/regulation-and-policy/internal-governance/guidelines-on-ict-and-security-risk-management
