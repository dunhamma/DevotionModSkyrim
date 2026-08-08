# patch-source

Class: LIVING

Source of truth for **patch-only Papyrus** - scripts that belong to an optional per-mod
patch rather than to Devotion core.

## Do not edit the copies under `dist/`

`dist/PDV_QuestModPatches_FOMOD/**` is **produced** from this tree:

```bash
node tools/pdv_patch_source_deploy.mjs --check   # gate: does dist match this tree?
node tools/pdv_patch_source_deploy.mjs --write   # regenerate dist from here
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

The sha256 of each `.psc` as of its last compile, and of the `.pex` built from it. Edit a
`.psc` without recompiling and the gate goes red.

It is hashes rather than timestamps on purpose: **git does not preserve mtimes**, so an
"is the .psc newer than the .pex" check reports stale bytecode on a clean clone. A gate that
cries wolf on a fresh checkout gets ignored, which leaves the real problem unguarded.

After recompiling, accept the new bytecode explicitly:

```bash
node tools/pdv_patch_source_deploy.mjs --relock
```

`--relock` is a claim that you have recompiled. Do not run it to silence a red gate.

## Layout

Mirrors the destination so the mapping is readable at a glance.

```
patch-source/
  AFDI/Scripts/{Source/*.psc, *.pex}                -> common/AFDI  AND  plugins/individual/AFDI
  _Fragments/<Quest>/Scripts/{Source/*.psc, *.pex}  -> common/_Fragments/<Quest>
```

`PDV_AFDIObserver` deploys to **two** destinations because the two FOMOD options install
different folder sets. Those copies were byte-identical and kept so by hand; they are now
produced from one source, so they cannot drift.
