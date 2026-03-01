# Chapter 33 — Sovereign Operations Maturity Model

***

## Summary

This chapter presents a maturity model purpose-built for sovereign, agentic operations, filling a gap left by existing frameworks such as CMMI, DORA metrics and the CNCF Cloud Native Maturity Model, none of which address sovereignty constraints, policy-as-code enforcement or agent governance. Five maturity levels — from Ad-hoc and Reactive through to Optimised and Autonomous — define a progression across eight assessment dimensions: infrastructure codification, observability depth, automation coverage, sovereignty enforcement, agent adoption, governance maturity, cultural readiness and knowledge management. The chapter provides concrete guidance on conducting honest, evidence-based assessments, navigating the migration paths between levels, and recognising the interdependencies that make advancing one dimension contingent on progress in others. It closes with practical advice on combining quick wins with structural moves such as the sovereign core pattern, avoiding common transformation anti-patterns, and connecting maturity improvements to measurable business outcomes through quarterly reviews and leading indicators.

***

## 33.1 Why a maturity model

There is a moment in every transformation programme when the steering committee asks a question that sounds simple but is remarkably difficult to answer: "How far along are we?" The difficulty is not that nobody has an opinion. Everybody does. The infrastructure team believes they are well advanced because Terraform is in use for two cloud providers. The observability team considers themselves leading because they have adopted OpenTelemetry. The security group feels behind because policy-as-code covers only a fraction of the estate. The programme director suspects the whole thing is further behind than anyone will admit. Without a shared framework for assessment, these perspectives remain incommensurable. Investment cases are built on intuition rather than evidence, and accountability dissolves into competing narratives about progress [1].

A maturity model provides the common language that ad-hoc self-assessment cannot. It defines a set of levels—each with concrete, observable characteristics—and a set of dimensions across which those levels are measured. An organisation can use it to determine where it stands today, to set targets for where it wants to be, and to identify the specific gaps that investment and effort should address. Maturity models are not new to technology operations. The Capability Maturity Model Integration (CMMI) [2] has been used for decades to assess and improve software development and service delivery processes. The DORA research programme [3] introduced a widely cited set of maturity constructs for software delivery performance—deployment frequency, lead time for changes, change failure rate and mean time to restore—that have shaped how engineering organisations think about continuous improvement. The Cloud Native Maturity Model from the CNCF [4] provides a framework for assessing adoption of cloud-native practices across people, process, policy and technology dimensions.

What none of these frameworks does is address the specific concerns of sovereign operations. They do not ask whether infrastructure codification extends to sovereignty constraints, whether observability pipelines respect jurisdictional boundaries, whether automation guardrails enforce residency and access policies, or whether agentic systems operate within bounded authority. The maturity model presented in this chapter fills that gap. It is designed for organisations operating in regulated, multi-jurisdictional, sovereignty-aware environments—precisely the context this book addresses.

A well-constructed maturity model serves several practical purposes beyond assessment. It drives investment by providing evidence of where the organisation is under-developed and where additional spending will have the greatest impact. It creates accountability by making expectations explicit: if the target is to reach Level 3 across all dimensions within eighteen months, progress is visible and shortfalls are attributable. It enables benchmarking, both internally—comparing the maturity of different teams, regions or business units—and externally, where peer organisations adopt the same framework. And it provides a defence against two common failure modes of transformation programmes: the claim that "we are already doing this" when the reality is partial and inconsistent, and the opposite claim that "we need to do everything at once" when a sequenced, prioritised approach would be more effective [1].

The maturity model that follows is structured in two parts. First, five maturity levels define the overall progression from ad-hoc, reactive operations to optimised, autonomous sovereign operations. Second, eight assessment dimensions define the axes along which maturity is measured. An organisation's maturity is not a single number; it is a profile across these dimensions, and the most revealing insights often come from the unevenness of that profile.

***

## 33.2 The five maturity levels

The five levels described below represent a progression from chaotic, reactive operations to self-improving, autonomous sovereign operations. They are not a ladder that every organisation must climb in strict sequence—some may leapfrog aspects of a level, while others may find themselves at different levels on different dimensions. Nevertheless, the levels represent a broadly sequential arc: the capabilities at each level typically depend on foundations laid at the previous one.

### 33.2.1 Level 1 — Ad-hoc and Reactive

At Level 1, operations are driven by individual effort and heroic response. Infrastructure is provisioned manually or through inconsistent scripts that vary by team. Observability is limited to basic monitoring—CPU, memory, disk—with alerts configured by whoever last touched a system and dashboards that nobody fully trusts. Incidents are diagnosed through console access, tribal knowledge and the availability of the right person at the right time. There is no meaningful automation beyond simple cron jobs, and those are rarely documented or version-controlled.

Sovereignty, if it is considered at all, exists as a set of policy documents that bear little relationship to how infrastructure is actually configured or where data actually flows. Compliance is demonstrated through periodic manual audits that sample a tiny fraction of the estate and produce findings that take months to remediate. Agents are not in use, or if they are, they are experimental tools used by individuals without organisational awareness or governance.

![Figure 33.1 — The five maturity levels of the Sovereign Operations Maturity Model, shown as an ascending progression with key characteristics at each level](images/figure-33-1.png)

The defining characteristic of Level 1 is **unpredictability**. Outcomes depend on who is on call, what they happen to know, and whether the problem resembles one they have seen before. The same incident may be resolved in twenty minutes by one engineer and take four hours for another. There is no systematic learning from incidents, and the same failure modes recur.

### 33.2.2 Level 2 — Managed and Foundational

At Level 2, the organisation has begun to lay foundations. Infrastructure as code is in use for at least some environments, though coverage may be uneven—production may be codified while staging and development remain manual. Version control is standard practice for application code and is beginning to extend to configuration and infrastructure definitions. Observability has moved beyond basic monitoring: structured logging is in place for major services, distributed tracing covers some critical paths, and there are defined SLOs for the most important business capabilities [5].

Incident management follows a defined process—there is a ticketing system, an on-call rotation, and post-incident reviews happen for major outages, even if the resulting actions are not always followed through. Runbooks exist for common scenarios, though they are often out of date and stored in wikis that engineers consult only after exhausting their own knowledge.

Sovereignty awareness at Level 2 is emerging. The organisation has identified its sovereign zones at a conceptual level, and some infrastructure constraints—such as restricting deployments to specific regions—are enforced through IaC or cloud provider configurations. However, enforcement is incomplete and untested. Policy-as-code may exist in pockets but is not systematically applied. Data residency is managed through convention rather than technical controls [6].

The defining characteristic of Level 2 is **intent**. The organisation knows what good looks like and has begun to build the mechanisms, but coverage is partial, consistency is poor, and the gap between documented practice and actual practice remains significant.

### 33.2.3 Level 3 — Defined and Standardised

Level 3 represents the point at which practices become consistent across the organisation, not merely within individual teams. Infrastructure as code is the standard deployment mechanism, with peer review and approval workflows. Configuration management is version-controlled and auditable. Observability covers the full MELT stack across all production services, with correlation between metrics, logs, traces and events enabling efficient root cause analysis.

Runbooks are codified and version-controlled alongside the services they support. Automation handles routine operational tasks—scaling, certificate rotation, log management—with clear ownership and testing. Incident management is mature: severity classification is consistent, communication protocols are defined, and post-incident reviews produce actions that are tracked to completion.

Sovereign zones are defined in code and enforced through policy-as-code frameworks. Network policies, data residency constraints, identity boundaries and encryption requirements are expressed as machine-readable policies that are evaluated continuously, not merely at deployment time. Compliance evidence is generated automatically from telemetry and policy evaluation results. The control plane has a coherent view of which services operate in which zones and what constraints apply [7].

Agents may be in use at Level 3, but in read-only or advisory roles—summarising incidents, suggesting runbook steps, identifying relevant documentation. They operate within explicit guardrails and their outputs are reviewed by human operators before action is taken.

The defining characteristic of Level 3 is **consistency**. Practices are not merely defined but are actually followed, and deviations are detected and corrected. An engineer joining any team in the organisation will find recognisable patterns and tooling.

### 33.2.4 Level 4 — Measured and Integrated

At Level 4, the organisation uses quantitative data to manage and improve its operations. This goes beyond having dashboards and SLOs—it means systematically measuring operational performance, analysing trends, and using those measurements to drive decisions about investment, staffing and process change.

The observability plane is fully integrated: topology, metrics, traces, logs and events are correlated in a unified model that supports both real-time diagnosis and historical analysis. Change intelligence connects deployments, configuration changes and operational outcomes, enabling the organisation to measure the impact of every change on reliability, performance and compliance [3].

Sovereignty enforcement is continuous and auditable. Policy evaluations are logged, and the organisation can demonstrate at any point in time which policies were in effect, which resources were evaluated, and what the results were. Compliance is not a periodic exercise but a continuously maintained state, with drift detection and automated remediation for common violations.

Agents at Level 4 take on operational roles: executing diagnostics, performing bounded remediation actions, managing routine capacity decisions. Their actions are governed by explicit policies, logged with full lineage, and subject to the same review processes as human actions. The boundary between human and agent work is clearly defined and adjustable [8].

Cross-functional integration is a hallmark of Level 4. Operations, security, compliance and development teams share a common understanding of the estate's state and use the same data to make decisions. The shift-left operations model is fully realised: operational concerns are addressed during design and development, not discovered in production.

The defining characteristic of Level 4 is **data-driven management**. Decisions about operations—what to invest in, what to automate, where to tighten controls—are based on evidence, not opinion.

### 33.2.5 Level 5 — Optimised and Autonomous

Level 5 represents the aspirational end of the maturity spectrum. At this level, the organisation's operational practices are not merely consistent and measured but are continuously self-improving. Feedback loops from operational data drive refinement of runbooks, policies, automation and agent behaviour without requiring manual intervention for routine adjustments.

Agentic operations are fully realised within bounded domains. Agents manage incident detection, diagnosis and remediation for well-understood failure modes, escalating to human operators only for novel situations or decisions that exceed their delegated authority. Agent behaviour is governed by policies that are themselves refined based on outcome data—a closed loop in which the system learns from its own operational history [8].

Sovereignty is a property of the platform, not a project. New services are deployed into appropriate sovereign zones automatically, with constraints inherited from the zone definition. Compliance evidence is produced continuously and is always audit-ready. The organisation can respond to new regulatory requirements by updating zone policies and having those changes propagate across the estate without service-by-service remediation.

Knowledge management is active: insights from incidents, changes and operational patterns are captured, indexed and made available to both human operators and agents. The knowledge base is not a static repository but a living resource that evolves with the estate.

The defining characteristic of Level 5 is **adaptive autonomy**. The system—comprising people, processes, automation and agents—adapts to changing conditions, learns from outcomes, and improves without requiring a transformation programme to drive each advance.

***

## 33.3 Assessment dimensions

Maturity is not a single axis. An organisation may have sophisticated observability (Level 4) while its sovereignty enforcement remains rudimentary (Level 2) and its agent adoption is barely begun (Level 1). The unevenness of the profile is itself informative: it reveals where the organisation has invested, where it has neglected, and where the most significant risks and opportunities lie.

The Sovereign Operations Maturity Model assesses maturity across eight dimensions. Each dimension has its own progression from Level 1 to Level 5, and the descriptions below sketch what each level looks like for each dimension.

![Figure 33.2 — Radar chart showing eight assessment dimensions with an example organisation's maturity profile, illustrating typical unevenness across dimensions](images/figure-33-2.png)

**Infrastructure codification.** This dimension assesses the extent to which infrastructure is defined, provisioned and managed through code. At Level 1, infrastructure is manually provisioned. At Level 2, IaC is used for some environments. At Level 3, IaC is the standard for all environments with peer review and automated testing. At Level 4, infrastructure changes are measured for their impact on reliability and compliance. At Level 5, infrastructure adapts autonomously within policy-defined boundaries.

**Observability depth.** This dimension measures the richness and integration of the organisation's observability capabilities. Level 1 has basic resource monitoring. Level 2 introduces structured logging and partial tracing. Level 3 achieves full MELT coverage with cross-signal correlation. Level 4 integrates topology, change events and business context into a unified observability plane. Level 5 uses observability data to drive autonomous detection, diagnosis and learning.

**Automation coverage.** This dimension assesses the breadth and sophistication of operational automation. Level 1 relies on manual processes with occasional scripts. Level 2 has automation for specific, well-understood tasks. Level 3 has systematic automation of routine operations with codified runbooks. Level 4 has intelligent automation that selects and sequences actions based on context. Level 5 has self-improving automation that refines its own procedures based on outcome data.

**Sovereignty enforcement.** This dimension evaluates how effectively the organisation enforces its sovereignty commitments through technical controls. Level 1 has sovereignty defined only in policy documents. Level 2 has basic enforcement through cloud provider region restrictions. Level 3 has comprehensive policy-as-code with continuous evaluation. Level 4 has auditable sovereignty enforcement with drift detection and remediation. Level 5 has sovereignty as an inherent platform property that applies automatically to new services [6].

An important caveat applies across all dimensions but is most visible in sovereignty enforcement and governance maturity: what constitutes a given level must be calibrated to the regulatory frameworks applicable to the organisation. A financial services firm operating under DORA faces prescriptive requirements for ICT risk management, incident reporting timelines and third-party oversight that set a high bar for Level 3 and above. A healthcare organisation operating under HIPAA and the EU Medical Device Regulation confronts a different set of obligations — centred on patient data protection, clinical safety and post-market surveillance — that redefine what "comprehensive policy-as-code" means in practice. A manufacturer subject to the Cyber Resilience Act and IEC 62443 must demonstrate security-level enforcement across industrial zones and conduits, a concern that has no analogue in a pure financial services context. Maturity assessments that ignore these sector-specific requirements will produce scores that look favourable on paper but provide false assurance when regulators or auditors apply the lens of the applicable framework (see Chapter 3 for the full regulatory landscape).

**Agent adoption.** This dimension measures the extent to which agentic systems are used in operations and the maturity of their governance. Level 1 has no operational agents or ungoverned experimentation. Level 2 has read-only agents for information gathering. Level 3 has advisory agents with explicit guardrails. Level 4 has agents performing bounded operational actions under policy governance. Level 5 has autonomous agents managing well-defined operational domains with human oversight for exceptions.

**Governance maturity.** This dimension assesses the frameworks, processes and controls that govern operational decisions, changes and agent actions. Level 1 has informal, person-dependent governance. Level 2 has basic change management and approval processes. Level 3 has consistent, documented governance frameworks with clear ownership. Level 4 has governance integrated with operational data and continuously evaluated. Level 5 has adaptive governance that adjusts policies based on risk data and operational outcomes.

**Cultural readiness.** This dimension evaluates the organisation's culture in relation to sovereign, agentic operations—including blameless post-incident practices, willingness to automate, comfort with agent delegation, and cross-functional collaboration. Level 1 is characterised by blame culture and siloed teams. Level 2 begins blameless practices and cross-team communication. Level 3 has established learning culture with systematic knowledge sharing. Level 4 has deep cross-functional integration and proactive improvement. Level 5 has a self-improving culture that embraces experimentation within guardrails [9].

**Knowledge management.** This dimension measures how the organisation captures, maintains and makes available the operational knowledge that underpins both human and agent effectiveness. Level 1 relies on tribal knowledge. Level 2 has basic documentation in wikis and runbook repositories. Level 3 has version-controlled, regularly maintained knowledge assets integrated with operational tooling. Level 4 has knowledge that is actively curated and connected to operational data. Level 5 has knowledge that is continuously enriched by operational outcomes and accessible to both human operators and agents.

***

## 33.4 Assessing your current state

A maturity model is only useful if the assessment is honest. The most common failure mode is not that organisations lack a framework for assessment, but that they assess themselves more generously than the evidence warrants. A team that has written Terraform for its primary cloud provider and stored it in a git repository may claim Level 3 for infrastructure codification—but if those definitions cover only 40 per cent of the production estate, if there is no automated testing, and if manual changes are routinely made through the console and back-filled into code after the fact, the honest assessment is Level 2 at best.

### 33.4.1 Who should participate

The assessment should involve people who do the work, not only people who manage it. A senior manager's view of operational maturity is inevitably shaped by what has been reported upward, which is often more optimistic than the reality experienced by the on-call engineer at three in the morning. A good assessment team includes representatives from infrastructure engineering, application development, observability, security, compliance, incident management and—if agents are in use—the teams responsible for agent development and governance.

External perspective is valuable but not essential. An outside assessor—whether from a consultancy, an internal audit function or a peer organisation—can challenge assumptions that insiders take for granted. The risk of purely internal assessment is that shared blind spots remain unexamined. The risk of purely external assessment is that it misses context and produces findings that feel disconnected from operational reality.

### 33.4.2 What evidence to gather

Assessment should be evidence-based, not opinion-based. For each dimension, the assessment team should gather concrete artefacts and data.

For infrastructure codification: What percentage of the production estate is defined in IaC? Are IaC definitions tested before application? How often are manual changes made outside IaC workflows? Is there drift detection?

For observability depth: Which services have structured logging, distributed tracing and defined SLOs? Can the team demonstrate cross-signal correlation for a recent incident? Is observability data sovereignty-aware—stored and processed within appropriate jurisdictional boundaries?

For automation coverage: What percentage of routine operational tasks are automated? Are automated runbooks version-controlled and tested? When did automation last prevent an incident or reduce mean time to restore?

For sovereignty enforcement: Are sovereign zones defined in code? Are policies continuously evaluated or only at deployment? Can the organisation produce compliance evidence for a specific point in time within hours rather than weeks?

For agent adoption: What agents are in use? What are their scopes and guardrails? Are agent actions logged and reviewed? Has agent behaviour been refined based on operational outcomes?

For governance maturity: Is there a consistent change management process? Are governance decisions traceable? Do governance frameworks cover agent actions as well as human actions?

For cultural readiness: Are post-incident reviews blameless? Do teams share knowledge across functional boundaries? Is there demonstrated willingness to delegate operational tasks to automation and agents?

For knowledge management: Are runbooks current? Can a new team member find the information they need without relying on a specific colleague? Is knowledge connected to the systems it describes?

### 33.4.3 Common pitfalls

Three pitfalls recur in maturity assessments.

**Over-rating** is the most common. It stems from a natural desire to present progress positively, compounded by ambiguity in maturity level definitions. The remedy is to anchor assessments in evidence: not "we do IaC" but "IaC covers 78 per cent of production resources, with automated drift detection running daily." Quantification is not always possible, but specificity always is.

**Dimension blindness** occurs when the assessment focuses on dimensions where the organisation is strong and glosses over dimensions where it is weak. An infrastructure-heavy team may produce a detailed assessment of codification and observability while spending five minutes on cultural readiness and knowledge management. A balanced assessment allocates comparable effort to each dimension.

**Point-in-time fixation** treats the assessment as a snapshot to be filed rather than a baseline to be improved upon. The value of a maturity assessment lies not in the initial scores but in the trajectory: are scores improving, and are they improving in the dimensions that matter most for the organisation's strategic objectives?

***

## 33.5 Migration paths between levels

Understanding where the organisation stands is necessary but not sufficient. The practical question is how to move from one level to the next, and in which dimensions to invest first. The transitions between levels have different characters: some are primarily technical, some are primarily organisational, and some require both to change simultaneously.

### 33.5.1 Level 1 to Level 2 — Building foundations

The transition from Level 1 to Level 2 is about establishing basic discipline. It does not require sophisticated tooling or large investment; it requires consistency and commitment.

For infrastructure codification, the first step is to pick one environment—ideally production for a non-critical service—and define its infrastructure entirely in code. This establishes the pattern and builds the team's confidence. The common mistake is to start with the most complex, most critical service; the common wisdom is to start with something important enough to matter but simple enough to succeed with.

For observability, Level 2 requires structured logging for major services and at least partial distributed tracing. The OpenTelemetry SDK [10] provides a low-friction starting point, and the investment required is modest compared to the diagnostic value gained.

For sovereignty enforcement, Level 2 means making sovereignty commitments concrete: identifying the sovereign zones, mapping which services and data belong to which zones, and implementing basic technical controls such as region restrictions. The output is often a sovereignty register—a maintained record of zones, their constraints and the services within them.

For automation, Level 2 means codifying the most common and most time-consuming manual operational tasks: the restart procedures, the log collection scripts, the health-check sequences that on-call engineers perform repeatedly. These become the nucleus of an automation library.

The cultural prerequisite for Level 2 is management commitment. Teams need permission to invest time in foundations rather than features, and they need to see that commitment sustained over quarters, not just weeks.

### 33.5.2 Level 2 to Level 3 — Standardisation

The transition from Level 2 to Level 3 is about extending what works in pockets to work everywhere. This is often the most difficult transition because it requires organisational alignment, not just technical capability.

Infrastructure codification must become the standard, not an option. This means establishing IaC review processes, automated testing for infrastructure definitions, and—critically—removing the ability to make untracked manual changes. Cloud provider configurations that allow console-based changes to IaC-managed resources must be locked down, and drift detection must be in place to catch violations.

Observability must achieve full coverage: every production service must have structured logging, tracing and defined SLOs. The observability platform must support cross-signal correlation, enabling engineers to move from a metric anomaly to the relevant traces and logs without switching tools or performing manual joins.

Sovereignty enforcement must move from basic region restrictions to comprehensive policy-as-code. This is the point at which policy frameworks such as Open Policy Agent become essential—expressing sovereignty constraints as machine-readable rules that are evaluated continuously, with violations reported and tracked [7].

Standardisation requires a platform engineering function, or something equivalent, that takes responsibility for defining and maintaining the shared patterns, tooling and practices that all teams use. Without this function, standardisation degrades into a series of team-level interpretations that gradually diverge.

### 33.5.3 Level 3 to Level 4 — Measurement and integration

The transition from Level 3 to Level 4 shifts the focus from doing things consistently to measuring what those things achieve. This transition often requires new instrumentation and new analytical capabilities.

The organisation must begin measuring operational outcomes quantitatively: not just "we have SLOs" but "our SLO attainment for Tier 1 services was 99.7 per cent this quarter, up from 99.4 per cent last quarter." Not just "we do post-incident reviews" but "the percentage of review actions completed within their target window was 82 per cent, and the recurrence rate for reviewed incident types dropped by 30 per cent." The DORA metrics [3]—deployment frequency, lead time for changes, change failure rate and time to restore service—provide a useful starting framework, but sovereign operations require additional measures: policy compliance rates, sovereignty violation counts, agent action success rates and mean time to produce compliance evidence.

Integration means connecting systems that were previously separate. The observability plane must integrate with the change management system, so that deployments and configuration changes are automatically correlated with operational outcomes. The compliance system must integrate with the observability plane, so that evidence is generated continuously rather than assembled retrospectively. Agent governance must integrate with the broader governance framework, so that agent actions are subject to the same scrutiny and accountability as human actions.

![Figure 33.3 — Feedback loops at Level 4](images/figure-33-3.png)

### 33.5.4 Level 4 to Level 5 — Optimisation and autonomy

The transition from Level 4 to Level 5 is the most demanding and the least well-defined, because Level 5 represents a state that few organisations have fully achieved. It requires not just mature practices but the confidence to close feedback loops—to allow systems to adjust their own behaviour based on operational data, within carefully defined boundaries.

Automation at Level 5 is self-refining: runbooks are updated based on the outcomes of their execution, and the system can identify when a runbook is becoming less effective and flag it for human review. Agents at Level 5 manage well-defined operational domains with genuine autonomy—not in the sense that they act without constraint, but in the sense that they make and execute decisions within their delegated authority without requiring human approval for each action [8].

Sovereignty at Level 5 is a platform property: when a new service is created, the platform determines which sovereign zone it belongs to based on its data classification and regulatory context, applies the appropriate policies, provisions the necessary infrastructure and configures the relevant observability and compliance pipelines—all without manual intervention.

The transition to Level 5 is not something that can be planned and executed as a programme. It emerges from the systematic application of the capabilities built at Levels 3 and 4, combined with a culture that is comfortable with bounded autonomy and rigorous about measuring outcomes.

### 33.5.5 Dependencies between dimensions

Dimensions are not independent. Progress in one dimension often depends on progress in another, and attempting to advance a dimension without its prerequisites leads to fragile, unsustainable gains.

Agent adoption depends heavily on observability depth and automation coverage. An agent that cannot observe the system state cannot make sound decisions; an agent that has no automation to invoke cannot take useful actions. Attempting to deploy operational agents before observability and automation are at Level 3 is a common and costly mistake.

Sovereignty enforcement depends on infrastructure codification. You cannot enforce sovereignty constraints through policy-as-code if the infrastructure is not defined in code. Manual infrastructure management and meaningful sovereignty enforcement are fundamentally incompatible at scale.

Governance maturity depends on cultural readiness. Governance frameworks that are imposed on a culture that does not value transparency and accountability become compliance theatre—boxes are ticked, but the underlying behaviours do not change.

Knowledge management depends on and supports every other dimension. Without well-maintained knowledge, automation breaks when context changes, agents make decisions based on stale information, and new team members take months to become effective.

***

## 33.6 Quick wins and structural moves

The maturity model provides a framework for assessment and target-setting, but the practical reality of transformation is messier than any model suggests. Organisations cannot advance uniformly across all dimensions; they must make choices about where to invest first and how to sequence their efforts. Two categories of action are available, and effective transformation requires both.

### 33.6.1 Quick wins that build credibility

Quick wins are changes that deliver visible improvements within weeks, not quarters. They build confidence in the direction of travel and create the political capital needed for larger structural changes.

Introducing richer observability for a critical service—including topology views, SLOs and basic event correlation—is a quick win that improves the daily experience of the operations team and demonstrates the value of the approach. Codifying a handful of high-value runbooks and automating routine diagnostics is another: it reduces toil, improves consistency and provides a tangible example of what codified operations look like. Converting a fragile manual environment to infrastructure as code, even within a single cloud provider, establishes the pattern and builds skill.

Quick wins work best when they are chosen to address genuine pain points. If the on-call team's biggest frustration is the time spent on a particular recurring incident, automating the diagnosis and remediation of that incident is a quick win that earns trust. If a compliance team spends weeks assembling audit evidence, automating the generation of compliance reports from observability data is a quick win that earns a powerful ally.

### 33.6.2 Structural moves that set direction

Quick wins, however numerous, do not by themselves create sovereign, agentic operations. Structural moves are changes that reshape the organisation's operational foundations—they take longer, require more investment, and often touch organisational boundaries.

The **sovereign core pattern** is a structural move that has proven effective in multiple contexts. The organisation defines a new sovereign zone with strong constraints—full IaC, comprehensive observability, policy-as-code enforcement, zero-copy integration patterns—and moves a carefully chosen set of services into it. The core is small at first: perhaps a single payment path, a single citizen-facing service, or a single patient-record system. But it is designed according to the full model, demonstrating what the target state looks like at small scale.

Around this core, the organisation builds governed interfaces—bridges between the sovereign core and the legacy estate. Legacy systems may still emit batch files, but a translation layer converts them into events for the core. The core provides APIs that legacy systems call, while direct database access is gradually reduced. Observability spans both worlds, but with richer context in the core.

Establishing a platform engineering function is another structural move. This function takes responsibility for shared patterns, tooling and practices, providing the consistency that standardisation (Level 3) requires. Without it, standards are suggestions; with it, they are sustained.

### 33.6.3 Avoiding transformation anti-patterns

Several anti-patterns recur in transformation programmes, and the maturity model provides a framework for recognising and avoiding them.

**The big-bang rewrite** attempts to redesign everything in one massive programme, with benefits promised only at the end. By the time the new architecture is ready, the world and the estate have both changed. The maturity model counsels incremental, measurable progress: advance one level at a time, demonstrate value at each level, and use that value to fund the next advance.

**The new silo** creates a sophisticated sovereign or agentic platform that only a few new services can use, while the bulk of critical workloads remain in the legacy estate, untouched. The sovereign core pattern avoids this trap by building bridges from the outset—the core is designed to coexist with and gradually absorb legacy workloads, not to exist in splendid isolation.

**The tooling-only transformation** buys or builds new platforms and agents without changing operating models, policies or incentives. The new tools are used like the old ones, and nothing fundamental changes. The maturity model makes this visible: high scores on infrastructure codification with low scores on governance maturity and cultural readiness indicate a tooling-only transformation in progress.

**Paper-only sovereignty** writes sovereignty policies that are impossible to implement with current topology and integration patterns, leading to a widening gap between what the organisation claims and what it actually does. The maturity model's sovereignty enforcement dimension specifically assesses whether policies are technically enforced, not merely documented.

**The unbounded agent** gives an early agent broad production access in the hope that it will learn, without guardrails, explicit scopes or outcome monitoring. When it misbehaves or underperforms, trust in the entire agentic approach collapses. The agent adoption dimension requires that agent governance mature alongside agent capability—agents at Level 4 operate under policy governance, not under faith.

***

## 33.7 Measuring progress and sustaining momentum

A maturity assessment conducted once and filed is a waste of effort. The value of the model lies in repeated assessment—tracking movement over time, identifying stalled dimensions, and connecting maturity improvements to operational and business outcomes.

### 33.7.1 Quarterly maturity reviews

A quarterly cadence has proven effective for maturity reviews. Monthly is too frequent—insufficient change occurs between assessments to make them worthwhile, and the process becomes burdensome. Annually is too infrequent—problems fester, progress goes unrecognised, and the connection between investment and outcome is lost.

Each quarterly review should assess all eight dimensions, compare scores to the previous quarter, and identify the two or three dimensions where focused effort in the next quarter will have the greatest impact. The output is not a report for filing but a prioritised action plan with owners and timelines.

### 33.7.2 Leading and lagging indicators

Maturity levels are, by nature, lagging indicators—they describe what the organisation has achieved, not what it is currently doing. To sustain momentum, the organisation needs leading indicators that signal whether progress is on track before the next maturity assessment.

Leading indicators for infrastructure codification include the percentage of new infrastructure provisioned through IaC (which should be approaching 100 per cent well before the overall estate reaches that level) and the number of manual console changes detected by drift monitoring (which should be declining toward zero).

Leading indicators for observability depth include the percentage of new services deployed with OpenTelemetry instrumentation from day one and the mean time from incident detection to root cause identification (which should decrease as observability improves).

Leading indicators for sovereignty enforcement include the number of policy violations detected and the mean time to remediate them—a decreasing violation count and a decreasing remediation time both signal progress.

Leading indicators for agent adoption include the percentage of incidents where agents contributed to diagnosis or remediation and the ratio of agent-recommended actions that were accepted versus overridden by human operators—a stable or increasing acceptance rate signals growing trust and agent effectiveness.

### 33.7.3 Connecting maturity to business outcomes

Maturity improvements must be connected to outcomes that the business cares about, or they will eventually lose executive support. The connection is not always direct—"we moved from Level 2 to Level 3 on observability" does not resonate in a board room—but it can be articulated through operational and business metrics.

Reduced mean time to restore translates to less downtime, which translates to revenue preserved and customer satisfaction maintained. Automated compliance evidence generation translates to reduced audit preparation costs and faster regulatory response. Improved change failure rates translate to fewer production incidents caused by deployments, which translates to engineering time freed for value-creating work rather than fire-fighting. Agent-assisted incident resolution translates to reduced cognitive load on on-call engineers, which translates to better retention and reduced burnout [3].

These connections should be made explicit and tracked. When a maturity improvement can be linked to a measurable business outcome, that link should be documented and communicated. When it cannot, the organisation should ask whether the improvement is genuinely valuable or merely satisfying a desire for technical sophistication.

### 33.7.4 Avoiding maturity model fatigue

Maturity models can become counterproductive when they are treated as ends in themselves rather than means to better outcomes. If teams feel that their primary obligation is to increase their maturity scores rather than to improve their operations, the model has become a bureaucratic burden rather than a useful tool.

Several practices help avoid this trap. First, keep the assessment process lightweight—a half-day workshop, not a multi-week data-gathering exercise. Second, focus on a small number of priority dimensions each quarter rather than trying to advance on all fronts simultaneously. Third, celebrate genuine improvements in operational outcomes rather than improvements in scores. Fourth, be willing to revise the model itself when it no longer reflects the organisation's priorities—a maturity model is a tool, not a constitution.

***

## Key Takeaways

- A maturity model provides the shared language and structured framework that ad-hoc self-assessment cannot, enabling evidence-based investment, accountability and benchmarking.

- The five levels—Ad-hoc, Managed, Defined, Measured, Optimised—represent a progression from chaotic, person-dependent operations to self-improving, autonomous sovereign operations. Most organisations will find themselves at different levels across different dimensions.

- Eight assessment dimensions—infrastructure codification, observability depth, automation coverage, sovereignty enforcement, agent adoption, governance maturity, cultural readiness and knowledge management—provide a comprehensive profile of operational maturity. The unevenness of the profile is often more revealing than the average.

- Honest, evidence-based assessment is essential. The most common pitfall is over-rating, driven by ambiguity in definitions and a natural desire to present progress positively. Anchoring assessments in specific evidence rather than general claims is the remedy.

- Dimensions are interdependent: agent adoption depends on observability and automation; sovereignty enforcement depends on infrastructure codification; governance depends on cultural readiness. Respecting these dependencies avoids fragile, unsustainable progress.

- Effective transformation combines quick wins that build credibility with structural moves—such as the sovereign core pattern and platform engineering—that reshape operational foundations. Five named anti-patterns (big-bang rewrite, new silo, tooling-only transformation, paper-only sovereignty, unbounded agent) should be actively monitored and avoided.

- Quarterly maturity reviews, leading indicators and explicit connection to business outcomes sustain momentum. The model should serve operations, not the other way around.

***

## Bridge to Chapter 34 — Reference Blueprints

The maturity model provides a framework for understanding where an organisation stands and how it should progress, but it deliberately avoids prescribing specific architectural patterns. Chapter 34 turns to that question directly, presenting reference blueprints—concrete architectural templates for sovereign, agentic operations at different scales and in different contexts. Where this chapter asked "how mature are we?", the next asks "what should the architecture look like?" The blueprints draw on the maturity model to indicate which capabilities must be in place before a given blueprint can be effectively adopted, connecting assessment to action.

***

## References

[1] H. Kerzner, *Project Management: A Systems Approach to Planning, Scheduling, and Controlling*, 13th ed. Hoboken, NJ: Wiley, 2022.

[2] CMMI Institute, "CMMI V2.0 Model at a Glance," ISACA, 2018. [Online]. Available: https://cmmiinstitute.com/cmmi

[3] N. Forsgren, J. Humble, and G. Kim, *Accelerate: The Science of Lean Software and DevOps*, Portland, OR: IT Revolution Press, 2018.

[4] Cloud Native Computing Foundation, "Cloud Native Maturity Model," CNCF TAG App Delivery, 2023. [Online]. Available: https://maturitymodel.cncf.io/

[5] A. Hidalgo, *Implementing Service Level Objectives*, Sebastopol, CA: O'Reilly Media, 2020.

[6] European Union Agency for Cybersecurity (ENISA), "Cloud Computing Risk Assessment," ENISA, 2009. [Online]. Available: https://www.enisa.europa.eu/publications/cloud-computing-risk-assessment

[7] Open Policy Agent, "Policy Language (Rego)," The Linux Foundation, 2024. [Online]. Available: https://www.openpolicyagent.org/docs/latest/policy-language/

[8] M. Lippi, M. Mamei, S. Mariani, and F. Zambonelli, "An Argumentation-Based Perspective over the Social IoT," *IEEE Internet of Things Journal*, vol. 5, no. 4, pp. 2537–2547, 2018.

[9] R. Westrum, "A Typology of Organisational Cultures," *BMJ Quality & Safety*, vol. 13, suppl. 2, pp. ii22–ii27, 2004.

[10] OpenTelemetry Authors, "OpenTelemetry Specification," Cloud Native Computing Foundation, 2024. [Online]. Available: https://opentelemetry.io/docs/specs/otel/
