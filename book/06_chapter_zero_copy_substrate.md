# Chapter 6 — Zero‑Copy Integration as Operational Substrate

***

## Summary

This chapter reframes zero-copy integration as an operational substrate rather than a purely architectural pattern, showing how the shift from copy-heavy to event-driven, in-place data access fundamentally changes what it means to run a multi-cloud estate. It exposes the operational fragility of copy-heavy architectures — synchronisation lag, silent ETL failures, schema drift, exploding compliance surface area and impoverished data lineage — and contrasts these with the simpler failure surface, richer event signals and tighter audit trails that a zero-copy model provides. The chapter examines four event patterns (notification, event-carried state transfer, event sourcing and CQRS), treats lineage as both an operational debugging tool and a sovereign control mechanism, and explains how agentic systems exploit the structured, event-rich substrate to reason about the estate in real time. Architects are cautioned that whilst zero-copy simplifies structural reasoning, it increases real-time sensitivity and demands correspondingly better observability, disciplined change management and network-aware design. The chapter also confronts the realistic limits of zero-copy — acknowledging that whilst it is the right principle for operational data (telemetry, events, lineage metadata, policy artefacts), it cannot eliminate all data movement for multi-petabyte analytical workloads, and introduces the authorised-copy pattern for governed exceptions where data gravity makes in-place access impractical.

***

## 6.1 From integration pattern to operating surface

Zero‑Copy Integration began as an answer to a familiar architectural mess: data replicated into warehouses, marts, caches and shadow databases until no one could say with confidence where the truth lived. The original argument was primarily about **architecture** and **governance**—about reducing copies, exposing data via well‑governed APIs or virtualisation layers, and propagating changes as streams of events rather than as opaque batch jobs [1].

In the context of this book, zero‑copy takes on an additional role. It becomes the **substrate on which operations play out**. When applications, analytics and AI agents depend on in‑place access and real‑time events, the integration fabric is no longer something you "set and forget" beneath your systems. It becomes part of the operational foreground. Incidents propagate along it, sovereignty is enforced through it, and agents reason about the estate in terms of the events and access paths it provides [2].

The move from copy‑heavy to zero‑copy integration therefore changes what it means to "run" an estate. It doesn't just alter where data sits; it alters how systems behave in production and what kinds of observability and control you need [3]. Kleppmann's foundational treatment of data-intensive systems makes this point precisely: the log—a durable, append-only record of changes—is not merely a storage structure but the authoritative source of truth from which all derived representations should flow [4]. That insight, originally developed in the context of database internals, generalises directly to the enterprise integration problem: when state changes propagate as an ordered stream of events, the estate becomes coherent in a way that periodic batch copying can never achieve.

### Executive Perspective

Zero-copy integration is, at its core, a risk and cost discipline. Every unnecessary copy of a dataset is a liability: it increases storage spend, multiplies the compliance surface that regulators can examine, and creates synchronisation lag that causes downstream systems to act on stale information — a material concern in financial services, insurance and any domain where real-time accuracy drives revenue or regulatory standing. By consolidating access to authoritative sources and replacing fragile ETL pipelines with governed event streams, the organisation reduces the probability of silent data corruption, shortens incident investigation times, and shrinks the evidence burden at audit. For the CIO, the strategic value is operational resilience: a zero-copy substrate means fewer places where things can go wrong, faster root-cause analysis when they do, and a demonstrably smaller attack surface for data sovereignty violations that could attract regulatory penalty or reputational damage.

***

## 6.2 Why copy‑heavy estates are operationally fragile

To see why zero‑copy matters for operations, imagine a conventional integration landscape in a large enterprise.

A core system of record feeds nightly exports into a central warehouse. From there, subject‑specific marts are populated for finance, marketing, risk and operations. Downstream applications consume data from a mix of these stores and their own local caches. Some systems pull CSV extracts into bespoke databases for reporting. Others rely on periodic file drops over SFTP from partners. ETL jobs proliferate, each with its own schedule, error‑handling quirks and log format. From a purely functional standpoint, this may "work." Reports appear on time; APIs return data; stakeholders see dashboards. Operationally, however, the picture is grim.

**The data copy tax.** Every replicated store incurs costs that extend far beyond the storage bill itself. Storage cost is the most visible: multiple copies of large datasets occupy capacity that must be provisioned, backed up and, eventually, decommissioned. But the more insidious cost is synchronisation lag. A nightly extract that completes at 03:00 means that, throughout the following business day, the mart is already up to twenty-four hours stale relative to the system of record. In financial services or insurance, where the state of a customer account or policy may change multiple times daily, that lag is not an inconvenience but a structural source of incorrect decisions [5]. Risk models run on yesterday's positions; customer-facing agents quote yesterday's balances. When the discrepancy surfaces—often through a customer complaint or a failed regulatory report—the investigation begins with the fundamental question of which copy was read and when.

Consistency failures compound the synchronisation problem. In a copy-heavy estate, the same entity may exist in several stores simultaneously, each at a different point in its lifecycle. A customer address updated in the CRM may not yet have propagated to the billing system, the regulatory reporting mart, or the fraud detection engine. The organisation may satisfy each of these copies separately, yet none of them reflects the current ground truth. When Kleppmann describes the challenge of keeping derived data systems consistent with their sources, he characterises it as one of the fundamental problems of distributed systems, one that copy-heavy architectures make worse by introducing unbounded replication delays and no canonical reconciliation mechanism [4].

The compliance surface area expands with every copy. Under Article 5 of the United Kingdom General Data Protection Regulation (UK GDPR) and its EU equivalent, personal data must be "adequate, relevant and limited to what is necessary in relation to the purposes for which they are processed"—the data minimisation principle [6]. Each copy of a dataset containing personal data is, in legal terms, a separate instance of processing. A dataset that exists in twelve different stores—each created for a legitimate purpose, each maintained by a different team—is a dataset whose compliance posture must be managed in twelve places. Consent records, subject access request responses, right-to-erasure obligations and data retention schedules all multiply accordingly. Regulators are increasingly aware of this dynamic: the UK Information Commissioner's Office has noted that organisations cannot demonstrate meaningful data minimisation if they cannot account for all the places their data resides [7].

**ETL pipelines as operational liabilities.** The brittle, schedule-driven nature of extract, transform and load processes deserves particular attention, because they are so pervasive and so frequently underestimated as a source of operational risk. A pipeline designed when a source schema was understood may run without incident for months or years, quietly encoding assumptions about field formats, nullability and referential integrity that no longer hold. When a source system is upgraded and a field changes from a numeric to an alphanumeric format, the pipeline may not fail immediately. It may truncate silently, substitute a default value, or simply skip affected rows without raising an alert [4]. The downstream mart then contains subtly corrupted data that may not be detected until a senior analyst notices an anomaly in a quarterly report.

Silent failures are particularly dangerous because they do not trigger the incident-response machinery. An SRE monitoring error rates and queue depths will see nothing unusual. A dashboard showing data freshness by pipeline name will show the pipeline as "completed successfully" even if it silently discarded twenty per cent of its rows. The only indicator may be a semantic anomaly in derived reports—an anomaly that could have been introduced at any of several pipeline stages. Debugging this class of problem routinely requires comparing data at multiple pipeline stages, correlating execution logs with source-system audit trails, and reconstructing the transformation history of individual records. In large organisations with mature data warehouse platforms, this work can take days.

Schema drift compounds the problem. In a copy-heavy estate, schema changes in source systems propagate slowly and unevenly. A source team that adds a new field to a transaction record and communicates it through a ticket or a data dictionary update has no guarantee that every downstream pipeline will be updated before the next execution. Some pipelines may ignore the new field; others may fail; others may produce incorrect output. Co-ordinating schema changes across dozens of pipelines and dozens of consuming teams is one of the most demanding operational activities in a large enterprise data platform, and it rarely receives the attention or tooling it deserves [5].

**The lineage problem.** In a copy-heavy estate, reconstructing what happened to a dataset requires tracing through multiple pipelines, each with its own log format, scheduling system and error-handling behaviour. When a regulatory inquiry asks which datasets were used to produce a particular risk model output, the answer may require interviews with three or four teams, manual inspection of pipeline configurations dating back several years, and a degree of inference where records are incomplete. This is not a hypothetical scenario; it is the common experience of organisations responding to regulatory examinations or internal audit requests. The absence of systematic lineage recording means that the answer to "where did this data come from?" is reconstructed from memory, convention and incomplete artefacts rather than read from an authoritative record [8].

From a sovereignty perspective, the situation is even more precarious. Copies have a tendency to drift into places they were never intended to be: a data mart deployed hastily in a convenient region, a logging system that retains more payload detail than intended, an analytical export replicated into a less tightly controlled environment. Even if the system of record is carefully located, its replicas become a web of risk.

In short, copy‑heavy estates are **fragile** because they multiply both the number of failure points and the number of places where policy can be violated. They make it difficult to answer the simplest operational questions: "Where is the truth?" "Who saw what?" "Which systems are affected?" "Can we safely stop this pipeline right now?"

***

## 6.3 The operational shape of a zero‑copy estate

Zero‑copy integration responds to this by changing the default stance. Instead of copying data into new silos whenever a consumer appears, the environment privileges:

- **In‑place access** via APIs, data virtualisation or shared stores designed for multi‑tenant access under strict governance [9].
- **Event‑driven propagation** of state changes, where downstream systems react to events rather than relying on periodic bulk refreshes [2].
- **Deliberate, limited replication** only where necessary, with clear lineage and controls [8].

Operationally, this creates a different shape.

The number of authoritative stores is smaller. When operators investigate an issue, there are fewer possible "truth locations" to consider. A payment status, for example, will be read from one of a small set of systems rather than a sprawl of marts. When a system of record is misbehaving, its centrality is obvious; when it is healthy, downstream inconsistencies are easier to diagnose [9].

Events become **primary signals** of business activity. Instead of inferring the health of a process indirectly from CPU usage or queue depth, operators can monitor the actual flow of semantic events: "OrderPlaced," "PaymentAuthorised," "PolicyIssued," "ConsentWithdrawn." Delays, failures and unusual patterns in these streams point directly to where business value is being affected [10].

Sovereignty improves because there are simply fewer places where sensitive data lives. Access control is concentrated. Logging and monitoring of usage becomes more meaningful: access logs reflect real use, not just copying operations. When regulators ask where certain data has travelled, the graph is smaller and better understood [3].

However, this simplification in one dimension is matched by an increase in **real‑time sensitivity**. In a zero‑copy estate, more interactions depend on live connectivity. A single user request may involve multiple in‑place reads and writes, plus the emission and consumption of events. Small perturbations in latency, intermittent network issues or subtle policy misconfigurations can affect behaviour quickly. There is less slack in the system: fewer overnight jobs to "catch up," fewer redundant stores that hide temporary access problems.

Thus a zero‑copy substrate is **easier to reason about structurally** but **less tolerant of improvisation**. It demands better observability, more disciplined change, and smarter assistance when things go wrong [2].

***

![Figure 6.1 — Zero-copy vs. copy-heavy data flows: operational complexity compared](images/figure-6-1.png)
> A side-by-side architectural diagram contrasting the sprawl of ETL-fed marts and shadow databases on the left against the concentrated, event-driven access topology of a zero-copy estate on the right, with failure investigation paths and compliance surfaces marked on both.

***

## 6.4 Events as an operational nervous system

In zero‑copy architectures, events do more than integrate systems; they become the **nervous system of operations** [2].

Understanding what "events" means in this context requires distinguishing four related but distinct architectural patterns, each with a different operational character. Gregor Hohpe and Bobby Woolf's canonical work on enterprise integration patterns established the foundational taxonomy, but the modern event-driven literature—including Kleppmann's treatment of stream processing [4]—has refined and extended it considerably.

**Event notification** is the simplest pattern. A system emits a lightweight signal indicating that something has changed—"CustomerUpdated," "PaymentFailed"—without including the changed data itself. Consumers that need the new state must retrieve it from the source system. This pattern minimises the data carried in the event and keeps the event broker free of sensitive content, which has obvious sovereignty advantages. Its operational weakness is that it creates tight coupling between the event and the source system: if the source is unavailable when a consumer responds to the notification, the consumer cannot proceed.

**Event-carried state transfer** extends notification by including the changed state in the event payload. Consumers receive everything they need without querying the source, which improves autonomy and resilience. The operational consequence is that the event stream now carries potentially sensitive data, which must be governed as carefully as any other data access path. Consumers may also derive inconsistent state if they process events out of order or miss events during an outage [4].

**Event sourcing** is a more radical commitment: the event log becomes the system of record rather than a derived representation of it. All state changes are captured as immutable events; the current state of any entity is computed by replaying the relevant events from the beginning of its history. This approach gives operations teams remarkable debugging power—the ability to replay the event history of a specific entity to understand exactly what happened and in what sequence—but demands careful attention to schema evolution, storage management and the performance of replay operations [10].

**Command Query Responsibility Segregation (CQRS)** frequently accompanies event sourcing. Write operations (commands) flow through the event log; read operations (queries) are served from one or more materialised views built by projecting events. The operational implication is that read models may lag behind the event log by a small but non-zero duration: a concept known as eventual consistency. In operational contexts, this means that the observability tooling consuming event-derived read models must account for this lag and must not treat an absence of events as definitive evidence of an absence of state changes [4].

**Apache Kafka architecture.** In practice, the majority of large-scale enterprise event streaming deployments are built on Apache Kafka or its managed derivatives [11]. Kafka's architecture warrants a brief operational overview because it shapes many of the design choices that follow. The fundamental unit is the **topic**: a durable, ordered log of records to which producers append and from which consumers read. Topics are partitioned: each partition is an ordered sequence of records stored on a broker, replicated across multiple brokers for fault tolerance. Consumers operate within **consumer groups**: each record in a partition is delivered to exactly one member of a given consumer group, which enables horizontal scaling of consumption while preserving the ordering guarantees within a partition [11].

Two Kafka features have particular operational significance. **Log compaction** retains, for each record key, the most recent value, discarding older values once they are no longer needed for catch-up. This is how Kafka supports event-carried state transfer without unbounded storage growth: the compacted topic represents the current state of each entity, while the full event log represents the complete history. **Retention policies** determine how long records are kept in the full log. Operationally, retention must be calibrated to balance the ability of consumers to catch up after an outage against storage costs and, in regulated environments, data minimisation obligations [12]. A retention policy of seven days may be appropriate for most operational events; a compliance event that must be available for regulatory inspection may require a separate, longer-retention topic or archive.

**CloudEvents.** The proliferation of event-driven systems has created a secondary problem: each platform tends to invent its own schema for event metadata. A Kafka event, an Azure Event Grid notification, an AWS EventBridge event and a Knative trigger all carry similar information—source, event type, timestamp, correlation identifier—but in different fields with different naming conventions. The CloudEvents specification, published by the Cloud Native Computing Foundation (CNCF) and now at version 1.0.2, defines a standardised schema for this metadata [13]. Its mandatory attributes include `source` (a URI identifying the event source), `type` (a reverse-DNS-namespaced event type identifier), `time` (an RFC 3339 timestamp), and `datacontenttype` (a media type describing the event payload). The optional `dataref` attribute supports event notification patterns by providing a URI from which the full event data can be retrieved, rather than embedding it in the event itself.

Adopting CloudEvents as a standard within the enterprise event fabric has immediate operational benefits. Observability tooling can be written once and applied consistently across event sources. Routing rules can reference standardised metadata fields. Audit logs can correlate events from different systems without manual field mapping. IBM Event Streams, IBM's managed Kafka service, supports CloudEvents as a standard envelope format, enabling enterprises to build observability and compliance tooling that operates uniformly across the event fabric [14].

![Figure 6.3 — Kafka topic architecture with zone-aware partitioning, consumer groups and retention policies](images/figure-6-3.png)

**Events as multi-subscriber operational signals.** A particularly powerful property of a well-designed event fabric is that a single event can be consumed simultaneously by multiple subscribers with different concerns. Consider a configuration change event emitted by a platform control plane when an API gateway route is modified. A security auditing subscriber receives the event and writes it to an immutable audit log. An observability correlation subscriber receives the same event and annotates its incident timeline, allowing operators to see that a configuration change coincided with a latency anomaly. A compliance checking subscriber evaluates the change against policy constraints and raises a finding if the new route would expose a regulated endpoint without the appropriate authorisation controls. All three subscribers act on the same event without the originating system needing to know about any of them. The event fabric provides the decoupling; the CloudEvents schema provides the interoperability; the Kafka consumer group model provides the delivery guarantees.

Take an e‑commerce example. Every significant change in the lifecycle of an order emits an event: order placed, payment authorised, inventory reserved, shipment dispatched, delivery confirmed, return requested. These events are consumed by various services to update state, trigger actions and maintain projections. But they can also be consumed by the operations fabric [10].

By monitoring event streams, observability and AIOps platforms can detect anomalies in **rates** (a sudden drop in "PaymentAuthorised" events may indicate a payment gateway issue), anomalies in **latencies** (increasing delay between "OrderPlaced" and "InventoryReserved" may suggest problems in inventory services or dependencies), and anomalies in **patterns** (spikes in "FraudCheckFailed" from a specific region may hint at attacks or misconfigurations).

Because these events are semantic, they carry more immediate meaning for both humans and agents than low‑level metrics alone. An SRE can glance at an event dashboard and see that "orders are being placed, but payments are failing," which is a more actionable statement than "error rate on service X has increased" [2].

Events also support **recovery and reconciliation**. If a downstream service is offline or degraded, it can catch up by replaying missed events when restored. The operations team can query the event log to determine which business entities were affected during an incident. In regulated environments, event logs can provide evidence of what was or was not done at particular times [10].

**IBM Event Streams** is IBM's managed Kafka service, available within sovereign-zone deployments where the event fabric must itself remain within jurisdictional boundaries [14]. Beyond the standard Kafka capabilities, Event Streams provides MirrorMaker 2 replication for cross-zone event propagation with configurable topic filtering—a mechanism for controlling which events cross zone boundaries and which remain local. This is directly relevant to sovereignty: a payment event containing personal data may be retained within its origin zone while a derived, anonymised analytics event is permitted to propagate to a cross-zone analytics fabric. The zone-aware deployment model, combined with schema registry integration, gives architects a principled way to enforce data residency at the event-fabric level rather than relying solely on network controls.

For agentic operations, events are a natural input. An operations agent investigating an incident can start from event anomalies ("payments failing since 10:32 UTC") and correlate them with topology and metrics. A resilience‑focused system can correlate event anomalies with known risks and failure modes. The combination of event‑level insight and infrastructure‑level telemetry provides a richer basis for AI‑assisted reasoning than either alone [8].

***

## 6.5 Lineage as an operational and sovereign control

Lineage—knowing how data moved and transformed—is often discussed in the context of analytics and compliance. In a zero‑copy world, it becomes an operational tool as well [8].

**OpenLineage.** The absence of a universal standard for lineage metadata has historically been one of the primary obstacles to operationalising data lineage at scale. Each orchestration platform, ETL tool and query engine has produced its own lineage representation, making cross-platform lineage graphs difficult to assemble and maintain. The OpenLineage specification, published under the Linux Foundation, addresses this by defining a common model for capturing lineage events at the job and dataset level [15]. An OpenLineage event is emitted when a job starts, completes or fails; it identifies the input datasets consumed, the output datasets produced, and—where available—the transformation logic applied. The specification is transport-agnostic: events can be emitted over HTTP to a compatible backend, or can be written to a Kafka topic for consumption by lineage aggregation services.

The OpenLineage data model distinguishes between **runs** (individual executions of a job), **jobs** (logical transformation units, such as a Spark job or a dbt model), and **datasets** (the inputs and outputs, identified by namespace and name). This three-level hierarchy is sufficiently expressive to represent both simple pipeline stages and complex multi-step transformation graphs. The Marquez project, also hosted by the Linux Foundation, provides a reference implementation of an OpenLineage-compatible metadata store with a REST API and a lineage graph visualisation [15].

In copy‑heavy estates, lineage diagrams can be daunting webs. In zero‑copy estates, the web is smaller but still complex enough that intuition alone is insufficient. A change in one service's schema may affect downstream projections; a policy change in one zone may impact what events are published across boundaries [1].

Operationally, lineage answers questions that no other data source can: "Which downstream services were affected by this schema change?" is a question about the forward-propagation of a change through the lineage graph—which jobs read from the modified dataset, and which datasets those jobs produce. Answering it without a lineage graph requires manual interrogation of pipeline configurations or source code, a process that is slow, error-prone and frequently incomplete. With an OpenLineage-compatible metadata store, the same query becomes a graph traversal: starting from the modified dataset, follow all edges representing job outputs to their downstream datasets, recursively, until the full impact surface is enumerated [15].

"Which systems read this dataset before the incident?" is a retrospective question, asking which jobs consumed a specific dataset within a given time window. This is the lineage equivalent of a security access log: a record of which principals accessed which data and when. In an incident involving data quality or potential data exfiltration, this record is the foundation of the investigation. OpenLineage's run-level granularity—with start and end timestamps for each job execution—supports this kind of temporal query directly.

**Lineage as regulatory evidence.** The UK GDPR and EU GDPR both impose restrictions on the transfer of personal data to third countries [6]. Demonstrating compliance with these restrictions requires not only that the right policies are in place, but that there is evidence of which data flows actually occurred. A lineage graph maintained by an OpenLineage-compatible system provides exactly this: an auditable record of which datasets were produced from which sources, by which jobs, at which times, and—where the namespace convention identifies zone boundaries—whether any cross-boundary flows occurred. The Information Commissioner's Office's guidance on international transfers explicitly anticipates that organisations should be able to demonstrate the actual routes by which data has flowed, not merely the intended routes [7]. A maintained OpenLineage record is far more credible evidence than a data flow diagram drawn by an architect.

NIST Special Publication 800-188, "De-Identifying Government Datasets," provides relevant guidance on a related matter: when observability telemetry or lineage metadata itself contains personal data, de-identification techniques must be applied to prevent the compliance tooling from becoming a compliance liability [16]. In practice, this means that job names, dataset identifiers and run parameters included in OpenLineage events should be reviewed to ensure they do not embed personal identifiers—a consideration that is easy to overlook when pipeline metadata is treated as purely technical rather than potentially sensitive.

**Integration with Concert.** IBM Concert's topology model—its understanding of how applications, services, datasets and infrastructure components relate—is significantly enriched when lineage metadata is available as an input [17]. A topology that shows only runtime dependencies (which service calls which API) is incomplete from an operational perspective. When lineage metadata from an OpenLineage-compatible source is integrated, Concert can show not only how services interact at the API level, but which datasets flow between them and how those datasets are derived from upstream sources. This enriched topology supports more precise impact analysis when a component fails or a policy change is applied, and it gives Concert's AI-assisted resilience scoring a richer substrate from which to identify hidden dependencies and concentration risks.

From a sovereignty standpoint, lineage is how we **prove** that data has not crossed certain boundaries or been used in prohibited ways. In a zero‑copy architecture, where copies are limited and controlled, lineage is simpler but more critical. The few sanctioned replication paths and event exports must be well understood and monitored [8].

When lineage metadata is available to the operations plane, it enhances incident response. During an incident involving data quality or policy violation, agents and humans can see not just where symptoms appear, but how data reached those points. This supports more precise remediation—fixing or disabling the right transformation, pausing the correct stream—rather than blunt measures.

Zero‑copy architectures tend to encourage the use of platforms that can provide lineage out of the box—API gateways with request logging, event brokers with durable logs, virtualisation layers that track query patterns. When that lineage is integrated into operations tooling, it becomes part of the feedback loop: a way to understand and refine how the estate behaves over time. IBM StreamSets [23], as a data integration engine, complements this by providing sovereign-aware data pipelines with declarative routing policies that direct data flows along zone-scoped paths. StreamSets pipelines emit OpenLineage-compatible events at each stage, ensuring that even the residual data movement that a zero-copy architecture still requires — CDC feeds, reference data synchronisation, permitted cross-zone transfers — is fully instrumented and subject to the same lineage governance as the in-place access patterns.

***

![Figure 6.2 — Event-driven lineage: how a single event propagates through the operational fabric](images/figure-6-2.png)
> A directed graph showing a source system emitting a CloudEvents-formatted event onto a Kafka topic, with downstream consumers representing the observability correlator, compliance checker, audit log writer, and lineage recorder each receiving the same event independently, illustrating the fan-out model of operational signal propagation.

***

## 6.6 Zero‑copy and the network: performance and fragility

Because zero‑copy relies on live access, the **network** is intimately involved. A query that would have been served from a local mart in a copy‑heavy design might now traverse a cross‑region or cross‑cloud path to reach the system of record. An event that would have been buried in a batch file now flows through an event mesh [18].

This tight coupling has two opposing effects.

On the positive side, it makes performance problems more **visible**. Latency issues show up immediately in application metrics and event timings. There is less room for "silent failure" where a pipeline is broken but no one notices for a day. If a link between two zones is congested, the impact is felt quickly and can be investigated [2].

On the negative side, it increases **sensitivity**. Brief network disturbances can ripple through user journeys. Subtle increases in jitter or packet loss along critical paths can degrade perceived responsiveness before anyone raises an alarm. If topology is not designed with appropriate locality—co‑locating chatty services and data—network costs and latencies can become a constant headache.

This is why Chapter 5 emphasises latency budgets and data gravity. Zero‑copy does not mean "ignore proximity"; it means "stop hiding proximity problems behind copies and address them directly." It also explains why network observability is a core part of the operations architecture. Tools that can trace requests across services and show network contributions to latency become essential. Resilience and placement decisions must incorporate network‑aware information rather than only CPU and memory.

In sovereign operations, network paths are also policy instruments. Zero‑copy architectures make it easier to reason about where data is accessed; the network design must ensure that those access paths respect jurisdictional boundaries. An elegant zero‑copy design that routinely sends sensitive queries across non‑compliant links is not sovereign in practice [3].

Apache Arrow's columnar in-memory format deserves mention here as a technical enabler of performant zero-copy access patterns [19]. When analytical queries must be served from a system of record without materialising a copy, the efficiency of the in-place read is critical. Arrow's columnar layout enables vectorised computation on data without per-row deserialization overhead, and its inter-process communication (IPC) format allows data to be passed between processes—including across language boundaries—without copying the underlying buffer. Apache Parquet, the columnar storage format that Arrow complements, enables efficient predicate pushdown and column pruning in analytical reads, so that a query accessing a subset of columns from a large dataset need not read the full record width [20]. Together, Arrow and Parquet represent the technical foundation for making zero-copy access to large analytical datasets operationally viable, not merely architecturally desirable.

![Figure 6.5 — Network sensitivity in zero-copy architectures: latency paths and data gravity effects across sovereign zones](images/figure-6-5.png)

IBM DataStage and IBM Data Fabric extend these principles into enterprise data virtualisation, providing query federation across heterogeneous sources—relational databases, object stores, mainframe datasets—through a unified access layer [21]. From a zero-copy perspective, virtualisation is the mechanism by which in-place access is made possible without requiring source systems to adopt new protocols or expose raw query interfaces. The virtualisation layer handles translation, optimisation and access control, presenting a consistent query surface to consumers while leaving the data in situ. Operationally, this means that the number of access patterns that must be monitored and governed is reduced to the virtualisation layer's query log rather than to the individual access logs of each source system.

IBM watsonx.data [22] brings an open data lakehouse architecture to this virtualisation layer, built on open table formats (Apache Iceberg) and open query engines (Presto, Spark) that federate analytical queries across data sources residing in different sovereign zones without requiring the data to be copied into a central store. For zero-copy sovereignty, watsonx.data's fit-for-purpose engine approach is particularly relevant: queries are routed to the engine best suited to the data source and workload type, while zone-level access policies ensure that a federated query cannot materialise results containing regulated data outside the zone in which that data resides. The lakehouse's metadata layer maintains a unified catalogue of datasets across zones, giving Concert's topology model visibility into analytical data dependencies that would otherwise be invisible to the operational plane.

***

## 6.7 How agents exploit a zero‑copy substrate

Agentic operations reach their full potential in a zero‑copy environment because the information landscape is more coherent.

When an operations agent is asked to investigate a slowdown in a customer journey, it can query observability for real‑time metrics on the relevant services [2], inspect event streams to see where semantic delays or failures occur [10], consult topology and lineage to understand which systems of record and transformations are involved [8], and propose changes—scaling a particular service, adjusting a timeout, rerouting traffic—that are precisely targeted.

In a copy‑heavy estate, the same agent would struggle. It would have to disentangle multiple copies and pipelines, many of which may not be fully instrumented or documented. Its recommendations would be less precise; its confidence, lower [1].

Zero‑copy also makes it easier to **govern** agents. When data is centralised under strong access control, it is simpler to enforce which agents may access what. Policies like "this agent may use anonymised aggregates but not raw records" are more enforceable when there is one place to apply them, rather than dozens of replicated stores [9].

In this sense, zero‑copy is not just friendly to agents; it is an enabler of **safe** agentic operations.

![Figure 6.4 — Agent reasoning over a zero-copy substrate: how coherent data topology enables precise, targeted remediation](images/figure-6-4.png)

***

## 6.8 Zero‑copy as a design constraint for sovereign operations

Seen through the lens of this book, zero‑copy is no longer a purely architectural preference. It becomes a **design constraint** for sovereign operations.

If an organisation aspires to have clear visibility into how business events flow, coherent control over where and how data is accessed, effective AI‑assisted incident detection and remediation, and demonstrable compliance with sovereignty and data protection obligations, then a copy‑heavy, pipeline‑dominated integration estate will constantly undermine those goals. It will bury signals, multiply control surfaces and resist coherent reasoning [1].

By contrast, a zero‑copy substrate concentrates access into well‑governed interfaces [9], produces meaningful events and lineage [8], reduces the number of systems that must be considered during an incident [3], and makes it easier to prove that certain classes of data never left certain zones [15].

It is not a silver bullet. There will still be legitimate reasons to replicate data in controlled ways. Legacy systems will linger. Migration will take time. But as a direction of travel, zero‑copy provides a north star that aligns architectural, operational and regulatory interests.

The rest of this book will assume that you are either on that path or see its necessity. When we talk about observability, we will often mean observability of events and in‑place access. When we talk about automation, we will assume that many changes are about adjusting live fabric rather than manipulating copies. When we talk about agentic operations, we will picture agents reasoning over a landscape shaped by zero‑copy principles [2].

In that sense, zero‑copy integration is not just an underpinning technology. It is the **terrain** on which sovereign, agentic operations must learn to move.

***

## 6.9 Zero‑copy in practice: a worked example

To make these principles concrete, consider what happens when a retail payment transaction flows through a zero‑copy architecture from origination to regulatory compliance check, without a copy of the payment record being created.

A customer initiates a payment through a mobile application. The request arrives at an API gateway, which authenticates the caller, applies rate-limiting policy and forwards the request to the payment orchestration service. The payment orchestration service reads the customer's current account standing directly from the account service—not from a mart or cache—using a virtualised query layer that enforces row-level access control based on the caller's identity and the account's jurisdiction. Because the account service sits within the same sovereignty zone as the payment orchestration service, this read does not cross a zone boundary, and no data residency policy is triggered. The query is handled by the virtualisation layer using Apache Arrow's IPC format, which passes the relevant account fields to the orchestration service without serialising and deserialising through an intermediate format [19].

The payment orchestration service issues the payment instruction to the payment gateway and, upon receiving confirmation, emits a single CloudEvents-formatted event to the enterprise event fabric [13]. The event's `type` is `com.enterprise.payment.authorised`; its `source` identifies the payment orchestration service by URI; its `time` captures the authorisation timestamp in RFC 3339 format; and its `data` section carries the payment reference, amount, currency, merchant category code and the zone identifier of the originating service. The event does not carry the customer's name, address, card number or any other personal identifier beyond the pseudonymised customer reference. The payment record itself remains in the account service; the event carries only the metadata necessary for downstream systems to identify the transaction and retrieve further detail through governed access if they require it.

This single event is simultaneously consumed by four subscribers, each operating within their own consumer group and therefore receiving an independent copy of the event without any subscriber affecting the others' position in the log [11]. The observability correlator receives the event and records it in the operational timeline, noting that a payment authorisation occurred at a specific timestamp and correlating it with the latency metrics being reported by the payment gateway at the same moment. This correlation is available to any engineer or agent investigating payment gateway performance within seconds of the event being emitted.

The compliance monitoring service receives the same event and evaluates it against a set of declarative rules: does the payment amount exceed the threshold that triggers enhanced due-diligence reporting? Does the merchant category code match any restricted category for this customer's account jurisdiction? Does the zone identifier on the event match the zone identifier recorded in the customer's consent record? All three evaluations complete within the same second as the payment authorisation. If any rule triggers, the compliance service emits a secondary event to a compliance alert topic, which is consumed by the case management system; no human intervention is required to initiate the compliance workflow.

The audit log writer receives the event and appends it, in immutable form, to the zone-local audit store. Because the event carries only pseudonymised identifiers, the audit record satisfies the data minimisation principle under UK GDPR Article 5 while still being sufficient for regulatory inspection purposes [6]. NIST SP 800-188 guidance on de-identification provides the technical basis for asserting that the pseudonymised reference in the audit record does not constitute personal data in isolation [16].

The OpenLineage lineage recorder receives the event and notes that the payment orchestration service produced a payment authorisation event from inputs that included the account service's account-standing query. It records the job run, the input dataset (the account service query endpoint, identified by namespace and name), and the output dataset (the payment event topic) [15]. This lineage entry is immediately available for impact analysis: if the account service schema is subsequently changed, the lineage graph will identify the payment orchestration service as a downstream consumer that must be assessed for compatibility.

At no point in this flow was a copy of the payment record created. The account service remains the sole authoritative store of the account state. The event fabric carries event metadata, not replicated records. The compliance, observability and audit systems consume the event and operate within their own domains without requiring write access to any other system's data. The lineage record is derived from the event and stored in the lineage metadata store, not from any replication of the payment record itself. When the customer exercises their right of access under UK GDPR Article 15, the organisation can respond by reading directly from the account service, which holds the ground truth, rather than attempting to reconcile multiple copies across a sprawl of downstream stores [6].

This is not a theoretical architecture. Every component described—the CloudEvents-formatted event, the Kafka consumer group model, the OpenLineage lineage recorder, the virtualisation layer enabling in-place account reads—is available today using the standards and products described in this chapter. The discipline required is not primarily technical; it is the organisational commitment to treat the event fabric as the canonical propagation mechanism rather than as a supplement to batch copying.

***

## 6.10 Data gravity, honest scope and the authorised-copy pattern

### What zero-copy covers — and what it does not

The preceding sections present a compelling case for zero-copy integration as the operational substrate for sovereign cloud estates. It is important, however, to be intellectually honest about where that principle applies and where it encounters hard physical and economic limits.

Zero-copy is an architectural principle for **operational data**. It works well — and should be the default — for metrics, logs, traces, events, topology data, configuration artefacts, policy definitions, lineage metadata, compliance evidence and the telemetry that feeds agentic reasoning. These datasets are characterised by modest record sizes, high velocity, wide fan-out and a need for real-time or near-real-time access. For them, in-place access via APIs, virtualisation and event streaming is superior to copying on every relevant dimension: freshness, consistency, auditability and compliance surface area.

Zero-copy has structural limits, however, for a different class of workload. Multi-petabyte analytical data lakes, machine-learning training corpora, data warehouse ETL pipelines and batch analytics that require tight co-location of compute and storage operate under constraints that no amount of architectural elegance can override. When fifty petabytes of transaction history sit in an object store in a specific sovereign zone, the processing must happen where the data is. This is the principle of **data gravity** — a term coined by Dave McCrory to describe the observation that data, like a celestial body, attracts applications, services and further data in proportion to its mass [24]. At petabyte scale, moving compute to data is orders of magnitude cheaper than moving data to compute. Cross-zone queries against remote multi-petabyte stores incur network egress costs that can dwarf the cost of the analysis itself, and latencies that make interactive or even batch-window queries impractical. This is physics and economics, not a solvable architectural problem.

A storage architect who has spent a decade managing petabyte-scale data platforms will rightly dismiss any framework that ignores data gravity. The honest position is that zero-copy reduces unnecessary data proliferation by eighty to ninety per cent, but the remaining ten to twenty per cent of data movement must be explicitly governed, not eliminated. The architecture's value lies in making every copy visible, justified and governed — not in pretending that copies never need to happen.

### The authorised-copy pattern

For analytical workloads where data gravity demands co-location of compute and storage, the zero-copy architecture accommodates a governed exception: the **authorised copy**. This is not a retreat from the zero-copy principle; it is the disciplined complement that makes the principle credible in the real world.

An authorised copy differs from the ad-hoc replication of a copy-heavy estate in every dimension that matters. Each copy is **explicitly approved** through a data governance workflow — there is no self-service replication without oversight. Each copy is **classified** according to the organisation's data classification scheme, inheriting the sensitivity labels and handling restrictions of the source dataset. Each copy is **tracked** in the data lineage graph: the OpenLineage record captures what was copied, from which source, to which destination, by which principal, for which stated purpose and with which expiry date [15]. Each copy has a **defined lifetime** — a retention policy attached at creation, enforced by automated policy rather than by manual housekeeping. And each copy is subject to the same **sovereign zone policies** as any other data movement: if the source data is restricted to a particular jurisdiction, the copy may only be created within a zone that satisfies the same residency and sovereignty constraints.

The lineage system transforms a copy from a liability into a governed artefact. When an analyst in a European sovereign zone requests a subset of a North American transaction dataset for regulatory modelling, the authorised-copy workflow records the provenance chain end to end: source dataset, transformation applied (aggregation, pseudonymisation, column filtering), destination, requesting and approving principals, purpose code, retention period and the policy rules evaluated to permit the transfer. If a regulator asks where copies of that dataset exist, the answer is a graph query rather than an archaeological expedition. If the retention period expires, the automated policy engine deletes the copy and records the deletion in the same lineage graph. The copy's entire lifecycle — creation, access, expiry, deletion — is auditable.

### Federated query as the middle ground

Between pure zero-copy access and full authorised copies lies a middle ground. Federated query engines — including watsonx.data's Presto and Spark engines [22], Starburst, Trino and Dremio — execute analytical queries across data residing in multiple stores and sovereign zones, pushing predicates and aggregations down to the source engines and returning only the result set to the requesting zone. For moderate-scale analytical queries — reports, dashboards, ad-hoc investigations involving gigabytes to low terabytes of source data — federation delivers acceptable performance without any data copying.

Federation has its own limits. Queries requiring full-table scans of petabyte-scale datasets, complex multi-way joins across zones, or iterative machine-learning training loops that make hundreds of passes over the same data will not perform adequately through a federation layer alone. This is where the authorised-copy pattern takes over: the data is copied once, under governance, to a location where compute can operate at local-storage speeds, and the copy is retired when the analysis is complete [25].

The practical architecture therefore operates on a spectrum. At one end, operational telemetry and event data flow through the zero-copy substrate with no copies at all. In the middle, moderate-scale analytics are served by federated query engines that access data in place. At the far end, large-scale analytical and machine-learning workloads use authorised copies with full lineage governance. The zero-copy principle is not violated by the existence of this spectrum; it is *fulfilled* by it, because every point on the spectrum is governed, visible and auditable. The alternative — the copy-heavy estate where data replicates without oversight — is what zero-copy exists to prevent [26].

***

## Key Takeaways

- Copy-heavy integration estates impose a compounding "data copy tax" in the form of storage cost, synchronisation lag, consistency failures and expanded regulatory compliance surface area; each copy of personal data is, in UK GDPR terms, a separate instance of processing subject to the data minimisation principle [6].

- ETL pipelines are operational liabilities because their scheduled, batch nature enables silent failures and schema drift to accumulate undetected; debugging a corrupted downstream dataset in a pipeline-heavy estate routinely requires cross-team, cross-tool investigation that can take days [4].

- A zero-copy substrate, built on in-place data access, event-driven propagation and deliberate limited replication, is structurally simpler and compliance-friendlier than a copy-heavy estate, but demands more disciplined observability and change management because it offers less slack in the system [3].

- Apache Kafka's topic, partition and consumer group model provides the delivery guarantees and horizontal scalability that enterprise event streaming requires; the CloudEvents specification provides the standardised metadata envelope that makes event-driven observability and compliance tooling portable across platforms [11][13].

- OpenLineage provides the open standard for capturing data lineage at the job and dataset level; a maintained lineage record is both an operational tool for impact analysis and regulatory evidence that data flows comply with transfer restrictions under UK and EU GDPR [15][6].

- IBM Event Streams and IBM Data Fabric provide the sovereign-zone-aware implementations of these capabilities within the IBM stack, enabling organisations to deploy event streaming and data virtualisation under customer-controlled operational authority within jurisdictional boundaries [14][21].

- Agentic operations are significantly more effective in a zero-copy estate because the information landscape is more coherent: fewer copies to disentangle, richer event signals to reason over, and more precisely targeted remediation actions available to AI-assisted systems [17].

- Zero-copy is the right principle for operational data — telemetry, events, lineage metadata, configuration and policy artefacts — but it cannot eliminate all data movement for multi-petabyte analytical workloads where data gravity dictates that compute must move to the data; intellectual honesty about this scope is essential to the architecture's credibility with practitioners [24].

- Where data co-location is unavoidable, the authorised-copy pattern provides a governed exception: each copy is explicitly approved, classified, tracked in the OpenLineage lineage graph with full provenance, given a defined retention lifetime and subject to the same sovereign zone policies as any other data movement — transforming copies from uncontrolled liabilities into auditable, time-bounded artefacts [15][26].

- Federated query engines (watsonx.data, Trino, Starburst, Dremio) occupy the middle ground between pure zero-copy access and full authorised copies, serving moderate-scale analytical queries by pushing computation to source data without moving it, though they reach performance limits at extreme scale [22][25].

***

## Bridge to Chapter 7 — Observability Architecture

This chapter has established zero-copy integration not merely as an architectural preference but as the operational substrate on which sovereignty, observability and agentic assistance depend. The argument is cumulative: copy-heavy estates are fragile because they multiply failure points, expand compliance surface area and obscure data lineage; event-driven architectures, built on standards such as Kafka, CloudEvents and OpenLineage, replace batch propagation with real-time signal flow and replace opaque pipeline graphs with auditable lineage records; and the resulting estate is one in which agents can reason coherently, regulators can be answered precisely, and operators can investigate incidents without first reconstructing the history of a dozen ETL jobs.

The worked example in Section 6.9 illustrates that these are not aspirational patterns: every component is available today, and the discipline required is primarily organisational rather than technical.

Chapter 7 builds directly on this foundation. With a zero-copy substrate in place—where state changes propagate as events, data is accessed in situ, and lineage is recorded systematically—the observability architecture can be designed to operate at a different level of fidelity and intelligence. Instead of treating observability as an afterthought applied to opaque pipelines, Chapter 7 describes how to instrument a zero-copy estate so that the observability plane itself becomes sovereignty-aware: understanding not only what is happening, but where, under whose authority, and whether that behaviour is consistent with the organisation's regulatory commitments. The design principles for a sovereignty-aware observability architecture are the subject of that chapter.

***

## References

[1] D. Demers, "Zero-Copy Integration: Origin, Evolution and Impact," LinkedIn Pulse, 2023.

[2] New Relic, "Why Observability Matters for Event-Driven Architecture," New Relic Blog, 2023. [Online]. Available: https://newrelic.com/blog/infrastructure-monitoring/why-observability-matters-for-event-driven-architecture

[3] Cognixia, "What Is Zero-Copy Integration for Enterprise APIs?" Cognixia Blog, 2023. [Online]. Available: https://www.cognixia.com/blog/what-is-zero-copy-integration-for-enterprise-apis/

[4] M. Kleppmann, *Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems*. Sebastopol, CA: O'Reilly Media, 2017.

[5] TechRepublic, "Zero-Copy Integration: David vs. Goliath," TechRepublic, 2023. [Online]. Available: https://www.techrepublic.com/article/zero-copy-integration-david-goliath/

[6] UK General Data Protection Regulation (UK GDPR), Article 5 (Data Minimisation Principle), Article 15 (Right of Access), Article 46 (International Transfers). Retained under the European Union (Withdrawal) Act 2018, as amended by the Data Protection, Privacy and Electronic Communications (Amendments etc) (EU Exit) Regulations 2019.

[7] UK Information Commissioner's Office (ICO), "Guide to the UK GDPR: Principle (c) – Data Minimisation," ICO, 2023. [Online]. Available: https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/data-protection-principles/a-guide-to-the-data-protection-principles/the-principles/data-minimisation/

[8] Secoda, "Data Lineage vs. Data Observability," Secoda Blog, 2023. [Online]. Available: https://www.secoda.co/blog/data-lineage-vs-data-observability

[9] Salesforce, "Zero Copy Partner Network: Architect's Guide," Salesforce, 2023. [Online]. Available: https://www.salesforce.com/data/zero-copy-partner-network/guide/

[10] Kurrent, "Benefits of Event Sourcing," Kurrent Blog, 2023. [Online]. Available: https://www.kurrent.io/blog/benefits-of-event-sourcing/

[11] Apache Software Foundation, "Apache Kafka Documentation," Apache Kafka, version 3.7, 2024. [Online]. Available: https://kafka.apache.org/documentation/

[12] IBM, "IBM Event Streams Documentation," IBM, 2024. [Online]. Available: https://ibm.github.io/event-streams/

[13] Cloud Native Computing Foundation (CNCF), "CloudEvents Specification v1.0.2," CNCF, 2022. [Online]. Available: https://cloudevents.io/

[14] IBM, "IBM Event Streams: Managed Apache Kafka on IBM Cloud," IBM Cloud Documentation, 2024. [Online]. Available: https://cloud.ibm.com/docs/EventStreams

[15] Linux Foundation, "OpenLineage Specification," OpenLineage Project, 2024. [Online]. Available: https://openlineage.io/

[16] National Institute of Standards and Technology (NIST), *De-Identifying Government Datasets*, NIST Special Publication 800-188, Gaithersburg, MD: NIST, 2016.

[17] IBM, "IBM Concert: AI-Powered Application Resilience Management," IBM Product Documentation, 2024. [Online]. Available: https://www.ibm.com/docs/en/concert

[18] TechHQ, "Data Gravity Won't Stop the Move to Multi-Cloud: Here's Why," TechHQ, 2023. [Online]. Available: https://techhq.com/news/data-gravity-wont-stop-the-move-to-multi-cloud-heres-why/

[19] Apache Software Foundation, "Apache Arrow: Columnar In-Memory Analytics," Apache Arrow Documentation, 2024. [Online]. Available: https://arrow.apache.org/docs/

[20] Apache Software Foundation, "Apache Parquet: Columnar Storage Format," Apache Parquet Documentation, 2024. [Online]. Available: https://parquet.apache.org/docs/

[21] IBM, "IBM Data Fabric and IBM DataStage Documentation," IBM, 2024. [Online]. Available: https://www.ibm.com/products/datastage

[22] IBM Corporation, "IBM watsonx.data: Open Data Lakehouse for AI and Analytics," IBM Documentation, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/products/watsonx-data

[23] IBM Corporation, "IBM StreamSets: Data Integration and Pipeline Management," IBM Documentation, Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/products/streamsets

[24] D. McCrory, "Data Gravity — In the Clouds," *Data Gravity Blog*, 2010. [Online]. Available: https://datagravity.org/2010/12/18/data-gravity-in-the-clouds/

[25] A. Lakshman and P. Malik, "Cassandra: A Decentralized Structured Storage System," *ACM SIGOPS Operating Systems Review*, vol. 44, no. 2, pp. 35–40, 2010. (Cited for the general principle that distributed query performance degrades as data volume and network distance increase, motivating compute-to-data placement strategies.)

[26] DAMA International, *DAMA-DMBOK: Data Management Body of Knowledge*, 2nd ed. Basking Ridge, NJ: Technics Publications, 2017. (Chapter 8: Data Integration and Interoperability; Chapter 13: Data Quality; guidance on governed replication and data movement policies.)
