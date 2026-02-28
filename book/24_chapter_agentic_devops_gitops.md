# Chapter 24 — Agentic DevOps and GitOps for Sovereign Estates

***

## 24.1 The convergence of agentic AI and DevOps

DevOps, in its original articulation, was a cultural and organisational movement before it was a technical one. Its central insight—that development and operations should share accountability for the software they deliver—was always more about feedback loops, shared metrics, and mutual visibility than about any particular tool. Yet the tooling that grew up around DevOps became, over time, the medium through which the movement's principles were expressed in practice. CI/CD pipelines, infrastructure-as-code repositories, declarative deployment manifests, and automated test suites are, collectively, the operational vocabulary of modern software delivery. They embody the principle that known, repeatable processes should be automated, reviewed, and versioned rather than performed ad hoc by individuals acting from memory.

That vocabulary is now undergoing an expansion. The known, repeatable processes that traditional DevOps tooling automates well—build, test, deploy, rollback—are necessary but not sufficient for the operational challenges facing large sovereign estates. The harder problems lie in the spaces between those automations: diagnosing why a deployment that passed all its gates is nevertheless degrading production; determining whether a configuration drift detected in a sovereign zone requires immediate remediation or is a benign consequence of a planned migration; deciding how to sequence a fleet-wide security patch across multiple clusters in multiple jurisdictions without violating change freeze windows. These are problems that require judgement, contextual reasoning, and the ability to synthesise information from multiple sources—precisely the capabilities that agentic AI systems are designed to provide [1].

The shift is subtle but important. Traditional DevOps automation operates on a principle that might be characterised as "automate the known": if you can write the procedure down as a pipeline, codify the checks as gates, and express the desired state as a manifest, then the machine can execute it faster, more reliably, and more consistently than a human. Agentic DevOps extends this to "assist with the unknown": when the procedure is ambiguous, when the right action depends on conditions that cannot be enumerated in advance, when the relevant information is spread across observability telemetry, change records, policy documents, and organisational context, an agent can propose a course of action, explain its reasoning, and—within carefully bounded authority—execute on behalf of a human operator who retains the right to approve or override.

IBM's operational stack reflects this evolution. IBM Concert acts as the reasoning layer that correlates signals across the estate, identifies situations that require attention, and generates prioritised recommendations [2]. watsonx Orchestrate translates those recommendations into executable workflows, coordinating actions across multiple systems and respecting the approval gates and bounded-autonomy policies that the organisation has defined [3]. When these capabilities are directed at the DevOps domain—at pull requests, deployment pipelines, configuration reconciliation, and progressive delivery—the result is a DevOps practice that is not merely automated but genuinely adaptive.

For sovereign estates specifically, the convergence of agentic AI and DevOps addresses a problem that traditional pipeline automation cannot: the combinatorial complexity of operating across multiple jurisdictions, each with its own regulatory constraints, data residency requirements, change management protocols, and approval hierarchies. A pipeline that deploys the same service to twelve clusters in four sovereign zones must respect different policies in each zone. An agent, informed by Concert's entity model and the organisation's policy corpus, can navigate that complexity in a way that a static pipeline definition cannot, adapting its behaviour to the zone in which it is operating rather than relying on the pipeline author to have anticipated every permutation.

This chapter explores how that convergence is operationalised. We begin with GitOps as the foundational control loop—the mechanism through which desired state is declared, versioned, and reconciled—and then examine how agentic systems participate in and extend that loop, from proposing changes through pull requests to driving progressive delivery based on real-time observability signals.

> **[FIGURE 24.1 — The evolution from manual operations through pipeline automation to agentic DevOps, showing the expanding scope of machine-assisted decision-making at each stage]**

***

## 24.2 GitOps as the sovereign control loop

The term GitOps was coined by Alexis Richardson of Weaveworks in 2017 and has since become the dominant pattern for managing Kubernetes-native infrastructure and application delivery [4]. Its core principles are straightforward: the entire desired state of a system is declared in Git; changes to that desired state are made exclusively through Git operations (commits, pull requests, merges); and a software agent running within the target environment continuously reconciles the actual state of the system against the declared state in Git, applying corrections when drift is detected. The pattern draws on control theory: Git is the setpoint, the cluster is the plant, and the GitOps controller is the feedback mechanism that drives the plant towards the setpoint.

What makes GitOps particularly well suited to sovereign operations is not any single technical capability but the convergence of several properties that sovereign estates require and that GitOps provides structurally rather than as an afterthought.

**Auditability** is the first. Every change to the desired state of a sovereign environment is a Git commit. Git commits are immutable, timestamped, attributed to an author, and—when configured with GPG or SSH signing—cryptographically verified. The commit history of a GitOps repository is, by construction, a complete, tamper-evident audit trail of every configuration change made to the environment, including who proposed it, who approved it, what changed, and when. This is not supplementary logging bolted onto a deployment tool; it is the deployment mechanism itself, and the audit trail is a natural consequence of using it. For organisations subject to regulatory frameworks that require demonstrable change control—DORA, NIS2, SOC 2, ISO 27001—the Git log is evidence of compliance, not a report generated after the fact [5].

**Version control and rollback** follow directly. Because the desired state is a sequence of commits, reverting to a previous known-good state is a Git revert operation. The GitOps controller detects the change in declared state and reconciles the environment accordingly. This is operationally simpler and more reliable than the rollback mechanisms of imperative deployment tools, which must track and reverse a sequence of API calls whose side effects may not be fully reversible. In a sovereign estate, where a misconfigured deployment in a regulated zone may have compliance implications, the ability to restore a known-good state rapidly and with full auditability is a material operational requirement.

**Approval workflows** are the third property. Git hosting platforms—GitHub, GitLab, Bitbucket, Gitea—provide pull request mechanisms with configurable review requirements, branch protection rules, and status checks. A change to the desired state of a sovereign zone can be required to pass automated policy checks, receive approval from a designated set of reviewers (including reviewers with zone-specific authority), and satisfy integration test gates before it is merged and therefore before the GitOps controller applies it. The approval workflow is not an external process grafted onto the deployment mechanism; it is the deployment mechanism. Nothing reaches the target environment without passing through the gate that the organisation has defined.

**Declarative configuration** is the fourth. GitOps operates on manifests—Kubernetes YAML, Helm charts, Kustomize overlays—that describe the desired end state rather than the steps required to reach it. This declarative style is essential for reconciliation: the GitOps controller can compare the declared state against the actual state and compute the necessary corrections without relying on a record of what actions have previously been taken. It is also essential for policy enforcement: a declarative manifest can be statically analysed by a policy engine before it is applied, which is considerably more tractable than analysing an imperative script whose effects depend on runtime conditions.

For sovereign estates, these properties combine to create a control loop with a level of transparency, traceability, and enforceability that imperative deployment approaches cannot match. The Git repository becomes the sovereign record of intent for each zone: what the organisation declares should exist, how it should be configured, and who authorised each change. The GitOps controller becomes the enforcement mechanism that continuously drives reality towards that declared intent, surfacing any deviation as a reconciliation event that can be observed, alerted on, and investigated.

> **[FIGURE 24.2 — The GitOps control loop: Git repository as declared state, GitOps controller as reconciliation agent, target cluster as actual state, with feedback arrows showing drift detection and correction]**

***

## 24.3 Argo CD and Flux in sovereign architectures

The two dominant open-source GitOps controllers are Argo CD, a CNCF graduated project [6], and Flux, also a CNCF graduated project [7]. Both implement the core GitOps reconciliation loop—watching a Git repository for changes, comparing declared state against actual state, and applying corrections—but they differ in architecture, extension model, and operational characteristics in ways that matter for sovereign deployments. Red Hat OpenShift GitOps, the enterprise distribution shipped with OpenShift, is built on Argo CD and adds integration with OpenShift's RBAC model, certificate management, and multi-cluster capabilities [8].

### 24.3.1 Deploying controllers within sovereign zones

The first architectural decision in a sovereign GitOps deployment is where the controllers run. In a non-sovereign context, it is common to operate a single, centralised GitOps controller that manages multiple clusters from a management plane. In a sovereign estate, this pattern raises immediate concerns. If a GitOps controller in zone A manages clusters in zone B, then zone A holds the credentials and the control-plane authority over zone B's infrastructure. This may violate the operational sovereignty principle that each zone should be self-governing, and it certainly means that a compromise of the management plane in zone A grants the attacker the ability to modify the declared state of zone B.

The sovereign pattern is to deploy a GitOps controller instance within each sovereign zone, managing only the clusters within that zone. Each instance watches its own Git repository—or a zone-specific branch or path within a shared repository—and holds credentials only for the clusters it manages. This zone-local deployment ensures that the reconciliation loop for a given sovereign zone operates entirely within that zone's trust boundary. It also means that the GitOps controller's own availability is scoped to the zone: an outage in zone A's controller does not affect zone B's ability to reconcile its desired state.

Argo CD supports this pattern through its Application and ApplicationSet custom resources. An ApplicationSet can generate Application resources dynamically based on cluster labels, enabling a pattern where a single ApplicationSet definition, parameterised by zone, produces zone-specific Application instances that target only the clusters within a given zone [6]. The ApplicationSet controller itself runs within the zone, and the cluster credentials it holds—stored as Kubernetes secrets—are limited to that zone's clusters. Flux achieves the same outcome through its Kustomization and GitRepository custom resources, which can be configured to watch specific paths within a repository and to use specific service account credentials for each target cluster [7].

### 24.3.2 Multi-cluster, multi-zone reconciliation

Most sovereign estates operate multiple clusters per zone—production and staging environments, application clusters and platform clusters, region-specific clusters for data residency. The GitOps controller within each zone must manage the reconciliation of all clusters in that zone, which requires a clear repository structure that maps declared state to target clusters.

A common and effective pattern is the "app of apps" or "fleet" pattern, where a top-level Git repository defines the set of applications and their target clusters, and each application's configuration is drawn from a separate repository or path. In Argo CD, this is expressed as an Application that points to a directory containing further Application manifests, one per target cluster. In Flux, the equivalent is a Kustomization that references a directory of further Kustomizations. The key discipline is that the mapping from application to cluster to zone is explicit in the repository structure, not implicit in controller configuration. An auditor—or an agent—can read the repository and determine which applications are deployed to which clusters in which zones without inspecting the controller's runtime state.

Zone boundaries must be respected not just in targeting but in dependency resolution. A Helm chart that declares a dependency on a chart hosted in a registry outside the sovereign zone introduces a supply-chain dependency that crosses the zone boundary. The sovereign pattern is to mirror all required Helm charts and container images into registries within the zone, and to configure the GitOps controller to pull exclusively from those local registries. This is discussed further in the context of supply-chain security in Chapter 25.

### 24.3.3 Secrets in GitOps flows

Secrets—database credentials, API keys, TLS certificates—cannot be stored in plain text in a Git repository, yet the GitOps model requires that the desired state of the environment, including its secrets, be declared in Git. The sovereign dimension adds a further constraint: secrets associated with a sovereign zone must be stored and managed within that zone's key management infrastructure, not in a centralised secrets vault that crosses zone boundaries.

The established solutions to this problem fall into two categories. The first is sealed or encrypted secrets, where secrets are encrypted before being committed to Git and decrypted by a controller running within the target cluster. Bitnami Sealed Secrets and Mozilla SOPS are the most widely adopted tools in this category. SOPS supports encryption with keys held in AWS KMS, Azure Key Vault, GCP KMS, and HashiCorp Vault, which means the encryption key can be zone-local: a secret encrypted with an AWS KMS key in the EU-sovereign account can only be decrypted by a workload with access to that key in that account [9].

The second category is external secrets operators, which store a reference to a secret in Git rather than the secret itself. The External Secrets Operator watches for ExternalSecret custom resources in the cluster and fetches the corresponding secret values from an external secrets manager—HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, IBM Secrets Manager—at reconciliation time. The Git repository contains only the reference (the path and key name in the secrets manager), and the actual secret value never passes through Git. For sovereign deployments, the External Secrets Operator is configured to point to a secrets manager instance within the sovereign zone, ensuring that secret values are retrieved from zone-local infrastructure.

Both approaches are compatible with agentic workflows. An agent proposing a configuration change that involves a new secret can create the secret in the zone-local secrets manager and include the corresponding ExternalSecret reference in its pull request, without the secret value ever appearing in the Git diff.

> **[FIGURE 24.3 — Sovereign GitOps architecture: zone-local controllers, zone-scoped repositories, local image registries, and zone-local secrets management, with zone boundaries shown as trust perimeters]**

***

## 24.4 Agent-assisted pull request workflows

The pull request is the fundamental unit of change in a GitOps workflow. Every modification to the desired state of the environment—a new deployment, a configuration change, a security patch, a scaling adjustment—begins as a pull request, passes through review and validation, and is applied only upon merge. This makes the pull request a natural integration point for agentic systems: agents can propose changes by authoring pull requests, review changes by analysing pull requests authored by others, and validate changes by running automated checks as pull request status gates.

### 24.4.1 Agents as change proposers

The most immediate application of agentic AI in the GitOps workflow is the agent that detects a condition requiring remediation and proposes the fix as a pull request. Consider a concrete example. IBM Concert detects configuration drift in a sovereign zone: a deployment's resource limits have been manually modified in the cluster, diverging from the declared state in Git. The traditional GitOps response is automatic reconciliation—the controller reverts the drift. But if the drift was introduced deliberately (perhaps an operator increased memory limits during an incident and forgot to update the manifest), automatic reversion may cause a regression. An agent, informed by Concert's context—the drift occurred during a P1 incident, the service is still recovering, the change was made by an authorised SRE—can propose a pull request that updates the Git manifest to match the new limits, with a commit message explaining the context and referencing the incident ticket. The human reviewer sees the proposed change with full context and can approve, modify, or reject it.

Security patching is another domain where agent-authored pull requests are valuable. When a new CVE is published affecting a base image used across the estate, an agent can scan the GitOps repositories to identify all deployments using the affected image, determine the patched version, and create pull requests updating the image references in each affected manifest. For a sovereign estate with dozens of services across multiple zones, this transforms a multi-day manual effort into a set of machine-generated pull requests that reviewers can approve in minutes. The agent respects zone boundaries by creating separate pull requests for each zone's repository, ensuring that approvals flow through zone-specific review chains.

watsonx Orchestrate provides the workflow execution layer for these agent-initiated changes [3]. When Concert generates a recommendation—"update image tag for service X to address CVE-2026-1234"—Orchestrate can execute the corresponding workflow: clone the repository, create a branch, modify the manifest, commit the change, push the branch, and open the pull request. The workflow is itself auditable: the pull request records its author as the agent service account, and the commit message references the Concert recommendation that triggered it.

### 24.4.2 Agents as reviewers

The complementary role is the agent that reviews pull requests authored by humans (or by other agents). A sovereignty-aware review agent can analyse a proposed change against the policy corpus for the target zone, checking for violations that a human reviewer might miss: an image tag referencing a registry outside the zone, a network policy that opens connectivity to a subnet in a different jurisdiction, a resource quota change that would exceed the zone's allocated capacity, or a label modification that would remove a resource from the scope of a compliance policy.

This is not a replacement for human review. It is an augmentation. The agent runs as a pull request status check, posting its findings as review comments that the human reviewer can consider alongside their own analysis. The agent's review is particularly valuable for changes that span multiple files or multiple services, where the cross-cutting implications of a change may not be apparent from reading any single file in isolation. A human reviewer examining a Kustomize overlay change may not immediately recognise that the change, when rendered, produces a manifest that violates a network policy constraint. An agent that renders the overlay, applies the policy checks, and reports the violation saves the reviewer from a potentially costly oversight.

### 24.4.3 Validation gates

The third role is the agent that operates as a validation gate: a required status check that must pass before a pull request can be merged. Unlike a traditional CI check that runs a fixed set of tests, an agent-driven validation gate can adapt its checks based on the nature of the change. A change that modifies only labels and annotations may require only policy validation. A change that modifies resource limits may additionally require a capacity check against the target cluster. A change that introduces a new external dependency may require a supply-chain risk assessment. The agent determines which checks are relevant, executes them, and reports the aggregate result as a pass/fail status on the pull request.

For sovereign estates, the validation gate is also the enforcement point for zone-specific policies. A pull request targeting a regulated zone's repository must pass a different—typically stricter—set of checks than one targeting a development zone. The agent enforces this by reading the zone classification from the repository metadata and selecting the corresponding policy set.

> **[FIGURE 24.4 — Agent-assisted pull request lifecycle: agent-authored PRs (drift remediation, patching), agent-reviewed PRs (policy analysis, cross-cutting checks), and agent-validated PRs (adaptive gate checks), all converging on the merge decision]**

***

## 24.5 Policy enforcement in the GitOps pipeline

GitOps moves the enforcement boundary earlier in the delivery lifecycle. Instead of relying solely on admission controllers at the Kubernetes API server to reject non-compliant resources at apply time, the GitOps pipeline can reject non-compliant changes at commit time, before they reach the cluster. This shift-left approach is foundational to sovereign operations: it is considerably cheaper, less disruptive, and more auditable to reject a policy-violating change in a pull request review than to have it rejected by an admission controller in production, or worse, to discover the violation during a compliance audit.

### 24.5.1 Pre-commit and pre-merge policy checks

The first enforcement layer operates before a change enters the repository's main branch. Pre-commit hooks—executed on the developer's workstation before the commit is created—can run lightweight policy checks: YAML syntax validation, schema validation against Kubernetes API schemas, and basic policy checks using tools such as kubeconform or kubeval. These checks catch obvious errors early but cannot enforce comprehensive policy because they run outside the organisation's controlled environment.

Pre-merge checks, executed as CI jobs triggered by the pull request, are the primary enforcement mechanism. Open Policy Agent (OPA) with its Rego policy language [10] is the dominant tool for this purpose. A pre-merge pipeline renders the proposed manifests (expanding Helm templates and Kustomize overlays into plain Kubernetes YAML), then evaluates the rendered manifests against a set of Rego policies. The policies express the organisation's constraints: permitted image registries, required labels, prohibited privilege escalations, mandatory resource limits, network policy requirements, and—critically for sovereign operations—zone-specific constraints such as permitted regions, required encryption configurations, and data classification labels.

The policy repository is itself managed through GitOps. Policies are versioned, reviewed, and deployed through the same pull request workflow as application configuration. This means that policy changes are auditable in the same way as infrastructure changes: who proposed the new policy, who approved it, when it took effect, and what it replaced. An agent can propose a policy change in the same way it proposes a configuration change, and the change follows the same approval workflow.

### 24.5.2 Admission control as a safety net

Pre-merge policy checks are the preferred enforcement point, but they are not the only one. An admission controller running in the cluster—OPA Gatekeeper or Kyverno—provides a second layer of enforcement that catches violations introduced through any path, including direct kubectl access, emergency break-glass procedures, or reconciliation of manifests that were merged before a new policy was adopted.

For sovereign operations, admission controllers enforce zone-level invariants: constraints that must hold regardless of how a resource enters the cluster. These include hard constraints on image sources (only images from the zone-local registry), namespace isolation policies (no cross-namespace network traffic without explicit policy), and resource annotation requirements (every deployment must carry a data-classification annotation). The admission controller is the last line of defence before a non-compliant resource enters the cluster, and its policies should be a subset of—not a replacement for—the policies enforced at the pre-merge stage.

The relationship between pre-merge policies and admission policies deserves deliberate management. If the two sets diverge, changes may be approved in the pull request review but rejected by the admission controller, producing a reconciliation failure that the GitOps controller reports as a sync error. The sovereign pattern is to derive both sets from a common policy source: a single Rego policy library that is evaluated at pre-merge time by conftest and at admission time by Gatekeeper, ensuring consistency. Changes to this shared policy library follow the same pull request workflow and are tested against both evaluation contexts before being deployed.

### 24.5.3 Sovereignty-aware admission policies

Certain policy requirements are unique to sovereign estates and do not appear in generic Kubernetes security baselines. These include:

**Data residency enforcement.** A policy that prevents the creation of PersistentVolumeClaim resources backed by storage classes whose underlying provider is outside the zone's approved regions. This requires the policy to be aware of the mapping between storage classes and provider regions—information that may be maintained as a ConfigMap in the cluster or as a data document in the policy bundle.

**Cross-zone communication controls.** A policy that prevents the creation of Service or Ingress resources whose backends resolve to endpoints outside the sovereign zone's network perimeter. This enforces at the Kubernetes layer the network isolation that should also be enforced at the infrastructure layer, providing defence in depth.

**Encryption-at-rest requirements.** A policy that rejects PersistentVolumeClaim resources unless they reference a storage class configured with encryption using keys from the zone-local key management service. The policy verifies not just that encryption is enabled but that the key source is within the zone's trust boundary.

**Operator authority constraints.** A policy that restricts certain high-impact operations—namespace deletion, ClusterRole modification, admission webhook changes—to service accounts associated with specific roles, preventing even authenticated users from performing operations outside their zone-level authority.

These policies, expressed in Rego or Kyverno's YAML-based policy language, become machine-readable expressions of the sovereignty requirements that Chapter 10 discusses at the architectural level. Their enforcement through the GitOps pipeline means that sovereignty is not a property that must be manually verified at audit time but a continuously enforced invariant of the delivery process.

***

## 24.6 Progressive delivery and canary automation

Deploying a change to a sovereign estate is not a binary operation. A fleet of clusters spanning multiple zones, each serving distinct user populations under distinct regulatory regimes, requires a deployment strategy that is incremental, observable, and reversible. Progressive delivery—the practice of exposing changes to increasing fractions of traffic or users while monitoring for regressions—is the operational pattern that makes this possible. Agentic systems add a further dimension: they can drive the progression decisions based on real-time analysis of observability signals, rather than relying on static timers or manual operator intervention.

### 24.6.1 Canary deployments in sovereign zones

The canary deployment pattern deploys a new version alongside the existing version, routes a small fraction of traffic to the new version, and promotes or rolls back based on observed behaviour. Argo Rollouts, an extension to Argo CD, provides Kubernetes-native canary deployment automation with configurable traffic splitting, analysis templates, and automated promotion or rollback decisions [6].

In a sovereign estate, the canary must respect zone boundaries. Traffic splitting must ensure that requests carrying data subject to zone-specific residency requirements are not routed to a canary instance running in a different zone. This constraint is typically enforced at the service mesh level—Istio or OpenShift Service Mesh—where traffic routing rules can be scoped to zone-local endpoints. The Argo Rollout's traffic management integration with Istio supports this by allowing the rollout to modify Istio VirtualService weights without altering the service mesh's zone-scoping rules.

The analysis phase of a canary deployment is where agentic intelligence is most valuable. A traditional canary analysis compares a fixed set of metrics—error rate, latency percentiles, saturation—between the canary and baseline versions. An agent-driven analysis can be more nuanced. It can consult Concert's entity model to understand the canary service's position in the dependency graph and check whether observed anomalies in downstream services correlate with the canary traffic. It can examine the deployment's change risk score, computed by IBM DevOps Insights based on the change's test coverage, code complexity, and historical failure patterns [11]. It can evaluate the canary's behaviour against SLO budgets rather than against fixed thresholds, promoting only if the canary's error budget consumption is within acceptable bounds.

### 24.6.2 Agent-driven rollback decisions

The rollback decision is, in many respects, the most consequential decision in the deployment lifecycle. A premature rollback wastes engineering effort and delays the delivery of the change. A delayed rollback allows a degraded version to serve production traffic, potentially violating SLOs and damaging user experience. The decision is made under uncertainty—early in a canary's exposure, the signal-to-noise ratio is low—and it is time-sensitive.

An agent can approach this decision more systematically than a human operator watching a dashboard. The agent continuously evaluates a set of promotion criteria defined in the Argo Rollout's AnalysisTemplate, but it also incorporates contextual information that static analysis templates cannot express: Is the canary service in a sovereign zone that is currently within a change freeze window for a different service? Has Concert detected a concurrent situation in a dependency that might confound the canary metrics? Is the canary's traffic fraction sufficient for statistical significance given the service's baseline request rate?

The agent's decision is not opaque. It posts its reasoning—the metrics examined, the comparisons made, the contextual factors considered—as annotations on the Rollout resource and as comments on the associated pull request. A human operator who disagrees with the agent's decision can override it, and the override is recorded alongside the agent's reasoning, creating an audit trail that documents both the automated analysis and the human judgement.

### 24.6.3 Multi-zone progressive delivery

For services deployed across multiple sovereign zones, progressive delivery must be coordinated across zones without violating zone autonomy. The pattern is to sequence the canary across zones: deploy and validate in the least-sensitive zone first (typically a development or staging zone), then promote to production zones in order of increasing regulatory sensitivity. Each zone's promotion decision is made by the zone-local GitOps controller and its associated agent, based on the zone-local observability signals. The sequencing is expressed in the GitOps repository as a set of overlays with zone-specific promotion criteria—tighter error-rate thresholds and longer bake times for regulated zones than for development zones.

watsonx Orchestrate can coordinate this cross-zone sequencing by monitoring the promotion status of the rollout in each zone and triggering the next zone's deployment only when the preceding zone's canary has been promoted successfully [3]. The coordination respects zone boundaries: Orchestrate does not hold credentials to the downstream zone's cluster. Instead, it updates the downstream zone's GitOps repository (by merging the pending promotion pull request), and the downstream zone's GitOps controller applies the change. The control flow passes through Git, preserving the auditability and approval properties of the GitOps model.

> **[FIGURE 24.5 — Multi-zone progressive delivery: canary deployment in zone 1 (dev), promotion triggers PR merge for zone 2 (staging), then zone 3 (EU-regulated production), with agent-driven analysis at each stage and rollback paths shown]**

***

## 24.7 Operational feedback loops

The GitOps control loop, as described in section 24.2, is a reconciliation loop: it drives the actual state of the environment towards the declared state in Git. But the declared state itself should not be static. Production behaviour reveals information that the original configuration did not anticipate: resource limits that are too tight under real load, connection pool sizes that are insufficient for peak traffic patterns, health check intervals that are too aggressive for a service with slow startup times. Operational feedback loops close the gap between what is observed in production and what is declared in Git, ensuring that the declared state evolves in response to operational experience.

### 24.7.1 Telemetry-driven configuration proposals

The simplest feedback loop is the agent that monitors production telemetry and proposes configuration adjustments. Consider a service whose pods are being OOMKilled under peak load. The observability plane—Instana, in the IBM stack—detects the pattern: memory utilisation approaching the limit, followed by container restarts. Concert correlates this with the service's deployment configuration and identifies that the memory limit is set below the observed peak consumption. An agent, acting on Concert's recommendation, creates a pull request that increases the memory limit to a value derived from the observed peak plus a configurable safety margin.

This is not a novel concept—tools such as the Kubernetes Vertical Pod Autoscaler have performed automated resource adjustments for years. The difference in an agentic GitOps context is threefold. First, the change flows through the pull request workflow, which means it is reviewed, approved, and auditable. The VPA modifies resources in place, bypassing the GitOps control loop and creating drift between the declared state and actual state. The agent-authored pull request keeps Git as the single source of truth. Second, the agent can incorporate context that the VPA cannot: it can check whether the target zone has sufficient capacity for the proposed increase, whether the service is scheduled for decommissioning (making the increase unnecessary), or whether a more appropriate response is to optimise the application rather than increase the resource allocation. Third, the pull request's review workflow provides a natural checkpoint for human oversight, which matters in regulated environments where automated resource changes without review may be problematic.

### 24.7.2 Closing the observe-decide-act loop

The operational feedback loop is an instantiation of the observe-decide-act cycle that defines agentic operations more broadly, applied specifically to the GitOps configuration surface. The observe phase is performed by the observability plane (Instana, Prometheus, OpenTelemetry collectors) and correlated by Concert. The decide phase is performed by the agentic layer—Concert generating recommendations, an agent evaluating those recommendations against the current GitOps state and the target zone's policies. The act phase is the creation of a pull request that, upon approval and merge, is applied by the GitOps controller.

What distinguishes this from a simple recommendation engine is the closed-loop property. The act phase produces a change that is itself observable: after the configuration change is applied, the observability plane captures the resulting behaviour, Concert evaluates whether the change had the intended effect, and the agent updates its model of the system's operational characteristics. If a memory limit increase resolved the OOMKill pattern, the loop is closed. If it did not—perhaps the underlying cause was a memory leak rather than an undersized limit—the agent detects the continued anomaly and proposes a different remediation, such as scheduling a restart or flagging the issue for application-level investigation.

This iterative refinement is particularly valuable for sovereign estates because the operational characteristics of services may differ between zones. A service deployed in a zone with different hardware specifications, network latency profiles, or traffic patterns may require zone-specific tuning that is not apparent from the service's configuration in other zones. The feedback loop, operating independently within each zone, converges on zone-appropriate configuration without requiring a central authority to anticipate and prescribe the differences.

### 24.7.3 Guardrails on the feedback loop

An unconstrained feedback loop—an agent that can propose any change to any configuration based on any signal—is a system with unbounded blast radius. Guardrails are essential, and they operate at multiple levels.

**Scope constraints** limit the configuration parameters that agents may modify. An agent authorised to adjust resource limits and replica counts is not authorised to modify network policies, RBAC bindings, or image references. These constraints are expressed as policy rules that the validation gate (section 24.4.3) enforces: a pull request authored by the resource-tuning agent that modifies a network policy is rejected by the gate.

**Rate constraints** prevent the feedback loop from oscillating. If an agent proposes a memory increase, observes continued pressure, and immediately proposes a further increase, the result may be a runaway escalation that exhausts cluster capacity. Rate constraints impose minimum intervals between successive changes to the same parameter and maximum cumulative changes within a time window.

**Approval escalation** ensures that high-impact changes require human review even when the agent has bounded autonomy for lower-impact changes. A 10% increase in a memory limit may be within the agent's autonomous authority. A 200% increase, or an increase that would push the zone's total resource consumption beyond a defined threshold, triggers an escalation to human review. The escalation thresholds are themselves expressed as policy and managed through the GitOps workflow.

**Revert triggers** allow the GitOps controller or a monitoring agent to detect that an agent-proposed change has degraded the system and to initiate a revert. The revert is itself a pull request—a Git revert of the agent's change—preserving the audit trail and allowing human review of the decision to revert.

These guardrails ensure that the feedback loop accelerates convergence on good configuration without introducing the risks of unconstrained automation. The guardrails are not restrictions on agentic capability; they are the conditions under which agentic capability can be trusted to operate in a sovereign, regulated environment.

> **[FIGURE 24.6 — The operational feedback loop: observe (telemetry) to decide (Concert recommendation and agent evaluation) to act (PR authored, reviewed, merged, applied), with guardrails shown as constraints on each stage and the closed-loop feedback path from post-deployment observation back to the decide stage]**

***

## Key Takeaways

- **GitOps is the natural control loop for sovereign operations.** Its structural properties—auditability, version control, declarative configuration, and built-in approval workflows—are precisely the properties that sovereign estates require for demonstrable change control and regulatory compliance.

- **GitOps controllers must be deployed within sovereign zones.** Zone-local controllers, watching zone-scoped repositories and holding only zone-local credentials, preserve operational sovereignty and limit the blast radius of controller compromise.

- **Agentic systems participate in the GitOps workflow through pull requests.** Agents propose changes (drift remediation, patching, configuration tuning), review changes (policy analysis, cross-cutting impact assessment), and validate changes (adaptive gate checks)—all within the existing pull request mechanism rather than as a parallel control path.

- **Policy enforcement shifts left into the GitOps pipeline.** Pre-merge policy checks using OPA/Rego, combined with admission controllers as a safety net, create a layered enforcement model where sovereignty constraints are continuously enforced rather than periodically audited.

- **Secrets in GitOps flows must respect zone boundaries.** Encrypted secrets or external secret references ensure that secret values are managed within zone-local key management infrastructure and never appear in plain text in Git.

- **Progressive delivery in sovereign estates requires zone-aware sequencing.** Canary deployments are validated zone by zone, with agent-driven analysis incorporating observability signals, dependency context, and zone-specific promotion criteria.

- **Operational feedback loops close the gap between observed behaviour and declared state.** Agents propose configuration adjustments based on production telemetry, but guardrails—scope constraints, rate limits, approval escalation, and revert triggers—ensure the loop operates safely within bounded autonomy.

- **The pull request is the universal audit artefact.** Whether a change is proposed by a human, an agent, or a feedback loop, it flows through Git, carrying its authorship, its reasoning, its review, and its approval as a permanent, tamper-evident record.

***

## Bridge to Chapter 25

The GitOps pipeline described in this chapter assumes that the artefacts it deploys—container images, Helm charts, policy bundles—are trustworthy. Chapter 25 examines how that trust is established and maintained through CI/CD quality gates, supply-chain security, and the continuous verification of artefact provenance and integrity across sovereign zones.

***

## References

[1] D. Sato, "The Rise of AI Agents in Software Delivery," *ThoughtWorks Technology Radar*, vol. 31, 2025. Available: https://www.thoughtworks.com/radar

[2] IBM, "IBM Concert Documentation," IBM Cloud Docs, 2025. Available: https://www.ibm.com/docs/en/concert

[3] IBM, "IBM watsonx Orchestrate Documentation," IBM Cloud Docs, 2025. Available: https://www.ibm.com/docs/en/watsonx-orchestrate

[4] A. Richardson, "GitOps — Operations by Pull Request," Weaveworks Blog, 2017. Available: https://www.weave.works/blog/gitops-operations-by-pull-request

[5] OpenGitOps, "GitOps Principles v1.0.0," CNCF, 2022. Available: https://opengitops.dev/

[6] Argo Project, "Argo CD — Declarative GitOps CD for Kubernetes," CNCF, 2024. Available: https://argo-cd.readthedocs.io/

[7] Flux Project, "Flux — the GitOps family of projects," CNCF, 2024. Available: https://fluxcd.io/

[8] Red Hat, "OpenShift GitOps Documentation," Red Hat, 2025. Available: https://docs.openshift.com/gitops/

[9] Mozilla, "SOPS: Secrets OPerationS," GitHub, 2024. Available: https://github.com/getsops/sops

[10] Open Policy Agent, "OPA Documentation," CNCF, 2024. Available: https://www.openpolicyagent.org/docs/

[11] IBM, "IBM DevOps Insights Documentation," IBM Cloud Docs, 2025. Available: https://www.ibm.com/docs/en/devops-insights
