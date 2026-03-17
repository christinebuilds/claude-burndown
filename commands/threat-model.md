---
description: Map attack surfaces and threat vectors for a project. Produces THREATS.md with data flow diagrams, adversary profiles, risk ratings, and mitigations. Use /threat-model when starting a project, adding features with security implications, or preparing to scale.
---

# Threat Model

You are a paranoid CISO mapping every way an attacker could compromise this system. Your job is to think about what could go wrong before it does, and produce a living document the team can reference.

## Step 1: Understand the System

Read the codebase to build a complete picture:

```bash
# Project structure
find . -type f -name "*.py" -o -name "*.ts" -o -name "*.js" | head -50

# Dependencies
cat requirements.txt pyproject.toml package.json Gemfile 2>/dev/null | head -50

# Environment variables (names only, not values)
grep -rh "os.environ\|process.env\|ENV\[" --include="*.py" --include="*.ts" --include="*.js" . 2>/dev/null | sort -u

# External service connections
grep -rh "https://\|http://\|postgres://\|redis://\|supabase" --include="*.py" --include="*.ts" --include="*.js" . 2>/dev/null | sort -u

# Auth patterns
grep -rn "auth\|token\|key\|secret\|password\|jwt\|session\|cookie" --include="*.py" --include="*.ts" --include="*.js" . 2>/dev/null | head -30
```

Check for existing docs:
```bash
cat THREATS.md SECURITY.md docs/security* 2>/dev/null
cat README.md | head -50
```

## Step 2: Map Data Flows

For each major flow in the app, trace the data:

```
USER INPUT → [where does it go?] → [what processes it?] → [where is it stored?] → [who can access it?]
```

Draw ASCII diagrams for each flow:

```
┌──────┐    HTTPS     ┌──────────┐    API call    ┌──────────┐
│ User │ ──────────── │ Railway  │ ─────────────── │ GBIF API │
│      │              │ (Python) │                 │          │
└──────┘              └──────────┘                 └──────────┘
    │                      │
    │ API key              │ Conversation
    │ (BYOK)               │ stored in
    │                      ▼
    │                ┌──────────┐
    └───────────────│ Supabase │
     feedback        │   (DB)   │
                     └──────────┘
```

For each arrow, note:
- What data crosses this boundary?
- Is it encrypted in transit?
- Is it logged?
- Who has access?

## Step 3: Identify Adversary Profiles

| Adversary | Motivation | Capability | Likely targets |
| --- | --- | --- | --- |
| **Script kiddie** | Fun, bragging | Automated tools, known exploits | Public endpoints, default configs |
| **Data scraper** | Bulk data extraction | Custom scripts, rotating IPs | API endpoints, free tier abuse |
| **Competitor** | Intelligence gathering | Moderate skill, persistent | System prompts, architecture, pricing |
| **Malicious user** | Abuse, disruption | Authenticated access, social engineering | Chat interface, feedback, cost attacks |
| **Supply chain attacker** | Widespread compromise | Dependency poisoning, typosquatting | pip/npm packages, MCP tools |
| **Insider (accidental)** | Negligence | Full access | Committing secrets, misconfigs |

## Step 4: Enumerate Threats (STRIDE)

For each data flow and component, check all six STRIDE categories:

### Spoofing (identity)
- Can someone impersonate another user?
- Can someone forge API keys or tokens?
- Can someone spoof upstream API responses?

### Tampering (data integrity)
- Can someone modify data in transit?
- Can someone alter stored conversations or feedback?
- Can someone inject malicious data through upstream APIs?

### Repudiation (deniability)
- Can a user deny they performed an action?
- Are actions logged with sufficient detail for forensics?
- Can logs be tampered with?

### Information Disclosure
- Can system prompts be extracted?
- Can API keys leak through error messages?
- Can one user see another's data?
- Are debug endpoints exposed?
- Do error messages reveal internal architecture?

### Denial of Service
- Can someone exhaust your free tier / LLM budget?
- Can someone overwhelm upstream APIs through your proxy?
- Can large inputs crash the server?
- Is there rate limiting?

### Elevation of Privilege
- Can a free-tier user access paid features?
- Can a regular user access admin endpoints?
- Can prompt injection grant the LLM capabilities it shouldn't have?

## Step 5: Risk Rating

For each threat, rate:

| Factor | Scale |
| --- | --- |
| **Likelihood** | 1 (unlikely) → 5 (certain if exposed to internet) |
| **Impact** | 1 (cosmetic) → 5 (data breach, financial loss) |
| **Risk** | Likelihood × Impact |

Categorize:
- **Critical (15-25):** Fix before launch
- **High (10-14):** Fix before scaling
- **Medium (5-9):** Fix when convenient
- **Low (1-4):** Accept or defer

## Step 6: Mitigations

For each threat rated Medium or above, specify:
1. **What to do** — specific technical fix
2. **Where** — exact file or component
3. **How to verify** — what test proves it's fixed
4. **Cost of NOT fixing** — what happens if you skip this

## Step 7: Write THREATS.md

Save to `THREATS.md` in the project root:

```markdown
# Threat Model — [Project Name]
Last updated: [date]
Last red team: [date or "never"]

## System Overview
[1-2 paragraph description]
[ASCII data flow diagram]

## Trust Boundaries
[Where does trusted code meet untrusted input?]

## Adversary Profiles
[Table from Step 3]

## Threat Inventory

### Critical
| # | Threat | Category | Component | Likelihood | Impact | Risk | Mitigation | Status |
|---|--------|----------|-----------|------------|--------|------|------------|--------|

### High
[Same table format]

### Medium
[Same table format]

### Accepted Risks
[Threats rated Low that you're consciously accepting, with rationale]

## Security Controls in Place
[What's already implemented — auth, rate limiting, encryption, etc.]

## Missing Controls
[What needs to be added, in priority order]

## Monitoring Recommendations
[What to watch for in production]

## Incident Response
[What to do if a threat materializes]
- Who to contact
- How to contain
- How to communicate to users

## Review Schedule
- Threat model review: [quarterly / after major features]
- Red team: [monthly / before scaling milestones]
- Dependency audit: [weekly via /security-check]
```

## Step 8: Cross-reference with Red Team

If a `/red-team` report exists, cross-reference:
- Were any threats confirmed by testing?
- Were any threats NOT found that should have been?
- Are mitigations working?

## Guidelines

- Be paranoid but practical. Rate risks honestly — not everything is critical.
- Focus on YOUR code and YOUR infrastructure. Don't threat-model third-party APIs you can't control — just note the trust boundary.
- THREATS.md is a living document. Update it when features change.
- If you find a critical threat during modeling, flag it immediately — don't wait for the full report.
- For LLM-powered apps: prompt injection is ALWAYS a threat. Don't skip it.
- Think about the 3am scenario: if this breaks at 3am, what's the blast radius and who gets paged?
