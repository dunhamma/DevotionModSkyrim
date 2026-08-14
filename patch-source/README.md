# patch-source

Class: LIVING

Source of truth for **patch-only Papyrus** - scripts that belong to an optional per-mod
patch rather than to Devotion core.

## Do not edit the generated copies under `dist/`

The five adapter payloads under `dist/PDV_QuestModPatches_FOMOD/adapters/` are
**produced** from this tree and the compatibility manifest:

```bash
node tools/pdv_patch_source_lock.mjs --check
node tools/pdv_quest_reaction_build.mjs --self-test --check --json
node tools/pdv_quest_reaction_build.mjs --write  # intentional regeneration only
```

Before this tree existed, those ten `.psc` files lived **only** under `dist/`. For that class
the build output *was* the source: `pdv_compile.mjs` could not see them, nothing regenerated
them, and a `dist/` wipe would have lost them permanently. That is issue #41.

## Why not `live-source/`

Patch code must not enter the core build. `tools/pdv_arr25_nonquest_check.mjs` asserts that
AFDI stays out of core, and the AFDI observer is an opt-in patch.

## The distribution is still ONE FOMOD

This is a **source** tree, never a second shipped lane. Everything continues to ship inside
the single core-plus-patches installer. Splitting core from patches is what produced the JoJ
silent-underdelivery failure - core installed, eighteen covered mods sat inert, nothing
errored - so nothing here may reintroduce that split.

## `PDV_PatchSource.lock.json`

The sha256 of each `.psc` as of its last compile, and of the `.pex` built from it. The V3
build validates this lock before it reads any adapter asset. Edit a `.psc` without
recompiling and both the lock gate and package build go red.

It is hashes rather than timestamps on purpose: **git does not preserve mtimes**, so an
"is the .psc newer than the .pex" check reports stale bytecode on a clean clone. A gate that
cries wolf on a fresh checkout gets ignored, which leaves the real problem unguarded.

After recompiling, accept the new bytecode explicitly:

```bash
node tools/pdv_patch_source_lock.mjs --relock
```

`--relock` is a claim that you have recompiled. Do not run it to silence a red gate.

## Layout

Keeps canonical sources and locked artifacts together; the compatibility manifest owns
their generated install destinations.

```
patch-source/
  AFDI/Scripts/{Source/*.psc, *.pex}                -> adapters/afdi/Scripts
  _Fragments/<Quest>/Scripts/{Source/*.psc, *.pex}  -> adapters/<source-id>/Scripts
  <Adapter>/PDV_Patch_*.esp                         -> adapters/<source-id>/
```

The V1 common/individual duplication is retired. Every adapter asset has one canonical
source and one generated option destination.
