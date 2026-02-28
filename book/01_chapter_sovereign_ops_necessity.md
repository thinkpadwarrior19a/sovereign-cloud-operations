# Chapter 1 — The Sovereign Cloud Operations Necessity

***

## Summary

This chapter argues that the convergence of multi-cloud complexity, binding regulatory mandates and the limitations of dashboard-centric operations creates a structural necessity for a new operational model built around sovereignty, AI-assisted intelligence and zero-copy integration. It introduces operational sovereignty as the governing principle — concerned not merely with where data resides but with who can act on which systems, from which jurisdictions, under which policies — and traces the regulatory foundations in DORA, ENISA guidance and EBA requirements. The chapter makes the case for agentic operations, in which conversational AI systems correlate signals, propose remediations and execute approved changes, shifting human engineers from repetitive execution into supervisory and design roles. It positions IBM Concert and watsonx Orchestrate as a cross-cloud control and intelligence plane that spans hyperscaler estates rather than replacing them, and introduces shift-left operations and organisational culture as co-equal determinants of success alongside the technical architecture.

***

## 1.1 The limits of yesterday's "cloud success"

For many organisations, the past decade of cloud adoption has looked like progress. Data centres have thinned out. New features ship faster. Teams can spin up infrastructure with a few lines of code. Dashboards are abundant; alerts are plentiful; incident bridges are busy but mostly under control. On paper, the story is one of modernisation.

Beneath that surface, however, uncomfortable patterns have emerged. Integration has grown more complex, not less. Data exists in more places, under more regimes, with more copies than anyone can confidently count. Operational practices that worked when systems were fewer, simpler and less entangled have begun to creak under the strain. The fact that the organisation can usually "get through" incidents is less reassuring than it once was, because each incident feels harder to understand and more expensive to resolve than the last.

At the same time, the stakes have risen. Critical business processes now depend on chains of services that span multiple public clouds, on‑premises systems, SaaS platforms and partner APIs. Regulatory expectations have shifted from "have a disaster recovery plan" to "demonstrate continuous operational resilience and control". Customers, regulators and boards are asking sharper questions about where data lives, who operates the systems that handle it, and how AI is used in making operational decisions.

In this environment, incremental tuning of existing practices is no longer enough. The organisation needs a different way to think about operations: one that treats sovereignty, AI and multi‑cloud not as afterthoughts, but as defining constraints; one that recognises the centrality of the network and real‑time integration; and one that acknowledges that human attention is the scarcest operational resource of all.

***

## 1.2 From infrastructure sovereignty to operational sovereignty

The term "sovereign cloud" entered the vocabulary as a way of describing clouds that respected national or regional control over data. Early discussions focused on physical location: data must remain within the EU, within a particular country, or within a designated "trusted" region. Providers responded with region‑specific offerings and, in some cases, with facilities operated by local partners.

That focus on where data sits was a necessary first step, but it is no longer sufficient. As architectures have become more distributed and as regulators have become more sophisticated, a more demanding concept has emerged: **operational sovereignty**.

Operational sovereignty is less concerned with where bits rest and more concerned with **who can do what to which systems under which laws, and how those actions are governed**. It asks:

- Who has administrative access to production systems, from which locations and under which jurisdictions?
- How are incidents handled at three in the morning, and which people and tools are involved?
- Where are logs, metrics and traces stored, and who can query them?
- Where do AI models that have seen sensitive data run, and who can steer their behaviour?
- How are failover and recovery decisions made when they involve crossing national or provider boundaries?

These questions have moved from theoretical to legally enforceable. The European Union Agency for Cybersecurity (ENISA) has published detailed guidance establishing that cloud security must encompass not merely the physical location of data, but the operational controls, access management and jurisdictional governance that determine who can act on systems and their data at any point in the operational lifecycle [1]. At the same time, the Digital Operational Resilience Act (DORA), Regulation (EU) 2022/2554, has set a new benchmark for financial entities operating within the EU, requiring not only that ICT risks be managed but that firms demonstrate continuous, documented control over their operational processes, including those delivered through third‑party cloud providers [2]. The European Banking Authority's Guidelines on ICT and Security Risk Management (EBA/GL/2019/04) reinforce this by mandating that institutions maintain clear governance accountability for every element of their ICT supply chain, including the cloud‑hosted services that increasingly form its core [3].

Infrastructure sovereignty—choosing appropriate regions and providers—remains important. But it is only one layer. If, during an incident, an engineer or an AI agent acting from an unregulated environment can override critical protections, or if telemetry quietly flows into a service under a foreign jurisdiction, the sovereignty story weakens. Likewise, if models trained on sovereign data are invoked from contexts that are not covered by the original consent or regulatory assumptions, sovereignty is compromised in practice, regardless of storage location.

Operational sovereignty, then, is about the lived behaviour of the system over time. It is about the operating model and the control plane, not just about the infrastructure map.

***

## 1.3 Why dashboard‑centric operations are running out of road

For a while, the primary response to growing complexity was to add more dashboards. Each new system, each new provider, each new tool came with its own graphical view of health: CPU and memory graphs here, error rates and latency percentiles there, ticket queues in another place, network utilisation in yet another. Operations centres filled with screens; engineers learned to navigate multiple consoles in parallel.

This dashboard‑centric approach is now hitting its limits, for several reasons.

First, **volume**. The number of signals has grown faster than human capacity to interpret them. A single incident can generate hundreds or thousands of alerts across tools, many of them redundant, noisy or misleading [4]. Filtering these down to the few that matter is itself a job—one that Gartner has identified as a primary driver of alert fatigue in enterprise operations teams, a condition that directly reduces the speed and accuracy of incident response [5].

Second, **fragmentation**. Each dashboard tends to reflect one slice of reality: application metrics, database performance, network health, security events, business KPIs. Very few show how these slices fit together. Constructing that holistic picture is left to human operators jumping between tools, copying links into chat, and reconciling conflicting narratives.

Third, **context decay**. Dashboards are snapshots. They rarely show the full history of how the system arrived in its current state: what changes were made, which policies were updated, what previous incidents occurred in this area, how traffic patterns have evolved. Operators spend significant time retrieving this context from tickets, Git histories, change calendars and colleagues' memories. Research published through the DORA State of DevOps programme consistently identifies context fragmentation and cognitive overload as principal contributors to increased change failure rates and slower mean times to restore service [6].

Fourth, **cognitive overload**. In a high‑stakes incident, engineers must process a flood of visual information, recall relevant technical details, remember regulatory constraints and coordinate with others—all under time pressure. The more dashboards they must consult, the harder it is to think clearly about trade‑offs, let alone to consider sovereignty implications. Beyer and colleagues, in Google's canonical *Site Reliability Engineering* text, describe this condition precisely: the fundamental tension in operations is that as systems become larger and more complex, the cognitive demands of understanding them grow faster than any individual's capacity to respond, which is the argument for building systems that explain themselves rather than systems that merely display data [7].

In a zero‑copy, highly distributed environment, these issues become acute. When more interactions depend on live data access across services and locations, the number of ways things can go wrong multiplies. Problems may manifest as subtle latency increases, intermittent failures or shifts in traffic patterns that are hard to spot on any single dashboard. By the time the pattern is obvious, the impact may already be significant.

The conclusion is not that dashboards are worthless; they remain important tools. But as the primary interface to operations, they are no longer adequate. The system needs a way to *understand itself* and to present that understanding to humans in a more structured, conversational, context‑rich way.

***

## 1.4 Zero‑Copy Integration as a prerequisite for modern operations

This book stands on the conceptual foundation of **Zero‑Copy Integration**: the idea that, wherever possible, systems should access data where it resides rather than copying it into new silos; that state changes should be propagated as events rather than as bulk synchronisation; and that data access should be governed through a unified control plane rather than through a patchwork of point‑to‑point integrations.

Zero‑copy matters operationally for several reasons.

First, it **reduces the number of moving parts**. Every time data is copied into a new system, the organisation creates a new failure domain: another place where data can be inconsistent, another set of jobs that can stall or fail, another platform that must be monitored and patched. Over time, these copies accumulate into a tangle of dependencies that are difficult to reason about under pressure. Reducing unnecessary copies simplifies the landscape that operations must control. Kleppmann, in his foundational treatment of distributed systems design, articulates this directly: unbounded data replication is both a reliability liability and a governance problem, because each additional copy creates a new site of divergence that must be reconciled, and reconciliation under failure conditions is among the most reliably underestimated problems in systems engineering [8].

Second, it **improves the quality of signals**. In copy‑heavy architectures, many operational questions—"What was the state of this customer's data at this time?" "Which transactions were affected?"—must be answered by reconstructing flows through multiple pipelines and stores. In a zero‑copy model, where more access is direct and more changes are events, the lineage of actions is clearer. It becomes easier to see which system used which data, when and under what policy.

Third, it **raises the bar on real‑time behaviour**. When applications and analytical systems rely less on nightly batches and more on live queries and streams, the performance and reliability of the underlying fabric—network, services, policies—becomes central. Operations can no longer hide behind the buffers provided by copies; they must ensure that the live system behaves well.

From an economic perspective, zero‑copy reduces the "integration tax" of storage, processing and compliance associated with uncontrolled replication. From a sovereignty perspective, it reduces the number of places where sensitive data resides, making it easier to control and audit. From an operational perspective, it creates a foundation on which a more intelligent control plane can be built.

This book assumes that the reader either has embarked on a zero‑copy journey or recognises its architectural necessity. The focus here is not on re‑arguing that case, but on answering the next question: once you have—or intend to have—a zero‑copy, multi‑cloud architecture, how do you operate it sovereignly, reliably and at scale?

> **[FIGURE 1.1 — The operational gap: complexity and regulation outpacing traditional operating models]**
>
> As the number of services, providers and sovereign constraints grows linearly, the cognitive and governance burden placed on dashboard-centric, manual operations grows super-linearly, creating an expanding gap that only an intelligent control plane can close.

***

## 1.5 The rise of agentic operations: from dashboards to dialogue

As systems have become more complex, a quiet shift has begun in how leading organisations think about operations. Instead of assuming that humans will continue to trawl dashboards and execute runbooks manually, they are exploring models in which AI‑driven agents and automation play a central role, with humans acting as designers, supervisors and final decision‑makers. IBM Research has characterised this transition as the emergence of AI for IT Operations (AIOps), documenting how cognitive automation platforms can correlate heterogeneous telemetry, detect anomalous patterns across complex topologies and generate actionable recommendations at a speed and scale that manual approaches cannot match [9]. Gartner's AIOps Market Guide similarly identifies the shift from reactive monitoring to predictive, AI‑assisted operational intelligence as among the most significant platform transformations underway in enterprise technology [10].

The idea is simple but powerful: **replace the wall of dashboards with a conversation**.

In this model, an operations engineer does not start an incident by opening six tools. They start by asking a question: "What's going on with the payments service in Europe?" An operational assistant, with access to topology, metrics, logs, tickets and change history, responds: "Error rates from the payments API increased from 0.1% to 3% in the last ten minutes, correlated with a configuration change on the API gateway in region X. Latency on a cross‑cloud link between your front‑end in provider A and back‑end in provider B has also increased. Similar incidents occurred in March and July; in both cases, rolling back the gateway change and adjusting a routing policy resolved the issue."

The engineer can then ask follow‑up questions, request more detail or instruct the system to propose remediation plans. Those plans are expressed in terms of concrete actions: Terraform changes, Ansible playbooks, API calls, ITSM tickets, Git pull requests. The assistant can draft them, show the impact it expects, and ask for approval. Once approved, it can execute them, monitor the effect, and update the relevant records.

To make the pattern concrete, consider a scene that is increasingly realistic. It is 02:47 on a Tuesday morning. The on-call engineer, Priya, receives a PagerDuty notification: the payments service in the Frankfurt region has degraded, error rates climbing. Rather than opening five browser tabs, she opens the Concert conversational interface and types: "What is happening with payments in Frankfurt?" Within seconds, the system responds with a structured account. It has correlated the error spike with a configuration drift on the API gateway cluster, which diverged from its declared state twelve minutes ago following an automated certificate rotation job. It has identified that two prior incidents this quarter showed identical precursor patterns, and that in both cases the resolution involved re-synchronising the gateway configuration from the Git-held source of truth, a change that takes approximately four minutes to propagate. It notes that a Terraform plan is already staged in the relevant repository and offers to raise a pull request for Priya's review. She reads the diff, approves it, and watches the error rate fall back towards baseline—all without consulting a single dashboard or waking a second engineer. The entire exchange, from alert to resolution, takes eleven minutes.

This is not science fiction; it is the direction in which IBM Concert and IBM watsonx Orchestrate are pointed. Concert acts as the **operational brain**, continuously building a model of the estate and correlating signals. Orchestrate acts as the **conversational interface and workflow engine**, able to call tools, trigger pipelines, and update systems on behalf of users. Together, they enable a mode of working in which the default interaction with operations is through **dialogue with a system that understands the environment**.

Agentic operations do not remove humans from the loop. They change the loop. Instead of humans doing most of the correlation and execution work, they design workflows, define guardrails, review and approve actions, and intervene when the unexpected occurs. They spend more time specifying *what* good looks like and *why* certain behaviours are desired, and less time on repetitive mechanics.

***

## 1.6 IBM's role as a cross‑cloud control and intelligence plane

Most of the readers of this book will not be operating in an IBM‑only environment. They will have significant, often dominant, investments in AWS, Azure, Google Cloud and on‑premises infrastructure. They will use each provider's native services and tools where those make sense. They will run SaaS platforms and partner integrations that are not under their direct control.

The question is not whether to replace these with IBM Cloud; it is how to **govern and operate them coherently**.

IBM's sovereign operations story is therefore deliberately positioned as a **control and intelligence layer that spans providers**, rather than as a replacement for them. In practice, this means:

- Concert discovers and models services running on multiple clouds and in data centres, using telemetry, configurations and integrations to understand dependencies. It does not insist that workloads move; it insists on seeing them [11].
- Instana, often in combination with existing observability tools, provides a consistent view of application and network behaviour across environments, so that the same operational questions can be asked everywhere [12].
- Turbonomic uses this telemetry to make optimisation recommendations and, where appropriate, take action on placement, scaling and resource allocation across clouds and clusters [13].
- Orchestrate expresses workflows in terms of tools—Terraform, Ansible, ServiceNow, Jira, GitHub, GitLab, Kubernetes APIs—so that automation acts through the interfaces the organisation already trusts, whether those touch AWS, Azure, GCP or IBM Cloud [14].
- Bob operates against the Git repositories that define infrastructure and applications, regardless of which cloud they target, helping encode best practice, sovereignty constraints and operational knowledge into code [15].

This architecture respects the reality that **hyperscalers provide the bulk of compute and storage**, and likely will continue to do so. IBM's value lies in enabling a sovereign, intelligent, AI‑augmented operations layer on top of that reality: one that treats the estate as a whole, not as a set of silos.

***

## 1.7 Human factors: shift‑left operations and trust in automation

No amount of tooling will deliver sovereign operations if the human system around it is not ready. Agentic operations, zero‑copy architecture and multi‑cloud control planes require **changes in how people think about their work**, not just in what screens they look at.

A central theme in this book is **shift‑left operations**. Traditionally, operations considerations—resilience, monitoring, runbooks, capacity, sovereignty—have often been addressed late: after systems are designed, sometimes after they are built, occasionally only after they have failed. This pattern produces brittle systems and reactive cultures. Forsgren and colleagues, in *Accelerate*, document with empirical rigour that the organisational practices associated with high software delivery performance—continuous integration, deployment automation, monitoring driven by business outcomes, and loosely coupled, team-owned architectures—are not independent variables but are deeply intertwined with the culture and information-flow patterns of the organisation itself [6]. Westrum's organisational culture model, applied to technology organisations, distinguishes pathological, bureaucratic and generative cultures; research consistently shows that generative cultures—characterised by the free flow of information, shared accountability and willingness to surface problems—are the enabling condition for high operational performance rather than a by-product of it [16].

Shifting left means bringing operational thinking into design and development. When a new service is conceived, teams already consider:

- How will it be observed? Which metrics, logs and traces matter, and where will they be stored?
- How will it behave under failure? What are its dependencies, and how can it degrade gracefully?
- What sovereignty constraints apply? Where may its data and telemetry live? Who may operate it?
- What automation is required for deployment, configuration, remediation and retirement?
- How might agents assist in its operation, and what guardrails should apply?

Practically, this means SREs, platform engineers, security architects and compliance specialists working with developers early, using shared artefacts: architecture diagrams, policy‑as‑code modules, Terraform definitions, Kubernetes manifests, Orchestrate workflows. It means that "operational readiness" is not a checklist before go‑live, but a continuous concern throughout the lifecycle.

Trust in automation is the other human dimension. Engineers are understandably wary of agents that can modify production systems. That wariness is healthy; it prevents reckless adoption. To make agentic operations sustainable, organisations must build **transparent, predictable relationships between humans and agents**.

That starts with clear levels of autonomy. At one extreme, agents only suggest, never act. At an intermediate level, they may act automatically in low‑risk scenarios but require approval for high‑impact changes. At the other extreme, in well‑understood contexts, they may act autonomously within tight boundaries. The key is that these levels are explicit, configurable and visible.

Transparency is crucial. Engineers should be able to see what an agent plans to do, why it thinks that is appropriate, what evidence it is relying on, and how it will roll back if something goes wrong. When agents make mistakes or are overridden, those events should feed back into learning processes—not as grounds for blame, but as data for improving workflows, models and guardrails.

Psychological safety underpins all of this. If people fear that admitting an automation misstep will harm their careers, they will hide problems and resist experimentation. If, instead, the organisation treats incidents as opportunities to learn and improve, and recognises that judicious use of automation is a mark of professionalism, not laziness, trust can grow.

The later chapters of this book will return to these themes in more detail when discussing operating models, skills and maturity. They are introduced here because **without them, the technical architecture described in the rest of the book cannot succeed**.

***

## 1.8 What this book will cover—and how to use it

This book is not a product catalogue. It does not attempt to document every option in IBM Concert's configuration, every connector available to watsonx Orchestrate, or every metric that Instana can collect. Those details will change with every release cycle. Instead, the book focuses on **architectural patterns, design principles and operating models** that can survive the evolution of products and the emergence of new tools.

The structure is deliberately layered.

Part I, which this chapter begins, makes the case for change. It describes why sovereign cloud operations are necessary in light of economic, regulatory and architectural realities. Chapter 2 examines the economics; Chapter 3 explores the regulatory drivers and the operational governance they imply.

Part II introduces the **architectural reference model**: the planes—observability, automation & orchestration, agentic intelligence, governance & audit—that together constitute a sovereign operations control plane, and how they relate to the zero‑copy integration architecture you may already know.

Subsequent parts dive deeper into each plane: observability and network performance; automation via infrastructure and configuration as code; Concert as the operational brain; Orchestrate as the conversational, multi‑agent interface; watsonx.governance as the AI governance layer; agentic DevOps and GitOps; conversational and autonomous operations patterns; and, finally, operating model, skills, blueprints and case studies.

You do not need to read the book linearly. The chapters are written to be referenced independently. A CIO might focus on the strategy, economics, regulatory and operating‑model chapters. A platform team might concentrate on topology, observability, Concert and Orchestrate. An SRE team might jump directly to the chapters on network observability, agentic incident response and self‑healing patterns.

What unifies the whole is a single proposition: **in a world of zero‑copy data, multi‑cloud infrastructure, stringent sovereignty requirements and pervasive AI, the only sustainable path is to build a sovereign cloud operations control plane that is as thoughtfully designed as the applications it supports**. This chapter has sketched why that proposition matters. The rest of the book is about how to make it true in practice.

***

## Key Takeaways

- Operational sovereignty extends well beyond the physical location of data: it encompasses who can access and act upon systems, from which jurisdictions, under which policies, and how those actions are governed in real time—requirements that regulators including ENISA, DORA and the EBA have now made legally binding for financial entities across the EU [1][2][3].

- Dashboard‑centric operations are structurally ill-suited to modern, distributed environments: the volume, fragmentation and context decay of multi-tool monitoring creates cognitive overload that degrades both the speed and the quality of incident response, a finding supported by empirical research from both Google's SRE practice and the DORA State of DevOps programme [6][7].

- Zero‑Copy Integration is both an architectural principle and an operational prerequisite: by reducing unnecessary data replication, it simplifies the failure surface, improves data lineage and tightens the audit trail—making the environment easier to govern and easier for automated systems to reason about [8].

- Agentic operations—the replacement of passive dashboards with active, conversational AI systems that understand topology, correlate signals and propose or execute remediation—represent a qualitative rather than incremental advance in operating model capability, moving human engineers from execution work to supervisory and design roles [9][10].

- IBM Concert and watsonx Orchestrate are designed as cross-cloud control and intelligence planes, not as replacements for hyperscaler infrastructure: their value lies in providing coherent governance, observability and AI-assisted operations across environments that the organisation has no intention of consolidating [11][14].

- Organisational culture is not a soft addendum to technical architecture; it is a co-equal determinant of operational outcomes. Generative cultures characterised by psychological safety, free information flow and blameless learning are the enabling condition for both shift-left operations and trusted automation [6][16].

- The practical path to sovereign cloud operations combines three disciplines in sequence: establish the architectural foundation (zero-copy, multi-cloud, policy-as-code); build the intelligent control plane (observability, agentic intelligence, governance); and cultivate the human system that can design, supervise and improve it over time.

***

## Chapter summary and bridge

This chapter has argued that the forces driving organisations towards a new operating model are not primarily technological fashions but structural necessities: regulatory frameworks with legal force, architectural realities that outpace manual operations, and economic pressures that demand efficiency without compromising control. The concept of operational sovereignty—governing who does what, from where, under which rules—provides the framing within which the technical and organisational arguments cohere. Dashboard-centric operations, the dominant practice of the past decade, cannot meet these demands. Neither can architectures built on uncontrolled data replication. And neither can cultures that treat operations as a downstream concern of development.

Chapter 2 will ground these arguments in economics, examining the measurable costs of the current model—integration tax, incident cost, compliance overhead, talent drain—and the financial case for investing in the sovereign operations control plane described here. Chapter 3 will map the regulatory landscape in greater detail, examining how DORA, the EU AI Act, the Network and Information Security Directive and sector-specific requirements interact to produce the governance obligations that operational sovereignty must satisfy. Together, those two chapters complete the case for change before the book turns, in Part II, to the architecture and practice of building the control plane itself.

***

## References

[1] European Union Agency for Cybersecurity (ENISA), *Cloud Security for the EU: Security Framework for Cloud Services*, ENISA, Heraklion, Greece, 2021. [Online]. Available: https://www.enisa.europa.eu/publications/cloud-security-for-the-eu

[2] European Parliament and Council of the European Union, *Regulation (EU) 2022/2554 of the European Parliament and of the Council on digital operational resilience for the financial sector (DORA)*, Official Journal of the European Union, L 333, pp. 1–79, Dec. 2022.

[3] European Banking Authority, *Guidelines on ICT and Security Risk Management*, EBA/GL/2019/04, EBA, Paris, France, Nov. 2019. [Online]. Available: https://www.eba.europa.eu/regulation-and-policy/internal-governance/guidelines-on-ict-and-security-risk-management

[4] V. Morin, "Alert fatigue in IT operations: how noise undermines reliability," *IEEE Software*, vol. 38, no. 2, pp. 14–18, Mar./Apr. 2021.

[5] Gartner, *Market Guide for AIOps Platforms*, Gartner Research, Stamford, CT, USA, 2023.

[6] N. Forsgren, J. Humble, and G. Kim, *Accelerate: The Science of Lean Software and DevOps*, IT Revolution Press, Portland, OR, USA, 2018.

[7] B. Beyer, C. Jones, J. Petoff, and N. R. Murphy, Eds., *Site Reliability Engineering: How Google Runs Production Systems*, O'Reilly Media, Sebastopol, CA, USA, 2016.

[8] M. Kleppmann, *Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems*, O'Reilly Media, Sebastopol, CA, USA, 2017.

[9] IBM Research, *AI for IT Operations: Foundations and Applications*, IBM Research Report RZ3998, IBM, Armonk, NY, USA, 2020.

[10] Gartner, *AIOps Market Guide: Applying AI to IT Operations*, Gartner Research, Stamford, CT, USA, 2024.

[11] IBM, *IBM Concert Product Documentation: Service Discovery and Topology Modelling*, IBM Corp., Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/concert

[12] IBM, *IBM Instana Observability: Architecture and Capabilities*, IBM Corp., Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/instana-observability

[13] IBM, *IBM Turbonomic: Workload Optimisation and Resource Management*, IBM Corp., Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/tarm

[14] IBM, *IBM watsonx Orchestrate: Workflow Automation and Conversational AI*, IBM Corp., Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/watsonx/watson-orchestrate

[15] IBM, *IBM watsonx Code Assistant for Z and Hybrid Cloud (Bob): Documentation*, IBM Corp., Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/watsonx-code-assistant

[16] R. Westrum, "A typology of organisational cultures," *Quality and Safety in Health Care*, vol. 13, suppl. 2, pp. ii22–ii27, Dec. 2004.
