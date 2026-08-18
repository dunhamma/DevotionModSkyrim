// pdv_paths.mjs
//
// ONE canonical resolver for the live Devotion mod-folder paths that audit
// tools read. It exists to eliminate the source-path drift where tools
// hardcode the 1.5 folder (.../Anvil/mods/Devotion) and silently read the
// wrong build when a V3 folder (.../Anvil/mods/Devotion-V3Dev) is in play.
//
// Precedence a migrated tool must preserve:
//   tool-specific override (if the tool already had one)
//     > PDV_DEVOTION_ROOT (this resolver)
//     > the old hardcoded 1.5 literal (this resolver's default).
//
// Setting PDV_DEVOTION_ROOT to the V3 folder repoints every migrated tool at
// once; leaving it unset preserves the exact pre-existing 1.5 behavior.
//
// Dependency-free (node:path only). Mod-folder-derived getters return
// forward-slash paths so tool output stays consistent regardless of platform.

import path from "node:path";

// Legacy default: the 1.5 mod folder every migrated tool used to hardcode.
const LEGACY_DEVOTION_ROOT = "D:/Wabbajack/modlists/Anvil/mods/Devotion";

// Join with forward slashes, stripping any trailing slash on the base.
function joinFwd(base, ...parts) {
  const trimmed = String(base).replace(/[\\/]+$/, "");
  return [trimmed, ...parts].join("/");
}

// The live Devotion mod folder. Env override wins; else the legacy 1.5 default.
export function resolveDevotionRoot() {
  const env = process.env.PDV_DEVOTION_ROOT;
  return env && env.trim() ? env.trim() : LEGACY_DEVOTION_ROOT;
}

// <root>/Scripts/Source  -- Papyrus .psc sources.
export function devotionSource() {
  return joinFwd(resolveDevotionRoot(), "Scripts", "Source");
}

// <root>/Scripts  -- compiled .pex.
export function devotionPex() {
  return joinFwd(resolveDevotionRoot(), "Scripts");
}

// <root>/PrismaUI/views/Devotion/app.js  -- shipped Prisma view.
export function devotionPrismaView() {
  return joinFwd(resolveDevotionRoot(), "PrismaUI", "views", "Devotion", "app.js");
}

// <root>/Devotion.esp  -- shipped plugin.
export function devotionEsp() {
  return joinFwd(resolveDevotionRoot(), "Devotion.esp");
}

// Grandparent of root (.../Anvil): mods/<Devotion> -> mods -> Anvil.
export function anvilRoot() {
  return joinFwd(path.posix.dirname(path.posix.dirname(resolveDevotionRoot().replace(/\\/g, "/"))));
}

// <repoRoot>/live-source/Scripts/Source -- the worktree source mirror.
export function worktreeMirror(repoRoot) {
  return path.join(repoRoot, "live-source", "Scripts", "Source");
}
