# Chapter 4 — An Architectural Reference Model for Sovereign Cloud Operations

***

## 4.1 Why we need a reference model

When systems were fewer and simpler, it was possible for a small group of architects or operators to keep the entire estate in their heads. They knew which applications talked to which databases, which network segments connected which data centres, which monitoring tools covered which components. If you asked them, in a war room, “What happens if we lose this system?”, they could sketch a plausible answer on a whiteboard and be roughly right.

In a modern, multi‑cloud, zero‑copy environment, that mental map no longer scales. Services come and go. New regions are added. SaaS platforms appear in critical paths. AI‑based components make decisions whose internal workings are not immediately obvious. The number of dependencies is too large and too dynamic for any one person—or even any one team—to track accurately.

At the same time, the expectations placed on operations have grown. Regulators want evidence of control and resilience. Customers expect continuity and transparency. Boards want assurance that sovereignty commitments are not just marketing language. Operations teams want tools and processes that reduce, rather than increase, cognitive load.

In this context, a reference model is not an academic nicety; it is a survival tool. It gives the organisation a shared vocabulary for talking about operations architecture. It helps separate concerns that are often conflated. It provides a way to reason about where particular technologies fit and how they should interact. Above all, it makes it possible to design and evolve the environment intentionally instead of reactively.

This chapter proposes such a model for sovereign cloud operations. It does not pretend to be the only valid decomposition, but it is one that aligns well with both the emerging regulatory landscape and the direction of IBM’s own sovereign stack, including IBM Sovereign Core, Concert, Instana, Turbonomic and watsonx Orchestrate. [ibm](https://www.ibm.com/new/announcements/introducing-ibm-sovereign-core-a-new-software-foundation-for-sovereignty)

***

## 4.2 From three planes to four: extending the Zero‑Copy framework

In *Zero‑Copy Integration*, the architecture is organised around three integration planes—data, application, and event—governed by a control plane that enforces policy and provides observability. That decomposition is still valid in the sovereign operations world. The systems that move and expose data, mediate APIs, and propagate events are the substrate on which operations take place.

However, when we shift focus from integration to operations, a different set of concerns comes to the foreground. We are less interested in the internal details of each integration pattern and more interested in how the whole estate can be observed, controlled and adapted in real time. Questions like “Where does this data flow?” and “Which services consume this event stream?” remain important, but they are joined by questions like:

- “How do we know which business services are at risk right now?”  
- “How do we decide what to do next when something goes wrong?”  
- “How do we express and enforce sovereignty and resilience policies at runtime?”  
- “How do we incorporate AI into those decisions without losing control?”  

To answer these, it is helpful to introduce a complementary set of planes, focused not on *what is integrated* but on *how it is operated*. In this book, we will talk about four such planes:

1. The **Observability Plane**: how the estate is instrumented, how signals are collected, stored and made available.  
2. The **Automation & Orchestration Plane**: how changes are made, how workflows are represented and executed.  
3. The **Agentic Intelligence Plane**: how AI models and agents interpret signals, propose actions and sometimes act.  
4. The **Governance & Audit Plane**: how policies, constraints and evidence are expressed and enforced across the others.

These planes are not stacks in the sense of strict layers; they are perspectives on the same underlying systems. A Terraform plan that changes network routing touches automation. The metrics that report the effect of that change live in observability. An Orchestrate agent that suggests the change belongs to agentic intelligence. The policy that says such a change must not move data outside a jurisdiction belongs to governance.

Thinking in planes does not solve the problem by itself. It does, however, provide a way to ensure that each concern is given its due and that the technologies chosen for each are coherent.

***

## 4.3 The Observability Plane: seeing the sovereign estate

The observability plane is the nervous system of sovereign operations. It is how the organisation senses what is happening across its multi‑cloud, multi‑region, multi‑platform environment. Without it, everything else is guesswork.

In simple terms, observability is about telemetry: metrics, logs, traces and events. In practice, for sovereign operations it is also about **context** and **control**.

Context means that telemetry is not just raw data points but is tied to an understanding of what those data points represent. A CPU metric means little on its own; it matters when you know which service, on which cluster, in which region, supporting which business capability, under which sovereignty constraints, is experiencing that load. Tools like IBM Instana place great emphasis on this contextualisation: they automatically discover applications, services, processes, hosts, containers and network paths, building a topology that shows how components relate. [grantthornton](https://www.grantthornton.in/globalassets/1.-member-firms/india/assets/pdfs/observability_and_apm_services_with_ibm_instana.pdf)

Control means that the organisation can decide where telemetry resides and who can access it. In a sovereign context, this is crucial. Telemetry pipelines must respect the same boundaries as the systems they describe. That may mean running observability backends within specific jurisdictions, or federating them across regions, or keeping certain logs local while allowing aggregated views centrally. It may mean ensuring that AI models used for observability—such as Instana’s LLM observability features—operate on data within the right boundaries. [community.ibm](https://community.ibm.com/community/user/blogs/daisuke-hiraoka2/2026/02/04/instana-introduction-to-llm-observability-new-arch)

The observability plane is also increasingly **AI‑aware**. As large language models and other AI components become part of the operational fabric, they generate their own telemetry—prompts, responses, latencies, errors, token usage. Capturing and understanding this is essential for both performance and governance. Instana’s support for OpenLLMetry, for example, reflects this recognition: without structured telemetry from AI systems, their behaviour cannot be observed or managed effectively. [community.ibm](https://community.ibm.com/community/user/blogs/daisuke-hiraoka2/2026/02/04/instana-introduction-to-llm-observability-new-arch)

In this model, the observability plane is not limited to a single tool. It may include cloud‑native monitors from AWS, Azure and GCP; it may integrate existing logging stacks. But there needs to be a **unifying view**—a place where signals come together with consistent semantics. For the purposes of this book, we will treat Instana, augmented where necessary by other sources, as the canonical example of such a view. [grantthornton](https://www.grantthornton.in/globalassets/1.-member-firms/india/assets/pdfs/observability_and_apm_services_with_ibm_instana.pdf)

***

## 4.4 The Automation & Orchestration Plane: changing the system safely

If observability tells us what is happening, automation and orchestration are how we change it. In a sovereign estate, change is both necessary and dangerous. Necessary because systems must evolve, scale, heal and adapt; dangerous because every change is a potential incident and a potential compliance breach.

The automation and orchestration plane has three primary responsibilities.

The first is **infrastructure change**. This is where tools like Terraform and OpenShift GitOps come in. Infrastructure as code allows the organisation to specify the desired state of cloud resources—compute instances, networks, storage, identity policies—in a version‑controlled, reviewable, repeatable way. GitOps patterns ensure that changes are made through pull requests and pipelines rather than through ad‑hoc console clicks, and that the deployed state is continuously reconciled with the declared state.

In a sovereign context, these tools are where many policies are first encoded in executable form. Which regions may be used for which data classes, which network paths are allowed, which identity providers are trusted—these are not just conceptual decisions; they become Terraform modules, Kubernetes manifests and admission controllers.

The second responsibility is **configuration and remediation**. Even with well‑designed infrastructure, services require ongoing configuration, patching and operational adjustments. Red Hat Ansible Automation Platform plays a central role here, orchestrating changes across operating systems, middleware, applications and network devices. In the sovereign operations model, Ansible is not just a tool for sysadmins; it becomes a general‑purpose execution engine that agents can invoke to implement complex multi‑step changes consistently.

The third responsibility is **workflow representation**. Many operational tasks are not single actions but sequences: detect an issue, gather evidence, notify stakeholders, apply a change, verify the result, update tickets, adjust dashboards. Orchestrating these across systems requires more than a pile of scripts. IBM Concert contributes here through its capacity to define and trigger remediation workflows as part of its resilience management capabilities. Watsonx Orchestrate extends this by representing workflows as agents that can be invoked conversationally and can call multiple tools in sequence. [aws.amazon](https://aws.amazon.com/blogs/ibm-redhat/building-agentic-workflows-with-ibm-watsonx-orchestrate-on-aws/)

Crucially, the automation and orchestration plane is where **guardrails** are enforced. Which workflows are allowed to run in which environments? What approvals are required? How are changes rolled back if something goes wrong? How are failures reported and learned from? These questions bridge into the governance plane, but their answers must be encoded here.

***

## 4.5 The Agentic Intelligence Plane: understanding and deciding

The agentic intelligence plane is where AI comes into operations. It is not a separate “AI system” bolted onto the side; it is a perspective on how models and agents interpret the world and participate in decisions.

In this book’s architecture, we can identify three main roles for agentic intelligence.

The first is **interpretation**. Faced with a flood of signals, humans need help picking out what matters. Concert, for example, uses AI to correlate telemetry and configuration data, identify resilience risks, and propose likely root causes for issues. It quantifies resilience posture and highlights applications that are most at risk, not just those currently failing. Similarly, AI‑assisted capabilities in Instana can help distinguish noise from signal in performance data. [nand-research](https://nand-research.com/research-note-ibm-updates-concert-platform/)

The second role is **recommendation**. Interpretation produces an understanding of the situation; recommendation proposes what to do about it. Based on patterns learned from past incidents, known runbooks and SRE practices, systems like Concert can suggest concrete remediation steps. Turbonomic can recommend resource adjustments and workload placements that improve performance and reduce cost without violating policies. Watsonx Orchestrate can encapsulate these into agent behaviours that present options to humans in natural language. [prolifics](https://prolifics.com/usa/resource-center/news/ibm-watsonx-orchestrate-ai-agent-platform)

The third role is **action under supervision**. In bounded contexts, agents can execute workflows end‑to‑end: opening tickets, modifying infrastructure via Terraform, running Ansible playbooks, updating documentation. Orchestrate is designed explicitly for this kind of multi‑agent orchestration, where agents collaborate and hand off tasks to tools and each other. The key is that their actions are monitored, audited and constrained. [aws.amazon](https://aws.amazon.com/blogs/ibm-redhat/building-agentic-workflows-with-ibm-watsonx-orchestrate-on-aws/)

The agentic intelligence plane is where the promise and risk of AI in operations are most concentrated. A well‑designed agent can dramatically reduce time to understanding and time to change. A poorly governed one can make mistakes at machine speed. That is why this plane cannot be considered in isolation. It must be tightly linked to governance, and its scope must be designed deliberately: where should AI only advise, where may it act with approval, and where may it act autonomously?

***

## 4.6 The Governance & Audit Plane: embedding control into architecture

The governance and audit plane is the one that most directly reflects the regulatory drivers discussed in Chapter 3. It is where high‑level intents—sovereignty commitments, resilience requirements, security policies, AI governance rules—are translated into enforceable artefacts.

IBM Sovereign Core is a concrete manifestation of this idea. It is a software foundation that enforces sovereignty *architecturally* rather than contractually. Built on Red Hat OpenShift and designed to run under customer or local operational authority, Sovereign Core keeps identity, encryption keys, logs, telemetry and audit evidence within the sovereign boundary, and it provides a customer‑operated control plane for AI workloads. Sovereignty is not an overlay; it is a property of the platform’s design. [ibm](https://www.ibm.com/products/sovereign-core)

In the broader architecture of this book, the governance and audit plane encompasses:

- **Policy definition**: Expressing rules in forms that machines can understand—policy‑as‑code, infrastructure‑as‑code, guardrail configurations for agents.  
- **Policy enforcement**: Ensuring that when automation runs—whether it is a Terraform plan, an Ansible playbook, a Concert workflow or an Orchestrate agent—the applicable policies are evaluated and honoured.  
- **Evidence collection**: Capturing logs, decisions, actions and outcomes in a way that can be queried and presented to auditors, regulators and internal risk functions.  
- **AI governance**: Tracking models, their training data, their deployment contexts and their behaviour over time; setting constraints on their use; and ensuring explainability for their actions.

Watsonx.governance plays a central role for AI‑related aspects, providing a framework for governing models and AI workloads across the lifecycle. But governance is not limited to AI. It extends to the whole operations fabric. [ibm](https://www.ibm.com/docs/en/watsonx/saas?topic=governing-ai)

An important property of this plane is that it should be **cross‑cutting and provider‑agnostic**. Policies about data residency, access control, approval flows and AI autonomy should not have to be re‑implemented independently for each cloud and tool. They should be expressed once and enforced consistently, using open standards and integrations. This is where the combination of open platforms like OpenShift, open observability standards like OpenTelemetry and OpenLLMetry, and vendor‑neutral policy engines becomes powerful. [ibm](https://www.ibm.com/docs/en/instana-observability/1.0.309?topic=references-getting-started-instana)

***

## 4.7 Mapping IBM technologies into the model

Having outlined the four planes, it is helpful to position key IBM technologies within them. This is not an exercise in branding; it is a way to clarify which tools solve which parts of the problem and how they relate.

- In the **Observability Plane**, IBM Instana is the primary example. It provides real‑time, high‑fidelity observability across hybrid and multi‑cloud environments, automatically discovering services and dependencies and offering 1‑second metric granularity and end‑to‑end tracing. It is complemented by logging and metrics stores as needed, and increasingly by LLM observability via OpenLLMetry. [ibm](https://www.ibm.com/docs/en/instana-observability/1.0.309?topic=references-getting-started-instana)

- In the **Automation & Orchestration Plane**, HashiCorp Terraform (and IBM Cloud Schematics where used), Red Hat OpenShift GitOps, and Red Hat Ansible Automation Platform provide the core execution mechanisms. Concert’s remediation workflows and Orchestrate’s multi‑agent orchestration capabilities sit here as well, describing how sequences of actions are triggered and coordinated across tools. [nand-research](https://nand-research.com/research-note-ibm-updates-concert-platform/)

- In the **Agentic Intelligence Plane**, IBM Concert and IBM watsonx Orchestrate are central. Concert ingests signals, builds resilience scores, surfaces risks and recommends remediation across hybrid and multi‑cloud estates. Orchestrate provides the conversational and multi‑agent interface for executing those remediations through existing systems, with an open, interoperable architecture designed to plug into heterogeneous stacks. [ibm](https://www.ibm.com/products/concert-for-z)

- In the **Governance & Audit Plane**, IBM Sovereign Core represents the architectural enforcement of sovereignty across infrastructure and AI workloads. Watsonx.governance governs models and AI assets. Policy‑as‑code frameworks, identity providers and key management systems, along with orchestrated evidence capture in Concert, complete the picture. [cio](https://www.cio.com/article/4117279/ibm-pushes-sovereign-computing-with-a-software-stack-that-works-across-cloud-platforms.html)

This mapping is not meant to be exhaustive. Many other IBM and non‑IBM components will appear in later chapters. The important point is that each technology should have a clear “home” in the conceptual model, even if it touches multiple planes. That clarity helps prevent both gaps and overlaps.

***

## 4.8 How this model complements hyperscaler architectures

AWS, Azure and Google Cloud each offer their own well‑developed architectural frameworks, reference blueprints and best practices. They have native tools for observability, automation, security and governance. It is natural to ask: why introduce another model? Why not simply follow the guidance of whichever hyperscaler is most important to the organisation?

The answer lies in scope and accountability. Hyperscaler architectures are, understandably, focused on what happens within their own platforms. They do not typically provide a unified view across other clouds, on‑premises environments, mainframe systems and SaaS platforms. Nor do they directly address the socio‑technical dimensions of sovereignty, AI governance and cross‑provider operational resilience.

The model in this chapter is intended to sit **above and across** hyperscaler architectures. It assumes that organisations will continue to use cloud‑native services where appropriate. It does not prescribe which provider to choose for which workload. Instead, it provides a way to ensure that, whatever choices are made, the operations layer remains coherent and sovereign.

IBM’s Sovereign Core is a particularly clear example of this approach. It is explicitly designed to decouple sovereignty from dedicated data centre regions and to provide a software stack that can run under customer or local operational authority across cloud platforms. Similarly, IBM Concert is built to ingest signals from multiple observability tools and ITSM systems, including those native to hyperscalers, and to apply AI and workflow automation across them. Watsonx Orchestrate is engineered as an open, interoperable agent platform that plugs into existing workflows and tools rather than demanding wholesale replacement. [cloudnativenow](https://cloudnativenow.com/features/ibm-adds-sovereign-core-platform-based-on-red-hat-openshift/)

By adopting this model, organisations do not reject hyperscaler architectures; they **complement** them with a control plane that reflects their own sovereignty, governance and multi‑cloud needs.

***

## 4.9 Using the model in practice

A reference model is only useful if it helps guide actual decisions. In the rest of this book, we will use the four planes to structure our exploration of sovereign cloud operations:

- When we discuss observability, we will ask: Does our observability plane provide the context and control we need? Where does Instana fit? How do we handle network observability and AI‑related telemetry?  
- When we discuss automation, we will ask: Are changes expressed as code and workflows in a way that agents can safely execute? How do Terraform, Ansible, Concert and Orchestrate interact?  
- When we discuss agentic operations, we will ask: What decisions are we comfortable delegating to AI, and under what conditions? How do agents consume observability data and invoke automation?  
- When we discuss governance, we will ask: How are sovereignty, resilience and AI policies expressed and enforced? How does Sovereign Core shape the environment? How does watsonx.governance oversee models and agents?

In practical terms, you can use the model as a checklist. For any proposed change—adopting a new tool, designing a new platform, responding to a new regulatory requirement—ask what implications it has for each plane. A decision to centralise logs, for example, has observability and governance implications. A plan to introduce autonomous remediation has ramifications across automation, agentic intelligence and governance.

The model also helps frame conversations between teams. SREs, platform engineers, security architects, data protection officers and AI governance leads do not always share vocabulary. By adopting a shared language of planes and control points, they can more easily locate their concerns within a common map.

Finally, the model is a starting point for **evolution**. As new technologies and regulatory expectations emerge—new forms of AI, new sovereignty requirements, new patterns of workload placement—the planes may accommodate additional sub‑components. The core idea, however, should remain: sovereign cloud operations are not the property of a single tool or team; they are the emergent behaviour of an architecture in which observability, automation, agentic intelligence and governance are designed to work together.

***

### References

 IBM Sovereign Core – Product Overview, IBM. [ibm](https://www.ibm.com/products/sovereign-core)
 “Introducing IBM Sovereign Core: A new software foundation for sovereignty,” IBM Newsroom, 2026. [ibm](https://www.ibm.com/new/announcements/introducing-ibm-sovereign-core-a-new-software-foundation-for-sovereignty)
 “IBM launches Sovereign Core as the foundation for sovereign cloud and AI,” Techzine Europe, 2026. [techzine](https://www.techzine.eu/news/privacy-compliance/137981/ibm-launches-sovereign-core-as-the-foundation-for-sovereign-cloud-and-ai/)
 “IBM pushes sovereign computing with a software stack that works across cloud platforms,” CIO, 2026. [networkworld](https://www.networkworld.com/article/4117292/ibm-pushes-sovereign-computing-with-a-software-stack-that-works-across-cloud-platforms-2.html)
 “What is Sovereign Cloud?” IBM Think. [ibm](https://www.ibm.com/think/topics/sovereign-cloud)
 “Research Note: IBM Updates Concert Platform,” NAND Research, 2025. [newsroom.ibm](https://newsroom.ibm.com/announcements)
 IBM Concert for Z – Product Page. [newsroom.ibm](https://newsroom.ibm.com/2025-07-02-deutsche-telekom-selects-ibm-concert-to-accelerate-it-processes-with-ai-powered-automation)
 IBM Concert Technical Architecture on AWS – Session Recording. [youtube](https://www.youtube.com/watch?v=05uJurgrrtE)
 “Observability and APM services with IBM Instana,” Grant Thornton. [nand-research](https://nand-research.com/research-note-ibm-updates-concert-platform/)
 “Getting started with Instana,” IBM Documentation. [ibm](https://www.ibm.com/new/announcements/new-agentic-workflows-and-domain-agents-in-ibm-watsonx-orchestrate)
 “Instana Introduction to LLM Observability – New Architecture,” IBM Community. [ibm](https://www.ibm.com/docs/en/watsonx/saas?topic=governing-ai)
 Instana Observability integration with Turbonomic – IBM. [ibm](https://www.ibm.com/products/turbonomic/integrations/instana-observability)
 “A Turbonomic and Instana use case,” IBM. [ibm](https://www.ibm.com/new/product-blog/a-turbonomic-and-instana-use-case)
 “Building Agentic Workflows with IBM watsonx Orchestrate on AWS,” AWS & IBM Red Hat Blog. [heidloff](https://heidloff.net/article/watsonx-governance/)
 “IBM watsonx Orchestrate – Unite AI Agents for Success,” Prolifics. [ibm](https://www.ibm.com/docs/en/concert?topic=overview-introduction-concert)
 watsonx.governance documentation and implementation guides, IBM. [ibm](https://www.ibm.com/think/insights/ai-governance-implementation)
