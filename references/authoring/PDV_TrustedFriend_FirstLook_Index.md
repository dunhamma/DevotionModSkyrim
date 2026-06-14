# Devotion First-Look Index

Created: 2026-06-15
Audience: trusted first-look tester

This is a first-look package, not a public beta claim. The goal is to let one trusted tester load the current ESP, try normal play surfaces, and tell us whether the religious feedback feels understandable and worth continuing.

## Install

1. Install the packaged `Devotion` folder as a mod, or copy its contents into an existing test mod while preserving folders.
2. Enable `Devotion.esp`.
3. Start a new game or use a fresh test save.
4. Open MCM after the game settles, confirm Devotion appears, then use Survey Devotion from the player power if available.

## Fastest First Look

1. Start as Dunmer.
2. Confirm the player inventory contains `Ancestral Urn`.
3. Read or activate `Ancestral Urn` from inventory once.
4. Check whether the ancestral-prayer response is understandable and whether Survey Devotion reflects the beat.
5. Start as Argonian.
6. Confirm the player inventory contains `Hist Sap Token`.
7. Read or activate `Hist Sap Token` from inventory once.
8. Check whether the Hist-maintenance response is understandable and whether Survey Devotion reflects the beat.
9. Try any one race packet in `Docs` if there is time.

If you want more structure, open `PDV_TrustedFriend_OptionalTesting.md`. It lists the smallest useful checks without turning this into a full proof session.

## Token Notes

`Ancestral Urn` is a reusable Dunmer inventory book. It should appear automatically for Dunmer characters and route into the existing ancestral-prayer logic when read.

`Hist Sap Token` is a reusable Argonian inventory token. It should appear automatically for Argonian characters and route into the existing Hist-maintenance logic when read.

## Useful Feedback

The most useful notes are short and concrete:

- race used,
- whether the token appeared,
- what action was taken,
- what message, active effect, or Survey text appeared,
- whether anything felt confusing, too quiet, or too spammy.

Screenshots and `Papyrus.0.log` are useful if convenient, but this packet does not require formal runtime proof.
