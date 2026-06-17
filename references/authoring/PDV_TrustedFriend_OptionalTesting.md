# Optional First-Look Testing

Audience: trusted first-look tester
Status: optional runtime/manual evidence, not required for a casual first look

This sheet is for a tester who wants to go beyond loading the mod and trying the Dunmer/Argonian inventory tokens. These checks are useful, but they are not required for this package to be worth a first look.

## Ground Rules

Use a new game or a fresh disposable test save. Old saves can keep stale script state.

Do not treat one missing or confusing result as a public-beta failure. Write down what happened, the race used, and the exact action taken.

Useful evidence, in order:

- short written note,
- screenshot of inventory, Survey Devotion, Active Effects, or message text,
- `Papyrus.0.log` if convenient.

## Quick Optional Pass

1. Dunmer token: start Dunmer, confirm `Ancestral Urn` appears, read it once, then check Survey Devotion.
2. Argonian token: start Argonian, confirm `Hist Sap Vial` appears, use it once, then check Survey Devotion.
3. One race packet: choose any `PDV_BetaTestPacket_<Race>.md` in `Docs` and run only the opening route or first short scenario.
4. Basic silence check: try the same token or packet action on the wrong race and note whether it stays quiet or rejects cleanly.
5. Feel note: write whether the religious feedback was understandable, too quiet, too noisy, or unclear.

## Best Race Packets To Try First

Use these if the tester wants the most useful coverage with the least setup:

- `PDV_BetaTestPacket_Argonian.md`
- `PDV_BetaTestPacket_Dunmer.md`
- `PDV_BetaTestPacket_Bosmer.md`
- `PDV_BetaTestPacket_Nord.md`
- `PDV_BetaTestPacket_Orc.md`

Altmer, Imperial, Redguard, and Breton are still useful, but some packet sections may depend on more specific setup or partially pending route surfaces. If a section says pending or relies on a precise vanilla quest state, skip it for first-look testing.

## What Each Race Still Needs Eventually

For most races, the remaining evidence is manual/runtime, not ESP authoring:

- accepted-source route proof,
- wrong-origin rejection,
- generic-source silence,
- anti-farm or duplicate behavior,
- Survey/status clarity,
- reward or Active Effects snapshot,
- short manual feel note,
- asset or final placement note if the packet asks for it.

Altmer and Khajiit already have their current first-look packet evidence mostly closed; final-world placement remains separate.

Bosmer has useful DA05 evidence already, but broader stack and feel notes are still helpful.

Daedric Prince testing is a larger controlled pass. Skip it unless the tester explicitly wants a longer session.

## What To Send Back

Paste this shape for each thing tested:

```text
Race:
Save type: new game / fresh test save / existing save
Action:
Expected from packet:
Observed:
Survey or Active Effects:
Screenshot/log attached: yes/no
Feel note:
```
