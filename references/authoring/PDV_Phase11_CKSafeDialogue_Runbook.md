# PDV Phase 11 CK-Safe Arngeir Dialogue Runbook

Status: runtime-proven

Phase 11 must be authored through Creation Kit. Do not use
`tools/pdv-next-packet-author --unsafe-generate-phase11-dialogue`; that path is
blocked because the previous generated `DLBR`/`DIAL`/`INFO` records caused a
CrashLogger-confirmed CTD.

Runtime proof passed on 2026-05-26. The positive Nord/Kyne Champion state
received the Arngeir recognition line; non-Nord, wrong active deity, and
Nord/Kyne below Champion states did not; save/load sanity on the positive state
passed.

## Target Packet

Active plugin:

- `PlayerDevotion_Framework.esp`

Owner quest:

- `PDV__ManagerQuest`

Branch:

- EditorID: `PDV_DIAL_Phase11ArngeirKyneRecognitionBranch`
- Category: `Player`
- Flag: `TopLevel`
- Starting topic: `PDV_DIAL_Phase11ArngeirKyneRecognitionTopic`

Topic:

- EditorID: `PDV_DIAL_Phase11ArngeirKyneRecognitionTopic`
- Prompt: `Has Kyne marked my path?`
- Category: `Topic`
- Subtype: `Custom`

Info:

- Contract label: `PDV_INFO_Phase11ArngeirKyneRecognition`
- CK output: Topic Info records may save without an EditorID. If CK does not
  expose an EditorID field for the Topic Info, leave it unnamed and verify it by
  topic, speaker, prompt, response line, and conditions.
- Speaker: `Arngeir` (`Skyrim.esm:02C6C7`)
- Prompt: `Has Kyne marked my path?`
- Response line: `The wind has marked you, Dragonborn. Walk with Kyne's breath.`

Conditions:

| Function | Subject | Comparison | Value |
| --- | --- | --- | --- |
| `GetIsID` | Speaker | `==` | `Arngeir` |
| `GetGlobalValue` | none | `==` | `PDV_GLO_OriginRace`, value `0` |
| `GetGlobalValue` | none | `==` | `PDV_GLO_ActiveDeityIndex`, value `0` |
| `GetGlobalValue` | none | `>=` | `PDV_GLO_ActiveTier`, value `3` |

## CK Steps

1. Launch Anvil, select the Creation Kit executable, and run it.
2. Load `PlayerDevotion_Framework.esp` as the active file.
3. Open quest `PDV__ManagerQuest`.
4. Add the dialogue branch, topic, and info above using CK dialogue UI.
5. Confirm the line remains ASCII-only and under 80 characters.
6. Save `PlayerDevotion_Framework.esp`.
7. Refresh `Seq\PlayerDevotion_Framework.seq`.

## Post-CK Readback

Only after CK save and SEQ refresh, change
`references/authoring/PDV_Phase11PrivilegePilot.manifest.json`:

```json
"implementationStatus": "live-dialogue-authored"
```

Then run:

```powershell
node .\tools\pdv_verify.mjs --strict-khajiit --strict-commitment --strict-neglect-decay --strict-phase11 --strict-phase10 --strict-phase9 --strict-phase8 --strict-phase7 --strict-preflight --strict-skeleton --strict-pattern-proving
```

Expected readback:

- `PDV_DIAL_Phase11ArngeirKyneRecognitionBranch` exists as `DLBR`.
- `PDV_DIAL_Phase11ArngeirKyneRecognitionTopic` exists as `DIAL`.
- A CK-authored `INFO` exists under the PDV topic. It may be unnamed.
- INFO speaker, prompt, line, and all four conditions match the manifest.

## Bridge Capability Notes

Live CKPE bridge monitoring on 2026-05-25 confirmed that the named pipe is
reachable from `tools/creation-authoring` through the Windows
`NamedPipeClientStream` fallback. The bridge reports discovery and guarded GLOB
creation surfaces, but still lists the Phase 11 dialogue operations as blocked:

- `createDialogueBranch`
- `createDialogueTopic`
- `createDialogueInfo`
- `generateSeq`

Do not promote Phase 11 dialogue authoring to automated bridge creation until a
CKPE-side handler can create the branch/topic/info, save the active plugin, and
pass MO2 readback for the exact Arngeir/Kyne packet.

## Runtime Proofs

Positive:

- PASS: Fresh Nord/Kyne Champion state receives the Arngeir recognition line.

Negatives:

- PASS: non-Nord does not receive it.
- PASS: Nord with wrong active deity does not receive it.
- PASS: Nord/Kyne below Champion does not receive it.

Final sanity:

- PASS: Save/load the positive proof state and confirm the line remains
  available.

Final strict verifier:

- `PASS=908`, `INFO=28`, no `WARN`, `FAIL`, or `TODO`.
