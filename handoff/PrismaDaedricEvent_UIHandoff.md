# Prisma UI handoff — `daedric` event type

**For:** a Claude design/code pass on `app.js`.
**Context:** `PDV__ManagerQuest.psc` now emits `{"event":"daedric",...}` overlay payloads
for Daedric Prince interactions. Currently only Hircine is path-wired; the template is
built so that future Princes (Azura, Molag Bal, Boethiah, etc.) slot in without further
UI changes. This doc is the drop-in spec.

---

## 1. Payload shape

```json
{
  "mode": "toast",
  "toast": {
    "event":   "daedric",
    "prince":  "Hircine",
    "phase":   "boon" | "price" | "lapse" | "residue",
    "symbol":  "<prince symbol key — see below>",
    "context": "<optional short phrase>"
  }
}
```

### Phase vocabulary

| phase | meaning | tone |
|---|---|---|
| `boon` | Prince-granted positive beat (hunt rite scored, gift active) | `good` |
| `price` | Stigma cost, neglect, or devotion thinning | `warning` |
| `lapse` | Path renounced or curse-access broken | `warning` |
| `residue` | Post-lapse residue period active (recovery window) | `neutral` |

### Symbols emitted today vs. needed

| prince | symbol | glyph status |
|---|---|---|
| Hircine | `hircine` | Tier 1 — `journal` fallback until glyph lands |
| *(future)* Azura | `azura` | Tier 1 |
| *(future)* Boethiah | `boethiah` | Tier 1 |
| *(future)* Molag Bal | `molag-bal` | Tier 1 |
| *(future)* Meridia | `meridia` | Tier 1 |
| *(future)* all others | see glyph handoff Tier 1 table | Tier 1 |

---

## 2. `normalizeToastPayload` additions

```js
// After the existing if(!normalized.rival) block:
if (!normalized.prince) {
  normalized.prince = text(payload.prince || payload.daedra || payload.daedricPrince, "");
}
if (!normalized.phase) {
  normalized.phase = text(payload.phase || payload.daedricPhase, "");
}
```

---

## 3. `eventAliases` additions

```js
daedric_boon:    "daedric",
daedric_price:   "daedric",
daedric_lapse:   "daedric",
daedric_residue: "daedric",
```

---

## 4. `eventLanguage.daedric` block

```js
daedric: {
  tone: (payload) => {
    const phase = text(payload.phase, "");
    if (phase === "boon") return "good";
    if (phase === "residue") return "neutral";
    return "warning";
  },
  symbol: (payload) => text(payload.symbol, "journal"),
  title: (payload) => {
    const prince = text(payload.prince, "A Daedric Prince");
    const phase = text(payload.phase, "");
    if (phase === "boon") return `${prince} is satisfied`;
    if (phase === "price") return `${prince}'s price stirs`;
    if (phase === "lapse") return `${prince}'s hold breaks`;
    if (phase === "residue") return "Residue lingers";
    return `${prince} takes note`;
  },
  message: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    const phase = text(payload.phase, "");
    const prince = text(payload.prince, "The Prince");
    if (phase === "boon") return "The rite was answered.";
    if (phase === "price") return `${possessive(prince)} cost is rising.`;
    if (phase === "lapse") return "The path has been released.";
    if (phase === "residue") return "The mark has not fully faded.";
    return "Something stirs in that quarter.";
  },
  listTitle: (payload) => {
    const prince = text(payload.prince, "Daedric");
    const phase = text(payload.phase, "");
    if (phase === "boon") return `${prince}: boon`;
    if (phase === "price") return `${prince}: price`;
    if (phase === "lapse") return `${prince}: lapse`;
    if (phase === "residue") return `${prince}: residue`;
    return `${prince}: contact`;
  },
  listText: (payload) => {
    const context = contextName(payload);
    if (context) return context;
    const phase = text(payload.phase, "");
    return phase === "boon"
      ? "The rite was counted."
      : "The Prince has noticed.";
  },
},
```

---

## 5. Demo entries

```js
// In demoToasts:
daedric_boon:    { event: "daedric", prince: "Hircine", phase: "boon",    symbol: "hircine" },
daedric_price:   { event: "daedric", prince: "Hircine", phase: "price",   symbol: "hircine",  context: "Stigma has been rising." },
daedric_lapse:   { event: "daedric", prince: "Hircine", phase: "lapse",   symbol: "hircine" },
daedric_residue: { event: "daedric", prince: "Hircine", phase: "residue", symbol: "hircine" },
```

Demo buttons:

```html
<button type="button" data-demo-toast="daedric_boon">Daedric boon</button>
<button type="button" data-demo-toast="daedric_price">Daedric price</button>
<button type="button" data-demo-toast="daedric_lapse">Daedric lapse</button>
<button type="button" data-demo-toast="daedric_residue">Daedric residue</button>
```

---

## 6. Papyrus emit sites — current and planned

### Active (Hircine, wired now)
| site | function | phase emitted |
|---|---|---|
| `HandleHircineHuntRite` | `SendPrismaDaedricToast("Hircine", "boon", ...)` | `boon` |

### Planned (add as each Prince is scoring-wired in Papyrus)
| Prince | planned emit sites | phases |
|---|---|---|
| Hircine | `DebugRenounceHircinePath`, `BeginNordResidueRecovery`, `UpdateResidueRecovery` | `lapse`, `residue` |
| Azura / Boethiah / Mephala | Dunmer Reclamation route handlers | `boon`, `price` |
| Malacath | Orc life-mode / stronghold route | `boon`, `price` |
| Meridia | Undead-cleanse signal handler | `boon` |
| Molag Bal | Curse-access handler | `price`, `lapse` |
| *(others)* | per-Prince signal handler | varies |

No UI changes are needed when new Princes are wired — just call
`SendPrismaDaedricToast(princeName, phase, context, symbolKey)` from the Papyrus side.

---

## 7. Stigma and price — why no toast today

Stigma accumulates silently inside `RecordHuntRiteScaled` (via `AddStigma`) every time
a hunt rite scores. A `price` toast every single rite would be noisy. The recommended
approach is to emit `price` only on a *threshold crossing* (e.g. stigma reaching a
meaningful level), which requires a comparison inside `RecordHuntRiteScaled` or a dawn
check. This is a Papyrus-only change when the time comes; the UI block is ready for it.
