# PDV Ship Optimization Review — 2026-07-26

Status: implementation and 1.0.3 package proof complete on
`codex/pdv-ship-optimization`. The owner-side 1.0.3 smoke packet is complete.
The 1.0.4 candidate is deployed and compile/static clean; post-compaction
runtime/manual acceptance remains open.

This review keeps the proof boundaries separate. Static compilation, tooling,
archive readback, and houseCARL record readback do not close fresh-process
runtime or manual UI proof.

## Release lanes

### 1.0.3 — release tooling only

- Gameplay source in the live 1.0.3 smoke mod was not changed.
- Added an exact 216-entry release manifest. It requires all 96 PSC files and
  all 96 matching PEX files.
- Packaging now fails on missing or unexpected payload entries.
- Packaging now requires every PEX to be strictly newer than its PSC.
- `PDV__ManagerQuest` must compile before `PDV_MCM`; `PDV_MCM.pex` must be
  strictly newer than both manager source and bytecode.
- The native DLL must be strictly newer than every C/C++ source/header,
  `xmake.lua`, and `xmake-requires.lock`.
- Live Prisma assets must byte-match their canonical native-mod copies and use
  the cache key derived from `app.js` plus `styles.css`.
- Version, ANAM, SEQ, hash-bound houseCARL proof, exact archive reopen, and
  archive checksum gates are mandatory.
- PDBs, backups, old/staging files, and prior release artifacts remain excluded.
- No BSA was added and no generated data was minified for negligible savings.

### 1.0.4 — low-risk, save-compatible candidate

- `PDV_PlayerEvents` now checks `Game.IsPluginInstalled()` before optional bard
  `GetFormFromFile()` calls and caches the result once per load.
- The origin, combat, and bard lanes now record independent real-time
  deadlines. One scheduler owns the sole `RegisterForSingleUpdate()` call and
  arms the earliest outstanding deadline.
- `PDV__ManagerQuest` has additive one-minute profiling counters for its
  permanent one-second chain. Its cadence and behavior are intentionally
  unchanged pending measured before/after profiles.
- Quest-reaction jobs now compact unreachable/zero-value base rows and inactive
  meta slots at ingress, persist source/skipped/meta counts plus ingress-build
  timing, and retain the two-reaction/0.1-second worker bound. Already-saved
  jobs without the additive `Compacted` key retain the legacy worker-side
  cheap-skip path.
- Prisma toast growth is bounded to eight active toasts, eight toasts per
  payload, and 32 recent deduplication keys.
- Existing scripts, properties, and persistent variables were not renamed or
  removed.

After the owner-side 1.0.3 smoke packet closed, these gameplay/UI files were
deployed to the authoritative Anvil Devotion mod. Manager and MCM were compiled
in dependency order with zero errors and zero warnings.

### 1.1 — migration-sensitive tranche

The following remain deferred:

- script removal or renaming;
- manager decomposition;
- VMAD reduction;
- property/persistent-variable removal;
- queue persistence redesign;
- proven orphan record/script retirement.

## Baseline

Verified existing archive:

- file: `Devotion-1.0.3-20260726.zip`
- entries: 216
- size: 7,988,392 bytes
- SHA-256:
  `C6C52F3853C5DC08AC4B5975A921EA7A04348482ED438626DCD5C5489D4B5774`
- PSC/PEX pairs: 96

The generated JSON ledger contains each script's trigger indicators, update and
registration sites, latent waits, external-call-site counts, PSC/PEX hashes,
timestamps, and freshness result. The Markdown sibling holds the release-facing
finding ledger.

## Findings and decisions

| Finding | Classification | Decision | Release lane | Proof state |
| --- | --- | --- | --- | --- |
| Optional bard lookup | Clean after candidate fix | Guard optional plugins and cache once per load | 1.0.4 | Fresh-process absent-mod log pass; installed-mod route open |
| Shared PlayerEvents timer | Clean after candidate fix | One earliest-deadline scheduler for three lanes | 1.0.4 | Compiles/static gate pass; overlap runtime proof open |
| Manager one-second chain | Suboptimal | Instrument before moving any work; require at least 20% targeted external-call reduction or a proven defect | 1.0.4 measured tranche | Functional 60-tick profile marker pass; ten-minute profile open; cadence unchanged |
| Quest-reaction worker | Suboptimal after runtime measurement | Retain bounded worker and compact runnable base/meta rows at ingress after the two-second gate failed | 1.0.4 | Pre-compaction FIFO/Book pass; 11/5/5/5-second latency fail; post-compaction runtime retest open |
| Release payload/freshness | Clean after fix | Exact manifest and hard freshness gates | 1.0.3 | Implemented; final rebuild and reopen pass |
| VMAD property inventory | Suboptimal audit queue | Review individually; no mass binding/removal | Audit now / structure in 1.1 | 552 unbound Auto findings remain unclassified |
| Native bridge | Clean statically | Preserve twelve functions and payload schemas | 1.0.3 audit | Build/static review pass; runtime smoke open |
| Prisma UI idle work | Clean statically | Retain event-driven model; bound toast growth | 1.0.4 UI | Static audits pass; runtime UI smoke open |
| TTF plus WOFF2 fonts | Suboptimal pending proof | Remove one format only after embedded Prisma proof | 1.0.4 follow-up | Deferred; all four fonts retained |
| 2K urn textures | Clean | Keep DXT1/DXT5 textures with full mip chains | All | Retained unchanged |

## Compilation and machine proof

- All 83 active PDV scripts compiled from the candidate source with zero
  warnings and zero errors.
- Manager compiled before MCM.
- All 96 live PSC/PEX pairs are present and fresh.
- `pdv_verify`: `FAIL=0`, `WARN=0`, `TODO=1`, `PASS=4119`, `INFO=72`.
  The one existing TODO is generic book faucet routing and is outside this
  optimization tranche.
- Papyrus ASCII guard: 96 files clean.
- PlayerEvents optimization audit: 14 pass, 0 fail.
- Quest-reaction performance audit: pass; static proof only.
- Prisma toast fallback audit: 27 pass, 0 fail.
- Prisma-to-1.0 candidate audit: 76 pass, 0 fail.
- Book of Days candidate audit: pass.
- Prisma UI audit: pass.
- Existing 216-entry archive reopens and exactly matches the new manifest.

The 2026-07-26 fresh-process pre-compaction run established:

- three exact manager profile markers:
  `timer=60 menu=0 hot=60 disfavor=6 reconcile=2 context=20`;
- neither optional bard plugin was installed and neither produced a
  missing-plugin error;
- four quest jobs enqueued, started, and completed in the expected FIFO order;
- no overflow, coalesce, broad-scope abort, stack dump, or PDV-attributable
  error;
- the paired `VM is freezing` -> revert/load -> `VM is thawing` sequence was
  normal save-load lifecycle, not a queue failure;
- the four START-to-COMPLETE timings were approximately 11, 5, 5, and 5
  seconds, so the two-second latency gate failed;
- the supplied Book of Days screenshot showed four matching, legible entries.

This moved the FIFO/runtime-route and Book-delivery buckets, but not the
post-compaction latency, toast-count, scheduler-overlap, organic MQ106, or broad
regression buckets.

## houseCARL readback

Direct readback against Anvil profile `Devotion Dev`:

- `Devotion.esp` is active.
- 1,949 records across 21 record types.
- 0 dangling links.
- 0 missing masters.
- 0 parse failures.
- 33 contested records accounted for.
- `PDV__ManagerQuest` winner is `Devotion.esp`; VMAD remains present with one
  attached manager script and one alias.
- `PDV_MCM` winner is `Devotion.esp`; VMAD remains present.
- `WindhelmTempleofTalos` winner remains `Lux.esp`; the Devotion override carries
  no nested Devotion placed-reference set there.
- `QASmoke` winner remains `ANV_SynW4ENBPatcher.esp`; all 51 separately
  enumerated Devotion placed-object records still resolve to `Devotion.esp`.
- Script-property readback found 183 scripted records, 552 unbound Auto
  properties, 0 bound-null properties, and 0 unverifiable attachments.

The 552 unbound properties are an audit queue, not a defect count and not a
clean-binding claim. No ESP or VMAD data changed in this tranche.

## Native and asset review

- `DevotionPrismaBridge` built successfully with the existing twelve native
  Papyrus functions preserved.
- No new hook, co-save state, or public payload schema was added.
- Native execution remains lifecycle/call/input driven; no recurring idle
  callback was introduced.
- UI listeners remain one-time registrations; payload handling remains
  event-driven; toast/DOM growth is now bounded in the 1.0.4 candidate.
- Both urn textures remain compressed 2K DDS files with full mip chains.
- Both TTF and WOFF2 font variants remain shipped because embedded Prisma WOFF2
  rendering has not yet been manually proven.

## Release package result

After Skyrim closed, the rebuilt bridge was deployed to the authoritative Anvil
Devotion mod and the complete preflight passed:

- exact live payload: pass;
- 96 PSC/PEX freshness pairs: pass;
- manager-before-MCM freshness: pass;
- source/PEX/archive version agreement: pass;
- native DLL newer than five native/build dependencies: pass;
- eight Prisma assets and cache key: pass;
- ANAM: pass;
- SEQ: pass;
- hash-bound houseCARL structural/readback proof: pass.

The final archive was rebuilt from the live Anvil mod, reopened, and compared
against the exact manifest:

- file: `dist/Devotion-1.0.3-20260726.zip`
- entries: 216
- size: 7,988,837 bytes
- SHA-256:
  `5A1571739FF81A309E0BF902E443F0AE26B33916610BC3F84F1E5B161F81C7DF`
- manifest SHA-256:
  `536EEBE7CCB71A9BF9BDCB3C1807AF327D2BB41B56524746B58171ABB03319E8`
- deployed native DLL SHA-256:
  `532031A7F917D2C28FBE5EE71588BBE534E12CA8D588D7C0453CF398AF7CD891`
- proof receipt: `dist/Devotion-1.0.3-20260726.zip.proof.json`

Proof buckets in the receipt:

- static and packaging: passed;
- houseCARL readback: passed for the exact ESP hash;
- runtime and manual: not claimed by the packager.

During path diagnosis the same native DLL was also copied to the ARR Devotion
mod. The authoritative release build and proof use the Anvil `Devotion Dev`
profile and Anvil live-mod root.

## Open runtime/manual acceptance

Do not promote the candidate to runtime-complete until a fresh process proves:

1. Installed bard routes still work; the absent-mod error path has passed.
2. Overlapping origin, combat, and bard deadlines each fire on time with no
   starvation or early polling.
3. A controlled ten-minute idle profile is captured. The functional 60-tick
   marker shape already passed in the deterministic active run.
4. The post-compaction four-job sweep produces FIFO `COMPLETE` markers,
   matching toast/Book entries, no queue overflow or broad-scope abort, and no
   START-to-COMPLETE latency later than two seconds:

   ```powershell
   node .\tools\pdv_quest_reaction_runtime_check.mjs `
     --expected-sequence "210731|150,148154|160,207142|200,221587|220" `
     --max-job-ms 2000
   ```

5. Organic MQ106 routing passes after the controlled jobs.
6. MCM, shrine, ordinary piety, save/load, Prisma panel, Book of Days, and
   uninstall preparation retain existing behavior.
7. Embedded Prisma renders the WOFF2 fonts correctly before either font format
   is removed.

## Next required step

Run the post-compaction four-job sweep from a fresh Skyrim process and inspect
the new `cells`, `sourceCells`, `skipped`, `meta`, and `buildMs` markers with
the two-second checker above. If that passes, run organic MQ106 next. Manager
cadence and both font formats remain unchanged until their separate measured or
manual gates justify a change.
