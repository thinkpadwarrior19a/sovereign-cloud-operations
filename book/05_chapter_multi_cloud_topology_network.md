# Chapter 5 — Multi‑Cloud Topology, Network, and Sovereign Zones

***

## Summary

This chapter establishes topology as a first-class design instrument in sovereign cloud operations, introducing the sovereign zone — a bounded set of compute, network and storage resources defined by jurisdiction, permitted operators, data classification and key management boundary — as the fundamental unit of placement and policy enforcement. It describes three recurring zone types (primary sovereign, auxiliary and edge), shows how they map to Kubernetes clusters managed by Red Hat Advanced Cluster Management, and explains how IBM Cloud Satellite provides a practical instantiation of the sovereign zone concept on customer-owned infrastructure. The chapter treats the network as the integration fabric through which sovereignty is enforced, covering private connectivity options, BGP routing policy, service mesh enforcement with Istio and OPA/Gatekeeper admission control. Three topology patterns — hub-and-spoke, provider-aligned ring and edge-anchored mesh — are presented as architectural responses to DORA's concentration risk requirements and the operational realities of multi-cloud estates.

***

## 5.1 Why topology is no longer a background detail

Topology used to be something architects sketched late in the project—an arrangement of boxes and lines to reassure stakeholders that redundancy existed and traffic could flow. In a sovereign, zero‑copy, multi‑cloud world, topology moves from the margin to the centre. It becomes a primary design variable for performance, resilience and compliance.

The reason is straightforward: when more interactions are real‑time and more systems are distributed, **where** things are and **how** they are connected determine not just latency and cost, but also whether the organisation is capable of honouring its commitments under stress. A beautifully modular application running in the wrong place, connected by fragile or non‑compliant network paths, is a liability.

The Cloud Native Computing Foundation's Cloud Native Networking Whitepaper makes this point explicit: the network in a cloud native environment is not a static utility but a programmable, policy‑governed control surface on which application behaviour and security posture directly depend [1]. As containerised workloads span providers and jurisdictions, the network must be designed and operated with the same intent as the workloads themselves. Ignoring it is not a neutral act; it is the source of the majority of multi‑cloud operational failures.

DORA's Article 28 and Article 30 requirements around ICT third‑party risk and concentration risk add a regulatory dimension [2]. An organisation that has carefully classified its data, segmented its workloads and implemented fine‑grained access control, but then routes that workload traffic over uncontrolled or shared network paths, has not satisfied the spirit of those obligations. Network topology is part of the third‑party risk story.

This chapter explores how to think about topology in this new context. It introduces the idea of **sovereign zones** as a fundamental unit of placement, shows how network behaviour constrains what can be done across providers, and examines how IBM's Sovereign Core and related technologies provide a practical substrate for implementing these ideas in hybrid and multi‑cloud estates [3].

***

## 5.2 Sovereign zones: more than just regions

Cloud providers give us regions and availability zones. Regulators give us jurisdictions and supervisory boundaries. Architects talk about domains and trust zones. In practice, these concepts overlap but do not neatly align. The AWS region `eu-west-1`, for example, happens to be physically located in Ireland, but it is not automatically a "German sovereign zone" for purposes of BaFin guidance, because its control plane remains under AWS's operational authority and may be administered from outside the EU.

For the purposes of sovereign cloud operations, it is useful to establish a precise, working definition. A **sovereign zone** is a bounded set of compute, network and storage resources characterised by: a defined jurisdiction and legal regime under which all processing occurs; a designated set of permitted operators with explicit identities and access rights; an explicit data classification policy that governs what may enter, reside within and exit the zone; and a distinct key management boundary, such that encryption keys governing data within the zone are neither held by, nor accessible to, parties outside it without explicit and audited authorisation [4]. This definition is more demanding than a provider region and more concrete than a regulatory jurisdiction. It is an **operational construct** rather than a geographical or contractual one.

**Zone types.** In a typical large enterprise, sovereign zones are not homogeneous. Three recurring types are worth naming.

The first is the **primary sovereign zone**. This is where the most regulated workloads run: those subject to the highest data classification, the most scrutinised regulatory obligations, and the most constrained operator authority. A primary sovereign zone for a German retail bank might be implemented on on‑premises infrastructure or in a hyperscaler region with customer‑operated key management, FIDO2‑bound operator identities, and local audit log storage. All workloads touching BaFin‑regulated data, customer personal information classified as Category I, or DORA‑critical business services reside here. Egress from this zone requires both technical enforcement and documented authorisation. The control plane itself must reside within the zone; any external management plane access must traverse a governed, observable path.

The second type is the **auxiliary zone**. This is a cloud‑hosted environment of lower regulatory intensity, used for workloads that do not carry the most sensitive data but that must still respect certain constraints—GDPR residency requirements, for example, or sectoral data handling rules. Auxiliary zones benefit from the agility and managed services of hyperscalers. They are connected to the primary sovereign zone via governed private links, not over the public internet, and data classification policies precisely specify what may be shared between them. An analytics workload running against pseudonymised data, or a development environment that handles synthetic test data, would typically reside in an auxiliary zone.

The third type is the **edge zone**. In industries such as manufacturing, utilities, retail and telecoms, critical workloads must run at or near physical operational sites: factory floors, substations, retail locations, cell towers and hospital wards. Edge zones are on‑premises or co‑located environments that prioritise latency and local resilience over managed service richness. They must operate autonomously when connectivity to central hubs is degraded or lost. Edge zones have their own OpenShift clusters, their own local key management, and their own policy enforcement points. They synchronise with primary and auxiliary zones opportunistically, applying eventual consistency where strong consistency would require network paths that cannot be guaranteed.

**Mapping zones to Kubernetes clusters and namespaces.** In practice, a sovereign zone maps to one or more Kubernetes clusters rather than to namespaces alone. The CNI (Container Network Interface) specification [5], which governs how Kubernetes clusters manage pod networking, provides the mechanism by which network policies are enforced within a cluster—but a namespace boundary within a shared cluster is, without additional controls, a weaker isolation guarantee than a cluster boundary. For primary sovereign zones carrying the most sensitive regulated workloads, a dedicated cluster per zone is the appropriate granularity. Within that cluster, namespaces then provide the secondary segmentation: one namespace per application domain, with NetworkPolicy objects [5] enforcing that inter‑namespace traffic is only permitted along explicitly declared paths.

For auxiliary and edge zones, the calculus may differ. Auxiliary zones might share a multi‑tenant cluster where different namespaces correspond to different teams or applications, provided that the cluster itself is within the zone's jurisdictional and operator control boundary. Edge zones typically run single‑purpose clusters given the constrained hardware environment and the need for operational simplicity during autonomous operation.

**IBM Cloud Satellite as an instantiation of sovereign zone concepts.** IBM Cloud Satellite is not merely a deployment mechanism; it is an architectural realisation of the sovereign zone concept [6]. A Satellite location is a set of customer‑managed hosts—on‑premises, at a co‑location facility, or on another cloud provider—that are attached to the IBM Cloud control plane for management purposes while keeping workloads and their data physically within the customer's operational boundary. The customer controls the physical hosts, the network paths, and the local storage. IBM Cloud Satellite provisions and manages OpenShift clusters within the location, but the workloads running on those clusters never leave the customer's infrastructure.

This architecture means that a Satellite location maps naturally onto a primary sovereign zone: the workloads are customer‑operated, the keys may be customer‑held, the audit logs may remain local, and IBM Cloud's management plane touches the environment only through narrow, observable, controllable channels. A Satellite location in Frankfurt, running on customer‑owned hardware with customer‑operated key management, satisfies the formal definition of a primary sovereign zone in a way that a shared hyperscaler region, however well configured, does not.

**The zone boundary as a policy enforcement point.** In a well‑designed sovereign architecture, every network path that crosses a zone boundary is a policy enforcement point. This is realised in several complementary ways. Ingress and egress are governed by network policies enforced at the CNI layer and, where service mesh is deployed, at the sidecar proxy layer. Mutual TLS (mTLS) is enforced for all inter‑service communication that traverses a zone boundary, ensuring that both parties are authenticated and that the channel is encrypted end‑to‑end [7]. Open Policy Agent (OPA) and its Kubernetes integration, Gatekeeper, evaluate admission requests and runtime policies against the zone's data classification and operator constraint rules [8]. Any workload attempting to write to an external endpoint, call an API in a different zone, or escalate privileges must pass through these enforcement points before the action proceeds. The combination of CNI‑level network policy, service mesh mTLS and OPA/Gatekeeper admission control gives the primary sovereign zone a defence‑in‑depth boundary that is architecturally enforced rather than procedurally hoped for.

![Sovereign zone topology](images/figure-5-1.png)

***

## 5.3 The network as the integration fabric

Once sovereign zones are defined, the next question is how they are connected. In a zero‑copy architecture, the network is not a utility in the background; it is the **integration fabric**. Queries, API calls and events flow across it. The performance and reliability of those flows are directly visible to users and to downstream systems.

**Software‑defined networking and network virtualisation.** The dominant model for cloud network design is the Virtual Private Cloud (VPC) on AWS and GCP, or the equivalent Virtual Network (VNet) on Azure. These constructs provide logically isolated networking environments within a provider's infrastructure, implemented using overlay technologies such as VXLAN (Virtual Extensible LAN), which encapsulates Layer 2 Ethernet frames within UDP packets to enable logical separation across shared physical infrastructure [9]. Within a sovereign zone mapped to a cloud environment, each zone's workloads run within a dedicated VPC or VNet. Peering between VPCs or VNets allows controlled connectivity between zones within the same provider, while inter‑provider connectivity requires additional mechanisms.

This VLAN‑descended segmentation model [10]—the IEEE 802.1Q standard provides the foundational concept of tagged, bounded network segments—translated into software‑defined networking gives architects the ability to design network boundaries that are as rich as their policy requirements demand, without depending on physical cable runs or VLAN trunking configurations. The ability to express network segmentation as code, version it, and enforce it through automation is a significant operational advantage over the physical or VLAN‑based models it replaces.

**Private connectivity between on‑premises and cloud providers.** In single‑cloud designs, network design is often simplified by the provider's internal backbone. Traffic stays within the provider's network, and latencies are relatively predictable. Multi‑cloud architectures are different. Every cross‑provider interaction is one more dependency on the public internet or on direct interconnects. As commentators on multi‑cloud architectures have noted, network bandwidth and latency quickly become the bottleneck for distributed systems that assume cheap, reliable connectivity [11].

Each of the major cloud providers offers a dedicated private connectivity option for connecting on‑premises environments directly to their network fabric. AWS Direct Connect bypasses the public internet entirely, offering consistent 1 Gbps to 100 Gbps throughput with reduced latency variability [12]. Azure ExpressRoute provides equivalent capability for Azure workloads, with the option of Global Reach to connect on‑premises sites to one another via the Azure backbone [13]. Google Cloud Interconnect offers Dedicated Interconnect at 10 or 100 Gbps, or Partner Interconnect for lower bandwidth requirements via colocation providers [14]. IBM Direct Link provides the equivalent for IBM Cloud environments, and is particularly relevant when connecting IBM Cloud Satellite locations to the IBM Cloud management plane [15].

In a sovereign context, these private connectivity options are not merely a performance optimisation; they are a compliance requirement. Traffic between a primary sovereign zone and any supporting cloud services must not traverse the public internet, where it is subject to routing decisions outside the organisation's control and potentially visible to parties with no legitimate access. Private connectivity options provide the governed, observable network paths that sovereignty demands.

**BGP routing policy and sovereignty.** Border Gateway Protocol (BGP) routing policy deserves particular attention in a sovereign topology. BGP is the routing protocol that governs how network traffic is directed between autonomous systems, including the autonomous systems of cloud providers and internet service providers. In a multi‑cloud environment where dedicated interconnects converge at colocation facilities, BGP announcements determine which prefixes are reachable over which paths. An inadvertent or misconfigured BGP announcement can cause traffic intended for a private sovereign path to be routed over a public or otherwise uncontrolled network. Traffic for a German sovereign zone should not, even briefly, transit through a network segment outside the agreed topology. Maintaining strict BGP routing policy—preferring private interconnect paths, withdrawing announcements that would permit uncontrolled transit, and monitoring route tables continuously for unexpected changes—is a non‑trivial operational discipline, but it is one that the sovereign topology demands [1].

**The role of a service mesh.** The service mesh has emerged as the principal mechanism for imposing policy, observability and traffic control on inter‑service communication within and across Kubernetes clusters [16]. Istio, the most widely deployed service mesh, implements a sidecar proxy model: each service pod is accompanied by an Envoy proxy that intercepts all inbound and outbound traffic, enforcing mTLS, applying traffic policies (circuit breaking, retries, rate limiting), and emitting distributed traces and metrics without requiring changes to application code [7]. The CNCF Service Mesh Whitepaper characterises the service mesh as providing the network as a platform feature rather than an application concern, aligning security, observability and traffic management with the operational needs of distributed systems [16].

In a sovereign zone architecture, the service mesh plays several critical roles. Within a zone, it enforces mTLS between all services, ensuring that even lateral movement within the cluster requires valid identity. Across zone boundaries, it provides the authoritative enforcement point for inter‑zone traffic policy: a service in the auxiliary zone may be authorised to call a specific API in the primary sovereign zone, but only with a valid SPIFFE‑based workload identity, only over a designated private path, and only for requests that meet the policy criteria evaluated by the OPA integration. The Istio AuthorizationPolicy resource allows these rules to be expressed declaratively, versioned in Git, and distributed consistently across clusters.

IBM's own cloud services illustrate the recognition that network placement matters as much as service placement. Hosting Power‑based workloads and their data in the same IBM Cloud data centre is explicitly positioned as a way to achieve sub‑5 millisecond latencies, reduce costs and support chatty enterprise applications [17]. The same principle—co‑locating tightly coupled components and minimising cross‑boundary chatter—applies across providers and sovereign zones. A service mesh, combined with thoughtful zone topology, makes this co‑location strategy enforceable and observable.

In a sovereign context, the network is also a **control surface**. It is how the organisation ensures that data flows only along permitted paths. It is how it segments environments with different classification levels. It is how it enforces constraints such as "this traffic may only traverse domestic infrastructure" or "this class of telemetry must never leave the sovereign zone." Network paths between sovereign zones must be treated as scarce, governed resources, not as unbounded pipes.

***

## 5.4 Latency budgets, data gravity and placement

When designing topology for sovereign operations, it is helpful to think in terms of **latency budgets** and **data gravity**.

A latency budget is an explicit statement of how much time can be spent in each part of an end‑to‑end interaction while still meeting a service‑level objective. For a web request that must complete in, say, 300 milliseconds, a rough budget might allocate 50 ms to network round‑trip overhead, 150 ms to application logic, 50 ms to database access and 50 ms to downstream API calls. Those numbers will vary, but the act of budgeting forces teams to confront the reality that not all components can be far apart.

Data gravity is the tendency of large datasets to pull computation toward them. Moving computation (for example, analytic queries or models) to where the data is is often cheaper and faster than moving the data to the computation. In multi‑cloud environments, data gravity interacts with network economics (egress fees) and sovereignty to create "wells" around which topology must be arranged.

In sovereign operations, latency budgets and data gravity intersect with sovereignty in interesting ways. For example:

- A dataset containing EU personal data may have to remain in an EU‑based sovereign zone. Applications that need low‑latency access may therefore need to be deployed within that zone or very close to it.
- A real‑time risk scoring service may need to respond within tens of milliseconds. If its model is trained on sensitive data and must run within a sovereign boundary, calling it from a far‑away frontend may be infeasible; the frontend may need to be brought closer, or caching and degraded‑mode strategies devised.
- Cross‑zone analytics that bring together data from multiple jurisdictions may need to use federated query engines that execute where the data lives, returning only aggregates or anonymised results [18].

Turbonomic provides a concrete example of how these considerations can be codified. Its placement policies allow organisations to define logical boundaries and segments—such as clusters or regions—within which workloads should be placed, taking into account cluster boundaries, networks and data stores. In a sovereign architecture, these policies can reflect latency budgets and sovereignty constraints, guiding automated decisions about where services should run [19].

The key point is that **topology and placement are not purely technical optimisation problems**. They are where performance, cost and sovereignty intersect. They must therefore be designed and tuned with input from architecture, operations, risk and compliance.

***

## 5.5 Implementing sovereign zones with OpenShift and Satellite

If sovereign zones are the conceptual unit, we need a practical way to realise them across diverse infrastructure. Red Hat OpenShift and IBM Cloud Satellite provide such a mechanism, and when combined with Red Hat Advanced Cluster Management and OPA/Gatekeeper, they form a coherent implementation stack.

**Red Hat OpenShift as the consistent Kubernetes runtime.** OpenShift is not simply a packaged distribution of upstream Kubernetes. It is an enterprise platform that augments the Kubernetes runtime with consistent security defaults—SELinux enforcement, restricted pod security standards applied by default, integrated OAuth and LDAP identity providers—and with an operator lifecycle management framework that ensures platform components are installed, updated and reconciled consistently across environments [20]. The significance of this consistency in a sovereign multi‑cloud architecture is substantial. An OpenShift cluster running on bare metal in a Frankfurt data centre and an OpenShift cluster running within an IBM Cloud Satellite location in Tokyo present the same administrative interface, the same policy enforcement mechanisms and the same operator tooling to the teams responsible for operating them. This uniformity is not merely a convenience; it is an operational sovereignty enabler. It means that policies, runbooks and automation developed once are genuinely applicable everywhere, rather than requiring per‑provider adaptation that introduces error and drift.

OpenShift's integrated image registry, with its support for image signing and vulnerability scanning, extends this consistency into the software supply chain. In a sovereign architecture, knowing that every container image running in every zone was signed, scanned and admitted through the same policy gates is a material contribution to the organisation's control posture.

**IBM Cloud Satellite: attaching remote locations to IBM Cloud management.** IBM Cloud Satellite allows organisations to extend IBM Cloud's managed services—including OpenShift clusters, IBM Cloud Object Storage, and IBM Cloud Databases—to infrastructure that the customer owns and operates [6]. A Satellite location is provisioned by attaching a minimum of three customer‑managed hosts to the IBM Cloud control plane. Those hosts become the control plane nodes for the Satellite location; subsequent OpenShift worker nodes are then added to run workloads. From that point, the customer's infrastructure behaves, from an IBM Cloud management perspective, as another region—but the workloads, the data and the network paths remain entirely within the customer's operational boundary.

The management channel between the Satellite location and IBM Cloud is itself carefully scoped. IBM Cloud's management plane communicates with Satellite locations over a small set of outbound connections from the customer's infrastructure to IBM Cloud endpoints; the management plane does not initiate inbound connections to the customer's hosts. This architectural choice means the customer can inspect, monitor and, if necessary, restrict the management channel using their own network controls. For a primary sovereign zone, this is an important assurance: the customer retains network-level visibility into and control over the channel by which IBM Cloud manages the environment.

**Red Hat Advanced Cluster Management for multi‑cluster policy distribution.** In an estate with multiple sovereign zones—each implemented as one or more OpenShift clusters—maintaining consistent policy across all clusters by hand is neither scalable nor auditable. Red Hat Advanced Cluster Management (RHACM) addresses this directly. RHACM provides a hub-and-spoke management model: a central hub cluster runs the RHACM control plane, which manages the lifecycle, configuration and policy enforcement of multiple managed clusters [21]. Policies are expressed as RHACM Policy objects and distributed to managed clusters via placement rules that target clusters by label—by zone type, by jurisdiction, by data classification level, or by any combination thereof.

This means that a policy requiring, for example, that all pods in clusters labelled `zone-type=primary-sovereign` must run with a specific PodSecurityStandard, or that all namespaces must have a NetworkPolicy object governing egress, can be expressed once on the hub and enforced automatically across every cluster that matches the placement rule. RHACM continuously reconciles the desired policy state with the observed cluster state and reports compliance status back to the hub. This compliance reporting forms part of the governance and audit plane discussed in [Chapter 4](04_chapter_architecture_reference_model.html) [22].

**OPA/Gatekeeper policy distribution across clusters.** Open Policy Agent (OPA) and its Kubernetes integration, Gatekeeper, provide a policy engine that evaluates admission requests—workload deployments, configuration changes, service account bindings—against a corpus of Rego policies before the Kubernetes API server permits them [8]. The combination of RHACM and Gatekeeper closes a critical gap: RHACM distributes the desired policy state; Gatekeeper enforces it at the point of admission.

In a sovereign zone architecture, Gatekeeper constraint templates codify the zone's rules in executable form: no image may be admitted unless it has been signed by an approved key; no workload may declare a volume mount to a path outside the approved set; no service may expose a port to a CIDR range outside the zone's permitted egress list. These constraints are versioned in Git, reviewed and approved through the standard change management process, and distributed to managed clusters by RHACM. When a workload violates a constraint, the admission is rejected and the rejection is logged. The audit mode of Gatekeeper additionally scans existing resources against constraints on a schedule, surfacing policy drift that may have accumulated through legacy objects or manual intervention.

The practical effect is that the sovereign zone's policy enforcement is not dependent on individual engineers remembering to apply the right settings. It is architecturally embedded in the cluster's admission control layer, distributed consistently across all clusters in the zone by RHACM, and evaluated by OPA against the authoritative Rego policy corpus. The NIST Zero Trust Architecture principle of "never trust, always verify" [4] is applied at the Kubernetes API layer as much as at the network layer.

**API gateway enforcement at zone boundaries.** While the service mesh governs east-west traffic between services within and across clusters, the north-south boundary — where external consumers, partner systems and inter-zone API calls enter a sovereign zone — requires its own enforcement layer. IBM API Connect [26] provides API gateway and management capabilities that enforce rate limiting, mutual TLS authentication, OAuth 2.0 token validation and data classification policies at the API boundary. In a sovereign topology, API Connect gateways deployed at zone ingress points ensure that every inbound API call is authenticated, authorised against the zone's access policy, and subjected to payload inspection rules that can redact or reject requests carrying data classes not permitted to enter or leave the zone. The gateway's analytics stream feeds into the observability fabric, giving Concert visibility into API traffic patterns and policy violations at the zone perimeter.

This pattern allows organisations to deploy **AI‑ready, sovereign‑enabled environments** that remain under their own or a trusted partner's control, while still benefiting from automation and consistency [3]. It also allows them to replicate that pattern across multiple zones—national deployments, sectoral zones, partner‑operated environments—without reinventing the wheel each time.

From a topology perspective, the important thing is that **each sovereign zone looks similar from an operational standpoint**. The details of the underlying hardware and local networks may differ, but the way workloads are deployed, observed and governed is consistent. This consistency simplifies both operational tooling and human practice.

***

## 5.6 Network observability and secure connectivity

Designing topology is only half the story; the other half is being able to see and manage how it behaves in production. Network observability is therefore a first‑class requirement.

Instana's full‑stack observability includes network monitoring and topology visualisation. It can show how services communicate, how requests traverse nodes and clusters, and where latency or errors are introduced. This is essential for understanding the behaviour of cross‑cloud and cross‑zone interactions. When a service in one sovereign zone depends on another in a different zone or provider, the path between them must be visible [23]. The alternative—operating blind to cross‑zone latency contributions—is incompatible with the latency budget discipline described in section 5.4 and with the incident detection capabilities DORA requires under its ICT risk management framework [2].

In some scenarios, secure connectivity is not just about encryption but also about **keeping telemetry flows private and cost‑effective**. For example, when monitoring workloads on AWS, Instana can use AWS PrivateLink to transmit telemetry from VPCs to the Instana backend over the AWS private network, avoiding public internet exposure and reducing egress costs. Similar patterns exist for other providers [24]. The principle here is that the observability fabric must itself respect the sovereignty constraints of the workloads it describes. Telemetry that traverses the public internet to reach an observability backend may inadvertently carry information about the behaviour and performance characteristics of sovereign workloads into an uncontrolled context.

In a sovereign context, these capabilities support two goals. The first is ensuring that telemetry remains within acceptable boundaries. Using private connectivity and region‑specific backends can help keep observability data inside the same jurisdiction as the workloads it describes, or at least within clearly controlled routes [24]. The second is providing evidence for network‑related resilience and sovereignty. When incidents occur, being able to show exactly how traffic flowed, where it was slowed or blocked, and which parts of the network participated is valuable both for engineering and for regulatory compliance. The DORA requirement for detailed incident reporting, including the scope and duration of disruptions [2], can only be met if the observability infrastructure has the network‑level resolution to reconstruct what happened.

Network observability is also a key input to **agentic operations**. Agents cannot make good decisions about rerouting, failover or workload placement without an accurate view of network health and behaviour. Instana's telemetry feeds into Concert's resilience modelling and Turbonomic's placement decisions, allowing those systems to consider network realities rather than only CPU and memory [25]. An agent that recommends scaling a service without knowing that the network path between that service and its data store is already saturated will produce recommendations that may worsen, rather than alleviate, the problem.

***

## 5.7 Topology patterns for sovereign operations

While each organisation's topology will be unique, certain patterns recur. We will explore them in detail in later chapters and blueprints, but a few are worth introducing here.

One pattern is the **hub‑and‑spoke sovereign fabric**. In this design, a central control plane—often running in an IBM Sovereign Core deployment—is connected via secure, governed links to multiple sovereign zones. Each zone runs workloads autonomously under local constraints, but shares certain control plane services (policy, observability aggregation, AI governance) with the hub. The network is carefully segmented so that only permitted traffic flows between hub and spokes, and so that sensitive data remains local while metadata and signals are shared. RHACM's hub-and-spoke cluster management model maps naturally onto this topology: the hub cluster is the operational control point, and each spoke cluster is a sovereign zone implementation.

Another pattern is the **provider‑aligned sovereign ring**. Here, each major cloud provider hosts part of the sovereign fabric, with OpenShift clusters and Sovereign Core deployments in provider‑specific regions. Workloads are placed according to data gravity and regulatory needs, but the operations plane spans them. Network links between these rings are designed to minimise latency for specific flows while avoiding unnecessary cross‑provider chatter. Turbonomic's placement policies help enforce where workloads may move and where they may not [19]. The provider‑aligned ring pattern is particularly suited to organisations with deep investments in specific providers for particular domains—for example, manufacturing workloads on one provider and analytics on another—where the governance requirement is to ensure that neither provider's perimeter is inadvertently breached.

A third pattern is the **edge‑anchored sovereign mesh**. For industries such as manufacturing or telecoms, critical workloads run at the edge—factories, retail sites, cell towers—often with intermittent connectivity. In these cases, local sovereign zones exist at the edge, with their own OpenShift clusters and limited control planes, connected to central hubs when possible. Topology design focuses on degraded‑mode operation: what happens when links are slow or down; how data is buffered; how policies are applied locally and reconciled later. The NIST Zero Trust Architecture framework's guidance on network segmentation and micro‑perimeters [4] is particularly applicable here: each edge zone is its own micro‑perimeter, requiring authentication and authorisation for every interaction, even when temporarily disconnected from the central governance plane.

In all of these patterns, **human geography** matters as much as technical geography. Where are operators physically located? Which teams are responsible for which zones? How are on‑call rotations structured across time zones? The topology must support not just data flow but also people flow: escalation paths, collaboration channels, and access control. A beautifully segmented network topology that routes an operator's emergency console access through three sovereign zone boundaries will be subverted under pressure. Human factors must be designed in from the start.

DORA's concentration risk provisions [2, Art. 30] provide an additional lens on topology patterns. The regulator's concern is that an organisation that has placed all its critical workloads, data and connectivity with a single provider has created a concentration risk that cannot be mitigated by contractual terms alone. The topology patterns described above are architectural responses to this concern: by distributing across zones, providers and operators, the organisation reduces the blast radius of any single provider failure or contractual disruption, and can demonstrate to its supervisor that it has the exit strategies and transition plans Article 30 requires.

![Multi‑cloud topology patterns](images/figure-5-2.png)

***

## 5.8 Topology as a living artefact

Finally, topology must be treated as a **living artefact**, not a static diagram tucked into an architecture repository and forgotten. In a dynamic estate, new services, regions, providers and zones will appear; old ones will be retired; relationships will change.

A sovereign operations architecture therefore needs:

- **Automated discovery and documentation**: Tools like Instana and Concert that continuously update their understanding of the topology, not just of individual components but of the relationships between them [23].
- **Topology‑aware change management**: Pipelines and workflows that understand which parts of the topology a proposed change touches, and which sovereign zones and dependencies may be affected.
- **Topology‑informed planning**: The ability to simulate the effects of moving workloads, adding zones, or changing network paths on latency, cost, resilience and sovereignty, using tools like Turbonomic's planning capabilities [19].
- **Shared visualisations**: Views that can be understood by engineers, architects, risk managers and auditors alike, showing how critical business services are mapped onto the underlying topology and where the sovereign boundaries lie.

In the chapters that follow, we will return to topology from multiple angles: when discussing observability, we will consider how to instrument and monitor cross‑zone paths; when discussing automation, we will consider how to implement topology‑aware workflows; when discussing blueprints, we will detail specific patterns for different industries and risk profiles.

For now, the central message is this: **in sovereign cloud operations, topology is not static plumbing; it is a first‑class design instrument**. It determines what is possible, what is safe and what is sustainable. Getting it right, and keeping it right as the estate evolves, is one of the most important tasks in the entire programme.

***

## Key Takeaways

- A sovereign zone is a formal, operational construct—a bounded set of compute, network and storage resources defined by jurisdiction, permitted operators, data classification policy and a distinct key management boundary—not merely a cloud provider region or a regulatory geography.

- Three zone types recur in large enterprise estates: the primary sovereign zone (regulated, jurisdiction‑constrained, operator‑controlled), the auxiliary zone (cloud‑hosted, lower regulatory intensity) and the edge zone (on‑premises or co‑located, latency‑optimised, intermittently connected). Each maps to one or more dedicated Kubernetes clusters.

- IBM Cloud Satellite locations are a practical instantiation of sovereign zone concepts, placing OpenShift clusters on customer‑owned infrastructure while keeping workloads, data and network paths within the customer's operational boundary, with the management channel visible and controllable by the customer.

- The network is the integration fabric in a zero‑copy, multi‑cloud architecture. Private connectivity options—Direct Connect, ExpressRoute, Cloud Interconnect, IBM Direct Link—are compliance requirements as well as performance choices. BGP routing policy must be actively managed to ensure sovereign traffic does not transit uncontrolled paths.

- The service mesh (Istio, Linkerd) enforces mTLS, provides distributed observability and evaluates traffic policy at zone boundaries. OPA/Gatekeeper enforces admission-time constraints within clusters. RHACM distributes both policy sets consistently across all clusters in the estate. Together, these three layers constitute the technical enforcement of the sovereign zone boundary.

- Network observability must be as sovereign‑aware as the workloads it describes. Telemetry must travel over the same private paths as application traffic; region‑specific observability backends keep operational data within its jurisdictional boundary. This is not only good practice—it is a requirement of GDPR Article 32 and the spirit of DORA's ICT risk management obligations.

- Topology is a living artefact. Hub‑and‑spoke, provider‑aligned ring and edge‑anchored mesh are three recurring patterns, each suited to different organisational and regulatory contexts. All three must be continuously discovered, documented and adjusted as the estate evolves, with automated tooling rather than periodic manual surveys.

***

## Bridge to Chapter 6 — The Zero-Copy Integration Substrate

This chapter has established topology as a first‑class design instrument in sovereign cloud operations, introducing the sovereign zone—with its formal definition, its three principal types and its mapping to Kubernetes clusters managed by RHACM—as the fundamental unit of placement and policy. It has shown how the network, far from being background infrastructure, is the integration fabric through which all inter‑zone interactions flow and the control surface through which sovereignty is enforced. Private connectivity options, BGP routing policy, software‑defined networking constructs, service meshes and OPA/Gatekeeper enforcement combine to give that fabric the governed, observable character that regulated enterprises require. The three topology patterns—hub‑and‑spoke, provider‑aligned ring and edge‑anchored mesh—offer practical starting points for organisations at different stages of their multi‑cloud journey, each addressing the DORA concentration risk concern from a different angle.

The analysis in this chapter has implicitly assumed that the estate's integration model supports the topology's sovereignty goals. That assumption is the subject of [Chapter 6](06_chapter_zero_copy_substrate.html). Zero‑copy integration, as the operational substrate on which sovereign services run, determines whether the access paths, event flows and data boundaries designed into the topology are genuinely honoured at runtime. A sovereign topology built on a copy‑heavy integration estate is, ultimately, a leaky vessel: the data will find its way to where it should not be, not through deliberate breach but through the accumulated gravity of poorly governed pipelines. [Chapter 6](06_chapter_zero_copy_substrate.html) examines how zero‑copy principles harden the integration layer against that drift, and how the combination of principled topology and zero‑copy substrate creates the coherent, demonstrably sovereign estate that both regulators and the organisation's own risk appetite demand.

***

## References

[1] Cloud Native Computing Foundation, "Cloud Native Networking Whitepaper," CNCF, San Francisco, CA, v1.0, 2021. [Online]. Available: https://github.com/cncf/tag-network/blob/main/cloud-native-networking-whitepaper.md

[2] European Parliament and Council of the European Union, "Regulation (EU) 2022/2554 of the European Parliament and of the Council of 14 December 2022 on digital operational resilience for the financial sector (DORA)," *Official Journal of the European Union*, vol. L 333, pp. 1–79, Dec. 2022. [Art. 28: "General principles of ICT third‑party risk management"; Art. 30: "Key contractual provisions."] [Online]. Available: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32022R2554

[3] IBM Corporation, "Introducing IBM Sovereign Core: A new software foundation for sovereignty," IBM Newsroom, Jan. 2026. [Online]. Available: https://www.ibm.com/new/announcements/introducing-ibm-sovereign-core-a-new-software-foundation-for-sovereignty

[4] S. Rose, O. Borchert, S. Mitchell, and S. Connelly, "Zero Trust Architecture," National Institute of Standards and Technology Special Publication 800‑207, NIST, Gaithersburg, MD, USA, Aug. 2020. [Online]. Available: https://doi.org/10.6028/NIST.SP.800-207

[5] Cloud Native Computing Foundation, "Container Network Interface (CNI) Specification," CNCF, v1.0.0, 2021. [Online]. Available: https://github.com/containernetworking/cni/blob/main/SPEC.md

[6] IBM Corporation, "IBM Cloud Satellite documentation," IBM Cloud Docs, 2025. [Online]. Available: https://cloud.ibm.com/docs/satellite

[7] Istio Authors, "Istio Service Mesh Documentation," Istio, v1.21, 2024. [Online]. Available: https://istio.io/latest/docs/

[8] Open Policy Agent Contributors, "OPA Gatekeeper: Policy and Governance for Kubernetes," Open Policy Agent, 2024. [Online]. Available: https://open-policy-agent.github.io/gatekeeper/website/docs/

[9] M. Mahalingam et al., "Virtual eXtensible Local Area Network (VXLAN): A Framework for Overlaying Virtualized Layer 2 Networks over Layer 3 Networks," Internet Engineering Task Force RFC 7348, Aug. 2014. [Online]. Available: https://www.rfc-editor.org/rfc/rfc7348

[10] IEEE Standards Association, "IEEE 802.1Q-2022 — IEEE Standard for Local and Metropolitan Area Networks — Bridges and Bridged Networks," IEEE, New York, NY, USA, 2022. [Online]. Available: https://standards.ieee.org/ieee/802.1Q/10553/

[11] IEEE Innovation at Work, "The Multi-Cloud: Challenges and Solutions," IEEE, 2021. [Online]. Available: https://innovationatwork.ieee.org/the-multi-cloud-challenges-and-solutions/

[12] Amazon Web Services, "AWS Direct Connect — Dedicated connectivity from your data centre to AWS," AWS Documentation, 2025. [Online]. Available: https://docs.aws.amazon.com/directconnect/latest/UserGuide/Welcome.html

[13] Microsoft Corporation, "Azure ExpressRoute documentation," Microsoft Learn, 2025. [Online]. Available: https://learn.microsoft.com/en-us/azure/expressroute/

[14] Google LLC, "Cloud Interconnect overview," Google Cloud Documentation, 2025. [Online]. Available: https://cloud.google.com/network-connectivity/docs/interconnect/concepts/overview

[15] IBM Corporation, "IBM Direct Link documentation," IBM Cloud Docs, 2025. [Online]. Available: https://cloud.ibm.com/docs/dl

[16] Cloud Native Computing Foundation, "CNCF Service Mesh Whitepaper," CNCF, v2, 2023. [Online]. Available: https://github.com/cncf/tag-network/blob/main/CNCF_Service_Mesh_White_Paper_v2.pdf

[17] GH Systems, "Data Gravity & Latency: IBM Cloud is Designed for Power‑based Workloads," GH Systems Blog, 2024. [Online]. Available: https://www.ghsystems.com/blog/data-gravity-latency-ibm-cloud-is-designed-for-power-based-workloads

[18] IBM Corporation, "What is Sovereign Cloud?" IBM Think, 2025. [Online]. Available: https://www.ibm.com/think/topics/sovereign-cloud

[19] IBM Corporation, "Placement policies," IBM Turbonomic ARM Documentation, v8.18.0, 2025. [Online]. Available: https://www.ibm.com/docs/en/tarm/8.18.0?topic=policies-placement

[20] Red Hat Inc., "Red Hat OpenShift Container Platform documentation," Red Hat Customer Portal, 2025. [Online]. Available: https://docs.openshift.com/container-platform/latest/welcome/index.html

[21] Red Hat Inc., "Red Hat Advanced Cluster Management for Kubernetes documentation," Red Hat Customer Portal, 2025. [Online]. Available: https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes

[22] IBM Corporation, "IBM Sovereign Core — Product Overview," IBM, 2026. [Online]. Available: https://www.ibm.com/products/sovereign-core

[23] Grant Thornton India LLP, "Observability and APM services with IBM Instana," Grant Thornton, 2024. [Online]. Available: https://www.grantthornton.in/globalassets/1.-member-firms/india/assets/pdfs/observability_and_apm_services_with_ibm_instana.pdf

[24] Amazon Web Services and IBM, "Reducing Network Costs and Enhancing Observability Security with IBM Instana and AWS PrivateLink," AWS & IBM Red Hat Blog, 2025. [Online]. Available: https://aws.amazon.com/blogs/ibm-redhat/reduce-network-costs-and-secure-observability-with-ibm-instana-and-aws-privatelink/

[25] IBM Corporation, "Instana Observability integration with IBM Turbonomic," IBM, 2025. [Online]. Available: https://www.ibm.com/products/turbonomic/integrations/instana-observability

[26] IBM Corporation, "IBM API Connect: API Management, Security and Socialisation," IBM Documentation, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/products/api-connect
