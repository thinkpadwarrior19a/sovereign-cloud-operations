<!-- STAGED CONTENT from original Ch 16 (Migration Paths) — to be expanded and integrated into Ch 33 -->

Chapter 16 — Migration Paths and Transitional Architectures

***

## 16.1 You can't stop the world to rebuild it

There is always a moment, somewhere around the third or fourth architecture diagram, when someone leans back and says, "This all looks great, but we can't turn everything off for two years and start again." They are right. No bank, tax authority or health system can pause operations long enough to replace its entire topology, data landscape and operating model.

Migration to a sovereign, zero‑copy, agentic estate is therefore not a greenfield exercise. It is a sequence of **transitional architectures** that must run real workloads, under real regulatory scrutiny, while carrying legacy baggage. Each step has to earn its keep: reduce risk, create options, and avoid making future steps harder.

The challenge is to move in a way that is **directionally correct**—toward explicit sovereign zones, zero‑copy integration, better observability, codified operations and bounded agents—without insisting on perfection at each stage. This chapter is about those paths: how to assess where you are, choose the first moves, and avoid the traps that turn transformations into stalled programmes.

***

## 16.2 Seeing where you really are

Migration begins with a kind of operational cartography. The goal is not to produce a glossy "target architecture," but to understand your current **operational shape** well enough to plan.

You need three overlapping maps.

First, a **topology and network map**: which regions, data centres and providers you use; how they are connected; where traffic actually flows. This includes VPNs, direct connects, service meshes and any "temporary" links that became permanent.

Second, a **data and integration map**: which systems hold which data, where copies live, where batch feeds run, which event streams exist, and which integration tools glue everything together. The question here is not only "where is the golden record?" but "where are all the shadows?"

Third, an **operations and runbook map**: how incidents are really handled; which teams own which services; where tribal knowledge lives; what automation exists and what still depends on consoles and heroics.

None of these maps will be perfect. What matters is to get them good enough to answer pragmatic questions: Where are the biggest concentrations of risk? Which systems are most entangled? Where do we already have some of the patterns this book recommends, even if they're not yet standardised?

***

## 16.3 Sequencing change: from quick wins to structural moves

Every organisation has two kinds of change available: **quick wins** that show value fast, and **structural moves** that set up the next decade. Migration fails when you try to do only one kind.

Quick wins might include:

- Introducing better **observability** for a critical service, including topology views and basic SLOs.
- Codifying a handful of high‑value **runbooks** and automating routine diagnostics.
- Converting a fragile manual environment into **infrastructure as code**, even if only within one cloud provider.

These changes improve life for teams and build trust in the direction of travel. But they do not, by themselves, create sovereignty or zero‑copy integration.

Structural moves take longer and often touch organisational boundaries:

- Defining the first **sovereign zone** and moving a critical but well‑bounded service into it, with clear data and topology constraints.
- Refactoring a key integration from copy‑based ETL into **zero‑copy access** and events.
- Establishing a **platform engineering** function with responsibility for shared patterns, not just shared tooling.

The art is in sequencing: using quick wins to reduce friction and create credibility, while quietly lining up the structural moves in the background so that when they come, they land on more prepared ground.

***

## 16.4 Coexistence: living with old and new at the same time

For a long time—often years—you will be running **two worlds**:

- The emerging sovereign, zero‑copy, agentic world, with IaC, events, zones, guardrails and agents.
- The existing world, with copy‑heavy integrations, ad‑hoc networking, partial observability and manual operations.

There is no clean, hard cutover between them. Instead, you need patterns for **coexistence**.

One common pattern is the **sovereign core**: define a new zone with strong constraints and move a carefully chosen set of services into it, while leaving others in legacy environments. The core is small at first—perhaps a single payment path or a single citizen‑facing service—but it is designed according to the full model: zero‑copy integration, clear topology, rich observability, IaC and runbooks‑as‑code.

Around this core, you build **bridges**: carefully governed interfaces that allow the old world and the new world to talk. For example:

- Legacy systems may still emit batch files, but a translation layer turns them into events for the core.
- The core may provide APIs that legacy systems call, while you gradually reduce direct database access.
- Observability may span both worlds, but with richer context in the core.

The key is to avoid accidentally reproducing legacy anti‑patterns inside the new core. Every exception ("just this one direct connection," "just this one copy of the data") makes later consolidation harder.

***

## 16.5 Introducing sovereignty: zones, guardrails and pilots

You do not become "sovereign" by fiat. You become sovereign by **drawing boundaries in code and in practice**, and then learning how to live within them.

The first step is often a pilot **sovereign zone**. You pick:

- A jurisdiction or regulatory requirement that is clear enough to design for.
- A business service important enough to matter, but not so critical that any mis‑step would be catastrophic.
- A team willing to work within new constraints and help refine them.

For that zone, you make explicit decisions about:

- Allowed regions, providers and operators.
- Network paths in and out, including observability and support links.
- Data that may and may not cross the boundary.
- Key and identity management arrangements.

You then encode these decisions in **infrastructure as code, policy‑as‑code and guardrails**, so that topology, deployment, operations and agents all see the same picture. The result is often imperfect at first; there will be oversights and awkward corners. That is why it is a pilot.

As confidence grows, you:

- Add more services to the zone.
- Tighten policies and reduce legacy exemptions.
- Use what you learned to define additional zones (for other jurisdictions or data classes).

Over time, sovereignty shifts from a project to a **property of how you operate**: something that applies automatically when new services are created and new agents are deployed, because the platform itself is sovereignty‑aware.

***

## 16.6 Introducing agents: from read‑only helpers to bounded actors

In the same way, you do not start with fully autonomous agents in critical paths. You start small, prove value, and expand **within guardrails**.

Typical phases look like this:

1. **Read‑only helpers**: agents with no write access, focused on summarising incidents, pointing to relevant dashboards, explaining logs, and suggesting runbook steps.
2. **Automated diagnostics**: agents allowed to run non‑destructive diagnostics via existing automation—collecting logs, checking health endpoints, running queries—always under tight scope.
3. **Low‑risk actions**: agents allowed to execute a limited set of actions (for example, restarts of non‑critical services, cache flushes, feature‑flag flips) in pre‑defined contexts.
4. **Bounded actors**: agents managing well‑understood domains (for example, capacity for a particular service) within explicit policies and oversight.

At each step, you:

- Instrument agent behaviour and outcomes.
- Review them in post‑incident and change reviews.
- Adjust policies, runbooks and scopes based on what you learn.

Crucially, the process of introducing agents is tied to the maturation of your **substrate**: observability, IaC, runbooks‑as‑code, policy‑as‑code and guardrails. Agents amplify what these foundations allow. Without them, agents either become dangerous or useless.

***

## 16.7 Avoiding migration anti‑patterns

Finally, a few migration anti‑patterns are worth naming.

- **The big‑bang rewrite**: attempting to redesign everything in one massive programme, with a promise of benefits only at the end. By the time the new architecture is ready, the world and the estate have both changed.
- **The new silo**: creating a shiny sovereign or agentic platform that only a few new services can use, while the bulk of critical workloads remain in the old world, untouched.
- **The tooling‑only transformation**: buying or building new platforms and agents without changing operating models, policies or incentives. The new tools are used like the old ones, and nothing fundamental changes.
- **The paper‑only sovereignty**: writing sovereignty policies that are impossible to implement with current topology and integration patterns, leading to a widening gap between "what we say" and "what we do."
- **The unbounded agent**: giving an early agent broad production access in the hope it will "learn," without guardrails or clear scopes. When it misbehaves or underperforms, trust in the entire approach collapses.

Good migration paths are deliberately modest in their first steps and ambitious in their direction of travel. They produce **visible improvements** early—better visibility, fewer manual steps, clearer boundaries—while steadily replacing structural weaknesses with stronger patterns.

If the earlier chapters were about what a well‑designed sovereign, agentic estate looks like, this one is about something more prosaic and more difficult: how to move an imperfect, busy, real‑world estate in that direction without losing control of the journey.
