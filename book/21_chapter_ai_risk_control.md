# Chapter 21 — AI Risk and Control in Sovereign Operations

***

## Summary

This chapter presents a systematic risk management framework for AI agents deployed in sovereign operational environments, recognising that the failure modes of agentic systems—hallucination, prompt injection, scope creep, cross-zone data leakage, knowledge base corruption, and model drift—carry consequences qualitatively different from those of traditional monitoring and alerting. It applies the NIST AI Risk Management Framework's four-function structure to sovereign operations, maps operational agents against the EU AI Act's high-risk classification criteria, and constructs an operational risk taxonomy with targeted controls for each risk category. The chapter details runtime enforcement mechanisms including guardrail agents with policy-as-code, output validation, confidence thresholds, human-in-the-loop gates, and circuit breakers, alongside continuous monitoring of decision quality and structured feedback from post-incident reviews. Architects will find guidance on building and maintaining a sovereign AI risk register integrated with enterprise risk management, calibrating controls empirically rather than arbitrarily, and closing the loop between operational experience and risk posture.

***

The previous chapter closed with an observation that deserves explicit amplification before this chapter builds on it. Knowledge-augmented agents—the planner agents, executor agents and reviewer agents whose architecture, orchestration and knowledge layers have been the subject of Chapters 18 through 20—produce recommendations that are grounded in retrieved documents, topology models and real-time telemetry. That grounding is a significant improvement over reasoning from model pre-training alone. It is not, however, a guarantee of correctness. The documents retrieved may be stale. The embedding model may surface a superficially similar but materially different runbook. The generation model may produce a recommendation that is internally coherent, linguistically confident, and factually wrong. The agent may act on that recommendation within its bounded autonomy before a human operator has the opportunity to intervene.

These are not hypothetical concerns. They are the characteristic failure modes of AI-assisted operations, and they carry consequences that are qualitatively different from the consequences of a poorly written alert rule or a misconfigured dashboard. An agent that confidently executes the wrong runbook on a production database in a regulated sovereign zone does not merely cause an outage; it may violate data residency requirements, breach regulatory obligations, and produce an audit trail that demonstrates the organisation delegated a material operational decision to a system it did not adequately control. The operational risk is real, the regulatory exposure is real, and the reputational damage is real.

Managing these risks is the subject of this chapter. The approach taken here is deliberately pragmatic: not a philosophical treatment of AI ethics, but a structured application of established risk management disciplines to the specific challenges posed by operational AI agents in sovereign cloud estates. The chapter maps the NIST AI Risk Management Framework and the EU AI Act to operational agent deployments, enumerates the specific risks that arise in agentic operations, describes the practical structure of a sovereign AI risk register, examines the runtime controls that enforce risk boundaries during agent execution, and establishes the monitoring and feedback mechanisms that keep the risk posture current as the estate and its agents evolve.

> **[FIGURE 21.1 — AI risk and control in the sovereign operations architecture: a layered view showing the agentic operations control plane (planner, executor, reviewer agents from Chapter 18) with risk controls applied at each layer—input validation on telemetry and knowledge retrieval, guardrail enforcement during agent reasoning, output validation before action execution, and continuous monitoring feeding back to the risk register. The sovereign zone boundary encloses the entire stack.]**

***

## 21.1 Why operational AI needs a risk framework

The case for applying formal risk management to operational AI agents is not self-evident to every organisation. Many enterprises have deployed machine learning models in production for years—anomaly detection on time series, log classification, predictive alerting—without feeling the need for a dedicated AI risk framework. These models operate within narrow, well-understood parameters: they ingest numerical data, produce numerical scores, and the worst consequence of a bad prediction is a false alert that a human operator evaluates and dismisses. The risk surface is small and the blast radius is contained.

Agentic operations changes this calculus fundamentally. The agents described in earlier chapters do not merely predict; they reason, plan and act. A planner agent receiving a Concert situation assessment formulates a hypothesis about root cause, retrieves relevant knowledge from the operational knowledge base, evaluates remediation options against the current topology and policy constraints, and proposes a course of action. An executor agent, operating within its bounded autonomy, may carry out that action—scaling a deployment, draining a node, executing a remediation script—without human intervention. The chain from signal to action is shorter, the decision-making is more complex, and the consequences of error are more severe.

Several properties of this architecture create risks that generic AI ethics frameworks do not adequately address.

First, **hallucination in operational context** carries material consequences. When a conversational AI assistant hallucinates a citation in a research summary, the user can verify the claim. When an operational agent hallucinates a remediation step—recommending a database parameter change that is syntactically valid but semantically destructive—the consequence is not misinformation but infrastructure damage. The confidence with which large language models produce incorrect outputs is well documented in the evaluation literature [1], and that confidence is particularly dangerous when the consumer of the output is not a sceptical human but a downstream agent in an automated pipeline.

Second, **scope creep** in agent authority is an emergent risk. An agent initially authorised to restart pods in a development namespace may, through progressive trust-building and policy relaxation, accumulate authority to modify production configurations. Each individual expansion of scope may be justified; the cumulative effect may be an agent whose blast radius far exceeds what the organisation intended when it deployed agentic operations. The absence of a formal risk assessment at each scope expansion means the organisation's actual risk exposure diverges from its documented risk appetite.

Third, **data residency violations through model context** represent a sovereign-specific risk that has no analogue in non-sovereign deployments. An agent reasoning about an incident in a regulated European sovereign zone may, in assembling its context, retrieve knowledge fragments, telemetry data or configuration details from a different sovereign zone. If the generation model processes that cross-zone context, data that was required to remain within a specific jurisdiction has effectively been transferred—not by a network packet crossing a border, but by a prompt crossing a context boundary. The data residency violation is real even though no traditional data transfer occurred [2].

Fourth, **prompt injection through telemetry** is a threat vector unique to AI-augmented operations. Log messages, metric labels, container names, and even DNS records are data that operational agents ingest as context. An attacker who can influence any of these data sources can craft inputs designed to manipulate agent behaviour—instructing the agent to ignore certain alerts, to escalate privileges, or to exfiltrate configuration data through its action outputs. The OWASP Top 10 for LLM Applications identifies prompt injection as the most critical vulnerability in LLM-integrated systems [3], and the attack surface in operational environments is broader than in most application contexts because the range of ingested data sources is so large.

These risks are not addressed by the standard practices of model evaluation and testing that suffice for narrow ML deployments. They require a structured risk management framework that identifies operational AI-specific risks, assesses their likelihood and impact in the context of the specific estate, implements controls proportionate to the risk, and monitors the effectiveness of those controls over time. The remainder of this chapter provides that framework.

***

## 21.2 The NIST AI Risk Management Framework applied to operations

The NIST AI Risk Management Framework (AI RMF), published in January 2023 [4], provides the most comprehensive and broadly adopted structure for managing AI risk in the United States and in organisations that align their governance practices with NIST standards. The framework is voluntary, sector-agnostic, and designed to be adaptable to diverse AI applications. Its four core functions—Govern, Map, Measure, and Manage—provide a natural organising structure for operational AI risk management.

### Govern

The Govern function establishes the organisational structures, policies, roles and accountability mechanisms that make AI risk management possible. In the context of operational AI agents, governance begins with a clear statement of organisational risk appetite for agentic operations: under what circumstances is the organisation willing to allow AI agents to take autonomous action, what classes of action require human approval, and what classes of action are prohibited regardless of agent confidence?

This risk appetite statement must be specific to the operational domain, not a general corporate AI policy statement. A statement that says "the organisation will use AI responsibly" provides no actionable guidance to the team configuring agent autonomy boundaries. A statement that says "AI agents may autonomously execute pre-approved remediation runbooks on non-production workloads in non-regulated sovereign zones, with human-in-the-loop approval required for all actions affecting production workloads or regulated zones" provides precise, implementable guidance. The Govern function requires that such statements exist, that they are reviewed periodically, and that accountability for their enforcement is assigned to named roles [4].

In the IBM sovereign operations stack, the governance layer is realised through a combination of watsonx.governance—which provides the model lifecycle management, policy enforcement, and audit capabilities for AI models and agents—and IBM OpenPages, which serves as the enterprise governance, risk and compliance platform where AI risk policies, control assessments, and risk acceptance decisions are recorded [5]. The integration between these platforms ensures that the AI governance posture is not a separate, disconnected activity but part of the organisation's broader enterprise risk management programme.

### Map

The Map function requires the organisation to identify and characterise the AI systems in its operational estate. For agentic operations, this means maintaining an inventory of every agent, every model, every knowledge base, and every integration point in the agent pipeline. The inventory must record the purpose of each component, its inputs and outputs, its scope of authority, the sovereign zones in which it operates, and the data sources it accesses.

This mapping exercise is more demanding than it first appears. In a mature agentic operations deployment, the agent ecosystem is not a single monolithic system but a network of specialised agents—planner agents, executor agents, reviewer agents, knowledge retrieval agents, compliance checking agents—each with its own model, its own context assembly logic, and its own set of integrations. The Map function requires that this network be documented with sufficient granularity that a risk assessor can trace any agent action back to its originating signal, its reasoning context, and the authority boundary within which it operated.

The mapping should also identify the contexts in which AI systems interact with each other. A planner agent that consults a knowledge retrieval agent, which in turn queries a vector database populated by an embedding model, represents a chain of AI-mediated decisions. The risk profile of the chain is not simply the sum of the individual component risks; it includes the risks that arise from the interactions between components—an embedding model that systematically under-retrieves certain document types creates a blind spot that the planner agent inherits and the reviewer agent may not detect.

> **[FIGURE 21.2 — NIST AI RMF functions mapped to sovereign agentic operations: a four-quadrant diagram with Govern (risk appetite, accountability, policy), Map (agent inventory, authority boundaries, data flows, sovereign zone assignments), Measure (hallucination rates, decision accuracy, drift metrics, compliance violation counts), and Manage (guardrails, kill switches, human-in-the-loop gates, remediation procedures). Arrows connect the quadrants in a continuous cycle.]**

### Measure

The Measure function requires the organisation to assess and track the performance, reliability and trustworthiness of its AI systems against defined metrics. For operational agents, the relevant metrics fall into several categories.

**Decision accuracy** measures whether agent recommendations, when evaluated against ground truth or expert judgement, are correct. This is inherently difficult to measure in real time—the correctness of a remediation recommendation is often only apparent after the remediation has been executed—but it can be assessed retrospectively through structured review of agent decisions in post-incident analysis. A sample of agent recommendations can be presented to experienced operators for blind evaluation, producing a decision accuracy rate that is tracked over time.

**Hallucination rate** measures the frequency with which agent outputs contain claims that are not supported by the retrieved context or the telemetry data. Automated hallucination detection—using a separate model to evaluate whether the agent's output is consistent with its input context—is an active area of research and increasingly practical for production deployment [6]. In the IBM stack, watsonx.governance provides model evaluation capabilities that can be configured to assess output faithfulness against retrieved context.

**Scope compliance** measures whether agents operate within their defined authority boundaries. Every agent action should be logged with sufficient metadata to determine whether the action fell within the agent's authorised scope. The rate of out-of-scope actions—actions that were attempted but blocked by guardrails, or worse, actions that were executed outside the intended scope—is a critical risk metric.

**Sovereign zone integrity** measures whether agent operations respect sovereign zone boundaries. This includes both data flow integrity (no cross-zone data transfer in agent context) and action integrity (no agent action in a sovereign zone for which the agent is not authorised).

### Manage

The Manage function addresses the response to identified risks: the controls, mitigations and response procedures that reduce risk to an acceptable level. In operational AI, the Manage function encompasses the runtime controls described in Section 21.6 (guardrails, kill switches, circuit breakers), the risk register described in Section 21.5, and the incident response procedures that are invoked when an AI-related risk materialises.

The Manage function also addresses the lifecycle decisions that arise when risk measurements indicate that an agent or model is no longer performing within acceptable parameters. When decision accuracy drops below a defined threshold, or hallucination rates increase beyond tolerance, the Manage function prescribes the response: retraining the model, restricting agent autonomy, reverting to a previous model version, or retiring the agent entirely. These lifecycle decisions should be governed by pre-defined decision criteria, not left to ad hoc judgement during an incident.

The NIST framework's strength is its generality—it applies across AI deployment contexts. Its limitation in the operational sovereignty context is that it does not address jurisdiction-specific regulatory requirements, data residency obligations, or the specific characteristics of multi-zone sovereign estates. These gaps are filled by the EU AI Act provisions discussed in the next section and by the operational risk taxonomy developed in Section 21.4.

***

## 21.3 EU AI Act risk classifications for operational agents

The European Union's Artificial Intelligence Act [7], which entered into force in August 2024 with a phased implementation timeline extending to 2027, establishes the world's first comprehensive regulatory framework for AI systems. For organisations operating sovereign cloud estates in EU jurisdictions—or serving EU customers from sovereign zones that fall under EU regulatory scope—the AI Act is not an optional compliance aspiration; it is a binding legal obligation with significant penalties for non-compliance.

The Act classifies AI systems into four risk tiers: unacceptable risk (prohibited), high risk (subject to extensive requirements), limited risk (subject to transparency obligations), and minimal risk (largely unregulated). The classification of operational AI agents depends on their function, their domain of deployment, and their degree of autonomy.

### High-risk classification criteria

An AI system is classified as high-risk under the Act if it falls within one of the categories enumerated in Annex III, or if it is a safety component of a product covered by the EU's product safety legislation. The categories most relevant to operational AI agents include AI systems used as safety components of critical infrastructure (including digital infrastructure), AI systems intended for use in the management and operation of critical infrastructure, and AI systems that make decisions affecting the availability of essential services [7].

Operational AI agents in sovereign cloud estates frequently meet these criteria. An agent that autonomously executes remediation actions on infrastructure supporting financial services, healthcare systems, or government digital services is, by any reasonable interpretation, an AI system involved in the management of critical infrastructure. An agent that decides whether to scale, restart, or reconfigure components of a digital infrastructure platform is functioning as a safety component of that infrastructure. The organisation's legal and compliance teams must make this classification determination explicitly, document their reasoning, and accept the regulatory consequences of the classification.

For agents classified as high-risk, the Act imposes a substantial set of requirements. **Risk management**: high-risk AI systems must be subject to a risk management system that identifies, analyses and mitigates risks throughout the system lifecycle—a requirement that aligns closely with the NIST AI RMF Govern and Manage functions. **Data governance**: the training, validation and testing datasets used for the AI system must meet quality criteria, and the data governance practices must be documented. For operational agents that use RAG rather than fine-tuning, this requirement extends to the knowledge base and retrieval pipeline, not merely to the foundation model's original training data. **Technical documentation**: the provider must maintain technical documentation demonstrating compliance with the Act's requirements, including a description of the system's intended purpose, its capabilities and limitations, its performance metrics, and its risk management measures. **Record-keeping**: high-risk AI systems must automatically log events to enable traceability of the system's operation—a requirement that maps directly to the agent audit trails discussed in Chapters 18 and 19. **Human oversight**: high-risk AI systems must be designed to allow effective human oversight, including the ability to understand the system's capabilities and limitations, to monitor its operation, and to intervene or halt its operation when necessary [7].

### General-purpose AI model obligations

The AI Act also introduces obligations for providers of general-purpose AI (GPAI) models—the foundation models on which operational agents are built. Providers of GPAI models must maintain technical documentation, provide information to downstream deployers, comply with copyright law, and publish a sufficiently detailed summary of training data. For GPAI models designated as presenting systemic risk (broadly, models trained with more than 10^25 FLOPs of computation), additional obligations include adversarial testing, incident reporting, and cybersecurity measures [7].

For organisations deploying operational agents on IBM watsonx.ai foundation models, these GPAI obligations fall primarily on IBM as the model provider. However, the deploying organisation retains responsibility for the agent system as a whole—the retrieval pipeline, the prompt assembly, the authority boundaries, and the operational integration. The distinction between model provider obligations and deployer obligations is a critical governance boundary that must be clearly documented in the organisation's AI governance framework.

### Conformity assessment and documentation

High-risk AI systems must undergo a conformity assessment before being placed on the market or put into service. For most operational AI agents, this will be a self-assessment conducted by the deploying organisation (internal conformity assessment based on Annex VI of the Act), rather than a third-party assessment. The self-assessment must demonstrate that the system meets all applicable requirements and must be documented in a manner that can be presented to market surveillance authorities on request.

The documentation burden is significant but not unprecedented for organisations that already maintain ISO 27001 or SOC 2 compliance. The required documentation includes a general description of the AI system, a detailed description of its components and development process, information about the monitoring, functioning, and control of the system, a description of the risk management system, and records of the conformity assessment process. In practice, organisations should integrate this documentation into their existing governance, risk and compliance platforms—IBM OpenPages, for instance, can serve as the system of record for AI Act conformity documentation alongside existing regulatory compliance records.

> **[FIGURE 21.3 — EU AI Act risk classification decision tree for operational AI agents: a flowchart starting with "Does the agent autonomously affect critical infrastructure?" and branching through Annex III categories, safety component assessment, and autonomy level evaluation, arriving at high-risk, limited-risk, or minimal-risk classifications. Annotations show the obligations triggered at each classification level.]**

***

## 21.4 Operational risk taxonomy for AI agents

The regulatory frameworks described in Sections 21.2 and 21.3 provide the governance structure for AI risk management. They do not, however, enumerate the specific risks that operational AI agents introduce. This section develops an operational risk taxonomy—a structured catalogue of the risks that arise when AI agents participate in infrastructure operations within sovereign cloud estates. Each risk is described in terms of its mechanism, its potential impact, and the control categories that address it.

### Risk 1: Model hallucination in operational decisions

Large language models generate text by predicting the most probable next token given the preceding context. This mechanism produces fluent, coherent text regardless of whether the content is factually accurate. In operational contexts, hallucination manifests as recommendations that are syntactically valid—they use correct terminology, reference plausible configuration parameters, and follow the structure of legitimate runbook steps—but are semantically incorrect. An agent might recommend modifying a database connection pool parameter that does not exist in the version deployed, or propose a remediation sequence that would be correct for one cloud provider but is inapplicable to another.

The danger of operational hallucination is amplified by the confidence with which the output is presented. Unlike a probabilistic anomaly detector that returns a confidence score, a language model generating a remediation recommendation typically provides no calibrated uncertainty estimate. The recommendation reads as authoritative regardless of the model's internal certainty. Research on LLM calibration demonstrates that output confidence and factual accuracy are poorly correlated in current-generation models [1], making it unreliable to use the model's own confidence signals as a safety mechanism.

**Controls**: output validation against known-good schemas, retrieval provenance verification (ensuring the recommendation is traceable to specific retrieved documents), confidence thresholds based on retrieval relevance scores rather than generation confidence, and mandatory human review for actions above a defined blast radius threshold.

### Risk 2: Prompt injection through telemetry data

Operational agents ingest data from sources that may be influenced by adversaries. Log messages may contain crafted strings. Kubernetes labels and annotations are writable by anyone with appropriate RBAC permissions. DNS TXT records, HTTP headers, and error messages returned by external APIs are all potential vectors for injecting instructions into an agent's context. The OWASP Foundation's analysis of LLM vulnerabilities [3] identifies indirect prompt injection—where malicious instructions are embedded in data that the model processes rather than in the user's direct input—as particularly insidious because it exploits the model's inability to distinguish between trusted instructions and untrusted data.

In a sovereign operations context, prompt injection has implications beyond the immediate operational impact. An attacker who can manipulate an agent into executing unauthorised actions in a regulated sovereign zone has effectively weaponised the organisation's own agentic operations infrastructure against its compliance obligations.

**Controls**: input sanitisation on all telemetry data before inclusion in agent context, separation of instruction prompts from data context using architectural boundaries rather than prompt-level delimiters, anomaly detection on agent behaviour patterns to identify actions inconsistent with the triggering signal, and least-privilege authority boundaries that limit the damage achievable through successful injection.

### Risk 3: Agent scope creep

Scope creep occurs when the effective authority of an agent expands beyond its originally assessed and approved boundaries. This expansion may be deliberate—an operator broadens an agent's permissions to handle a new class of incident—or emergent—an agent's reasoning leads it to invoke tools or access data sources that were not contemplated in the original risk assessment. In either case, the result is an agent operating with authority that has not been subjected to formal risk assessment.

The mechanism is insidious because each incremental expansion may be individually reasonable. An agent authorised to restart pods may be given permission to also drain nodes, then to modify resource limits, then to update ConfigMaps, until its cumulative authority encompasses the ability to make substantial changes to the production environment—changes that the organisation would never have approved as a single grant of authority.

**Controls**: immutable authority boundary definitions stored as policy-as-code and enforced by the guardrail layer, periodic re-assessment of agent authority against the risk register, automated alerts when agent actions approach or test the boundaries of their defined authority, and formal change management for any modification to agent authority boundaries.

### Risk 4: Data residency violations via model context

This risk is specific to sovereign and multi-zone deployments. An agent operating in Sovereign Zone A may, during context assembly, retrieve documents indexed from Sovereign Zone B, ingest telemetry originating in Zone B, or receive topology data describing Zone B entities. When this cross-zone data is included in the prompt sent to a generation model, the data has been processed—even if it has not been stored—in a context that may not satisfy the residency requirements of Zone B.

The subtlety of this violation is that it occurs within the AI pipeline, not at the network or storage layer. Traditional data residency controls—network segmentation, storage encryption with zone-specific keys, data classification labelling—do not address the scenario where an LLM prompt assembles fragments from multiple jurisdictions into a single reasoning context.

**Controls**: zone-aware retrieval filters that restrict knowledge base queries to the sovereign zone of the triggering signal, zone-tagged telemetry pipelines that prevent cross-zone data from entering agent context, architectural enforcement of model deployment within sovereign zone boundaries (the generation model serving Zone A must run within Zone A), and audit logging of all data sources contributing to each agent reasoning cycle.

### Risk 5: Training data poisoning and knowledge base corruption

The operational knowledge base described in Chapter 20 is a critical input to agent reasoning. If the knowledge base is corrupted—through deliberate poisoning or through the inadvertent indexing of incorrect documents—agent recommendations will be systematically biased or wrong. Unlike model hallucination, which produces errors that are random and detectable through statistical monitoring, knowledge base corruption produces errors that are consistent and may appear authoritative because they are grounded in (corrupted) source documents.

Poisoning vectors include compromised runbook repositories, manipulated post-incident review records, and the indexing of draft or superseded documents that contain incorrect procedures.

**Controls**: provenance verification for all documents entering the knowledge base, version control integration that indexes only from approved branches, content integrity checks using cryptographic hashes, periodic expert review of high-impact knowledge base content, and retrieval audit trails that enable retrospective identification of recommendations influenced by corrupted documents.

### Risk 6: Model drift and performance degradation

Foundation models and embedding models do not degrade in the way that traditional software does—they do not have memory leaks or accumulate technical debt. They do, however, become progressively less effective as the operational environment evolves and the model remains static. New services are deployed with terminology the model has not encountered. Operational procedures change in ways that make the model's prior training less relevant. The embedding model's semantic space becomes less aligned with the current vocabulary of the estate.

Drift is particularly dangerous because it is gradual and may not produce obvious failures. Instead, it manifests as a slow decline in recommendation quality—recommendations that are slightly less relevant, retrieval results that are slightly less precise—that operators compensate for unconsciously until the accumulated degradation reaches a tipping point.

**Controls**: continuous monitoring of retrieval relevance scores and recommendation quality metrics (Section 21.7), scheduled model re-evaluation against current operational data, automated drift detection using statistical tests on model output distributions, and defined thresholds that trigger model refresh or replacement.

> **[FIGURE 21.4 — Operational risk taxonomy for AI agents: a matrix showing the six risk categories (hallucination, prompt injection, scope creep, data residency violation, knowledge base corruption, model drift) across columns, with rows for mechanism, impact severity, likelihood assessment, and primary control categories. The sovereign-specific risks (data residency violation, knowledge base corruption in sovereign context) are visually distinguished.]**

***

## 21.5 The sovereign AI risk register

A risk taxonomy identifies what can go wrong. A risk register records what the organisation has decided to do about it. The AI risk register is the operational instrument that connects the theoretical risk taxonomy of Section 21.4 to the practical governance activities of the organisation—risk identification, assessment, mitigation, residual risk acceptance, and periodic review.

### Structure of the register

Each entry in the AI risk register should contain the following elements.

**Risk identifier and title**: a unique reference and a concise description sufficient to identify the risk without ambiguity. The identifier should follow the organisation's existing risk register numbering scheme to enable integration with the enterprise risk management system.

**Risk category**: mapped to the taxonomy in Section 21.4, enabling aggregation and reporting by risk type.

**Affected agents and models**: the specific agents, models, knowledge bases, and sovereign zones to which the risk applies. A risk that applies to all agents using a particular foundation model has a different profile from a risk that applies only to the executor agent operating in a specific sovereign zone.

**Likelihood assessment**: the probability that the risk will materialise within the assessment period. For operational AI risks, likelihood should be assessed on the basis of both theoretical vulnerability analysis and empirical evidence from monitoring data. An agent that has never produced a hallucination in six months of operation has a different likelihood profile from an agent deployed last week.

**Impact assessment**: the consequence of the risk materialising, assessed across the organisation's standard impact dimensions—operational disruption, financial loss, regulatory penalty, reputational damage. In sovereign operations, the impact assessment must specifically address the regulatory consequences: a data residency violation in a jurisdiction subject to GDPR carries different penalties from a service disruption in a non-regulated zone.

**Inherent risk rating**: the risk level before controls are applied, derived from the likelihood and impact assessments.

**Controls**: the specific controls implemented to mitigate the risk, with references to the control implementations in the technical architecture. Each control should be described with sufficient specificity that its implementation can be verified—"guardrails are in place" is insufficient; "the executor agent's authority boundary is enforced by an OPA policy evaluated by the guardrail agent before every action execution, with policy definitions stored in the sovereign-ops-policies Git repository and deployed via ArgoCD" is adequate.

**Control effectiveness assessment**: an evaluation of whether the controls are operating as intended, based on testing and monitoring evidence. watsonx.governance provides automated control effectiveness monitoring for model-level controls; organisational controls (review processes, training, governance forums) require manual assessment.

**Residual risk rating**: the risk level after controls are applied. The residual risk must fall within the organisation's stated risk appetite; if it does not, additional controls must be implemented or the risk must be formally escalated for executive acceptance.

**Risk owner**: the individual accountable for managing the risk and ensuring that controls remain effective. For operational AI risks, this is typically the head of platform engineering or the AI governance lead, depending on the organisation's structure.

**Review schedule**: the frequency at which the risk entry is reviewed and updated. High-residual-risk entries should be reviewed quarterly; lower-risk entries may be reviewed semi-annually.

### Integration with enterprise risk management

The AI risk register should not exist in isolation. It must be integrated with the organisation's enterprise risk management (ERM) framework so that AI-specific risks are visible alongside other operational, financial, and strategic risks. This integration ensures that AI risk is managed with the same rigour and governance oversight as other enterprise risks, and that risk appetite decisions for agentic operations are made in the context of the organisation's overall risk posture.

In practical terms, this means the AI risk register should be maintained in the same GRC platform used for other risk domains. IBM OpenPages provides this capability, allowing AI risk entries to be linked to regulatory obligations (EU AI Act conformity requirements, DORA ICT risk management requirements), to operational controls (the guardrail policies and kill switches described in Section 21.6), and to audit findings from both internal assurance reviews and external regulatory examinations [5].

The risk register is not a static document. It is a living operational instrument that must be updated when new agents are deployed, when agent authority boundaries are modified, when new sovereign zones are established, when regulatory requirements change, and when incident reviews reveal new risk information. The discipline of maintaining the register—and the governance processes that ensure it is maintained—is as important as its initial creation.

***

## 21.6 Runtime risk controls

The risk register identifies risks and prescribes controls. Runtime risk controls are the mechanisms that enforce those controls during agent execution—the technical safeguards that prevent identified risks from materialising in production. This section examines the principal categories of runtime control and their implementation in the sovereign operations architecture.

### Guardrail agents

The guardrail agent pattern, introduced in the multi-agent orchestration discussion of Chapter 18, is the primary mechanism for enforcing policy constraints on agent actions at runtime. A guardrail agent is a specialised agent—or, in simpler implementations, a policy evaluation function—that intercepts every proposed action from an executor agent and evaluates it against the current policy set before allowing execution to proceed.

The guardrail evaluation is not a simple permission check. It is a contextual assessment that considers the proposed action, the current state of the affected entities (as reported by Concert's topology model), the sovereign zone constraints applicable to the target environment, the agent's defined authority boundary, and any active change freeze windows or incident-related restrictions. The guardrail agent queries the policy engine—typically Open Policy Agent (OPA) with policies expressed in Rego and maintained as policy-as-code in version control—and returns one of three verdicts: permit, deny, or escalate (require human approval) [8].

The escalate verdict deserves particular attention. In many operational scenarios, the binary permit/deny model is insufficient. An action may be within the agent's general authority but unusual in the current context—a production deployment during a period of elevated error rates, for instance. The escalate verdict allows the guardrail to impose a human-in-the-loop gate without denying the action outright, preserving the agent's ability to recommend while ensuring human judgement is applied where the context warrants it.

In the IBM stack, watsonx.governance enforces model-level guardrails—content filters, toxicity detection, and output format validation—while the guardrail agent enforces operational guardrails at the action level. The separation is deliberate: model-level guardrails address the properties of the model's output, while operational guardrails address the properties of the proposed action in its operational context.

### Output validation

Output validation is the practice of verifying that an agent's proposed action conforms to expected schemas, parameter ranges and structural constraints before execution. Unlike guardrail evaluation, which assesses policy compliance, output validation assesses technical validity: does the proposed Kubernetes manifest parse correctly? Are the resource limits within the range defined for this environment? Does the proposed database parameter exist in the target database version?

Output validation catches a specific class of hallucination: recommendations that use correct operational vocabulary but propose actions that are technically impossible or nonsensical. A recommendation to set a PostgreSQL parameter to a value outside its valid range, or to scale a deployment to a negative number of replicas, should be caught by output validation before reaching the guardrail agent.

The validation schemas should be maintained alongside the operational configurations they validate—in the same Git repository, subject to the same review and approval processes. When a new service is deployed or a configuration parameter range changes, the validation schema must be updated to reflect the new reality.

### Confidence thresholds and retrieval scoring

Not all agent recommendations carry the same level of certainty, and the organisation's response should be calibrated accordingly. Confidence thresholds establish minimum quality criteria for agent outputs based on measurable signals—primarily the relevance scores of retrieved documents and the semantic similarity between the query and the retrieved context.

When the retrieval relevance score for an agent's knowledge base query falls below a defined threshold, the agent's recommendation is flagged as low-confidence. Low-confidence recommendations are automatically routed through the human-in-the-loop gate rather than being eligible for autonomous execution. This mechanism ensures that agents operating with poor-quality context—because the knowledge base lacks relevant content, or because the situation is genuinely novel—do not take autonomous action on the basis of inadequate information.

The threshold values should be established empirically through analysis of historical retrieval quality and recommendation accuracy, not set arbitrarily. A threshold set too high will route nearly every recommendation to human review, negating the value of agent autonomy. A threshold set too low will allow poor-quality recommendations to proceed without review. The calibration of these thresholds is an ongoing activity, informed by the continuous monitoring described in Section 21.7.

### Human-in-the-loop gates

Human-in-the-loop (HITL) gates are the points in the agent pipeline where human approval is required before execution proceeds. The design of HITL gates involves three decisions: where in the pipeline to place them, what information to present to the human reviewer, and how to handle the case where no human reviewer is available within the required response time.

The placement decision is driven by the risk taxonomy. Actions with high blast radius (production environment modifications, cross-zone operations, irreversible changes) should always pass through a HITL gate. Actions with low blast radius (development environment adjustments, read-only diagnostic queries) may proceed autonomously. The boundary between these categories is defined in the guardrail policies and enforced by the guardrail agent.

The information presentation decision determines whether the human reviewer can make an informed judgement. A HITL gate that presents the proposed action without context is useless—the reviewer has no basis for approval or rejection. Effective HITL presentation includes the triggering signal (the Concert situation that initiated the agent pipeline), the agent's reasoning chain (the hypothesis, the retrieved knowledge, the evaluated options), the proposed action with its expected effect, and the risk assessment (what could go wrong if the action is executed). watsonx Orchestrate's conversational interface provides a natural medium for this presentation, allowing the reviewer to ask clarifying questions before approving or rejecting the proposed action.

The timeout decision addresses the operational reality that human reviewers are not always immediately available. If a HITL gate blocks indefinitely waiting for approval, the incident it was responding to may escalate beyond the point where the proposed remediation is relevant. The timeout policy should specify what happens when approval is not received within a defined period: safe default (take no action and escalate through the incident management process), reduced-scope action (execute only the lowest-risk subset of the proposed remediation), or escalation to a secondary approver.

### Kill switches and circuit breakers

Kill switches provide the ability to immediately halt all agent activity—globally, per sovereign zone, or per individual agent. They are the control of last resort, used when agent behaviour has become unpredictable or harmful and other controls have failed to contain the situation.

A well-designed kill switch system has three tiers. The **global kill switch** halts all agent activity across the entire estate, reverting to fully manual operations. It is the equivalent of pulling the emergency stop on a factory floor and should be used only in extreme circumstances. The **zone kill switch** halts all agent activity within a specific sovereign zone, leaving agents in other zones operational. This is appropriate when an AI-related incident is localised to a particular jurisdiction or environment. The **agent kill switch** halts a specific agent, leaving all other agents operational. This is appropriate when a specific agent is misbehaving but the broader agent ecosystem is functioning correctly.

Circuit breakers operate on the same principle as kill switches but are automatic rather than manual. A circuit breaker monitors a defined metric—agent error rate, guardrail rejection rate, HITL escalation rate—and trips when the metric exceeds a threshold, automatically suspending agent activity until the condition is resolved. Circuit breakers protect against cascading failures in agent pipelines: if a planner agent begins producing poor-quality recommendations due to a knowledge base issue, the circuit breaker on the executor agent's error rate will prevent those recommendations from being executed before a human operator has diagnosed the problem.

> **[FIGURE 21.5 — Runtime risk control architecture: a pipeline diagram showing the flow from signal ingestion through planner agent reasoning, guardrail evaluation (with OPA policy engine), output validation, confidence threshold check, HITL gate (with watsonx Orchestrate conversational interface), and executor action. Kill switch and circuit breaker controls are shown as cross-cutting mechanisms that can interrupt the pipeline at any stage. The sovereign zone boundary encloses the pipeline, with zone-aware filters at the signal ingestion and knowledge retrieval stages.]**

***

## 21.7 Continuous risk monitoring and model performance tracking

The controls described in Section 21.6 are effective only to the extent that they are calibrated to the current behaviour of the agents they govern. An output validation schema that was accurate at deployment time becomes progressively less effective as the operational environment evolves. A confidence threshold that was correctly calibrated against last quarter's retrieval quality data may be too permissive or too restrictive given this quarter's knowledge base state. Continuous monitoring closes this loop by tracking the performance and risk indicators of the agent ecosystem over time and feeding that information back into the risk register and control calibration processes.

### Decision quality tracking

The most fundamental metric for an operational AI agent is whether its decisions are correct. Measuring decision quality in real time is difficult because the ground truth—whether a remediation recommendation would have resolved the incident—is often not known until after the remediation has been attempted. Retrospective evaluation is therefore the primary mechanism.

A structured decision review process samples agent decisions at a defined frequency—weekly for high-risk agents, monthly for lower-risk agents—and presents them to experienced operators for blind evaluation. The evaluators assess each decision on three dimensions: correctness (was the recommendation factually accurate and operationally appropriate?), completeness (did the recommendation address the full scope of the situation, or did it miss important considerations?), and safety (if executed, would the recommendation have caused unintended harm?). The results are tracked as time series metrics and reviewed in the AI governance forum.

The decision review process also serves as a feedback mechanism for the knowledge base. Decisions that were incorrect because the agent retrieved outdated or irrelevant knowledge identify specific knowledge base entries that need updating. Decisions that were incomplete because the agent lacked knowledge about a particular service or procedure identify gaps in the knowledge base that should be addressed. This connection between decision review and knowledge maintenance ensures that the quality improvement cycle described in Chapter 20, Section 20.7 is driven by empirical evidence from agent performance, not by ad hoc editorial judgement.

### Drift detection

Model drift—the gradual degradation of model performance as the operational environment evolves—requires statistical monitoring that can detect subtle changes in output distributions before they manifest as visible failures. Drift detection operates on several signal types.

**Retrieval relevance drift** tracks the distribution of retrieval relevance scores over time. A downward trend in average relevance scores indicates that the embedding model's semantic space is becoming less aligned with current operational vocabulary, or that the knowledge base content is becoming less relevant to current operational situations.

**Action distribution drift** tracks the distribution of agent-recommended actions over time. A sudden shift in the types of actions recommended—an increase in recommendations to scale deployments, for example, or a decrease in recommendations involving configuration changes—may indicate that the model's reasoning has shifted due to changes in the input signal distribution, or that a knowledge base change has systematically altered retrieval results.

**Guardrail rejection rate drift** tracks the frequency with which guardrail agents deny or escalate proposed actions. An increasing rejection rate may indicate that the agent's recommendations are becoming less policy-compliant, which in turn may indicate model drift, knowledge base corruption, or a change in the policy environment that has not been reflected in the agent's training or context.

Drift detection should use established statistical methods—the Page-Hinkley test, the Kolmogorov-Smirnov test, or CUSUM (cumulative sum control chart) methods—applied to the relevant metric time series [9]. When drift is detected, the response should be defined in advance: a minor drift may trigger increased monitoring frequency; a significant drift may trigger a model re-evaluation; a severe drift may trigger the agent circuit breaker.

### A/B testing and canary deployments for agents

When a model is updated, a knowledge base is refreshed, or an agent's reasoning logic is modified, the change should not be deployed to the full production agent population simultaneously. A/B testing and canary deployment patterns, well established in software delivery, apply equally to agent deployments.

In an A/B test, the updated agent version and the existing version both receive a random subset of incoming situations, and their recommendations are compared on the decision quality metrics described above. If the updated version performs at least as well as the existing version across all metrics, it is promoted to full deployment. If it performs worse on any metric, the update is rolled back and the root cause is investigated.

Canary deployments follow a similar principle but with a progressive rollout: the updated agent version initially handles a small percentage of situations (perhaps five per cent), with the percentage increasing gradually as monitoring confirms acceptable performance. If any metric degrades during the rollout, the canary is automatically rolled back.

These patterns require that the agent deployment infrastructure support versioned, concurrent deployment of agent configurations—a capability that watsonx.governance provides through its model lifecycle management features, and that the broader agentic operations platform must support at the agent orchestration layer.

### Feedback loops from incident reviews

Post-incident reviews (PIRs) are the most valuable source of empirical risk information for the AI risk register. When an incident involves an AI agent—whether the agent contributed to the incident, failed to prevent it, or was part of the resolution—the PIR should include a specific AI risk review section that addresses the following questions.

Did the agent's recommendation contribute to the incident? If so, what was the root cause—hallucination, stale knowledge, prompt injection, scope creep, or another mechanism from the risk taxonomy?

Did the runtime controls (guardrails, output validation, HITL gates) function as designed? If they did not catch the problem, why not—was the control absent, misconfigured, or inadequate for this specific failure mode?

What change to the risk register, the control set, or the monitoring configuration would reduce the likelihood or impact of a similar incident in the future?

The answers to these questions feed directly back into the risk register (updating likelihood and impact assessments), the control configuration (adjusting guardrail policies, confidence thresholds, or HITL gate placement), and the monitoring configuration (adding new drift detection metrics or adjusting alert thresholds). This feedback loop is what makes the AI risk management framework a living system rather than a compliance artefact—each incident makes the framework more accurate and the controls more effective.

> **[FIGURE 21.6 — Continuous risk monitoring feedback loop: a circular diagram showing the flow from agent operation (producing decisions and actions) through monitoring (decision quality, drift detection, guardrail metrics) to analysis (trend identification, threshold evaluation, incident review) to risk register update (likelihood, impact, control effectiveness) to control recalibration (policy updates, threshold adjustments, authority boundary modifications) and back to agent operation. The PIR process is shown as an additional input to the analysis stage.]**

***

## Key Takeaways

- Operational AI agents carry risks that are qualitatively different from traditional monitoring and alerting systems: hallucination produces confident but incorrect recommendations, prompt injection exploits the breadth of ingested data sources, scope creep accumulates authority beyond assessed boundaries, and cross-zone context assembly can violate data residency requirements without any traditional data transfer occurring.

- The NIST AI Risk Management Framework provides a practical four-function structure (Govern, Map, Measure, Manage) for organising operational AI risk management. Its application to sovereign operations requires extending the framework with jurisdiction-specific regulatory requirements and sovereign zone constraints.

- Operational AI agents in sovereign cloud estates frequently meet the EU AI Act's criteria for high-risk AI systems, triggering substantial requirements for risk management, data governance, technical documentation, record-keeping, and human oversight. Organisations must make the classification determination explicitly and maintain conformity documentation.

- The operational risk taxonomy for AI agents encompasses six principal risk categories: model hallucination, prompt injection through telemetry, agent scope creep, data residency violations via model context, training data poisoning and knowledge base corruption, and model drift. Each requires specific, targeted controls rather than generic AI safety measures.

- The sovereign AI risk register is a living operational instrument that must be integrated with enterprise risk management, maintained in the organisation's GRC platform, and updated continuously as the agent ecosystem and regulatory environment evolve.

- Runtime risk controls—guardrail agents with policy-as-code enforcement, output validation, confidence thresholds, human-in-the-loop gates, kill switches, and circuit breakers—form the technical enforcement layer that prevents identified risks from materialising in production. These controls must be calibrated empirically, not set arbitrarily.

- Continuous monitoring of decision quality, drift detection across multiple signal types, A/B testing of agent updates, and structured feedback from post-incident reviews close the loop between operational experience and risk management, ensuring that the framework improves with every incident and every deployment.

***

## Bridge to Chapter 22

This chapter has established the risk management foundation for operational AI: the frameworks that identify and classify risks, the register that tracks them, the runtime controls that enforce risk boundaries, and the monitoring that keeps the risk posture current. These are necessary components, but they are not sufficient on their own. Risk management tells the organisation what can go wrong and how to prevent it. It does not tell the organisation how to govern the broader AI capability—how to make decisions about which agents to deploy, how to set and evolve autonomy boundaries, how to ensure accountability across the agent ecosystem, and how to demonstrate to regulators, auditors, and stakeholders that the organisation's use of AI in operations is not merely risk-managed but governed.

Chapter 22 addresses this broader governance challenge. It presents a comprehensive AI governance framework for sovereign operations that encompasses not only risk management but also accountability structures, transparency requirements, ethical guidelines, lifecycle governance from development through retirement, and the organisational mechanisms—governance boards, review processes, escalation paths—that make AI governance operational rather than aspirational. Where this chapter has asked "what could go wrong and how do we prevent it?", Chapter 22 asks "how do we ensure that our use of AI in operations is consistently responsible, accountable, and aligned with our organisational values and regulatory obligations?"

***

## References

[1] S. Lin, J. Hilton, and O. Evans, "TruthfulQA: Measuring how models mimic human falsehoods," in *Proceedings of the 60th Annual Meeting of the Association for Computational Linguistics*, vol. 1, Dublin, Ireland, May 2022, pp. 3214–3252.

[2] European Data Protection Board, "Guidelines 05/2020 on consent under Regulation 2016/679," EDPB, Brussels, Belgium, May 2020. [Online]. Available: https://edpb.europa.eu/our-work-tools/our-documents/guidelines/guidelines-052020-consent-under-regulation-2016679_en

[3] OWASP Foundation, "OWASP Top 10 for Large Language Model Applications, v1.1," OWASP, 2023. [Online]. Available: https://owasp.org/www-project-top-10-for-large-language-model-applications/

[4] National Institute of Standards and Technology, "Artificial Intelligence Risk Management Framework (AI RMF 1.0)," NIST AI 100-1, U.S. Department of Commerce, Gaithersburg, MD, USA, Jan. 2023. [Online]. Available: https://www.nist.gov/artificial-intelligence/ai-risk-management-framework

[5] IBM, *IBM watsonx.governance: AI Governance and Compliance*, IBM Documentation, IBM Corp., Armonk, NY, USA, 2024. [Online]. Available: https://www.ibm.com/docs/en/watsonx/govai

[6] A. Manakul, A. Liusie, and M. J. F. Gales, "SelfCheckGPT: Zero-resource black-box hallucination detection for generative large language models," in *Proceedings of the 2023 Conference on Empirical Methods in Natural Language Processing*, Singapore, Dec. 2023, pp. 9004–9017.

[7] European Parliament and Council of the European Union, "Regulation (EU) 2024/1689 laying down harmonised rules on artificial intelligence (Artificial Intelligence Act)," *Official Journal of the European Union*, L series, Aug. 2024. [Online]. Available: https://eur-lex.europa.eu/eli/reg/2024/1689

[8] Open Policy Agent, "OPA: Policy-based control for cloud native environments," Cloud Native Computing Foundation, 2024. [Online]. Available: https://www.openpolicyagent.org/docs/latest/

[9] J. Gama, I. Zliobaite, A. Bifet, M. Pechenizkiy, and A. Bouchachia, "A survey on concept drift adaptation," *ACM Computing Surveys*, vol. 46, no. 4, pp. 1–37, Apr. 2014.

[10] ISO/IEC, "ISO/IEC 42001:2023 — Information technology — Artificial intelligence — Management system," International Organization for Standardization, Geneva, Switzerland, 2023. [Online]. Available: https://www.iso.org/standard/81230.html

[11] European Commission, "Ethics guidelines for trustworthy AI," High-Level Expert Group on Artificial Intelligence, Brussels, Belgium, Apr. 2019. [Online]. Available: https://digital-strategy.ec.europa.eu/en/library/ethics-guidelines-trustworthy-ai
