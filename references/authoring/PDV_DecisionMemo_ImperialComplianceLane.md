# Decision Memo — Imperial Concordat Compliance lane

**Status:** Mostly reconciliation; one genuine sub-decision resolved (recommended, author may
flip). The immersion audit asked: "the Concordat Compliance lane has no Champion — is it a
loss-path or an alt-victory?" The locked Imperial design already answers the structural
question; only the *surfacing* of the Talos gate was genuinely open.

## What the locked design already says

Concordat compliance is **not a worship lane with its own deity** and so has no "Concordat
Champion." It is a **standing modifier** that reshapes which of the Nine an Imperial can reach:

- High compliance **closes Talos** — `Public Compliant` and `Concordat Enforcer` block Talos
  offers absent a fresh costly-defiance rupture (`PDV_RaceDesign_Imperial.md:56,107`).
- High compliance **blunts the mercy-gods** — Enforcer dampens Stendarr and Arkay daily shift
  (`:62,110`). "The civic religion judges its own failures" (`:184`).
- High compliance **keeps the order/commerce gods open** — `Public Compliant`/`Enforcer` may
  *amplify* Akatosh / Zenithar civic-order offer eligibility through genuine order-preserving,
  public-service, or honest-exchange acts (`:56,60`).

So it is **neither a dead loss-path nor a parallel victory.** A committed-compliant Imperial's
available high-tier payoff is an **Akatosh or Zenithar Champion** (order and honest commerce —
the gods a Concordat loyalist can still face honestly), while Talos is closed and Stendarr/Arkay
are blunted. That is a coherent, already-locked answer. **No new lane, no new Champion to
build.** This is recorded here so it stops being re-asked.

## The one genuinely open sub-decision: how to surface the closed Talos gate

There is a real tension in the existing notes:

- The audit wants an **explicit rejection** when compliance blocks Talos, so the player
  *learns* their political stance closed a path.
- The locked offer-gate note wants the block to **fail gracefully** — "it should feel like
  Talos hasn't noticed them yet rather than 'the mod blocked me'" (`:226`).

A blunt "you are blocked" popup at offer-evaluation time would violate `:226` and feel like a
nag. Pure silence leaves the audit's legitimate concern (invisible consequence) unaddressed.

### Resolution (recommended)

**Do not fire an offer-time rejection.** Preserve graceful failure (`:226`) — the Talos offer
simply does not surface. **Instead, make the cost legible through state, not interruption:**

1. **Survey Devotion / MCM Player row** for a compliant Imperial names the theological cost in
   thematic language — e.g. *"You enforce the White-Gold Concordat. The Ninth's voice does not
   reach the obedient."* This is non-voiced, fits the §16.3 surface set, and the player reads
   it when they choose to look.
2. **The standing-shift notification already exists** as a legible state change (a Medium
   surface per §16.2). When the player crosses into `Public Compliant` / `Enforcer`, that
   transition is surfaced by the standard transition contract (§16.7, the sect/mode/standing
   class) with copy that names the consequence — *"You have become an enforcer of the
   Concordat. Talos turns away; the mercy of Stendarr and Arkay grows distant."*

This satisfies both constraints: the player is never interrupted with a "blocked" nag at
offer time, but the consequence is surfaced at the moment the **standing** changes and remains
readable in status. The Talos gate stays graceful; the political cost stops being invisible.

**LOCKED 2026-08-25 (owner).** The lock stands: graceful Talos failure, no offer-time
rejection. The offer simply does not surface, and the cost is learned from state. The
author-flip option below is CLOSED and should not be re-opened without a new owner
decision. Confidence in the lock increased because the state copy is being rewritten to
actually name the cost -- the original discomfort with silence came from the state saying
nothing, not from the absence of a popup.

~~**Author may flip** to an explicit offer-time rejection if the preference is for louder
feedback; if so, gate it behind a first-time-only one-shot so it never repeats.~~

## Net

- Structural question: **already answered** by locked design — compliance is a standing
  modifier; Akatosh/Zenithar remain the compliant Imperial's Champion payoff; no new content.
- Surfacing question: resolved to **state-legible, not interrupt-driven** (transition copy on
  standing change + Survey/status line), implemented via the §16.7 transition-surfacing
  contract. Recorded as the recommended lock.
