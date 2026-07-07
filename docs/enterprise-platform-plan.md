# Summit — An Enterprise Business Launch Platform

*Working name: **Summit**. Positioning: LegalZoom + Wix + Polsia, fused into one done-with-you platform that takes a founder from "I have an idea" to "I run a licensed, funded, incorporated, professionally represented business," not just "I have a webpage."*

## 0. The Core Design Rule: Universal Foundation, Client-Determined Divergence

Every business needs the same underlying scaffolding — an entity, a bank account, a domain, a professional site, the right licenses, a payment setup that fits how money actually moves, and a path to capital. **What diverges by business is only the surface**: the industry, the product, the licenses that apply, the payment pattern that fits. Summit never guesses at that surface and never bakes a business type into the platform's design.

- The milestone tiers, the service stable, and the fee framework below are identical regardless of what the client is building — a bakery and a B2B software company walk the same pyramid.
- The client's own answers (industry, jurisdiction, model) determine which specific license, which specific payment pattern, which specific tax registration applies *within* each universal tier. The platform surfaces the right sub-choices dynamically; it does not pre-select a vertical template.
- A purpose-built **Site Build Agent** (Section 6) does the one thing Polsia does badly and Wix leaves entirely to the user: take the client's brand and content intake and produce a professional, correct, on-brand site in one well-executed pass — not a generic template, and not an endless back-and-forth.
- If a client doesn't yet know what business to build, Summit does not default to suggesting a SaaS company or any other generic template idea. It runs the **Idea Discovery Protocol** (Section 8) — a question-driven conversation that surfaces a specific, novel idea suited to that person, only when they explicitly ask for it.

## 1. Why Summit beats Polsia

| Polsia | Summit |
|---|---|
| Generic template site, "Made with Polsia" watermark everywhere | White-label, professionally designed site — the client's brand only, nowhere does our name appear on their storefront |
| Sub-domain or thin domain reseller, no email | Full domain acquisition, DNS, and business email (name@yourcompany.com) as a first-class, guided step |
| Stripe checkout bolted on, one-size-fits-all | Payment architecture matched to the actual business model: subscriptions, marketplaces with split payouts, invoicing/AR, POS + online, multi-currency, financed/BNPL checkout |
| Stops at "site is live" | Site launch is the *midpoint* of the pyramid, not the summit — the platform keeps going through entity formation, licensing, funding, and growth |
| No path to capital | Structured SBA loan packaging, lender matching, and grant discovery built into the product |
| Opaque or bundled pricing | Every fee — ours and every third party's (state filing fee, domain cost, trademark search) — is itemized, pre-authorized, and logged before an agent ever charges a card |
| Transactional relationship | Designed so that once a founder sees we can run formation, banking, compliance, funding, *and* the website, there's no reason to go anywhere else — retention through completeness, not lock-in |

The product thesis: **the website is the least valuable thing we build.** The valuable thing is the founder never having to leave to find a registered agent, a lender, an accountant, a trademark filer, or a pitch coach.

---

## 2. The Pyramid Model

Summit organizes the entire founder journey as a pyramid. Each tier must be substantially complete before the next unlocks (soft gates, not hard blocks — an advanced user can skip ahead, but the agent will flag missing prerequisites, e.g. "you're about to accept payments but haven't formed an entity yet").

```
                         ▲
                        / \
                       / 7 \        SCALE — multi-entity, M&A readiness, SOC2, cap table mgmt
                      /-----\
                     /   6   \      CAPITAL — SBA loans, grants, investor readiness, credit lines
                    /---------\
                   /     5     \    GROWTH OPS — CRM, marketing automation, SEO, support
                  /-------------\
                 /       4       \  COMMERCE — payments architecture matched to the business model
                /-----------------\
               /         3         \ COMPLIANCE — licenses, permits, insurance, policies
              /---------------------\
             /           2           \ BRAND & PRESENCE — domain, email, professional site, trademark
            /-------------------------\
           /             1             \ LEGAL FOUNDATION — entity, EIN, registered agent, banking
          /-----------------------------\
         /               0               \ DISCOVERY — idea validation, name clearance, business plan
        /---------------------------------\
```

Each tier below is a milestone set with pass/fail exit criteria, not vague advice.

---

## 3. Universal Milestone Checklist

Every item below applies to every business, regardless of industry. Where a tier has variable content (which license, which payment pattern), the checklist says so explicitly — the platform surfaces the client's own answers, it does not pre-fill an assumed vertical.

### Tier 0 — Discovery & Validation
- [ ] Problem/market validation summary produced (target customer, pain point, willingness-to-pay signal)
- [ ] Competitive landscape scan
- [ ] Business name generated, checked for: state entity-name availability, domain availability, USPTO trademark conflict (TESS knockout search), and matching social handles
- [ ] One-page business plan draft (auto-generated from founder interview, refined by agent)
- [ ] Entity type recommendation (sole prop / LLC / S-corp / C-corp) with a plain-language tradeoff explanation, not just a form

**Exit criteria:** name cleared, entity type chosen, plan drafted.

### Tier 1 — Legal Foundation
- [ ] State of formation selected (home state vs. Delaware/Wyoming tradeoffs explained)
- [ ] Entity filed (LLC/Corp Articles of Organization/Incorporation)
- [ ] EIN obtained (IRS Form SS-4 automation)
- [ ] Registered agent assigned
- [ ] Operating agreement / bylaws generated and e-signed
- [ ] Beneficial Ownership Information (BOI/CTA) report filed with FinCEN
- [ ] Business bank account opened, linked for read/write via Plaid
- [ ] Initial bookkeeping ledger created (chart of accounts scaffolded)

**Exit criteria:** entity active in good standing, EIN issued, bank account operational.

### Tier 2 — Brand & Digital Presence
- [ ] Domain purchased and DNS configured (no third-party subdomain)
- [ ] Business email live (name@domain, not a free consumer inbox)
- [ ] Professional website designed and deployed under the client's own brand only
- [ ] SSL/security baseline (HTTPS, security headers, backups)
- [ ] Trademark application filed (if cleared in Tier 0) — word mark and/or logo
- [ ] Brand kit delivered: logo, color system, typography, voice guide
- [ ] Google Business Profile and core directory listings claimed

**Exit criteria:** site live on owned domain, email operational, brand assets delivered.

### Tier 3 — Compliance
- [ ] Federal/state/local business licenses identified for the specific industry + jurisdiction
- [ ] Licenses filed and tracked to approval (liquor, health, contractor, professional, etc. as applicable)
- [ ] Sales tax nexus determined and registration filed where required
- [ ] Business insurance bound (general liability; add E&O, cyber, workers' comp as applicable)
- [ ] Terms of Service, Privacy Policy, Cookie Policy generated and published
- [ ] Website accessibility (WCAG/ADA) baseline check passed
- [ ] Data handling posture documented if PII/PCI is in scope

**Exit criteria:** all required licenses active or in-process with tracked status, insurance bound, legal policies published.

### Tier 4 — Commerce Architecture
Pick the pattern(s) that match the real business, not a default checkout button:
- [ ] Simple product sales (one-time payment)
- [ ] Subscription/recurring billing (metered or flat)
- [ ] Marketplace with split payouts to multiple parties
- [ ] Invoicing / accounts receivable for B2B terms (net-30/60)
- [ ] In-person + online unified (POS integration)
- [ ] Multi-currency / international settlement
- [ ] Financing at checkout (buy-now-pay-later)
- [ ] Sales tax automation wired into every payment path
- [ ] Chargeback/dispute workflow and fraud rules configured
- [ ] Payout schedule and reconciliation-to-bookkeeping pipeline connected

**Exit criteria:** the payment architecture matches the actual revenue model, taxes calculate automatically, money reconciles to the books without manual re-entry.

### Tier 5 — Growth Operations
- [ ] CRM installed and connected to the site's lead capture
- [ ] Email/SMS marketing automation configured
- [ ] Analytics + search console instrumented, conversion events defined
- [ ] SEO baseline (technical SEO, on-page, local SEO if applicable)
- [ ] Customer support channel (helpdesk/chat) wired in
- [ ] Reporting dashboard: revenue, CAC, retention, in one view

**Exit criteria:** founder can see pipeline and revenue trend without leaving the platform.

### Tier 6 — Capital
- [ ] Business credit profile established (Dun & Bradstreet, Nav)
- [ ] SBA loan readiness package assembled: 2 years financials/projections, business plan, debt schedule, personal financial statement, SBA Form 1919/413
- [ ] Lender matching run (SBA 7(a), 504, microloan, or non-SBA options) based on eligibility
- [ ] Grant discovery: federal (grants.gov, SBIR/STTR if R&D-heavy), state, and local economic development programs matched to the business profile
- [ ] Elevator pitch built and rehearsed with the agent (problem, solution, traction, ask — under 60 seconds)
- [ ] Investor-grade pitch deck generated if the business is raising equity, not just debt
- [ ] Application packages submitted and status tracked to decision

**Exit criteria:** at least one funding application submitted with a complete, lender-ready package; pitch rehearsed to a scored rubric.

### Tier 7 — Scale (Summit)
- [ ] Multi-entity or holding-company structuring if expanding
- [ ] Compliance certifications as needed (SOC 2, HIPAA, PCI-DSS Level per volume)
- [ ] Cap table management if outside capital was raised
- [ ] M&A / exit readiness documentation (clean data room)
- [ ] Advisory board / mentor network engagement (SCORE, SBDC)

**Exit criteria:** the business is running as a fundable, auditable, professionally represented company — the founder is "at the top."

---

## 4. The AI-Friendly Service Stable

Every row below is chosen because it has a real API/webhook surface an agent can drive end-to-end (submit, poll status, receive webhook, reconcile) — not a service that only works through a human clicking a dashboard.

### Domains, DNS, Email
| Service | Role | Why it's agent-friendly |
|---|---|---|
| Cloudflare Registrar + DNS API | Domain purchase, DNS records | At-cost domains, full REST API, DNSSEC |
| Porkbun API / Namecheap API | Domain purchase fallback | Broad TLD coverage, simple REST |
| Google Workspace API | Business email, calendar, docs | Provisioning API for accounts/aliases |
| Microsoft 365 Graph API | Business email alternative | Same category as Workspace, enterprise-preferred |
| ImprovMX API | Email forwarding-only option | Cheap path when a full mailbox isn't needed yet |
| Postmark / SendGrid / Mailgun API | Transactional + marketing email delivery | Deliverability tooling, webhook events for bounces/opens |

### Hosting & Site Delivery
| Service | Role |
|---|---|
| Vercel API | Site deploy, preview environments, domains |
| Netlify API | Alternative deploy target, forms, edge functions |
| Cloudflare Pages/Workers | Edge hosting, low-latency global delivery |
| AWS Amplify | Enterprise-tier hosting for clients needing AWS-native stacks |

### Payments (the actual differentiator vs. Polsia's Stripe-only checkout)
| Service | Role |
|---|---|
| Stripe Billing + Connect + Tax + Invoicing | Subscriptions, marketplace split payouts, automated sales tax, B2B invoicing — one vendor, four commerce patterns |
| Adyen | Enterprise-tier alternative, strong international/omnichannel |
| Square | Unified POS + online for physical + digital businesses |
| Plaid | Bank account verification/linking, ACH |
| Dwolla | ACH transfers for B2B/marketplace payouts |
| Wise / Airwallex | Multi-currency settlement for international sales |
| Affirm / Klarna | BNPL financing at checkout |
| Avalara / TaxJar | Sales tax calculation and filing automation across jurisdictions |

### Banking & Bookkeeping
| Service | Role |
|---|---|
| Mercury / Brex / Novo API | Business banking built for startups, API-accessible |
| Unit / Increase (BaaS) | If Summit ever wants to embed banking directly |
| QuickBooks Online API / Xero API | Bookkeeping sync, chart of accounts, reconciliation |
| Pilot.com / Bench | Managed bookkeeping when the founder wants it fully off their plate |

### Legal, Incorporation & Compliance
| Service | Role |
|---|---|
| Stripe Atlas / Firstbase / Clerky | Entity formation automation (Delaware C-corp heavy) |
| Northwest Registered Agent API-adjacent workflows | Registered agent + formation across all 50 states |
| Middesk | Business identity verification, license & registration tracking (KYB) |
| DocuSign / Ironclad API | E-signature for operating agreements, bylaws, contracts |
| USPTO TSDR/TESS data | Trademark knockout search automation |
| Trademark Engine / Corsearch | Full trademark filing and monitoring |
| Next Insurance / Vouch API | Business insurance quoting and binding |

### Funding: SBA Loans & Grants
| Service | Role |
|---|---|
| SBA Lender Match | Matches business to SBA-approved lenders based on profile |
| Nav / Dun & Bradstreet | Business credit profile building and monitoring |
| Fundera / Lendio (marketplace APIs where available) | Loan marketplace comparison beyond SBA-only |
| Grants.gov API | Federal grant discovery and eligibility matching |
| SBIR.gov data | R&D-heavy grant matching (SBIR/STTR) |
| SCORE / SBDC directories | Free mentor/coach matching for pitch and plan review |

### CRM, Marketing & Growth
| Service | Role |
|---|---|
| HubSpot API | CRM + marketing automation, generous free/API tier |
| Google Analytics 4 + Search Console APIs | Instrumentation and SEO baseline |
| Semrush / Ahrefs API | SEO research and monitoring |
| Mailchimp / Klaviyo API | Email/SMS marketing automation |
| Intercom / Zendesk API | Customer support |

### AI/Content Layer (what our own agents call)
| Service | Role |
|---|---|
| Claude API (Anthropic) | Core reasoning/orchestration engine for the Summit agents themselves |
| Gamma / Beautiful.ai / Canva API | Pitch deck and brand asset generation |
| ElevenLabs API | Voiceover for pitch rehearsal, elevator pitch coaching audio feedback |
| Image generation APIs | Logo/brand asset drafts for design review |

### E-commerce (when the business is product-based)
| Service | Role |
|---|---|
| Shopify Admin API | Storefront + inventory when a dedicated commerce engine beats a custom build |
| WooCommerce REST API | WordPress-based commerce alternative |

---

## 5. The Site Build Agent — Right the First Time

This is the purpose-built agent that replaces both Polsia's generic template and Wix's "build it yourself" drag-and-drop. It does not guess at what the client wants and it does not ship a placeholder site to be iterated on forever — it runs one structured intake, then produces a finished, on-brand, professional build.

### Intake (single pass, structured — not a guessing game)
- [ ] Business name, brand assets already on file from Tier 0/2 (logo, colors, voice guide)
- [ ] What the site needs to *do*: inform, capture leads, sell products, take bookings, process applications, serve content — client states this directly, agent does not infer it
- [ ] Pages/sections required, in the client's own words
- [ ] Real copy and real images provided by the client, or explicitly delegated to the agent to draft/source — never silently fabricated
- [ ] Any must-have integrations (the payment pattern chosen in Tier 4, a booking system, a form target)
- [ ] Accessibility and legal-page requirements pulled automatically from Tier 3 compliance status

### Build discipline
- [ ] One coherent design system generated from the brand kit — no stock template swapped in
- [ ] Full site assembled and internally reviewed against the intake checklist *before* the client sees a first draft, so the first thing they see is correct, not a rough cut
- [ ] Client review is a confirmation step, not a redesign session — if something is wrong it means the intake was incomplete, and the agent fixes the intake, not just the symptom
- [ ] Site ships wired to the domain, email, and payment/commerce integrations already provisioned in earlier tiers — nothing left as a manual follow-up step for the client

**Exit criteria:** the client's first look at the live site is also the last major revision — no watermark, no "you'll want to keep tweaking this," no third-party branding anywhere on it.

---

## 6. Transparent Fee & Agent Processing Framework

The core promise: **the founder never gets a surprise charge, and never wonders what an agent just paid for on their behalf.**

### Principles
1. **Itemize, don't bundle.** Every charge is tagged as either (a) a third-party pass-through cost (state filing fee, domain registration, trademark search fee) at the vendor's actual price, or (b) a Summit service fee for orchestrating that step. These are always shown as two separate line items, never blended.
2. **Pre-authorize, then execute.** Before any agent calls a paid API that spends the founder's money, it presents: what it's about to buy, from whom, for how much, and why — and requires explicit approval, except for pre-approved recurring items under a founder-set threshold (e.g., "auto-approve domain renewals under $50").
3. **Every spend is logged to a Fee Ledger** the founder can see in real time: timestamp, tier/milestone it belongs to, vendor, amount, agent that executed it, and status (pending/completed/refunded/disputed).
4. **No dark patterns on cancellation.** Any recurring service (domain renewal, insurance premium, subscription tooling) can be cancelled from the same dashboard it was purchased in, in one step.
5. **Fee schedule published up front**, tier by tier, so a founder can see the total realistic cost of reaching "top of the pyramid" before starting — not tier by tier surprise billing.

### Example Fee Ledger entry (schema sketch)
```json
{
  "milestone": "Tier 1 — Legal Foundation",
  "item": "LLC Articles of Organization filing, State of Texas",
  "vendor": "Texas Secretary of State",
  "pass_through_cost_usd": 300.00,
  "summit_service_fee_usd": 49.00,
  "status": "completed",
  "authorized_by": "founder",
  "authorized_at": "2026-07-02T14:03:00Z",
  "executed_by_agent": "formation-agent-v1",
  "receipt_url": "…"
}
```

### Agent roles mapped to fee-bearing actions
- **Formation Agent** — entity filing, EIN, registered agent, BOI report
- **Brand Agent** — domain purchase, email provisioning, site deploy
- **Compliance Agent** — license filings, insurance binding, tax registration
- **Commerce Agent** — payment processor onboarding, tax engine setup
- **Capital Agent** — loan package assembly, grant applications, lender submissions (no fee-bearing action without a completed, founder-reviewed package)
- **Growth Agent** — marketing tool provisioning, ad spend (always under an explicit, founder-set budget cap)

Every agent operates under the same rule: **propose the spend, show the itemized cost, wait for authorization (or a pre-set auto-approval rule), execute, log, receipt.**

---

## 7. Idea Discovery Protocol — Only On Explicit Request

Summit never proposes what business someone should build. If a client already knows, Tier 0 starts directly from their description. This protocol only activates when a client explicitly asks for help coming up with an idea — and even then, it does not hand them a generic template (a SaaS tool, a dropshipping store, a subscription box) as a default. There are millions of underserved, unimplemented ideas; the job is to help a specific person find one that fits *them*, through questions, not through a suggestion engine.

### The protocol is a conversation, not a generator
1. **Draw out the person, not a market category.** What do they already know deeply — a trade, a hobby, a job, a community, a frustration they've lived with? What do people already come to them for advice about?
2. **Surface unimplemented gaps, not trends.** Ask about problems they or people around them tolerate because "that's just how it is" — those are the ideas nobody has built yet, not the ones every generator suggests.
3. **Pressure-test with real constraints**, one at a time and only as they become relevant: available capital, time, location, regulatory exposure, whether they want to be hands-on or build something they can staff.
4. **Never default to a template category.** If the conversation stalls, the agent asks another question — it does not fall back to suggesting "an app for X" or "a SaaS for Y" as a safe default.
5. **Converge on one specific, describable business**, in the client's own words, that they recognize as theirs — then hand that description into Tier 0 as the starting input for everything above.

**Exit criteria:** a one- or two-sentence business description the client wrote or fully agrees with, specific enough to run a real name/domain/trademark clearance against — not a category, a concept.

---

## 8. What Makes This "One Stop Shop" Credible, Not Just Marketing

The Polsia failure mode is stopping at "site is live." Summit's retention thesis is the opposite: once a founder has their entity, EIN, bank account, licenses, insurance, live payments, and an SBA application in flight — all inside one dashboard with one fee ledger — the switching cost to go rebuild that elsewhere is enormous, and there's no reason to. Completeness is the moat, not lock-in tricks.

## 9. Suggested Next Steps
1. Build the Tier 0–4 flow as one universal path with dynamically surfaced sub-choices (license type, payment pattern) driven entirely by the client's own answers — no vertical branching baked into the platform itself.
2. Decide which 2-3 services per category in Section 4 are the *actual* v1 integrations (don't wire all of them at once) — recommend starting with: Cloudflare (domain/DNS/hosting), Stripe (Billing+Connect+Tax), Google Workspace (email), Northwest/Firstbase (formation), Plaid+Mercury (banking), grants.gov + SBA Lender Match (capital).
3. Design the Fee Ledger and approval-gate UI before building agent execution — this is the trust layer the whole pitch depends on.
4. Spec the Site Build Agent's intake schema (Section 5) so "first draft is the final draft" is actually achievable, not aspirational.
