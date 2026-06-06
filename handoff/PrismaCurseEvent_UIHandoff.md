# Prisma UI handoff — `curse` event type

**For:** a Claude design/code pass on `app.js`.
**Context:** `PDV__ManagerQuest.psc` emits `{"event":"curse",...}` overlay payloads when the
player's lycanthropy/vampirism curse state transitions (onset, cure, or a shift between
forms). The Papyrus side already supplies a race-aware `context` phrase
(`GetCurseContextForRace`); the UI owns the voice for the rest. This doc is the drop-in spec.

> **Note:** this doc was reconstructed from the live Papyrus emit
> (`SendPrismaCurseToast` / `HandleCurseStateTransition`) after the original handoff file
> was lost before it reached the repo. The payload shape below is taken verbatim from the
> emitting function, so it matches what ships today.

---

## 1. Payload shape

```json
{
  "mode": "toast",
  "toast": {
    "event":   "curse",
    "phase":   "onset" | "cure" | "shift",
    "curse":   "werewolf" | "vampire" | "",
    "symbol":  "curse-werewolf" | "curse-vampire" | "journal",
    "context": "<race-aware phrase from Papyrus — may be absent>",
    "deity":   "<active patron name if any — may be absent>"
  }
}
```

### Phase vocabulary

| phase | meaning | tone |
|---|---|---|
| `onset` | a curse just took hold (state `0 → werewolf/vampire`) | `warning` |
| `cure` | a curse was lifted (state `werewolf/vampire → 0`) | `good` |
| `shift` | one curse form replaced another (e.g. werewolf → vampire) | `warning` |

### Symbols emitted today vs. needed

| curse | symbol | glyph status |
|---|---|---|
| werewolf | `curse-werewolf` | Tier 3 — `journal` fallback (reuse `hircine` or new, per glyph handoff) |
| vampire | `curse-vampire` | Tier 3 — `journal` fallback (new "fanged moon" motif, per glyph handoff) |

---

## 2. `normalizeToastPayload` additions

`phase` is already surfaced by the `daedric` event additions; `curse` needs one more line.

```js
// After the existing if(!normalized.phase) block:
if (!normalized.curse) {
  normalized.curse = text(payload.curse || payload.curseType, "");
}
```

---

## 3. `eventAliases` additions

```js
curse_onset: "curse",
curse_cure:  "curse",
curse_shift: "curse",
```

---

## 4. `curseLabel` helper

Add alongside the other small text helpers (near `possessive` / `contextName`):

```js
const curseLabel = (payload = {}) => {
  const curse = text(payload.curse, "").toLowerCase();
  if (curse === "vampire") return "Vampirism";
  if (curse === "werewolf") return "Lycanthropy";
  return "The curse";
};
```

---

## 5. `eventLanguage.curse` block

```js
curse: {
  tone: (payload) => (text(payload.phase, "") === "cure" ? "good" : "warning"),
  symbol: (payload) => text(payload.symbol, "journal"),
  title: (payload) => {
    const curse = curseLabel(payload);
    const phase = text(payload.phase, "");
    if (phase === "onset") return `${curse} takes hold`;
    if (phase === "cure") return `${curse} is lifted`;
    if (phase === "shift") return "The curse changes shape";
    return "A curse stirs";
  },
  message: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    const phase = text(payload.phase, "");
    const curse = curseLabel(payload);
    if (phase === "onset") return `${curse} has taken root in your blood.`;
    if (phase === "cure") return `${curse} has been driven out.`;
    if (phase === "shift") return "One curse gives way to another.";
    return "Something has changed in your blood.";
  },
  listTitle: (payload) => {
    const curse = curseLabel(payload);
    const phase = text(payload.phase, "");
    if (phase === "cure") return `${curse}: lifted`;
    if (phase === "shift") return "Curse shifted";
    return `${curse}: onset`;
  },
  listText: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    return text(payload.phase, "") === "cure"
      ? "The mark has been lifted."
      : "The curse weighs on your devotion.";
  },
},
```

> **Prerequisite:** `resolveEventPayload` must call `language.tone` as a function when it is
> one (the `curse` and `daedric` tones are phase-dependent). The shift/daedric pass already
> added this guard:
> ```js
> const languageTone = typeof language.tone === "function" ? language.tone(normalized) : language.tone;
> resolved.tone = text(normalized.tone, languageTone);
> ```

---

## 6. Demo entries

```js
// In demoToasts:
curse_onset_vampire:  { event: "curse", phase: "onset", curse: "vampire",  symbol: "curse-vampire",  context: "Sovngarde is closed while the thirst remains." },
curse_cure_vampire:   { event: "curse", phase: "cure",  curse: "vampire",  symbol: "curse-vampire",  context: "The road opens again. The scar remains." },
curse_onset_werewolf: { event: "curse", phase: "onset", curse: "werewolf", symbol: "curse-werewolf", context: "The hunt pulls against Sovngarde." },
curse_shift:          { event: "curse", phase: "shift", curse: "vampire",  symbol: "curse-vampire" },
```

Demo buttons:

```html
<button type="button" data-demo-toast="curse_onset_vampire">Curse onset (vampire)</button>
<button type="button" data-demo-toast="curse_cure_vampire">Curse cure (vampire)</button>
<button type="button" data-demo-toast="curse_onset_werewolf">Curse onset (werewolf)</button>
<button type="button" data-demo-toast="curse_shift">Curse shift</button>
```

---

## 7. Papyrus emit site — current

| site | function | phases emitted |
|---|---|---|
| `HandleCurseStateTransition` → `SendPrismaCurseToast(oldState, newState)` | derives `onset` / `cure` / `shift` from the state delta | all three |

The race-aware `context` is produced by `GetCurseContextForRace(phase, curseType)` and
covers Nord, Altmer, Bosmer, Argonian, and Orc theologies; other races send no `context`
and rely on the UI fallbacks above. No further Papyrus changes are needed for `curse`.
