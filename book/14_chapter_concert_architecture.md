Here is Chapter 14 rewritten with embedded references and a brief reference list.

***

# Chapter 14 — Agentic Operations in Practice

***

## 14.1 From scripts to colleagues

For years, operations teams have relied on automation in the form of scripts, scheduled jobs and workflow engines. These tools were powerful but narrow: they did exactly what they were told, in precisely the conditions they were designed for, and failed when the world deviated from their assumptions. They had no sense of context, no ability to negotiate ambiguity, no notion of “this time is different.” [ibm](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-aiops/4.11.1?topic=apis-automation-runbook-api)

Agentic operations add something new. Instead of single‑purpose scripts, we get **agents**: software entities that can perceive the state of the estate through observability and events, reason over that state using models and policies, and take or propose actions via automation and infrastructure as code. Real‑world AIOps case studies show AI reducing operational load through incident triage, runbook automation and ticket deflection, acting more like junior colleagues than static tools. [devops](https://devops.com/from-automation-to-autonomy-what-aiops-actually-looks-like-today/)

The “intelligence” of an agent is not just in a language model or a rules engine, but in the **fabric it is embedded in**: good observability, accurate topology, reliable automation and clear policies. Without these, an agent is like a smart person dropped into a dark room; with them, it can navigate. [logicmonitor](https://www.logicmonitor.com/blog/agentic-aiops-strategy)

***

## 14.2 What an operational agent really is

For our purposes, an **operational agent** is characterised by four capabilities:

- **Perception**: it can ingest relevant signals—metrics, logs, traces, events, tickets, topology and lineage—through defined interfaces.  
- **Contextual understanding**: it can relate those signals to services, business capabilities, sovereign zones and policies, rather than treating them as isolated data points.  
- **Planning**: given an objective (“understand this incident,” “keep this SLO green,” “apply this policy”), it can break the problem into steps and choose which tools or runbooks to use.  
- **Action**: it can execute or orchestrate actions through existing automation and IaC, or produce concrete recommendations for humans.

This aligns with emerging descriptions of agentic AIOps and multi‑agent systems, where agents observe system telemetry, plan workflows and call tools to carry out operations. Vendors describing “AI ops bots” or “AI assistants for IT operations” emphasise the same pattern: AI agents sit on top of observability and automation, not replace them. [aws.amazon](https://aws.amazon.com/blogs/machine-learning/automate-it-operations-with-amazon-bedrock-agents/)

Importantly, agents are not general superheroes. Each should have a **clear domain**—diagnostics for a specific service or zone, runbook orchestration for a class of incidents, continuous optimisation for a set of resources, compliance checking for specific policies—so their behaviour is understandable and their blast radius contained. [arxiv](https://arxiv.org/html/2601.13671v1)

***

## 14.3 Multi‑agent patterns: scouts, planners and doers

In non‑trivial estates, a single omni‑agent quickly becomes unwieldy. Multi‑agent research and applied systems argue for orchestrated collections of specialised agents connected through a coordination layer. Rather than one agent trying to do everything, you deploy several with distinct roles: [aws.amazon](https://aws.amazon.com/blogs/industries/transforming-business-operations-with-multi-agent-systems-field-workforce-safety-ai-assistant/)

- **Scouts**: agents that watch the environment, detect patterns and surface possible issues. They might monitor SLOs, event streams, data quality metrics or policy signals, and create incidents or narratives when something looks wrong. [algomox](https://www.algomox.com/resources/blog/intelligent_runbooks_generative_ai_aiops)
- **Planners**: agents that, given a problem (often framed as an incident), gather context, consult runbooks and policies, and propose a course of action—including multiple options with trade‑offs. [anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)
- **Doers**: agents that execute specific workflows: running diagnostics, applying configuration changes, scaling resources, or performing compliance checks, always via existing automation interfaces and APIs. [youtube](https://www.youtube.com/watch?v=OXuJPfs9iPQ)

A multi‑agent outage‑management example from industry illustrates this pattern: one group of agents monitors grid operations and forecasts disruptions; others handle maintenance planning and resource allocation; another coordinates responses across teams. Multi‑agent architectures emphasise an orchestration layer that decomposes objectives into subtasks, assigns them to specialised agents and enforces policy across them. [arxiv](https://arxiv.org/html/2601.13671v1)

For operations, this means you might have a “SLO scout” agent that raises incidents, a “diagnostic planner” agent that assembles context and runbooks, and a “runbook executor” agent wired into your automation APIs.

***

## 14.4 Hand‑offs between humans and agents

Agentic operations are not about removing humans from the loop; they are about **changing where humans sit in the loop**.

Several hand‑off patterns recur in AIOps and agentic‑AI practice: [algomox](https://www.algomox.com/resources/blog/intelligent_runbooks_generative_ai_aiops/)

- **Agent‑to‑human escalation**: an agent reaches a point where policy or uncertainty requires human judgement. It summarises findings, presents options and explicitly asks for a decision. The human’s choice then guides further automated steps.  
- **Human‑to‑agent delegation**: an operator frames a goal (“investigate this alert,” “rotate these keys,” “prepare a failover plan for this service”) in natural language or via a console, and an agent translates that into steps, invoking tools and workflows as needed. [aws.amazon](https://aws.amazon.com/blogs/machine-learning/automate-it-operations-with-amazon-bedrock-agents/)
- **Shared workflows**: agents and humans interleave steps in a runbook. The agent performs data gathering and mechanical checks; the human inspects and decides; the agent executes low‑risk actions and prepares higher‑risk ones for review. [ibm](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-aiops/4.11.1?topic=apis-automation-runbook-api)

Intelligent runbook work, for example, shows agents using generative AI to fill in runbooks, propose next steps and adapt procedures based on feedback, while humans retain oversight. Cloud providers’ AIOps assistants similarly position agents as helpers that call existing runbooks and scripts on behalf of humans, rather than as fully autonomous operators. [algomox](https://www.algomox.com/resources/blog/intelligent_runbooks_generative_ai_aiops/)

The quality of these hand‑offs depends on how well agents can **explain themselves** (“what did you see?”, “what did you do?”, “what are you proposing next?”) and on humans framing intent and constraints clearly.

***

## 14.5 Autonomy levels and guardrails

Not all actions are equal. Restarting a stateless service in a non‑critical environment is not the same as failing over a regulated workload between jurisdictions or altering a database schema. An agent suitable for the first may be wildly inappropriate for the second.

Practitioners in AI operations and AI governance increasingly talk about **guardrails**: real‑time execution policies that protect both human and AI‑driven operations by intercepting commands at runtime, evaluating them against policy, and blocking unsafe or non‑compliant actions. Access Guardrails, for example, sit between AI tools (or humans) and production systems, inspecting what a command is trying to do, who requested it and whether it violates rules, blocking dangerous intents like bulk deletions or data exfiltration. [hoop](https://hoop.dev/blog/how-to-keep-ai-operations-automation-ai-command-monitoring-secure-and-compliant-with-access-guardrails/)

A practical operating model defines **levels of autonomy** for agents, often along lines like:

- **Level 0 — Advisory only**: the agent may observe, summarise and recommend, but must not make changes.  
- **Level 1 — Low‑risk actions**: the agent may execute a defined set of low‑risk operations (for example, collecting diagnostics, restarting non‑critical services) without explicit approval.  
- **Level 2 — Conditional actions**: the agent may perform more impactful changes if specific conditions are met and policy checks succeed.  
- **Level 3 — High autonomy**: the agent may manage a domain end‑to‑end within strict guardrails.

Autonomy level is always a property of **agent plus context**. The same agent might be allowed to restart services autonomously in a test environment (Level 2) but only advise in a regulated production zone (Level 0). Guardrails enforce these levels via:

- **Access controls and scoped credentials**: agents only have the permissions they need, and different in each environment. [hoop](https://hoop.dev/blog/build-faster-prove-control-access-guardrails-for-ai-operations-automation-aiops-governance/)
- **Policy evaluation at execution time**: every command passes through a policy layer that understands both the actor and the operation’s intent, blocking unsafe ones instantly. [docs.tetrate](https://docs.tetrate.io/agent-ops-director/guardrails/managing-guardrails)
- **Monitoring vs enforcement modes**: guardrails can start in “log only” mode to build understanding, then move to “enforce” once rules are trusted. [docs.tetrate](https://docs.tetrate.io/agent-ops-director/guardrails/managing-guardrails)

This makes it possible to increase autonomy gradually and demonstrably, rather than as an all‑or‑nothing leap.

***

## 14.6 Failure modes of agentic operations

Agentic operations add new ways to fail. Some are technical; others are social.

Common failure modes include:

- **Over‑trust**: humans treat agent recommendations as infallible, even when the agent’s confidence or context is limited. An AIOps bot suggesting a risky schema change that slips through because dashboards say “success” is a familiar cautionary tale. [hoop](https://hoop.dev/blog/how-to-keep-ai-runbook-automation-aiops-governance-secure-and-compliant-with-inline-compliance-prep/)
- **Under‑trust**: agents are ignored or second‑guessed so consistently that their benefits never materialise; humans continue to do all the toil.  
- **Stale context**: agents rely on outdated topology, policies or runbooks, leading them to propose or execute actions that are no longer appropriate. [algomox](https://www.algomox.com/resources/blog/intelligent_runbooks_generative_ai_aiops)
- **Scope creep**: agents are gradually given more permissions without corresponding updates to policies and monitoring, expanding their blast radius unnoticed. [hoop](https://hoop.dev/blog/how-to-keep-ai-operations-automation-ai-command-monitoring-secure-and-compliant-with-access-guardrails/)
- **Hidden coupling**: multiple agents act on overlapping domains without coordination, causing conflicting changes (for example, one scaling up while another scales down based on different signals). [aws.amazon](https://aws.amazon.com/blogs/industries/transforming-business-operations-with-multi-agent-systems-field-workforce-safety-ai-assistant/)

Mitigations blend technical and organisational measures:

- Regularly reviewing agent logs and outcomes as part of post‑incident and change reviews, treating agent behaviour as something to tune. [logicmonitor](https://www.logicmonitor.com/blog/agentic-aiops-strategy)
- Keeping agent capabilities, scopes and guardrails documented and visible.  
- Ensuring there is always a clear way to pause or roll back agent‑driven changes. Access Guardrails and similar frameworks explicitly support this by making every AI‑initiated command auditable and reversible. [hoop](https://hoop.dev/blog/build-faster-prove-control-access-guardrails-for-ai-operations-automation-aiops-governance/)
- Designing orchestration layers for multi‑agent systems that coordinate tasks, enforce policy and manage shared state, rather than letting agents operate independently. [anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)

From a sovereignty perspective, the critical failure mode is **boundary breach**: an agent taking actions that move data or workloads across jurisdictions in ways that violate policy. This is precisely the kind of risk guardrails, scoped credentials and policy‑as‑code are meant to prevent. [hoop](https://hoop.dev/blog/how-to-keep-ai-operations-automation-ai-command-monitoring-secure-and-compliant-with-access-guardrails/)

***

## 14.7 Training the organisation, not just the agents

Introducing agents into operations is as much a change‑management exercise as a technical one. AIOps adopters repeatedly report that success depends on people understanding how to work with AI assistants, not just on deploying models. [devops](https://devops.com/from-automation-to-autonomy-what-aiops-actually-looks-like-today/)

Teams need to learn:

- **How to talk to agents**: how to frame clear intents and constraints, and how to interpret agent responses in terms of confidence, scope and risk.  
- **When to rely on agents and when to override**: recognising situations where human judgement is essential: novel incidents, ethical dilemmas or ambiguous regulatory issues. [obsidiansecurity](https://www.obsidiansecurity.com/blog/ai-guardrails)
- **How to design for agents**: writing runbooks, policies and IaC in ways that agents can use effectively—structured, tagged, and discoverable. [ibm](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-aiops/4.11.1?topic=apis-automation-runbook-api)

Leaders need to calibrate expectations. Agents do not eliminate incidents, nor do they remove the need for on‑call. They change the **shape** of the work: less manual execution, more supervision and system design; fewer repetitive checks, more attention to signals and patterns that require human insight. [devops](https://devops.com/from-automation-to-autonomy-what-aiops-actually-looks-like-today/)

Governance and risk functions, in turn, need to become comfortable with machine‑executed actions—while insisting on transparency, auditability and clear accountability. Frameworks like Access Guardrails explicitly aim to make AI‑assisted operations “provable” by auto‑logging every interaction with policy context, so audits can be constructed from logs rather than recollections. [hoop](https://hoop.dev/blog/how-to-keep-ai-runbook-automation-aiops-governance-secure-and-compliant-with-inline-compliance-prep/)

***

## 14.8 Agentic operations as the “second shift” of automation

The first shift of automation in operations was about scripting and orchestration: taking known, repeatable tasks and making them faster and less error‑prone. The second shift—agentic operations—adds perception and adaptive planning on top of that substrate. [youtube](https://www.youtube.com/watch?v=OXuJPfs9iPQ)

In a mature sovereign, agentic estate:

- The **substrate** (infrastructure as code, observability, event streams, lineage, policy‑as‑code, runbooks‑as‑code) provides a rich, structured environment.  
- **Automation** (scripts, workflows, platform features) provides reliable ways to change that environment.  
- **Agents** sit on top as orchestration and reasoning layers, making it easier for humans to understand, and for the system to adapt, without sacrificing control. [logicmonitor](https://www.logicmonitor.com/blog/agentic-aiops-strategy)

When it works well, the day‑to‑day experience of operators and engineers changes. Instead of spending their time “clicking the same buttons” and “running the same commands,” they spend it:

- Designing better SLOs, runbooks and policies.  
- Reviewing and refining agent behaviour with real feedback loops. [algomox](https://www.algomox.com/resources/blog/intelligent_runbooks_generative_ai_aiops/)
- Working with governance colleagues to align what the system can do with what it is allowed to do, enforced by guardrails and policy‑as‑code. [devops](https://devops.com/declarative-compliance-with-policy-as-code-and-gitops/)
- Planning the next steps in the evolution of the estate.

Agentic operations, in this sense, are not about removing people from the system. They are about **raising the level at which people work**, so that human attention is focused where it matters most: on design, judgement and learning, rather than on rote execution. [anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)

In the next chapters, we will see how this plays out in specific industry contexts and migration paths: how a bank, a public‑sector agency or a healthcare provider might take their current operations and move, step by step, toward this sovereign, agentic model.

***

### References

1. IBM, “Runbook Automation API” and AIOps runbook automation documentation. [youtube](https://www.youtube.com/watch?v=OXuJPfs9iPQ)
2. DevOps.com, “From Automation to Autonomy: What AIOps Actually Looks Like Today.” [devops](https://devops.com/from-automation-to-autonomy-what-aiops-actually-looks-like-today/)
3. LogicMonitor, “Building an agentic AIOps strategy? Don’t start without this checklist.” [logicmonitor](https://www.logicmonitor.com/blog/agentic-aiops-strategy)
4. AWS, “Automate IT operations with Amazon Bedrock Agents.” [aws.amazon](https://aws.amazon.com/blogs/machine-learning/automate-it-operations-with-amazon-bedrock-agents/)
5. Algomox, “Creating Intelligent Runbooks with Generative AI in AIOps.” [algomox](https://www.algomox.com/resources/blog/intelligent_runbooks_generative_ai_aiops)
6. Hoop.dev, “How to keep AI operations automation secure and compliant with Access Guardrails” and related posts. [hoop](https://hoop.dev/blog/build-faster-prove-control-access-guardrails-for-ai-operations-automation-aiops-governance/)
7. Obsidian Security, “AI Guardrails: Enforcing Safety Without Slowing Innovation.” [obsidiansecurity](https://www.obsidiansecurity.com/blog/ai-guardrails)
8. Tetrate, “Managing Guardrails | Agent Operations Director.” [docs.tetrate](https://docs.tetrate.io/agent-ops-director/guardrails/managing-guardrails)  
9. Vi‑B Agent‑To‑Agent Protocol and multi‑agent orchestration paper (arXiv). [arxiv](https://arxiv.org/html/2601.13671v1)
10. Anthropic, “How we built our multi‑agent research system.” [anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)
11. AWS, “Transforming business operations with multi‑agent systems.” [aws.amazon](https://aws.amazon.com/blogs/industries/transforming-business-operations-with-multi-agent-systems-field-workforce-safety-ai-assistant/)
