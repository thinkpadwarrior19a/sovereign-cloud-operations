# Chapter 5 — Multi‑Cloud Topology, Network, and Sovereign Zones

***

## 5.1 Why topology is no longer a background detail

Topology used to be something architects sketched late in the project—an arrangement of boxes and lines to reassure stakeholders that redundancy existed and traffic could flow. In a sovereign, zero‑copy, multi‑cloud world, topology moves from the margin to the centre. It becomes a primary design variable for performance, resilience and compliance.

The reason is straightforward: when more interactions are real‑time and more systems are distributed, **where** things are and **how** they are connected determine not just latency and cost, but also whether the organisation is capable of honouring its commitments under stress. A beautifully modular application running in the wrong place, connected by fragile or non‑compliant network paths, is a liability.

This chapter explores how to think about topology in this new context. It introduces the idea of **sovereign zones** as a fundamental unit of placement, shows how network behaviour constrains what can be done across providers, and examines how IBM’s Sovereign Core and related technologies provide a practical substrate for implementing these ideas in hybrid and multi‑cloud estates. [ibm](https://www.ibm.com/new/announcements/introducing-ibm-sovereign-core-a-new-software-foundation-for-sovereignty)

***

## 5.2 Sovereign zones: more than just regions

Cloud providers give us regions and availability zones. Regulators give us jurisdictions and supervisory boundaries. Architects talk about domains and trust zones. In practice, these concepts overlap but do not neatly align.

For the purposes of sovereign cloud operations, it is useful to define a **sovereign zone** as a slice of the estate within which:

- A single set of legal and regulatory obligations applies;  
- Operational control is exercised by a clearly defined set of entities under those obligations; and  
- Data residency, telemetry flows, identity, keys and AI inference are constrained to stay within agreed boundaries, except where explicitly and auditedly permitted.

A sovereign zone might coincide with a country (for example, a German sovereign zone for workloads subject to BaFin and BSI guidance), a region (an EU‑wide zone for GDPR and DORA), or a sector‑specific boundary (a public sector zone with particular classification rules). It might be implemented using one or more cloud regions, on‑premises data centres, or combinations thereof.

The critical point is that a sovereign zone is not just a geographical or provider construct; it is an **operational construct**. It incorporates decisions about:

- Who operates the control plane and under what jurisdiction;  
- Where identity providers and key management systems live;  
- How logs and telemetry are stored and accessed;  
- Where AI models run and where agents can act.

IBM’s Sovereign Core embodies this concept. It provides a **customer‑operated control plane** that can be deployed into various environments—on‑premises, partner clouds, hyperscalers—while keeping identity, encryption keys, logs, telemetry and audit evidence entirely within the sovereign boundary. Sovereignty is enforced architecturally, not as an after‑the‑fact overlay. [ibm](https://www.ibm.com/products/sovereign-core)

In the topology of a large enterprise, there will usually be **multiple sovereign zones**, each with its own constraints and risk profile. The challenge is not only to design each zone well, but also to manage the relationships between them.

***

## 5.3 The network as the integration fabric

Once sovereign zones are defined, the next question is how they are connected. In a zero‑copy architecture, the network is not a utility in the background; it is the **integration fabric**. Queries, API calls and events flow across it. The performance and reliability of those flows are directly visible to users and to downstream systems.

In single‑cloud designs, network design is often simplified by the provider’s internal backbone. Traffic stays within the provider’s network, and latencies are relatively predictable. Multi‑cloud architectures are different. Every cross‑provider interaction is one more dependency on the public internet or on direct interconnects. As commentators on multi‑cloud architectures have noted, network bandwidth and latency quickly become the bottleneck for distributed systems that assume cheap, reliable connectivity. [innovationatwork.ieee](https://innovationatwork.ieee.org/the-multi-cloud-challenges-and-solutions/)

In a sovereign context, the network is also a **control surface**. It is how the organisation ensures that data flows only along permitted paths. It is how it segments environments with different classification levels. It is how it enforces constraints such as “this traffic may only traverse domestic infrastructure” or “this class of telemetry must never leave the sovereign zone.”

This has several implications:

- Topology cannot be drawn without considering real‑world latency and bandwidth, especially for chatty protocols and federated queries.  
- Network paths between sovereign zones must be treated as scarce, governed resources, not as unbounded pipes.  
- Observability and control of network behaviour must be first‑class concerns, not left until after application design is complete.

IBM’s own cloud services illustrate this recognition. For example, hosting Power‑based workloads and their data in the same IBM Cloud data centre is explicitly positioned as a way to achieve sub‑5 millisecond latencies, reduce costs and support chatty enterprise applications. The same principle—co‑locating tightly coupled components and minimising cross‑boundary chatter—applies across providers and sovereign zones. [ghsystems](https://www.ghsystems.com/blog/data-gravity-latency-ibm-cloud-is-designed-for-power-based-workloads)

***

## 5.4 Latency budgets, data gravity and placement

When designing topology for sovereign operations, it is helpful to think in terms of **latency budgets** and **data gravity**.

A latency budget is an explicit statement of how much time can be spent in each part of an end‑to‑end interaction while still meeting a service‑level objective. For a web request that must complete in, say, 300 milliseconds, a rough budget might allocate 50 ms to network round‑trip overhead, 150 ms to application logic, 50 ms to database access and 50 ms to downstream API calls. Those numbers will vary, but the act of budgeting forces teams to confront the reality that not all components can be far apart.

Data gravity is the tendency of large datasets to pull computation toward them. Moving computation (for example, analytic queries or models) to where the data is is often cheaper and faster than moving the data to the computation. In multi‑cloud environments, data gravity interacts with network economics (egress fees) and sovereignty to create “wells” around which topology must be arranged.

In sovereign operations, latency budgets and data gravity intersect with sovereignty in interesting ways. For example:

- A dataset containing EU personal data may have to remain in an EU‑based sovereign zone. Applications that need low‑latency access may therefore need to be deployed within that zone or very close to it.  
- A real‑time risk scoring service may need to respond within tens of milliseconds. If its model is trained on sensitive data and must run within a sovereign boundary, calling it from a far‑away frontend may be infeasible; the frontend may need to be brought closer, or caching and degraded‑mode strategies devised.  
- Cross‑zone analytics that bring together data from multiple jurisdictions may need to use federated query engines that execute where the data lives, returning only aggregates or anonymised results. [ibm](https://www.ibm.com/think/topics/sovereign-cloud)

Turbonomic provides a concrete example of how these considerations can be codified. Its placement policies allow organisations to define logical boundaries and segments—such as clusters or regions—within which workloads should be placed, taking into account cluster boundaries, networks and data stores. In a sovereign architecture, these policies can reflect latency budgets and sovereignty constraints, guiding automated decisions about where services should run. [ibm](https://www.ibm.com/docs/en/tarm/8.18.0?topic=policies-placement)

The key point is that **topology and placement are not purely technical optimisation problems**. They are where performance, cost and sovereignty intersect. They must therefore be designed and tuned with input from architecture, operations, risk and compliance.

***

## 5.5 Implementing sovereign zones with OpenShift and Satellite

If sovereign zones are the conceptual unit, we need a practical way to realise them across diverse infrastructure. Red Hat OpenShift and IBM Cloud Satellite provide such a mechanism.

OpenShift offers a consistent Kubernetes‑based platform that can run on bare metal, virtualised environments, private clouds and all major public clouds. Satellite extends IBM Cloud’s control plane to customer locations—on‑premises data centres, other cloud providers or edge sites—allowing IBM Cloud services to be run on customer‑owned infrastructure while being managed from a single pane of glass. [linkedin](https://www.linkedin.com/pulse/ibm-cloud-satellite-openshift-virtualization-sharad-chandra-leyvc)

In a sovereign operations architecture, a sovereign zone can be implemented as:

- One or more OpenShift clusters running within a specific jurisdiction, on hardware under controlled operational authority, with local identity and key management.  
- An IBM Sovereign Core deployment providing the control plane for those clusters, keeping identity, keys, logs, telemetry and audit evidence inside the zone. [crn](https://www.crn.com/news/ai/2026/ibm-s-sovereign-core-software-foundation-set-to-give-partners-more-control-over-ai)
- Satellite locations and related networking configured so that workloads in the zone can access necessary IBM Cloud services (for example, management services or AI tooling) without exposing sensitive data or control planes to external operators. [linkedin](https://www.linkedin.com/pulse/ibm-cloud-satellite-openshift-virtualization-sharad-chandra-leyvc)

This pattern allows organisations to deploy **AI‑ready, sovereign‑enabled environments** that remain under their own or a trusted partner’s control, while still benefiting from automation and consistency. It also allows them to replicate that pattern across multiple zones—national deployments, sectoral zones, partner‑operated environments—without reinventing the wheel each time. [fierce-network](https://www.fierce-network.com/cloud/ibm-drills-down-core-sovereign-ai-problem)

From a topology perspective, the important thing is that **each sovereign zone looks similar from an operational standpoint**. The details of the underlying hardware and local networks may differ, but the way workloads are deployed, observed and governed is consistent. This consistency simplifies both operational tooling and human practice.

***

## 5.6 Network observability and secure connectivity

Designing topology is only half the story; the other half is being able to see and manage how it behaves in production. Network observability is therefore a first‑class requirement.

Instana’s full‑stack observability includes network monitoring and topology visualisation. It can show how services communicate, how requests traverse nodes and clusters, and where latency or errors are introduced. This is essential for understanding the behaviour of cross‑cloud and cross‑zone interactions. When a service in one sovereign zone depends on another in a different zone or provider, the path between them must be visible. [youtube](https://www.youtube.com/watch?v=lb3atKZ5cS4)

In some scenarios, secure connectivity is not just about encryption but also about **keeping telemetry flows private and cost‑effective**. For example, when monitoring workloads on AWS, Instana can use AWS PrivateLink to transmit telemetry from VPCs to the Instana backend over the AWS private network, avoiding public internet exposure and reducing egress costs. Similar patterns exist for other providers. [aws.amazon](https://aws.amazon.com/blogs/ibm-redhat/reduce-network-costs-and-secure-observability-with-ibm-instana-and-aws-privatelink/)

In a sovereign context, these capabilities support two goals:

- Ensuring that telemetry remains within acceptable boundaries. Using private connectivity and region‑specific backends can help keep observability data inside the same jurisdiction as the workloads it describes, or at least within clearly controlled routes. [aws.amazon](https://aws.amazon.com/blogs/ibm-redhat/reduce-network-costs-and-secure-observability-with-ibm-instana-and-aws-privatelink/)
- Providing evidence for network‑related resilience and sovereignty. When incidents occur, being able to show exactly how traffic flowed, where it was slowed or blocked, and which parts of the network participated is valuable both for engineering and for compliance.

Network observability is also a key input to **agentic operations**. Agents cannot make good decisions about rerouting, failover or workload placement without an accurate view of network health and behaviour. Instana’s telemetry feeds into Concert’s resilience modelling and Turbonomic’s placement decisions, allowing those systems to consider network realities rather than only CPU and memory. [ibm](https://www.ibm.com/products/turbonomic/integrations/instana-observability)

***

## 5.7 Topology patterns for sovereign operations

While each organisation’s topology will be unique, certain patterns recur. We will explore them in detail in later chapters and blueprints, but a few are worth introducing here.

One pattern is the **hub‑and‑spoke sovereign fabric**. In this design, a central control plane—often running in an IBM Sovereign Core deployment—is connected via secure, governed links to multiple sovereign zones. Each zone runs workloads autonomously under local constraints, but shares certain control plane services (policy, observability aggregation, AI governance) with the hub. The network is carefully segmented so that only permitted traffic flows between hub and spokes, and so that sensitive data remains local while metadata and signals are shared.

Another pattern is the **provider‑aligned sovereign ring**. Here, each major cloud provider hosts part of the sovereign fabric, with OpenShift clusters and Sovereign Core deployments in provider‑specific regions. Workloads are placed according to data gravity and regulatory needs, but the operations plane spans them. Network links between these rings are designed to minimise latency for specific flows while avoiding unnecessary cross‑provider chatter. Turbonomic’s placement policies help enforce where workloads may move and where they may not. [ibm](https://www.ibm.com/docs/en/tarm/8.17.x?topic=policies-placement-policy-types)

A third pattern is the **edge‑anchored sovereign mesh**. For industries such as manufacturing or telecoms, critical workloads run at the edge—factories, retail sites, cell towers—often with intermittent connectivity. In these cases, local sovereign zones exist at the edge, with their own OpenShift clusters and limited control planes, connected to central hubs when possible. Topology design focuses on degraded‑mode operation: what happens when links are slow or down; how data is buffered; how policies are applied locally and reconciled later.

In all of these patterns, **human geography** matters as much as technical geography. Where are operators physically located? Which teams are responsible for which zones? How are on‑call rotations structured across time zones? The topology must support not just data flow but also people flow: escalation paths, collaboration channels, and access control.

***

## 5.8 Topology as a living artefact

Finally, topology must be treated as a **living artefact**, not a static diagram tucked into an architecture repository and forgotten. In a dynamic estate, new services, regions, providers and zones will appear; old ones will be retired; relationships will change.

A sovereign operations architecture therefore needs:

- **Automated discovery and documentation**: Tools like Instana and Concert that continuously update their understanding of the topology, not just of individual components but of the relationships between them. [grantthornton](https://www.grantthornton.in/globalassets/1.-member-firms/india/assets/pdfs/observability_and_apm_services_with_ibm_instana.pdf)
- **Topology‑aware change management**: Pipelines and workflows that understand which parts of the topology a proposed change touches, and which sovereign zones and dependencies may be affected.  
- **Topology‑informed planning**: The ability to simulate the effects of moving workloads, adding zones, or changing network paths on latency, cost, resilience and sovereignty, using tools like Turbonomic’s planning capabilities. [ibm](https://www.ibm.com/docs/en/tarm/8.18.0?topic=policies-placement)
- **Shared visualisations**: Views that can be understood by engineers, architects, risk managers and auditors alike, showing how critical business services are mapped onto the underlying topology and where the sovereign boundaries lie.

In the chapters that follow, we will return to topology from multiple angles: when discussing observability, we will consider how to instrument and monitor cross‑zone paths; when discussing automation, we will consider how to implement topology‑aware workflows; when discussing blueprints, we will detail specific patterns for different industries and risk profiles.

For now, the central message is this: **in sovereign cloud operations, topology is not static plumbing; it is a first‑class design instrument**. It determines what is possible, what is safe and what is sustainable. Getting it right, and keeping it right as the estate evolves, is one of the most important tasks in the entire programme.

***

### References

 “Introducing IBM Sovereign Core: A new software foundation for sovereignty,” IBM Newsroom, 2026. [ibm](https://www.ibm.com/new/announcements/introducing-ibm-sovereign-core-a-new-software-foundation-for-sovereignty)
 IBM Sovereign Core – Product Overview. [ibm](https://www.ibm.com/products/sovereign-core)
 “IBM pushes sovereign computing with a software stack that works across cloud platforms,” CIO, 2026. [cio](https://www.cio.com/article/4117279/ibm-pushes-sovereign-computing-with-a-software-stack-that-works-across-cloud-platforms.html)
 “IBM launches Sovereign Core software to help organisations address the digital sovereignty imperative,” Express Computer, 2026. [expresscomputer](https://www.expresscomputer.in/news/ibm-launches-sovereign-core-software-to-help-organisations-address-the-digital-sovereignty-imperative/131771/)
 “IBM drills down to the core of the sovereign AI problem,” Fierce Network, 2026. [community.ibm](https://community.ibm.com/community/user/blogs/tisha-loftus/2026/01/09/unlocking-the-power-of-ibm-concert-for-power-why-i)
 “IBM Cloud Satellite and OpenShift Virtualization,” LinkedIn article. [newsroom.ibm](https://newsroom.ibm.com/announcements)
 “Steps to deploy an OpenShift cluster to an IBM Cloud Satellite Location,” GitHub Gist. [gist.github](https://gist.github.com/liamchampton/fcfbcb88a9c4faa90abc16e445a4bbbd)
 “Reducing Network Costs and Enhancing Observability Security with IBM Instana and AWS PrivateLink,” AWS & IBM Blog, 2025. [msspalert](https://www.msspalert.com/news/ibm-advances-observability-with-ai-driven-resilience-in-concert-platform)
 “Observability and APM services with IBM Instana,” Grant Thornton. [nand-research](https://nand-research.com/research-note-ibm-updates-concert-platform/)
 “Getting started with Instana,” IBM Documentation. [ibm](https://www.ibm.com/docs/en/instana-observability/1.0.309?topic=references-getting-started-instana)
 “Monitoring IBM Power Observability: Best Practices with Instana,” IBM session. [ibm](https://www.ibm.com/docs/en/watsonx/saas?topic=governing-ai)
 “Data Gravity & Latency: IBM Cloud is Designed for Power-based Workloads,” GH Systems. [moorinsightsstrategy](https://moorinsightsstrategy.com/research-notes/ibm-concert-aims-to-supercharge-enterprise-operations-through-ai/)
 “Placement policies” and “Placement policy types,” IBM Turbonomic Documentation. [aws.amazon](https://aws.amazon.com/blogs/ibm-redhat/building-agentic-workflows-with-ibm-watsonx-orchestrate-on-aws/)
 “The Multi-Cloud: Challenges and Solutions,” IEEE Innovation at Work. [heidloff](https://heidloff.net/article/watsonx-governance/)
