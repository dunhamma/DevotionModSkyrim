# PDV Startup Choice Messages (framework ESP records)

These are the explicit-choice `MessageBox` records the startup/setup quest references
when a race must pick its devotional frame at first run. They use the framework
`PDV_MSG_Startup*` EditorID convention (the script binds to these exact IDs), distinct
from the per-race authoring stubs already in `PDV_RaceContent_Manifest.md`
(`PDV_Msg_Bosmer_PathChoice_Setup`, `PDV_Msg_Breton_TraditionChoice_Setup`). The records
below are the player-facing realization of those stubs and supersede them in the ESP.

**Voice:** Narrator — literary, second-person, lightly fatalistic, matching the existing
setup rows. Each body is instructive: it names what every option *means* and what it
*costs*, so the player can choose on understanding rather than vibe.

**Flow (per race):**
1. Show the race's `PDV_MSG_Startup<Race>Choice`. The selected button writes the *pending*
   value for that race's state variable.
2. Show `PDV_MSG_StartupConfirmChoice`.
   - **Yes** → commit the pending value to the state variable; setup completes.
   - **No** → re-show the race choice. Nothing is committed until Yes.
3. Fallback only applies if setup is somehow exited without a committed value (see each
   record). Breton is the exception: it has **no** fallback and the choice must re-present
   until answered.

`MessageBox` button order below is the authoring order; map each button to the listed
state value, not to its on-screen index, so reordering buttons never silently remaps state.

---

## PDV_MSG_StartupBretonChoice

- **Fires:** first-run setup for a Breton character; one-time.
- **Writes:** `PDV_State_BretonTradition` — `KnightsRoad = 0`, `HiddenArt = 1`, `GreenWay = 2`.
- **Fallback:** none. The setup choice must be explicit; if dismissed, re-present until
  answered (see `PDV_RaceDesign_Breton.md` → Implementation acceptance criteria).

**Title:** `Which Tradition`

**Body:**
> Breton faith is the road you walk, and the gods take their shape from it. The Knight's
> Road keeps a vow of mercy and service to the Divines — an honor you can hold or break.
> The Hidden Art buys occult and Daedric power at the price of secrecy; in time the world
> may come to see what you are. The Green Way answers to Y'ffre and the living land. Choose
> now. This holds for the life ahead, and only a rare, hard turn will move it.

**Buttons:**
| Button label | → `PDV_State_BretonTradition` |
| --- | --- |
| `The Knight's Road` | `0` (KnightsRoad) |
| `The Hidden Art` | `1` (HiddenArt) |
| `The Green Way` | `2` (GreenWay) |

---

## PDV_MSG_StartupRedguardChoice

- **Fires:** first-run setup for a Redguard character; one-time.
- **Writes:** `PDV_State_RedguardSect` — `Crown = 0`, `Forebear = 1`, `AshAbah = 2`.
- **Fallback:** `Forebear` (`1`) if sect state is ever unset or corrupt — the broadest
  Skyrim bridge position (see `PDV_RaceDesign_Redguard.md` → "Implementation locks (LOCKED)").
- **Note:** the ancestor reverence layer is always active for every sect; this choice sets
  emphasis and social burden, not a different theology.

**Title:** `Your Sect`

**Body:**
> Every Redguard keeps the Yokudan spine — Satakal the Worldskin, Tu'whacca who guides the
> dead, and the ancestors who are always watching. The age only asks which sect you stand
> in. The Crown bears the orthodox martial inheritance with proud restraint. The Forebear
> adapts — public, pragmatic, at ease among foreigners. The Ash'abah carry the dead no one
> else will touch and cleanse the unquiet — a duty honored and costly at once. Choose your sect.

**Buttons:**
| Button label | → `PDV_State_RedguardSect` |
| --- | --- |
| `Crown — orthodox bearing` | `0` (Crown) |
| `Forebear — pragmatic adaptation` | `1` (Forebear) |
| `Ash'abah — the death-duty` | `2` (AshAbah) |

---

## PDV_MSG_StartupOrcChoice

- **Fires:** first-run setup for an Orc character; one-time.
- **Writes:** `PDV_State_OrcLifeMode` — `City = 0`, `Stronghold = 1`, `LegionExile = 2`.
- **Fallback:** `City` (`0`) — the default bridge state.
- **Intent, not entitlement (LOCKED):** the button records *intent*. The active scoring/favor
  lane stays at `City` until the world confirms eligibility — `Stronghold` requires Blood-Kin
  or stronghold acceptance plus active stronghold conduct; `Legion/Exile` requires explicit
  service/exile commitment or a completed service milestone (see `PDV_RaceDesign_Orc.md` →
  "Life-mode implementation rule (LOCKED)"). The body says this plainly so a player who picks
  Stronghold and stays at City is not surprised.

**Title:** `Your Life Under Malacath`

**Body:**
> Malacath is your god, and that will not change — you are not choosing a deity but the life
> you keep under his code. The Stronghold Orc proves strength among kin, but that standing is
> earned, through Blood-Kin and the work of the stronghold, not merely declared. The City Orc
> holds private faith beneath public compromise. The Legion or Exile keeps the code alone,
> under foreign discipline. Name the life you intend; the world will test it and confirm it.

**Buttons:**
| Button label | → `PDV_State_OrcLifeMode` (intent) |
| --- | --- |
| `Stronghold — strength among kin` | `1` (Stronghold) |
| `City — fidelity under compromise` | `0` (City) |
| `Legion or Exile — the code alone` | `2` (LegionExile) |

---

## PDV_MSG_StartupConfirmChoice

- **Fires:** immediately after any startup race choice above; shared / race-agnostic
  (also usable by the existing Bosmer `PathChoice` flow).
- **Writes:** nothing directly. It gates the commit:
  - **Yes** → commit the pending selection to the race's state variable.
  - **No** → discard the pending selection and re-show the race choice.

**Title:** `Hold to This?`

**Body:**
> What you have named shapes how the gods read your every act for the life ahead. To turn
> from it later is deliberate and dearly bought — never an idle change of mind. Do you hold
> to this road?

**Buttons:**
| Button label | Action |
| --- | --- |
| `Yes — this is my road` | Commit pending selection; finish setup |
| `No — let me choose again` | Discard; re-show the race choice |
