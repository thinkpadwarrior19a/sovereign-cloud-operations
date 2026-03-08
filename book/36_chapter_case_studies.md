# Chapter 36 — Case Studies in Sovereign Operations

***

## Summary

This chapter presents five composite case studies — drawn from patterns observed across real organisations in banking, healthcare, insurance, government digital services and critical infrastructure — that illustrate how sovereign operations programmes unfold in practice, including their false starts, organisational friction and hard-won outcomes. Each study follows a consistent structure of context, challenge, approach, implementation, outcomes and lessons, grounding the book's architectural principles in concrete operational narratives with quantitative results. Cross-cutting lessons distilled from the five cases reinforce that observability must precede automation, that zero-copy integration is a sovereignty enabler, that policy-as-code requires iterative refinement under real conditions, and that organisational and cultural change is at least as demanding as the technical migration.

***

## 36.1 How to read these case studies

The preceding chapters of this book have built a conceptual and architectural framework: sovereign zones, zero-copy integration, observability planes, policy-as-code, agentic operations, progressive autonomy, and the platforms that support them. Frameworks, however, are abstractions. They explain what ought to be done and why, but they do not show what it feels like to do it—the false starts, the organisational friction, the moments when an architecture diagram meets a legacy estate and something has to give.

This chapter offers five composite case studies. Each is a fictionalised narrative constructed from patterns observed across multiple real organisations in different industries and geographies. No single organisation experienced exactly the sequence of events described; names, jurisdictions, and technical details have been altered and combined to create coherent stories that illustrate the challenges and trade-offs that recur in sovereign operations programmes. These are not vendor success stories. They include mistakes, delays, and unresolved tensions alongside genuine progress [1].

Each case study follows a consistent structure:

- **Context** — the organisation, its operating environment, and the regulatory landscape it inhabits.
- **Challenge** — the specific operational and architectural problems that prompted action.
- **Approach** — the design decisions, technology choices, and organisational changes adopted.
- **Implementation** — how the programme unfolded in practice, including difficulties encountered.
- **Outcomes** — measurable results, expressed quantitatively where the patterns support it.
- **Lessons** — what the organisation learned that may be transferable to other contexts.

A note on quantitative outcomes: the figures cited are representative of what organisations in similar situations have achieved, derived from published benchmarks, industry reports, and practitioner accounts [2][3]. They are not guaranteed results. They are included because architectural narratives without measurable consequences tend to remain aspirational rather than actionable.

***

## 36.2 Case Study A: European banking group

### Context

Europan Financial Holdings (EFH) is a composite representing a mid-tier European banking group with retail and corporate banking operations across three EU member states—Germany, France, and the Netherlands—and a smaller presence in the United Kingdom. Its technology estate spans two major public cloud providers, three on-premises data centres of varying vintage, and a mainframe environment that still processes a significant proportion of batch settlement operations. The group employs approximately 3,200 technology staff across its subsidiaries, each of which had historically operated with substantial autonomy over its own infrastructure and tooling.

EFH operates under GDPR, PSD2, and the national implementations of DORA across its jurisdictions. Its regulators had, in successive supervisory reviews, raised concerns about the group's ability to demonstrate operational resilience across its multi-entity, multi-country estate—particularly around incident response times, the visibility of cross-border dependencies, and the proliferation of uncontrolled data copies used for analytics and reporting.

### Challenge

Three problems converged. First, the group's integration landscape had grown into what its chief architect described as "a copy factory." Transaction data from core banking systems was replicated nightly into fourteen separate analytical stores across the three countries, each maintained by a different team, each with its own retention policies, and several with unclear data lineage. When a GDPR subject access request arrived, identifying all locations where a customer's data resided required manual investigation that typically took two to three weeks.

Second, observability was fragmented. Each subsidiary operated its own monitoring stack—a mixture of Prometheus, Grafana, legacy Nagios installations, and vendor-specific tools. There was no unified view of service health across the group, and when an incident in the German subsidiary's payment processing affected downstream services in the Dutch entity, it took an average of forty-seven minutes to establish that the two events were related.

Third, the group had no coherent sovereign zone architecture. Data residency was managed through a patchwork of contractual clauses, manual deployment checks, and spreadsheet-based registers of where workloads ran. Regulators in one jurisdiction had begun asking pointed questions about whether telemetry data—logs containing transaction identifiers—was being exported to a centralised logging platform hosted in a different country.

### Approach

EFH's architecture team designed a programme around three pillars: sovereign zone definition, zero-copy integration, and unified operational intelligence.

**Sovereign zones** were defined at the jurisdictional level: a German zone, a French zone, a Dutch zone, and a UK zone. Each zone was implemented as a set of OpenShift clusters and associated cloud accounts with explicit network boundaries, zone-local identity providers, and zone-local observability backends. The zone boundaries were encoded in infrastructure as code using Terraform modules and enforced through Open Policy Agent (OPA) policies that prevented workload deployment outside the designated zone without explicit exception approval [4].

**Zero-copy integration** replaced the nightly batch replication model. Core banking systems in each zone exposed governed APIs and event streams through an Apache Kafka-based event mesh. Downstream consumers—risk, reporting, anti-money laundering, marketing analytics—were migrated from owning copies of raw transaction tables to subscribing to event streams and maintaining projections. The event mesh was configured with zone-aware topic routing: events containing customer-identifiable data remained within their originating zone, while anonymised aggregates could be consumed cross-zone for group-level reporting [5].

**Unified operational intelligence** was implemented through IBM Concert, deployed as a group-wide reasoning layer that ingested signals from Instana agents running in each sovereign zone. Critically, Concert's architecture respected zone boundaries: raw telemetry remained in zone-local Instana backends, while Concert consumed aggregated metrics, topology information, and situation summaries through zone-aware integration points. This design satisfied the regulators' concerns about telemetry export while providing the group-wide operational visibility that had previously been absent.

![EFH sovereign zone architecture with zone-local observability and group-level Concert reasoning layer](images/figure-36-1.png)

### Implementation

The programme ran over eighteen months, and its trajectory was not linear.

The first six months focused on the German zone as a pilot. The team stood up the first sovereign OpenShift cluster, migrated two payment processing services into it, deployed Instana with zone-local storage, and implemented the first zero-copy event streams for transaction reporting. The pilot surfaced two significant problems. First, the OPA policies for zone boundary enforcement were initially too coarse, blocking legitimate cross-zone API calls needed for group-level treasury operations. The team spent three weeks refining the policy model to distinguish between data-carrying flows that required zone containment and metadata flows that could safely cross boundaries. Second, the migration from batch replication to event streams required downstream analytics teams to rewrite their data pipelines, and several teams resisted until the programme secured executive sponsorship to fund their migration effort.

Months seven through twelve extended the pattern to France and the Netherlands, while deepening the German implementation. Concert was deployed during this phase, initially in a read-only advisory mode. Its first contribution was topological: within two weeks of deployment, Concert's discovery process identified eleven cross-zone dependencies that the architecture team had not documented—services in the German zone making API calls to endpoints hosted in the French subsidiary's cloud accounts, established years earlier and forgotten. Remediating these undocumented dependencies consumed six weeks of engineering effort but eliminated a compliance risk that had been invisible.

The final six months focused on the UK zone, Concert-driven incident response, and the decommissioning of legacy monitoring stacks. The UK zone presented additional complexity because of post-Brexit regulatory divergence, requiring a distinct set of policy-as-code rules for UK-specific data handling requirements.

### Outcomes

After eighteen months, EFH measured the following changes against its pre-programme baseline:

- **Incident correlation time** (the elapsed time from first alert to confirmed understanding of which services and zones were affected) decreased from a mean of forty-seven minutes to six minutes, driven primarily by Concert's topology-aware situation correlation.
- **GDPR subject access request fulfilment** decreased from a median of seventeen working days to three working days, as the zero-copy architecture reduced the number of data locations requiring investigation from fourteen to four (the zone-local systems of record plus three legacy stores still undergoing decommissioning).
- **Compliance audit preparation effort** for DORA-related supervisory reviews decreased by approximately 60 per cent, as sovereign zone configurations, policy-as-code definitions, and event lineage records provided machine-readable evidence that had previously required manual assembly.
- **Operational cost** for data integration decreased by approximately 30 per cent, primarily through the elimination of batch replication infrastructure and the consolidation of analytics stores.

### Lessons

EFH's experience reinforced several principles. Zero-copy integration is not merely a data architecture pattern; it is a sovereignty enabler, because reducing copies reduces the surface area of data residency risk. Observability must precede automation: Concert's value was greatest when Instana's telemetry was already comprehensive, and weakest in areas where instrumentation coverage was thin. Finally, policy-as-code requires iterative refinement in real operating conditions; policies written in the abstract proved too blunt when applied to the complexity of actual cross-zone interactions.

***

## 36.3 Case Study B: National health service digital transformation

### Context

Healthnet (a composite) is a national health service operating across a country of approximately twenty million people. Its digital estate includes a national electronic health record (EHR) system, a network of regional hospital information systems, a laboratory information management system, a national imaging archive, and a recently launched patient-facing portal for appointment booking and result retrieval. The estate is a mixture of on-premises data centres in hospitals, a government cloud tenancy, and a managed private cloud operated by a contracted systems integrator.

Healthnet operates under national health data protection legislation that is stricter than GDPR in several respects: clinical data may not leave the national territory under any circumstances, and secondary use of identifiable patient data for operational purposes (as opposed to direct clinical care) requires explicit ethical approval. The system faces severe operational pressures: bed occupancy rates routinely exceed 95 per cent, emergency department waiting times are a persistent political concern, and technology teams are significantly understaffed relative to the complexity of the estate.

### Challenge

Healthnet's operational challenges were both technical and organisational. The national EHR had been deployed three years earlier, but its integration with regional hospital systems remained incomplete. Patient data was duplicated across the national system and regional systems, with reconciliation running as nightly batch jobs that frequently failed silently. When a patient presented at a hospital, clinicians sometimes faced conflicting medication lists depending on whether they consulted the national or regional record.

Operationally, Healthnet lacked visibility into system performance at the national level. Each hospital had its own monitoring arrangements, typically basic server-level monitoring with no application-level observability. When the national EHR experienced degraded performance, the incident response process relied on a teleconference bridge where representatives from each hospital dialled in to report symptoms—a process that consumed hours and produced unreliable information.

The most pressing operational problem, however, was bed management. Hospital bed availability was tracked in a mixture of electronic systems and paper records, with no real-time national picture. Discharge planning was largely manual, and the average time from a patient being declared medically fit for discharge to actual discharge was 2.4 days, driven by coordination failures between clinical teams, social care, pharmacy, and transport services.

### Approach

Healthnet's programme was designed around three workstreams: clinical data sovereignty, national operational observability, and agent-assisted capacity management.

**Clinical data sovereignty** was implemented through two sovereign zones. The first, designated the clinical zone, encompassed all systems handling identifiable patient data. This zone was restricted to the national government cloud and hospital-based infrastructure, with no connectivity to public cloud services. The second, designated the operational analytics zone, held de-identified data used for capacity planning, population health analysis, and system performance monitoring. The boundary between the two zones was enforced through network segmentation, API gateways with field-level data masking, and policy-as-code rules implemented in OPA [4].

**National operational observability** was implemented by deploying Instana agents across the national EHR, laboratory, and imaging systems, with zone-local data storage. A national operations centre was established with Concert providing topology-aware situation correlation across the distributed estate. The implementation respected clinical zone constraints: Instana agents running inside the clinical zone stored traces and logs locally, while exporting only aggregated performance metrics to the national Concert instance. This satisfied the data protection requirement that identifiable clinical data should not leave the clinical zone, while providing the national-level visibility that had been entirely absent [6].

**Agent-assisted capacity management** was the most cautious element of the programme. Given the clinical safety implications, Healthnet adopted a deliberately conservative approach to agentic operations. The initial deployment used read-only agents that consumed bed management events—admissions, discharges, transfers, and "medically fit for discharge" declarations—and generated recommendations for discharge coordinators. The agents did not have authority to execute any actions; they surfaced information and suggested next steps, and humans decided what to act on.

![Healthnet sovereign zone architecture](images/figure-36-2.png)

### Implementation

The programme ran over two years, reflecting the complexity of the estate and the caution required in a clinical environment.

The first phase focused on observability. Deploying Instana into clinical systems required a security review that took four months, primarily because the clinical data protection framework required evidence that the instrumentation agent would not exfiltrate patient data. The Instana deployment was eventually approved with a configuration that disabled automatic capture of HTTP request and response bodies in clinical system traces—a pragmatic compromise that reduced diagnostic depth but satisfied the data protection requirements. Even with this constraint, the improvement in visibility was transformative. Within three months of deployment, the national operations centre identified that the nightly EHR-to-regional-system reconciliation failures—previously invisible at the national level—were occurring in 23 per cent of hospitals on any given night, and that the failures correlated with a specific combination of database lock contention and network timeout settings.

The second phase addressed the zero-copy integration problem. The nightly batch reconciliation between the national EHR and regional systems was replaced with a near-real-time event-driven synchronisation model. Patient record updates in the national EHR were emitted as events on a zone-contained event mesh; regional systems consumed these events and applied them as updates, with conflict resolution rules handling concurrent modifications. This eliminated the category of "silent reconciliation failure" entirely, though the migration required eighteen months because each regional hospital system had a different integration interface.

The third phase introduced the bed management agents. These agents consumed a stream of events from hospital patient administration systems: admissions, ward transfers, discharge orders, pharmacy dispensing completions, transport bookings, and social care referral outcomes. Using historical patterns and real-time event flows, they generated recommendations displayed on a dashboard in each hospital's discharge coordination office. Recommendations included: "Patient in Ward 7B, Bed 4, has been medically fit for discharge for 18 hours; pharmacy dispensing is complete; a social care assessment is pending—consider escalating the social care referral." The agents operated under strict guardrails: they could not access or display clinical notes, they could not override clinical decisions, and their recommendations were explicitly labelled as operational suggestions, not clinical advice [7].

### Outcomes

After two years, Healthnet measured the following changes:

- **Mean time from medically fit for discharge to actual discharge** decreased from 2.4 days to 1.6 days, a reduction of approximately 33 per cent. The improvement was attributed roughly equally to the event-driven synchronisation (which eliminated information gaps that had delayed discharge processes) and the agent recommendations (which surfaced actionable bottlenecks to discharge coordinators).
- **National EHR reconciliation failures** decreased from an average of 23 per cent of hospitals affected per night to less than 1 per cent, through the elimination of the batch reconciliation model.
- **Mean incident detection time** for national EHR performance degradation decreased from over two hours (the time to organise and conduct a telephone bridge) to fourteen minutes (Concert-based automated detection and correlation).
- **Bed availability visibility** improved from "unknown at the national level" to a real-time dashboard with fifteen-minute refresh, enabling national-level capacity coordination for the first time.

### Lessons

Healthnet's experience demonstrated that sovereignty constraints, far from being obstacles to operational improvement, can serve as forcing functions for better architecture. The clinical data protection requirements compelled the team to design a clean separation between clinical and operational data, which in turn made the observability deployment simpler and the agent guardrails more straightforward. The most important lesson, however, was about trust: clinical staff accepted the bed management agents only after a six-month period during which the agents operated in a purely advisory mode with no authority, during which their recommendations were informally evaluated against what coordinators would have done anyway. Trust was earned through demonstrated accuracy, not through technical capability alone.

***

## 36.4 Case Study C: Pan-European insurance group

### Context

Continental Assurance Group (CAG) is a composite representing a pan-European insurance company with subsidiaries in eight countries. The group writes life, health, property, and casualty insurance across its markets, with products, pricing, and distribution varying significantly by country due to local regulatory requirements. CAG's technology estate is a consequence of two decades of acquisitions: each subsidiary operates largely independent systems for policy administration, claims processing, and customer management, with group-level consolidation limited to financial reporting and reinsurance calculations.

CAG's regulatory environment includes GDPR, Solvency II, the Insurance Distribution Directive, and eight sets of national insurance supervisory requirements. Its group chief information officer had, for several years, been attempting to standardise operations across subsidiaries, with limited success due to local resistance and the genuine complexity of local regulatory differences.

### Challenge

CAG's operational challenges were rooted in fragmentation. The group operated eighteen separate monitoring installations across its subsidiaries, with no group-level visibility into service health. When the group's reinsurance calculation engine—a shared service consumed by all subsidiaries—experienced a performance degradation, the group operations team learned about it only when subsidiary IT managers began calling to report that their month-end processes were running late. The mean time to detect group-wide incidents was measured in hours, not minutes.

Claims processing was the most operationally significant area. CAG processed approximately 2.3 million claims annually across the group, with end-to-end processing times varying from three days (for simple motor claims in the Netherlands) to forty-five days (for complex liability claims in Italy). The group suspected that a significant proportion of this variation was attributable to operational inefficiency rather than genuine complexity, but it lacked the cross-subsidiary visibility to confirm or quantify this.

Data integration was copy-heavy by necessity and by habit. Solvency II reporting required group-level aggregation of risk exposure data from all subsidiaries, which was achieved through nightly extraction into a central data warehouse. Reinsurance calculations required similar aggregation. Customer data was duplicated across systems, creating GDPR compliance risks and making group-wide fraud detection difficult.

### Approach

CAG's programme focused on three areas: federated observability, progressive agent autonomy, and zero-copy risk integration.

**Federated observability** was designed to respect the principle that raw operational telemetry should remain within each subsidiary's sovereign zone while providing group-level situational awareness. Instana was deployed in each subsidiary, with zone-local data retention. Concert was deployed at the group level, consuming aggregated metrics, topology summaries, and situation reports from each subsidiary's Instana instance. This federated model meant that a French subsidiary's detailed application traces never left France, while the group operations centre could see that "the French subsidiary's claims processing service is experiencing elevated error rates" and correlate this with similar patterns in other subsidiaries [6].

**Progressive agent autonomy** was implemented through a four-phase model that mirrored the maturity framework described in [Chapter 33](33_chapter_maturity_model.html). In phase one, agents operated in a purely observational mode, generating weekly reports on claims processing performance across subsidiaries with comparisons and anomaly highlights. In phase two, agents began generating real-time recommendations during incidents—suggesting specific diagnostic steps, identifying probable root causes based on Concert's topology-aware correlation, and proposing remediation actions. In phase three, agents were authorised to execute a limited set of pre-approved remediation actions: restarting non-critical services, scaling compute resources within pre-defined bounds, and toggling feature flags to activate fallback processing paths. Phase four, not yet reached at the time of writing, would extend agent authority to include automated capacity management and predictive scaling for claims processing workloads.

**Zero-copy risk integration** addressed the Solvency II reporting problem. Rather than extracting subsidiary risk data nightly into a central warehouse, CAG implemented a federated query model using data virtualisation. The group-level Solvency II calculation engine queried subsidiary risk data in place, through governed APIs that applied field-level masking and access controls appropriate to the requester's role and jurisdiction. Raw policy-level data remained in the subsidiary's sovereign zone; the group engine received only the aggregated risk metrics needed for its calculations [5].

![CAG federated observability architecture](images/figure-36-3.png)

### Implementation

CAG's programme ran over twenty-four months across four phases.

The first phase (months one through six) deployed Instana in three pilot subsidiaries—the Netherlands, Germany, and Spain—chosen because they had the most modern infrastructure and the most cooperative local IT leadership. Even in these relatively favourable environments, the deployment surfaced challenges. The Spanish subsidiary's claims processing system ran on a legacy application server that Instana could not instrument automatically; the team spent six weeks developing custom instrumentation to provide basic request-level telemetry. The Dutch subsidiary's network security team initially blocked the Instana agent's outbound telemetry traffic, requiring a redesign of the agent's communication path to route through the subsidiary's existing monitoring network segment.

The second phase (months seven through twelve) extended Instana to the remaining five subsidiaries and deployed Concert at the group level. The Concert deployment was the most politically sensitive element of the programme: subsidiary IT directors were concerned that group-level visibility would be used to micromanage their operations or to benchmark their performance unfavourably against other subsidiaries. The programme's sponsor addressed this by establishing a charter for the group operations centre that explicitly defined its role as coordination and support, not oversight—and by ensuring that subsidiary-level telemetry detail was not accessible from the group console.

The third phase (months thirteen through eighteen) introduced the first agents. The observational agents that generated weekly performance reports proved unexpectedly valuable: for the first time, the group could see that claims processing throughput in Italy was 40 per cent lower per-capita than in the Netherlands, and that the difference was attributable not to regulatory complexity but to a specific bottleneck in the Italian subsidiary's document ingestion workflow. This finding led to a targeted improvement project that reduced Italian claims processing time by eight days on average.

The fourth phase (months nineteen through twenty-four) advanced agents to phases two and three of the progressive autonomy model. Real-time incident recommendations were well received by subsidiary operations teams, who found that Concert-informed agents could diagnose cross-subsidiary incidents significantly faster than the previous telephone-based coordination model. The authorisation of agents to execute limited remediation actions was approved only after a three-month trial in which proposed actions were logged but not executed, and were retrospectively compared against the actions that human operators had actually taken. The comparison showed 91 per cent agreement, which provided sufficient confidence to proceed.

### Outcomes

After twenty-four months, CAG measured the following results:

- **Group-wide incident detection time** decreased from a mean of 3.2 hours to eleven minutes for incidents affecting shared services consumed by multiple subsidiaries.
- **Claims processing time variance** across subsidiaries decreased by approximately 35 per cent, as group-level visibility enabled targeted improvement of the weakest-performing subsidiaries.
- **Solvency II reporting preparation time** decreased from twelve working days to four working days, driven by the elimination of batch data extraction and the adoption of federated query.
- **Agent-executed remediation actions** in the phase three pilot (three subsidiaries) achieved a 94 per cent success rate, with the remaining 6 per cent safely caught by guardrails that escalated to human operators when the action's preconditions were not fully met.

### Lessons

CAG's experience highlighted the importance of organisational design in federated sovereignty programmes. The technical architecture—federated observability with zone-local data retention—was necessary but insufficient. The programme succeeded only because it was accompanied by a governance model that respected subsidiary autonomy while creating incentives for coordination. The progressive autonomy approach proved essential for building trust: each phase provided evidence that informed the decision to proceed to the next. Perhaps most importantly, the observational agents that generated comparative performance reports created a form of peer visibility that motivated local improvement without requiring top-down mandates.

***

## 36.5 Case Study D: Government digital services platform

### Context

GovServe (a composite) is the digital services platform of a European national government, serving approximately thirty government departments and agencies. The platform provides shared infrastructure—compute, networking, identity, and common services such as notifications, payments, and document management—on which departments build and operate their citizen-facing digital services. GovServe processes approximately 150 million citizen interactions annually, ranging from tax filing and benefit applications to passport renewals and business registrations.

The constitutional and legal framework within which GovServe operates is distinctive. The national constitution includes a provision establishing that citizens have the right to understand how government decisions affecting them are made, which has been interpreted by the courts to extend to decisions made with the assistance of automated systems. National information security legislation designates the platform as critical national infrastructure, requiring that all operational control remain under national authority. A recent government policy directive requires that all new government AI deployments, including AI used in operations, be subject to transparency assessments and public registers [8].

### Challenge

GovServe's challenges were shaped by its constitutional obligations. The platform had grown organically over eight years, and its operational model had not kept pace with its scale. Incident response was slow: the mean time to restore service after a significant incident was 4.3 hours, which was unacceptable for services on which citizens depended. The platform had experienced two high-profile outages in the preceding year—one affecting the national tax filing service during peak filing season, and one affecting the benefit payments system during a holiday period—both of which generated parliamentary questions and press coverage.

The operational sovereignty requirement was absolute. GovServe could not use cloud-based operations tools that processed telemetry outside the national territory, which eliminated several major observability and AIOps platforms from consideration. The transparency obligation created an additional constraint: any AI system used in operations had to be capable of producing explanations of its reasoning that could, in principle, be disclosed to citizens or parliamentary oversight bodies.

Departmental autonomy added complexity. Each government department retained operational responsibility for its own services running on the platform, but the platform team was responsible for the shared infrastructure on which those services depended. When an infrastructure incident affected multiple departments simultaneously, the coordination challenge was substantial, and the political dynamics—departments blaming the platform, the platform blaming departments—were corrosive.

### Approach

GovServe's programme was structured around national sovereign infrastructure, transparent agentic operations, and a federated responsibility model.

**National sovereign infrastructure** was implemented by deploying all platform components—including observability, operational intelligence, and agent frameworks—on nationally-operated OpenShift clusters in government data centres. Instana was deployed with all data storage on-premises, and Concert was configured to operate within the national sovereign zone with no external dependencies [6]. The entire operational toolchain was subject to a security assessment that verified no telemetry, model data, or operational metadata left the national territory.

**Transparent agentic operations** were designed from the outset to satisfy the constitutional transparency requirement. Every agent action—whether a diagnostic query, a recommendation, or an executed remediation—was logged in an immutable audit trail that recorded the input signals the agent consumed, the reasoning chain it followed, the recommendation or action it produced, and the human approval (if any) that authorised execution. These audit records were structured using a schema designed to be interpretable by non-technical reviewers, including parliamentary staff. The agents were built on watsonx Orchestrate, configured with explicit guardrails that prevented any action affecting citizen-facing services without human approval from a designated incident commander [9].

**The federated responsibility model** established clear boundaries between the platform team and departmental teams, encoded in policy-as-code. The platform team was responsible for shared infrastructure—compute, networking, identity, observability, and the agent framework. Departmental teams were responsible for their own application-level services. Concert's topology model was configured to recognise this boundary: when it identified a situation, it attributed root cause to either the platform layer or the departmental application layer, and routed recommendations accordingly. This attribution capability transformed incident coordination from a political negotiation into an evidence-based conversation.

![GovServe operational architecture](images/figure-36-4.png)

### Implementation

GovServe's programme ran over twenty months.

The transparency framework consumed the first four months and proved to be the most consequential design decision. The team considered several approaches to agent explainability and settled on a structured reasoning log that recorded, for each agent recommendation, the specific signals that triggered the reasoning, the topology relationships consulted, the policy constraints applied, and the confidence level of the recommendation. This log was designed not for machine consumption but for human review, and the team tested it by presenting sample logs to non-technical parliamentary staff and iterating on the format until reviewers reported that they could follow the reasoning without technical assistance.

The Instana and Concert deployment occupied months three through eight. The most significant challenge was scaling Instana's on-premises deployment to handle the telemetry volume generated by 150 million annual citizen interactions. The team initially under-provisioned the Instana backend, resulting in telemetry sampling that reduced diagnostic coverage. A capacity expansion in month six resolved this, and from that point the platform had comprehensive application-level observability for the first time.

Agent deployment proceeded in three phases, from months nine through twenty. Phase one agents were purely diagnostic: they consumed Concert situations and generated structured incident summaries for platform operators, replacing a manual process that had previously taken thirty to forty-five minutes per incident. Phase two agents added remediation recommendations, which were reviewed and approved by human incident commanders before execution. Phase three agents were authorised to execute a limited set of infrastructure-level actions—restarting platform services, scaling compute nodes, and rerouting traffic between availability zones—without prior human approval, but with immediate notification and a sixty-second automatic rollback window if the action did not produce the expected improvement.

The most revealing moment in the programme occurred during month fourteen, when a phase two agent generated a recommendation during a live incident that was subsequently cited in a parliamentary answer. The minister responsible for digital services was asked how the government's tax filing service had been restored after a brief outage, and the answer included the statement that "an AI-assisted operational system identified the root cause within four minutes and recommended a remediation action that was approved and executed by the platform team within nine minutes." This was the first time an agentic operations system had been cited in a parliamentary context, and it validated the investment in the transparency framework: the audit trail supported the minister's answer with verifiable evidence.

### Outcomes

After twenty months, GovServe measured the following changes:

- **Mean time to restore** for significant incidents decreased from 4.3 hours to 38 minutes, with the improvement attributed to faster root cause identification (Concert), faster diagnostic context assembly (agents), and the elimination of political coordination overhead (evidence-based attribution).
- **Incident coordination overhead** (the number of person-hours spent in coordination activities per incident) decreased by approximately 70 per cent, driven by Concert's automated attribution of root cause to either the platform or departmental layers.
- **Transparency compliance** was achieved: all agent actions were logged in the required audit format, and a public register of AI systems used in government operations was updated to include the agentic operations deployment, satisfying the government policy directive.
- **Citizen-facing service availability** improved from 99.2 per cent to 99.7 per cent (measured monthly), reflecting both the faster incident resolution and the proactive capacity management enabled by phase three agents.

### Lessons

GovServe's experience demonstrated that transparency obligations, like sovereignty constraints, can be architectural assets rather than burdens. The requirement to produce explainable agent reasoning forced the team to build agents with well-structured reasoning chains, which made the agents more debuggable, more trustworthy to operators, and easier to improve over time. The federated responsibility model, encoded in policy-as-code and enforced through Concert's topology-aware attribution, resolved a political problem through architectural means—a pattern that is transferable to any organisation where incident coordination is complicated by unclear accountability.

***

## 36.6 Case Study E: Critical infrastructure operator

### Context

NatGrid Energy (a composite) is a national energy transmission and distribution operator responsible for the high-voltage electricity grid of a medium-sized European country. The company operates approximately 12,000 kilometres of transmission lines, 340 substations, and a national grid control centre that balances electricity supply and demand in real time. Its technology estate spans two domains: operational technology (OT) systems that directly control physical grid equipment, and information technology (IT) systems that support business operations, market participation, customer management, and regulatory reporting.

NatGrid holds a national security designation that imposes stringent requirements on its operational infrastructure. Its grid control systems must operate independently of external networks. Foreign-operated cloud services may not be used for any system that directly or indirectly influences grid operations. All operational staff must hold national security clearances. The company is subject to the EU Network and Information Security Directive (NIS2) and its national implementation, which imposes specific requirements for incident reporting, supply chain security, and operational resilience [10].

### Challenge

NatGrid faced the challenge of modernising its IT operations while maintaining the absolute reliability and isolation required for its OT systems. The OT estate—SCADA systems, energy management systems, protection relays, and substation automation—operated in an air-gapped environment with no connectivity to corporate IT networks or the internet. This isolation was a safety and security requirement, but it created an operational blind spot: the IT operations team had no visibility into the health of OT systems, and the OT engineering team had no access to the modern operational tooling available on the IT side.

The convergence of IT and OT was accelerating due to the energy transition. The integration of renewable energy sources, battery storage, and demand response programmes required increasingly sophisticated data exchange between OT systems (which managed the physical grid) and IT systems (which managed market participation, forecasting, and customer-facing flexibility programmes). This data exchange had been implemented through a series of point-to-point interfaces—files transferred between networks via one-way data diodes—that were fragile, opaque, and difficult to monitor.

NatGrid's IT operations were themselves in need of improvement. The company's IT monitoring was basic, incident response was largely manual, and the mean time to resolve IT incidents was 3.8 hours. The IT operations team was small and overstretched, supporting an estate that had grown significantly as the company digitised its market and customer operations.

### Approach

NatGrid's programme was structured around three zones, a controlled convergence architecture, and cautious agent introduction.

**Three sovereign zones** were defined. The OT zone encompassed all systems that directly controlled or monitored physical grid equipment. This zone was air-gapped from all other networks, with data egress permitted only through hardware-enforced one-way data diodes. The IT zone encompassed corporate business systems, customer management, market participation, and regulatory reporting. This zone was hosted on nationally-operated OpenShift clusters with no foreign cloud dependencies. The convergence zone was a new construct: a purpose-built environment positioned between the OT and IT zones, designed to receive data from the OT zone through data diodes, process it, and make derived information available to the IT zone. The convergence zone had no ability to send data or commands to the OT zone—the data diodes enforced physical one-way flow—and its access to the IT zone was governed by strict API-level controls [10].

**Controlled convergence** was implemented by redesigning the OT-to-IT data flows through the convergence zone. The point-to-point file transfers were replaced with a structured event-driven architecture within the convergence zone. Grid telemetry—voltage levels, frequency measurements, equipment status, alarm states—was transmitted through data diodes into the convergence zone, where it was processed into events and made available through governed APIs to authorised IT systems. This provided the IT estate with real-time visibility into grid operational data for the first time, enabling market operations, forecasting, and customer-facing services to consume grid state information without any risk of inadvertent command injection into the OT environment.

**Agent introduction** was handled with extreme caution. NatGrid's national security designation meant that any AI system used in operations required approval from the national cybersecurity authority. The approval process took seven months and resulted in a set of constraints: agents could operate only in the IT zone, could not receive data directly from the OT zone (only from the convergence zone's processed output), could not generate any output that could be interpreted as a control command, and their models had to run on nationally-operated infrastructure with no external API calls. Within these constraints, agents were deployed for IT operations only: incident diagnosis, remediation recommendations, and capacity management for the IT estate.

![NatGrid three-zone architecture](images/figure-36-5.png)

### Implementation

NatGrid's programme ran over twenty-six months, reflecting the additional complexity and caution required in a critical infrastructure context.

The first phase (months one through eight) focused on establishing the convergence zone and redesigning the OT-to-IT data flows. This was the most technically challenging element of the programme, because the existing point-to-point file transfers had accumulated undocumented dependencies over fifteen years. The team catalogued forty-seven distinct data flows crossing the OT-IT boundary, of which thirty-one were active, nine were dormant but still configured, and seven were undocumented flows discovered only through network traffic analysis. Redesigning these flows as structured events required close collaboration between OT engineers (who understood the grid data semantics) and IT architects (who understood the event-driven architecture), and the two groups initially struggled with different vocabularies, different risk tolerances, and different operational cultures.

The second phase (months nine through sixteen) deployed Instana in the IT zone and the convergence zone, Concert at the IT zone level, and the first observability capabilities for convergence zone data flows. For the first time, the IT operations team could see not just whether their own systems were healthy, but whether the data feeds from the OT environment—grid state, equipment alarms, generation forecasts—were arriving on time, complete, and consistent. This visibility proved immediately valuable: within the first month, Concert identified a pattern where a specific data diode's throughput degraded during peak grid activity, causing delayed delivery of generation forecast data that affected the accuracy of market position calculations.

The third phase (months seventeen through twenty-six) introduced agents in the IT zone. The agents were conservative by design: they consumed Concert situations and generated diagnostic summaries and remediation recommendations for IT operators. They did not execute remediation actions autonomously. The national cybersecurity authority's constraints meant that phase three agents (autonomous execution) were deferred to a future programme phase, pending the development of a formal verification framework for agent actions in critical infrastructure contexts.

### Outcomes

After twenty-six months, NatGrid measured the following changes:

- **IT incident mean time to resolve** decreased from 3.8 hours to 52 minutes, driven by Concert-based correlation and agent-generated diagnostic summaries.
- **Convergence zone data flow reliability** improved from 94.2 per cent (measured as the percentage of data feeds delivered on time and complete) to 99.6 per cent, through the replacement of point-to-point file transfers with structured event-driven delivery and the addition of observability to the convergence zone.
- **Undocumented cross-boundary data flows** were reduced from seven to zero through the systematic cataloguing and redesign process.
- **Regulatory audit preparation time** for NIS2-related assessments decreased by approximately 50 per cent, as the zone architecture, policy-as-code definitions, and event lineage provided machine-readable evidence of operational control.

### Lessons

NatGrid's experience illustrated the extreme end of the sovereignty spectrum, where operational sovereignty is not a regulatory preference but a physical safety requirement. The most transferable lesson was the value of the convergence zone as an architectural pattern for IT-OT integration: rather than attempting to bridge air-gapped environments directly, the convergence zone provided a controlled space where OT data could be processed and made available to IT systems without compromising OT isolation. The programme also demonstrated that agentic operations can deliver value even under severe constraints: agents operating only in the IT zone, consuming only processed data from the convergence zone, still reduced incident resolution time by more than 70 per cent. The constraints shaped the agents' design, but they did not eliminate their utility.

***

## 36.7 Cross-cutting lessons

Five organisations, five industries, five regulatory environments, and five distinct starting points. Yet the patterns that emerged across these case studies are remarkably consistent. Six cross-cutting lessons deserve explicit attention.

### 36.7.1 Start with observability

Every case study began with observability, and in every case, the improvement in visibility was the foundation on which everything else was built. EFH could not implement zero-copy integration without first understanding its existing data flows. Healthnet could not deploy bed management agents without first instrumenting the clinical systems that generated the events those agents consumed. CAG could not build federated observability without first deploying zone-local instrumentation. GovServe could not achieve transparent agentic operations without first having the telemetry to make agent reasoning chains verifiable. NatGrid could not improve convergence zone reliability without first being able to see what was flowing through it.

This pattern is consistent with the architectural principle established in [Chapter 7](07_chapter_observability_architecture.html) and [Chapter 8](08_chapter_network_observability_performance.html): observability is not a feature of an operations programme; it is the precondition for one. Organisations that attempted to deploy agents or automation before achieving adequate observability universally reported frustration, as the agents had insufficient context to generate useful recommendations [1].

### 36.7.2 Sovereignty as a design constraint, not a burden

In every case study, sovereignty requirements—whether regulatory, constitutional, or security-driven—functioned as architectural forcing functions that produced better designs. EFH's zone architecture was cleaner because regulators demanded it. Healthnet's clinical data separation was more rigorous because health data legislation required it. GovServe's transparency framework was more thorough because the constitution required it. NatGrid's convergence zone was more carefully designed because national security required it.

This is not to suggest that sovereignty constraints are costless; they add complexity, limit design options, and extend programme timelines. But the organisations in these case studies consistently reported that the resulting architectures were more maintainable, more auditable, and more operationally sound than the ad-hoc arrangements they replaced. Sovereignty, treated as a first-class design constraint rather than a compliance afterthought, produces architectures that are easier to operate, not harder [4].

### 36.7.3 Progressive autonomy is not optional

No organisation in these case studies began with autonomous agents. All followed some variant of the progressive autonomy model described in [Chapter 33](33_chapter_maturity_model.html): observe, recommend, execute with approval, execute autonomously within guardrails. The progression was driven not by a predetermined timeline but by accumulated evidence: each phase produced data about agent accuracy, reliability, and safety that informed the decision to proceed to the next phase.

CAG's experience is particularly instructive. The three-month trial in which proposed agent actions were logged but not executed, and retrospectively compared against human decisions, provided a 91 per cent agreement rate that gave the organisation confidence to proceed. This "shadow mode" deployment pattern appeared, in some form, in every case study. It reflects a fundamental truth about agentic operations in regulated environments: trust is not a technical property; it is a social one, and it must be earned through demonstrated performance in conditions that approximate production without carrying production risk [7].

### 36.7.4 Zero-copy integration enables sovereignty

The relationship between zero-copy integration and operational sovereignty is causal, not merely correlational. Reducing the number of copies of sensitive data reduces the surface area of data residency risk, simplifies GDPR compliance, and makes it possible to maintain meaningful sovereign zone boundaries. EFH's reduction from fourteen data copies to four zone-local systems of record directly enabled its GDPR subject access request fulfilment improvement. CAG's federated query model for Solvency II reporting eliminated the group-level data warehouse that had been the most significant single data residency risk in the organisation.

Conversely, organisations that attempted to implement sovereign zones without addressing their integration landscape found that data copies proliferated across zone boundaries, undermining the sovereignty guarantees that the zones were intended to provide. Zero-copy integration and sovereign zone architecture are complementary patterns that should be adopted together [5].

### 36.7.5 Cultural change is the hardest part

In every case study, the technical implementation—deploying platforms, configuring zones, building agents—was ultimately less difficult than the organisational and cultural changes required to make the architecture work. EFH's downstream analytics teams resisted the migration from copy-based integration. CAG's subsidiary IT directors were suspicious of group-level visibility. GovServe's departments resisted evidence-based attribution of incident root cause. NatGrid's OT and IT teams struggled with different vocabularies and risk tolerances.

These are not implementation details; they are the substance of transformation. The organisations that navigated them most successfully did so by combining top-down executive sponsorship with bottom-up evidence generation: demonstrating value through early wins (observability improvements, faster incident response) that gave sceptical teams reasons to engage. The organisations that struggled most were those that treated cultural change as a communication problem rather than a structural one—assuming that explaining the benefits would be sufficient, without changing incentives, governance structures, or the distribution of operational authority.

### 36.7.6 Common mistakes

Several mistakes appeared across multiple case studies, often independently:

- **Under-provisioning observability infrastructure**, resulting in telemetry sampling that reduced diagnostic coverage and undermined agent effectiveness. Every organisation that deployed Instana at scale initially under-estimated the storage and compute requirements for high-fidelity telemetry retention.
- **Writing policy-as-code in the abstract**, without testing against real operational scenarios. EFH's initial OPA policies were too coarse; GovServe's initial guardrails were too permissive for one category of action and too restrictive for another. Policy-as-code requires the same iterative refinement as application code.
- **Neglecting the convergence between old and new**, assuming that legacy systems could be ignored until they were decommissioned. In practice, legacy systems persisted longer than planned, and the interfaces between legacy and modern systems became the most fragile points in the architecture.
- **Treating agent deployment as a technology project** rather than an operating model change. Agents change how teams work, what skills they need, and how authority is distributed. Organisations that deployed agents without adjusting team structures, on-call models, and escalation procedures found that the agents generated recommendations that no one acted on [3].

***

## Key Takeaways

- Composite case studies illustrate that sovereign operations programmes succeed when they begin with observability, treat sovereignty as a design constraint, and adopt progressive autonomy for agentic capabilities.
- Zero-copy integration and sovereign zone architecture are complementary: reducing data copies reduces sovereignty risk and simplifies compliance.
- Federated observability models—zone-local telemetry with group-level reasoning—respect sovereignty boundaries while providing cross-entity operational visibility.
- Transparency obligations (as in the government case study) and safety requirements (as in the health and energy case studies) function as forcing functions that produce more rigorous and more maintainable architectures.
- Progressive autonomy—observe, recommend, execute with approval, execute autonomously—is the universal pattern for introducing agentic operations in regulated environments.
- Cultural and organisational change is at least as challenging as technical implementation, and programmes that neglect it achieve architectural change without operational improvement.
- Common mistakes include under-provisioning observability infrastructure, writing policy-as-code without iterative testing, and treating agent deployment as a technology project rather than an operating model transformation.

***

## Bridge to Chapter 37 — Generative AI on the Horizon

These case studies describe what organisations are achieving today and in the near term with sovereign, agentic operations. But the technology landscape is not standing still. Generative AI capabilities are advancing rapidly, regulatory frameworks are evolving, and new patterns for human-AI collaboration in operations are emerging. [Chapter 37](37_chapter_genai_horizon.html) looks beyond current implementations to the horizon: how generative AI, frontier models, and evolving regulatory expectations will shape the next generation of sovereign operations, and what architects and operators should be designing for today to be ready for what comes next.

***

## References

[1] IBM, "IBM Concert: AI-Powered IT Operations Management," IBM Documentation, 2025. [Online]. Available: https://www.ibm.com/docs/en/concert

[2] Gartner, "Market Guide for AIOps Platforms," Gartner Research, 2024.

[3] S. Earley, "The Role of Organisational Change in Digital Transformation," *MIT Sloan Management Review*, vol. 64, no. 2, pp. 42-49, 2023.

[4] Open Policy Agent, "OPA: Policy-Based Control for Cloud Native Environments," CNCF, 2024. [Online]. Available: https://www.openpolicyagent.org

[5] A. Aslett, "Zero-Copy Data Integration: Eliminating Redundancy in Regulated Environments," *Bloor Research*, 2024.

[6] IBM, "IBM Instana Observability," IBM Documentation, 2025. [Online]. Available: https://www.ibm.com/docs/en/instana-observability

[7] European Commission, "Ethics Guidelines for Trustworthy AI," High-Level Expert Group on Artificial Intelligence, Brussels, 2019. [Online]. Available: https://digital-strategy.ec.europa.eu/en/library/ethics-guidelines-trustworthy-ai

[8] European Parliament and Council, "Regulation (EU) 2024/1689 Laying Down Harmonised Rules on Artificial Intelligence (AI Act)," *Official Journal of the European Union*, L 2024/1689, Jul. 2024. [Online]. Available: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32024R1689

[9] IBM, "IBM watsonx Orchestrate," IBM Documentation, 2025. [Online]. Available: https://www.ibm.com/docs/en/watsonx-orchestrate

[10] European Parliament and Council, "Directive (EU) 2022/2555 on Measures for a High Common Level of Cybersecurity across the Union (NIS2)," *Official Journal of the European Union*, L 333, pp. 80-152, Dec. 2022. [Online]. Available: https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32022L2555
