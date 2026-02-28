Here is Chapter 13 rewritten in the same narrative style, now with embedded references and a brief reference list you can attach at the end of the chapter.

***

# Chapter 13 — The Human Operating Model for Sovereign, Agentic Operations

***

## 13.1 Technology is not enough

It is tempting, when looking at the architectures in the previous chapters, to believe that the problem is mostly technical. If only we had the right observability stack, the right automation, the right agents and the right policies‑as‑code, everything else would follow. In practice, many of the worst failures in complex systems have not been down to missing tools, but to misaligned roles, unclear decision rights, overloaded teams and invisible assumptions about who is responsible for what. [cloud.google](https://cloud.google.com/blog/products/devops-sre/evaluating-where-your-team-lies-on-the-sre-spectrum)

A beautifully designed sovereign, agentic architecture can still fail if, at 3 a.m., no one knows who is allowed to approve a risky remediation, who speaks to regulators, or whether the agent’s recommendation should be trusted. SRE and incident‑management guidance is explicit that clear roles, responsibilities and escalation paths are essential to effective response. [atlassian](https://www.atlassian.com/incident-management/incident-response/incident-commander)

This chapter is about the **human operating model** that sits on top of the technical model. It explores how roles, responsibilities, escalation paths and trust boundaries need to change when sovereignty and AI move from slides to production. The goal is not to prescribe a single organisation chart, but to describe patterns that make sovereign, agentic operations sustainable for the people who live in them.

***

## 13.2 From silos to shared planes

Traditional IT organisations often mirror the layers of their stack: network teams, server teams, database teams, application teams, security teams, each with their own tools and practices. In the best cases, they collaborate; in the worst, they throw tickets over the wall. In multi‑cloud environments, this fragmentation becomes even more acute as each provider adds its own specialists. [sydneyacademics](https://sydneyacademics.com/index.php/ajmlra/article/view/128)

The four planes introduced in Chapter 4—Observability, Automation & Orchestration, Agentic Intelligence, Governance & Audit—cut across these silos. Observability needs signals from everywhere; automation must touch networks, platforms and applications; agents need to reason across domains; governance must speak to both risk and engineering.

Organisations that succeed with multi‑cloud and SRE tend to converge on a set of cross‑cutting capabilities: [red-gate](https://www.red-gate.com/simple-talk/?p=106756)

- A **platform engineering** or **platform operations** team that owns the substrate: infrastructure as code, clusters, network fabrics, identity and key management. Their job is to provide a safe, well‑governed platform for others to build on. [200oksolutions](https://www.200oksolutions.com/blog/multi-cloud-platform-engineering-azure-aws-gcp/)
- A **site reliability engineering (SRE)** or **service reliability** function that focuses on keeping critical services healthy, shaping SLOs, runbooks, incident response and post‑incident learning. [sre](https://sre.google/workbook/incident-response/)
- A **data and AI platform** team that owns shared data services, AI tooling, model governance and the agent framework, including AI guardrails. [restratconsulting](https://www.restratconsulting.com/post/accountable-ai-guardrails-decision-intelligence)
- A **governance, risk and compliance (GRC)** function that works closely with technical teams to express policies as code and interpret operational signals in regulatory terms. [devops](https://devops.com/declarative-compliance-with-policy-as-code-and-gitops/)

These are not rigid departments; in smaller organisations, functions may be combined, and in larger ones, federated. The important shift is from **component‑centric silos** to **plane‑centric collaboration**, where people align around capabilities the architecture assumes rather than around individual technologies.

***

## 13.3 Who owns what in an incident?

Incidents are where the operating model is tested. In steady state, blurred responsibilities can be muddled through. Under pressure, they turn into confusion.

Modern incident‑management practice formalises key roles. Google’s SRE guidance and industry blogs describe structures where an **Incident Commander** coordinates the overall response, supported by technical leads and communications leads. The Incident Commander’s job is not to fix the problem personally, but to keep the team focused, make decisions, manage communication, and ensure that the right experts are engaged. [sre](https://sre.google/resources/practices-and-processes/incident-management-guide/)

In a sovereign, agentic estate, a typical critical incident might involve:

- A business service behaving badly (for example, failed payments in a particular region).  
- Multiple technical systems (APIs, event brokers, databases, networks).  
- Sovereign considerations (impacted customers in a specific jurisdiction, failover options constrained by data residency).  
- Agents proposing or executing diagnostic and remediation steps.

A clear incident operating model answers a few questions up front:

- **Who is Incident Commander?** Someone has the mandate to coordinate, make calls and manage communication, even if they are not the most technically expert person on the call. [devopstraininginstitute](https://www.devopstraininginstitute.com/blog/what-is-the-purpose-of-sre-incident-commanders-during-outages)
- **Who are the domain experts?** Platform, application, data and security specialists who can interpret signals and propose options.  
- **Who can approve risky changes?** For example, temporarily loosening limits, degrading features, or invoking a failover path that has regulatory implications.  
- **What role do agents play?** Are they allowed to execute diagnostics automatically? To apply low‑risk remediations unilaterally? To propose actions that always require human approval?

SRE teams emphasise rehearsing these roles and documenting them so that, under stress, people do not have to negotiate responsibilities on the fly. The sovereign twist is that you also need **regulatory and sovereignty stewards**—people who understand the constraints and can say, “Option B fixes the technical issue faster, but takes us out of compliance; Option A is slower but acceptable.” [cloud.google](https://cloud.google.com/blog/products/devops-sre/evaluating-where-your-team-lies-on-the-sre-spectrum)

Agents fit into this model as specialised responders: “diagnostic agents,” “runbook agents,” “change‑proposal agents,” each with clearly defined scope and escalation rules. [hoop](https://hoop.dev/blog/how-to-keep-ai-accountability-ai-operations-automation-secure-and-compliant-with-access-guardrails/)

***

## 13.4 Decision rights in an AI‑augmented world

When AI systems enter operations, new questions appear: Who is allowed to override an agent? Who is accountable if an agent’s action causes harm? Who decides how much autonomy an agent should have in a given context?

Accountable‑AI guidance stresses the importance of **operational guardrails** and clear protocols specifying when human judgement should override automated decisions, coupled with audit trails documenting inputs, outputs and interventions. DevOps and policy‑as‑code practitioners similarly talk about “closed‑loop control systems” where policies in Git constrain what automation may do, with clear ownership of those policies. [linkedin](https://www.linkedin.com/pulse/automating-security-compliance-gitops-policy-code-senthilraj-krishnan-18hlc)

A healthy operating model distinguishes between:

- **Authority**: who has the right to make a decision (for example, defining that an agent may auto‑scale a given service).  
- **Agency**: who or what actually performs the action (human operator, script, or agent).  
- **Accountability**: who is answerable for the outcome (often a service owner or engineering leader).

For example:

- A reliability lead and product owner might jointly decide that, for a low‑risk service in a non‑regulated environment, an agent is allowed to auto‑scale and restart services without human approval.  
- The agent has agency: it executes scaling actions based on SLO breaches.  
- The organisation still holds the service owner and SRE team accountable for reliability, just as if the actions were scripted. [restratconsulting](https://www.restratconsulting.com/post/accountable-ai-guardrails-decision-intelligence)

In regulated zones, the balance shifts. Agents may be restricted to diagnostics and recommendations; humans exercise authority and agency for changes with regulatory impact. Over time, as evidence accumulates that certain agent actions are safe and beneficial, autonomy can increase—but always within the bounds set by governance and documented policies. [obsidiansecurity](https://www.obsidiansecurity.com/blog/ai-guardrails)

The key is to make these decisions explicit and tie them to service criticality, data sensitivity and jurisdiction, rather than leaving them to improvisation.

***

## 13.5 Trust, transparency and explainability

Sovereign operations live under a heightened demand for **trust and explainability**. Regulators, boards and customers want to know not only that systems function, but how decisions are made, especially when AI is involved. [hoop](https://hoop.dev/blog/how-to-keep-ai-accountability-ai-operations-automation-secure-and-compliant-with-access-guardrails/)

At the human level, trust is built through:

- **Transparency**: making observability, runbooks, automation and policies visible across roles, so people can see how the system behaves. [red-gate](https://www.red-gate.com/simple-talk/?p=106756)
- **Participation**: involving engineers, operators and GRC in the design of policies and agents, rather than imposing them from above. [sydneyacademics](https://sydneyacademics.com/index.php/ajmlra/article/view/128)
- **Learning culture**: treating incidents as opportunities to improve systems and processes, not to assign blame, in line with SRE post‑mortem practices. [sre](https://sre.google/workbook/incident-response/)

At the AI level, trust requires:

- **Traceability**: agents and models must leave logs of what inputs they saw, what context and policies they applied, and what actions they took. [obsidiansecurity](https://www.obsidiansecurity.com/blog/ai-guardrails)
- **Boundaries**: clear articulation of what agents are and are not allowed to do in each context, enforced through access and policy guardrails. [hoop](https://hoop.dev/blog/how-to-keep-ai-accountability-ai-operations-automation-secure-and-compliant-with-access-guardrails/)
- **Fallbacks**: the ability for humans to override, suspend or roll back agent actions quickly when something feels wrong.

Explainability here is pragmatic. It is less about exposing every weight in a model than about being able to answer operational questions: “Why did the system decide to degrade feature X rather than fail over?” “Why did the agent not choose option B?” The answers often lie in policies‑as‑code, runbooks, SLOs and topology as much as in model internals. [devops](https://devops.com/declarative-compliance-with-policy-as-code-and-gitops/)

***

## 13.6 The shape of the teams

No two organisations will structure themselves identically, but certain patterns recur where sovereign, agentic operations are working well: [200oksolutions](https://www.200oksolutions.com/blog/multi-cloud-platform-engineering-azure-aws-gcp/)

- **Platform engineering / platform SRE**: owns the shared platform, including IaC, clusters, networking, identity and observability. Acts as an internal provider to product teams, often establishing “golden paths” and standardised workflows. [sydneyacademics](https://sydneyacademics.com/index.php/ajmlra/article/view/128)
- **Product or service teams**: own specific business services end‑to‑end, including SLOs, deployments, runbooks and integration with agents. They consume platform capabilities rather than building bespoke stacks. [cloud.google](https://cloud.google.com/blog/products/devops-sre/evaluating-where-your-team-lies-on-the-sre-spectrum)
- **Data and AI platform teams**: provide shared data services, AI tooling, model lifecycle management, and agent frameworks with access and safety guardrails. [restratconsulting](https://www.restratconsulting.com/post/accountable-ai-guardrails-decision-intelligence)
- **Central SRE / resilience office**: shapes incident‑management practices, runs drills, maintains cross‑cutting runbooks, and works with product teams on reliability and resilience patterns. [red-gate](https://www.red-gate.com/simple-talk/?p=106756)
- **Governance, risk and compliance**: partners with technical teams to define policies, manage policy‑as‑code repositories, review evidence and interact with regulators. [linkedin](https://www.linkedin.com/pulse/automating-security-compliance-gitops-policy-code-senthilraj-krishnan-18hlc)

Security may be embedded in each of these teams or operate as a strong central function that collaborates closely with platform and product. DevOps/SRE literature tends to argue for “bridging the gap, not building walls,” emphasising shared responsibility over strict hand‑offs. [red-gate](https://www.red-gate.com/simple-talk/?p=106756)

The critical factor for sovereignty is that governance and AI safety are **embedded**, not isolated. Risk and compliance people are part of design conversations about topology, data flows and agent autonomy, rather than inspecting the result from afar.

***

## 13.7 Skills and mindset shifts

Sovereign, agentic operations demand a different mix of skills and mindsets than traditional operations.

Engineers and operators need:

- **Systems thinking**: the ability to see how topology, data flows, policies and human behaviours interact, not just focus on one layer. [200oksolutions](https://www.200oksolutions.com/blog/multi-cloud-platform-engineering-azure-aws-gcp/)
- **Comfort with code**: even if they are not full‑time developers, they must be comfortable reading and modifying infrastructure‑as‑code, runbooks‑as‑code and policies‑as‑code. [octopus](https://octopus.com/blog/introducing-config-as-code-runbooks)
- **Data literacy**: the ability to interpret observability data, lineage maps and AI metrics in meaningful ways. [atlan](https://atlan.com/data-lineage-and-data-observability/)

Risk and governance professionals need:

- **Technical literacy**: enough understanding of cloud, AI and automation to participate in policy‑as‑code and control design, not just policy writing. [devops](https://devops.com/declarative-compliance-with-policy-as-code-and-gitops/)
- **Operational empathy**: appreciation of the realities of on‑call, incident response and engineering constraints, so policies are implementable rather than idealised. [cloud.google](https://cloud.google.com/blog/products/devops-sre/evaluating-where-your-team-lies-on-the-sre-spectrum)

Leaders need:

- **Appetite for transparency**: willingness to see where controls are weak or failing, rather than relying solely on paper assurances. [chef](https://www.chef.io/whitepapers/buyers-guide-for-continuous-compliance-solutions-in-devops)
- **Investment mindset**: recognition that building the human and technical operating model is a programme, not a checklist, and that platform engineering and SRE functions are strategic, not overhead. [sydneyacademics](https://sydneyacademics.com/index.php/ajmlra/article/view/128)

Culturally, the model thrives in organisations that treat automation and AI as **amplifiers of human capability**, not as cost‑cutting replacements. Agents take on toil and routine work; humans focus on design, judgement and improvement. [hoop](https://hoop.dev/blog/how-to-keep-ai-accountability-ai-operations-automation-secure-and-compliant-with-access-guardrails/)

***

## 13.8 Living with sovereign, agentic operations

For the people inside it, a well‑designed sovereign, agentic operating model does not feel like a machine where humans are merely cogs. It feels more like a cockpit with good instruments, well‑tested procedures, and an intelligent co‑pilot.

On a good day, you see:

- Alerts that are meaningful, not spam, because observability and SLOs are well‑tuned. [cloud.google](https://cloud.google.com/blog/products/devops-sre/evaluating-where-your-team-lies-on-the-sre-spectrum)
- Runbooks and automations that match reality and make incidents feel manageable. [developer.harness](https://developer.harness.io/docs/category/runbooks/)
- Agents that handle the drudgery of data gathering and simple fixes, leaving humans to handle ambiguity and trade‑offs, under clear guardrails. [developer.harness](https://developer.harness.io/docs/ai-sre/runbooks/)
- Policies that feel like guardrails, not handcuffs, because they are aligned with how the system is actually built and are enforced declaratively via GitOps and policy‑as‑code. [puppet](https://www.puppet.com/resources/accelerating-continuous-compliance)

On a bad day—and there will always be bad days—you see:

- Incidents where things go wrong, sometimes badly.  
- A system of people, tools and agents that can explain what happened, learn from it, and adjust. [sre](https://sre.google/workbook/incident-response/)
- A governance function that is close enough to operations to understand trade‑offs, and yet independent enough to insist on certain lines not being crossed. [obsidiansecurity](https://www.obsidiansecurity.com/blog/ai-guardrails)

The promise of the architecture we have been building is not that things will never fail, nor that AI will magically make operations effortless. It is that **when things fail**, they will fail in ways that are visible, bounded and recoverable, within constraints that the organisation has chosen consciously.

In the chapters that follow, we will see how this operating model plays out in concrete agentic patterns and industry‑specific blueprints, and how organisations can move from their current reality toward this target state without stopping the world to rebuild it.

***

### References

1. Atlassian, “The role of the incident commander.” [atlassian](https://www.atlassian.com/incident-management/incident-response/incident-commander)
2. Google SRE, “Incident management and response” and SRE workbook guidance. [sre](https://sre.google/resources/practices-and-processes/incident-management-guide/)
3. Uptime Labs, “What is an Incident Commander?” [uptimelabs](https://uptimelabs.io/learn/what-is-an-incident-commander/)
4. StatusPal, “The Role of an Incident Commander: Key Responsibilities.” [statuspal](https://www.statuspal.io/blog/2023-10-04-what-is-the-role-of-an-incident-commander)
5. DevOps Training Institute, “What Is The Purpose Of SRE Incident Commanders During Outages?” [devopstraininginstitute](https://www.devopstraininginstitute.com/blog/what-is-the-purpose-of-sre-incident-commanders-during-outages)
6. Spike.sh, “Incident Commander: Roles, Responsibilities, and Key Skills.” [spike](https://spike.sh/blog/incident-commander/)
7. “Platform Engineering for Multi‑Cloud Enterprise Architectures: Design Patterns and Best Practices.” [sydneyacademics](https://sydneyacademics.com/index.php/ajmlra/article/view/128)
8. 200OK Solutions, “Azure, AWS, GCP: Multi‑Cloud Platform Engineering.” [200oksolutions](https://www.200oksolutions.com/blog/multi-cloud-platform-engineering-azure-aws-gcp/)
9. Google Cloud, “Evaluating where your team lies on the SRE spectrum.” [cloud.google](https://cloud.google.com/blog/products/devops-sre/evaluating-where-your-team-lies-on-the-sre-spectrum)
10. Redgate, “DevOps vs. SRE: Bridging the Gap, Not Building Walls.” [red-gate](https://www.red-gate.com/simple-talk/?p=106756)
11. DevOps.com, “Declarative Compliance With Policy‑as‑Code and GitOps.” [devops](https://devops.com/declarative-compliance-with-policy-as-code-and-gitops/)
12. Senthilraj Krishnan, “Automating Security Compliance with GitOps & Policy as Code.” [linkedin](https://www.linkedin.com/pulse/automating-security-compliance-gitops-policy-code-senthilraj-krishnan-18hlc)
13. Puppet and others on policy‑as‑code for compliance. [trendmicro](https://www.trendmicro.com/en_gb/research/23/c/policy-as-code-vs-compliance-as-code.html)
14. Restrat Consulting, “Accountable AI: Guardrails for Decision Intelligence.” [restratconsulting](https://www.restratconsulting.com/post/accountable-ai-guardrails-decision-intelligence)
15. Hoop.dev, “How to keep AI accountability and AI operations automation secure and compliant with access guardrails.” [hoop](https://hoop.dev/blog/how-to-keep-ai-accountability-ai-operations-automation-secure-and-compliant-with-access-guardrails/)
16. Obsidian Security, “AI Guardrails: Enforcing Safety Without Slowing Innovation.” [obsidiansecurity](https://www.obsidiansecurity.com/blog/ai-guardrails)
17. Octopus, “Config as Code for Runbooks / Configuration As Code For Runbooks.” [octopus](https://octopus.com/blog/config-as-code-runbooks)
18. Harness, “Runbooks” documentation. [developer.harness](https://developer.harness.io/docs/category/runbooks/)
19. SolarWinds, “Runbook Best Practices.” [solarwinds](https://www.solarwinds.com/sre-best-practices/runbook-automation)
