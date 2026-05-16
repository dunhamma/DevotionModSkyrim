# PlayerDevotion Beta Tester Brief

Status: Draft tester communication for future beta rounds.
Authority: This document is not architecture authority. `PDV_Architecture_v3.md`
is the source of truth for implementation scope, system gates, and roadmap
decisions. If this brief conflicts with v3, update this brief.

---

## What PlayerDevotion Is

PlayerDevotion is a Skyrim Special Edition roleplay mod that tracks religious
devotion through the player's race, actions, patron commitments, and religious
context. It aims to make faith feel like part of everyday play: not just shrine
bonuses, but cultural practice, neglect, recognition, and consequences.

The beta will be staged. Early testers should expect strong systems work with
incomplete content breadth. Later testers should expect a richer roleplay feel
and should judge whether the religion layer is legible, meaningful, and
lore-grounded.

---

## Beta Stages

### Technical Beta

Audience: small trusted testers who are comfortable with rough edges.

The technical beta is ready when:

- Install/update instructions are usable.
- Core systems are stable on clean starts.
- MCM/status surfaces are readable.
- No known hard verifier failures remain.
- Several worship paths are content-ready.
- Normal gameplay can produce useful bug reports without console-only flows.

What to expect:

- Systems are real and should work.
- Content breadth is incomplete.
- Balance and roleplay texture are still being tuned.
- Some future worship targets may exist internally but remain hidden from
  player-facing UI and gameplay.

What to report:

- Install or load-order problems.
- MCM/status display issues.
- Piety, tier, patron, dawn, boon, neglect, or rivalry behavior that feels
  broken or confusing.
- Save/load weirdness after a clean-start test.
- Any player-facing text that is unclear, too technical, or not ASCII-safe.

### Content-Feel Beta

Audience: trusted roleplay testers.

The content-feel beta is ready when:

- Every race has at least one credible, race-aware foreground path.
- Khajiit, Dunmer, and Argonian substrate layers feel distinct.
- The named race mechanics are visible enough to judge: Imperial Concordat
  neutrality/walk-back, Breton tradition tension, Bosmer Green Pact failure,
  Nord broad-worship combos, Khajiit emergent emphasis, Orc community support,
  Redguard HoonDing big wins, Altmer crisis pressure, Dunmer portable shrine
  practice, and Argonian Hist/community maintenance.
- Commitment, neglect, decay, curse-state, and UI are live.
- Enough dialogue, shrine, notification, and recognition texture exists to
  judge the religious feel.
- Dev-only scaffolds remain hidden from player-facing surfaces.

What to expect:

- The mod should feel like a religious roleplay layer, not just a debugged
  piety tracker.
- Testing should focus on meaning, tone, pacing, clarity, and whether the
  system respects race-specific theology.
- Some post-1.0 expansion paths may still be absent, but visible 1.0 content
  should feel intentional rather than placeholder.

What to report:

- Moments where devotion changes but the reason is unclear.
- Races whose worship feels generic or flattened.
- Race-specific mechanics that technically fire but do not feel meaningful.
- Patron commitments that feel too easy, too sudden, or too hidden.
- Neglect, decay, or curse behavior that feels punitive without meaning.
- Dialogue, shrine, or notification text that breaks tone.

---

## Launch Bar

The target is a content-rich 1.0 launch.

Launch is ready when:

- All 10 races have satisfying authored devotional play.
- Major Aedric, Nordic, and Daedric paths are not merely scaffolded.
- Player-facing text is polished and ASCII-safe.
- Light authored moments are present, including commitment offers,
  shrine/ritual interactions, dialogue recognition, and notifications.
- No original multi-stage questlines are required for 1.0.
- Compatibility posture is documented.
- External beta feedback has been addressed or explicitly deferred.

---

## Tester Notes

- Test from clean starts unless a test request explicitly asks for an existing
  save.
- Report what you did, what you expected, what happened, and whether it
  survived save/load.
- Include race, patron, current tier, curse state, and relevant MCM/status
  readout when possible.
- Avoid judging hidden or dev-only scaffold content as unfinished player
  content. If it appears in normal play, that is a bug.
