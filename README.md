# VentureSmith

**Autonomous Startup Opportunity Discovery powered by Somnia Agents**

VentureSmith helps developers discover startup opportunities they can realistically build.

Instead of starting with ideas, VentureSmith starts with evidence.

A founder describes their background, skills, and available time. VentureSmith then discovers market pain signals, extracts structured evidence, evaluates founder fit, and generates startup opportunities backed by real discussions and user demand.

Built for the Somnia Agentathon.

---

# The Problem

Most founders ask:

> What should I build?

The internet already contains thousands of signals:

* GitHub issues
* feature requests
* bug reports
* Hacker News discussions
* community workarounds
* documentation gaps
* developer complaints

The problem is not the lack of ideas.

The problem is identifying opportunities that:

* solve a real problem
* have supporting evidence
* match the founder's skills
* can realistically be built within a limited time

---

# The Solution

VentureSmith is an autonomous startup opportunity scout.

A founder may provide:

* background
* skills
* GitHub profile
* LinkedIn profile
* available time

For example:

```text
Ruby on Rails developer
PostgreSQL
Hotwire
Docker
30 available days
```

VentureSmith discovers emerging opportunities, evaluates market signals, and ranks them based on founder fit and build feasibility.

---

# Why Somnia

VentureSmith is not a traditional Rails + LLM application.

Rails acts only as:

* UI
* orchestration layer
* local persistence

The core discovery and evaluation workflow is executed through Somnia Agents.

---

# Somnia Agent Architecture

## 1. Discovery

### JSON API Request Agent

Agent ID:

```text
13174292974160097713
```

Purpose:

* discover candidate evidence sources
* search GitHub Issues
* search Hacker News
* collect discussions and public signals
* return URLs for further analysis

Output:

```json
[
  {
    "title": "...",
    "url": "https://..."
  }
]
```

The Discovery layer answers:

> Where should we look?

---

## 2. Evidence Normalization

### LLM Parse Website Agent

Agent ID:

```text
12875401142070969085
```

Purpose:

* parse discovered pages
* extract structured pain signals
* normalize heterogeneous sources into a common schema

Sources may include:

* GitHub issues
* Hacker News discussions
* blog posts
* documentation pages
* community forums

Output:

```json
{
  "pain": "...",
  "affected_user": "...",
  "current_workaround": "...",
  "severity": "high",
  "startup_signal": "..."
}
```

The Normalization layer answers:

> What problem is actually being described?

---

## 3. Opportunity Generation

### LLM Inference Agent

Agent ID:

```text
12847293847561029384
```

Purpose:

* cluster related pain signals
* generate startup opportunities
* evaluate founder fit
* estimate MVP feasibility
* score opportunities

Input:

```json
{
  "pain": "...",
  "affected_user": "...",
  "severity": "high"
}
```

Output:

```json
{
  "title": "...",
  "problem": "...",
  "audience": "...",
  "score": 91,
  "build_fit": 95,
  "time_fit": 88,
  "mvp_plan": [
    "..."
  ]
}
```

The Reasoning layer answers:

> What should a founder build?

---

# Pipeline

```text
Founder Profile
        ↓
     Scout Run
        ↓
JSON API Request Agent
        ↓
LLM Parse Website Agent
        ↓
LLM Inference Agent
        ↓
Opportunity
        ↓
Somnia Smart Contract
        ↓
On-Chain Result
```

---

# Why Use LLM Parse Website?

GitHub already provides structured JSON.

However, VentureSmith is designed to discover opportunities across multiple ecosystems, not only GitHub.

Future evidence sources include:

* Hacker News
* blogs
* documentation sites
* community forums
* product feedback pages

The LLM Parse Website Agent acts as a normalization layer.

It converts different content formats into a common evidence schema before opportunity generation.

This keeps the reasoning layer independent of any specific source.

---

# Example

Input:

```text
I am a Ruby on Rails developer.

Find startup opportunities I can build in 30 days.
```

Potential output:

```text
GitHub Issue Triage Copilot

Market Signal:
Growing issue-management complaints across multiple repositories.

Founder Match:
93

Why now:
Discussion volume increased 240% during the last 30 days.

Why you:
Strong Rails fit.
Can be shipped as an MVP within 30 days.

30-Day MVP:
Week 1 — issue ingestion
Week 2 — duplicate detection
Week 3 — maintainer dashboard
Week 4 — deployment
```

---

# Smart Contract

VentureSmith uses a Somnia smart contract as a trust boundary.

The contract stores:

* opportunity metadata hash
* evidence hash
* evaluation score
* agent request ID
* callback result hash

The contract does not assume agent outputs are always correct.

It verifies:

* callback origin
* request lifecycle
* result ownership

The blockchain stores verifiable agent outputs, not absolute truth.

---

# Technology Stack

## Backend

* Ruby 3.3
* Rails 8
* PostgreSQL

## Blockchain

* Somnia Shannon Testnet
* Solidity
* Hardhat

## Agents

* JSON API Request Agent
* LLM Parse Website Agent
* LLM Inference Agent

---

# Current MVP Status

## Implemented

* Founder profiles
* Scout runs
* Opportunity model
* Evidence model
* Somnia request tracking
* Somnia contract deployment
* Somnia Agent orchestration foundation
* Multi-stage Somnia pipeline design

## In Progress

* JSON API Request integration
* LLM Parse Website integration
* LLM Inference integration
* Agent callback processing
* End-to-end opportunity evaluation

---

# Vision

Most startup idea generators answer:

"What could I build?"

VentureSmith answers a different question:

"What opportunity is emerging right now, and why am I uniquely positioned to capture it?"

The long-term vision is an autonomous opportunity radar that continuously monitors public signals, detects emerging market pain, and ranks opportunities for individual founders.

Instead of generating random startup ideas, VentureSmith helps founders identify opportunities with evidence, momentum, and personal execution advantage.

---

Built for Somnia Agentathon.

Powered by Somnia Agents.
