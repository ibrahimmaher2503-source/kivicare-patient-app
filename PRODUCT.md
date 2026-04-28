# Espitalia Design Context

## Users

**Primary segments:**
- Ages 20-45: Young adults & families booking appointments, managing children's visits
- Ages 45-65: Chronic care patients checking lab results, reviewing encounters

**Tech-savviness:** Moderate — comfortable with smartphones, not power users. Many are Arabic-speaking and expect RTL-first layouts.

**Context of use:**
- Anxious patient at 2 AM checking lab results (needs calm, reassuring UI)
- Busy parent quickly booking an appointment (needs speed, minimal steps)
- Chronic care patient reviewing visit history (needs clarity, not medical jargon)

**Key constraint:** The UI must be extremely simple, fast, and stress-reducing. No cognitive overhead.

## Brand Personality

**Three words:** Caring, Professional, Simple

**Emotional goals:** Trust — Clarity — Control
- "I trust this hospital"
- "This is easy to use"
- "I'm in control of my health"

**Positioning:** "A calm, trustworthy, and simple healthcare experience for everyday people."

## Aesthetic Direction

**Visual tone:** Warm Professional
- Not overly clinical (cold/sterile)
- Not overly playful (childish/unserious)
- Soft rounded corners, comfortable spacing, simple icons, highly readable typography

**References:**
- Vezeeta → Fast, simple booking functionality
- One Medical → Clean, premium, minimal visual design
- Cleo → Friendly tone, conversational microcopy

**Anti-references:**
- Outdated "government-style" UI
- Text-heavy medical dashboards
- Harsh or overly bright colors
- Long, complex forms

**Theme:** Light mode primary. Dark mode optional (important for late-night lab result checking).

**Color palette:**
- Navy (`#08234F`) → Trust & professionalism (primary)
- Teal (`#037F7C`) → Health & calm (secondary)
- Light teal (`#13BAAA`) → Accent, positive states
- Soft gray backgrounds + generous white space

## Design Principles

1. **Calm over clever.** Every screen should lower anxiety, not raise it. No visual noise, no competing elements, no surprise interactions.

2. **3-step maximum.** Core flows (especially booking: Specialty > Doctor > Time > Confirm) must complete in 3 steps or fewer. If it takes more, simplify.

3. **Plain language always.** Lab results show status (Normal / Low / High) with color indicators and short explanations — never raw medical values alone. All copy should be conversational and human.

4. **Inclusive by default.** Large text support for older users. High contrast. Color-blind friendly palette. Icons always paired with text labels. RTL as a first-class layout, not an afterthought.

5. **Empty states teach.** Blank screens feel broken. Every empty state should be helpful and human — guide the user toward their next action.

## Typography Direction

Current fonts (Plus Jakarta Sans + Outfit) are widely used across AI-generated projects. Future design work should explore alternatives that better express "caring professional" — consider humanist sans-serifs with warmer geometry (e.g., Nunito Sans, Atkinson Hyperlegible for accessibility, or Source Sans 3 for a neutral professional tone with excellent Arabic companion fonts).

**Priority:** Readability above all. Large base sizes (16px minimum body), generous line height, clear weight hierarchy.

## UX Priorities

1. **Appointment booking** — primary flow, must be fastest
2. **Lab results** — secondary but emotionally charged, must be calming and clear
3. **Encounters/visits** — review and reference, must be scannable
4. **Prescriptions** — actionable information, must be unambiguous
