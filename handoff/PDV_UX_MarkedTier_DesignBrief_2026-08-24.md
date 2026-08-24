# PDV UX design brief — the Marked tier and the two Nord Talos beats

**Status:** LIVING. Opened 2026-08-24. Awaiting owner decisions (section 6).
**Workstream:** design-only, per `handoff/PDV_UX_Claude_Handoff_2026-08-24.md`.
**Evidence bucket:** static only — workbook read, tracked design docs, and `live-source`
grep. No in-game presentation proof, no ESP readback, no runtime route exercised.
**Change boundary:** no game file, `.psc`, ESP, Prisma asset, or prose authority was
modified in producing this brief.

---

## 1. Why this brief exists

The disposition audit's `Consider new implementation` queue includes two Nord Talos
"Marked" beats. Working them as the pilot cluster surfaced something larger than two
popups: the surfacing tier they belong to has no implementation anywhere.

## 2. Mechanical truth

`PDV_Architecture_v3.md` section 10.6 defines a three-rung surfacing ladder:

| Level | Bucket | Player feedback |
|---|---|---|
| `Quiet` | Momentary combat favor | No notification; felt through the effect |
| `Noted` | After-act and environmental favor | Short notification when rare enough |
| `Marked` | Rare major favor, costly-but-faithful moments | Named message; meant to be remembered |

The section also states that costly-but-faithful events may be surfaced one level higher
than their duration bucket, because the point of the event is that the character paid a
real theological cost.

What the current source implements:

- The favor **families** are live. `PDV_ContextualFavorRuntime.psc` defines
  `FAVOR_FAMILY_OLD_WAYS_TALOS_DEFIANCE`, resolves it to a live spell
  `PDV_SPEL_Favor_NordBroadOldWays_HiddenTalosDefiance`, and gives it the display label
  "Hidden Talos defiance".
- The **ladder is not modelled**. There is no surfacing-level constant or branch in that
  file. The strings `MARKED` and `QUIET` appear only inside favor family names
  (`FAVOR_FAMILY_KYNE_WIND_MARKED_PASSAGE`, `FAVOR_FAMILY_OLD_WAYS_ANCESTOR_QUIET`) and
  are coincidental words, not tier constants.
- Every contextual favor leaves through **one call**, at
  `PDV_ContextualFavorRuntime.psc:177`:
  `Manager.Prisma.SendPrismaEventToast("favor", favorDeity, contextText, "", "")`.

So a cheap favor and a costly one are surfaced identically. The rung the architecture
reserves for "moments the player should remember" is the rung that does not exist.

Search scope, stated honestly: the claim is that no identifier matching
`FavorMarked`, `_Marked`, or `MarkedSurfac` exists in `live-source/Scripts/Source`, and
that the favor runtime routes all surfacing through the single `"favor"` toast above. A
Marked-tier beat implemented under some entirely different name would not be caught by
that search.

## 3. Player comprehension job

Hiding a Talos worshipper from the Thalmor and sleeping outdoors both currently produce
the same quiet acknowledgement. The player has no way to learn that the game noticed the
risk they took. The Marked tier's job is to make a costly act legible as costly — once,
in the god's own voice, at a volume the player will remember.

## 4. The two beats

Both are `Consider new implementation`, Nord, MessageBox body, moment `unclassified`.
Draft prose and trigger conditions are the owner's from
`race-sheets/PDV_RaceContent_Manifest.md` (lines 309 and 314); they are reproduced here
as design context, and the workbook remains the authority for exact wording.

| Copy ID | Trigger (manifest) | Draft title | Draft body |
|---|---|---|---|
| `PDV_Msg_Nord_FavorMarked_TalosDefiance` | High-cost defiance only: hiding a worshipper, protecting a shrine, defying Thalmor face-to-face. One per event, per-event cooldown. | Talos Notes the Risk | You stood between them and me. Carry the old breath a little longer. |
| `PDV_Msg_Nord_FavorMarked_NineTalosOpenDefiance` | High-cost only, per-event cooldown. The Nine-Divines lane carrying Talos anyway. | Talos Inside the Nine | You carried both my name and theirs, and would not put me down. Walk on. |

Their `Noted`-tier siblings are already live and dispositioned `Reconcile to current
runtime`: `PDV_Notif_Nord_FavorNoted_OldWays_TalosDefiance` ("A small thing kept hidden.
Talos answers.") and `PDV_Notif_Nord_FavorNoted_NineDivines_TalosPressure` ("The
contradiction holds. Talos hears even here."). The ladder therefore has a live bottom and
a missing top for the same theme.

## 5. Current presentation and the surface constraint

The historical drafts specify a **title**, and architecture 10.6 calls the Marked level a
*named* message. The drafts also nominate MessageBox as the surface. Those two facts
collide: per `references/authoring/PDV_UXSurfaceCatalogue.json`, a vanilla MessageBox does
not display the `MESG` Name — "Treat the body and buttons as the complete vanilla
presentation."

Every draft fits every candidate surface; only the title placement differs.

| Surface | Title | Body | Pause | Persistence | Cost |
|---|---|---|---|---|---|
| Prisma toast | 20/32 and 21/32 | 68/90 and 72/90 | No | Transient | Low, existing bridge |
| Prisma choice | fits 42 | fits 320 | Explicit | Until decision | Medium |
| Book of Days entry | fits 36 | fits 220 | No | Survives the session | Low |
| Vanilla MessageBox | **cannot render** | 68/420 and 72/420 | Yes | Until dismissed | Low |

## 6. Feasible options, and the recommendation

**Recommended: Prisma toast for the moment, paired with a Book of Days entry for
permanence, vanilla notification as the D0 fallback.**

Why this is the cheap option rather than the ambitious one:
`SendPrismaEventToast(eventName, deity, context, tierLabel, rival, allowFallback)` already
builds a typed JSON payload keyed on an `event` name, and already degrades through
`BuildPrismaEventFallbackText` to a vanilla notification when the bridge is down. A Marked
beat is therefore a **new event name on an already-wired channel**, plus a render case in
the Prisma view, plus the copy — not a new surface and not a new dependency.

It also satisfies the architecture's own wording: level `Marked` permits a "named
notification or message", and a Prisma toast is a named notification.

Known constraints that come with this route:
- A Prisma view edit requires the `index.html` cache key to be bumped, or the change does
  not reach the running game.
- The Prisma toast heading is rendered by the JS view, which is where deity-name casing is
  decided; a new event's heading must resolve the public display name, not a symbol.
- Diegetic channels are D0-gated. The fallback must read honestly with the bridge down,
  and the fallback loses the title.
- Anti-farm: the manifest already specifies one per event with a per-event cooldown. Any
  Marked signal needs its cap on the pulse, not only on the presentation.

Alternatives, for the record: MessageBox buys a genuine pause and a "Walk on"
acknowledgement, at the cost of folding the title into the body's first line and
interrupting play — defensible for a beat this rare. Prisma choice is over-built here;
nothing is being decided by the player.

## 7. Audit finding: `Reconcile to current runtime` is over-counted for this tier

Four of the 19 historical `FavorMarked` rows are classified `Reconcile to current
runtime`. Spot-checking three, the cited current records are different moments, not
renamed ones:

- `PDV_Msg_Imperial_FavorMarked_TalosDefiance` (standing between the Thalmor and a Talos
  worshipper) is reconciled to `PDV_Msg_Daedric_Mora_Response_Imperial`, which is about
  forbidden scholarship and Hermaeus Mora. Unrelated.
- `PDV_Msg_Breton_FavorMarked_HiddenArt_NotoriousRupture` (the irreversible moment of
  stopping hiding) is reconciled to `PDV_MSG_Confirm_Breton_HiddenArt`, which is the
  origin-choice confirmation prompt at character setup.
- `PDV_Msg_Redguard_FavorMarked_AshAbah_HardPassage` (a hard passage accomplished) is
  reconciled to the Ash'abah *entry* notice and *survey* line.

These look like topical-adjacency matches. The consequence is that the audit's headline
"311 reconcile to current runtime" masks a structural gap for the Marked tier: the
moments were not renamed, they were never built. This does not invalidate the audit's
other buckets, and it is not a defect in any game file — but the four rows want
re-dispositioning before the 311 figure is quoted as coverage.

## 8. Owner decisions needed

1. Adopt the Marked tier as a real surfacing rung, or rule it out and retire the 19
   historical Marked rows deliberately.
2. If adopted: confirm the Prisma-toast-plus-Book-of-Days treatment, or pick MessageBox
   and accept the title folding into the body.
3. Confirm or revise the two draft titles and bodies (workbook is the authority; nothing
   in this brief is a wording approval).
4. Re-disposition the four `FavorMarked` rows currently marked `Reconcile`.
5. Confirm whether the Imperial Talos-defiance beat should ship alongside the Nord pair,
   since it is the same mechanic and the same false reconcile.

## 9. Proof buckets required before any of this is called done

Static/readback is not sufficient for this feature. A shipped Marked beat needs:

- **static** — copy present in its authority; view render case present; cache key bumped;
- **runtime route** — the new event name actually dispatched from the high-cost branch;
- **player surface** — the toast seen in game, with the title rendering the public deity
  display name;
- **fallback** — the same beat with the Prisma bridge down, reading honestly;
- **anti-farm** — the per-event cooldown observed across repeated qualifying acts;
- **save/load** — the one-per-event state surviving a reload.

## 10. What this tranche did not do

No Penpot module was created or changed: the Penpot MCP server is available to Claude but
the workspace plugin was not connected during this session, so no board was read or
written. Section 5's surface comparison is therefore workbook-and-catalogue evidence, not
a canvas artifact, and no module is marked `Approved for implementation`.
