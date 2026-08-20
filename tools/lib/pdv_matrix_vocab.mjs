// The two closed vocabularies every quest-reaction row is written against, each PARSED from
// its source rather than kept as a second copy.
//
// WHY A SHARED MODULE. The deity-name model was already parsed out of PDV__ManagerQuest.psc
// inside pdv_matrix_runtime_preflight, and the act-tag vocabulary lived only in a Markdown
// table that nothing read. Adding a linter that re-derived either one would have created the
// exact drift this repo has a standing rule against: one value living in two places, where
// the copies disagree quietly and the disagreement surfaces as a row that silently never
// fires. Both callers now read the same function.
//
// NEITHER LIST IS EVER HAND-MAINTAINED. Part A gains a tag by someone editing Part A; the
// manager gains a deity by someone editing the manager. A hardcoded list here would be
// pinning, not verifying.

import fs from "node:fs";
import path from "node:path";
import { familySourceText } from "./pdv_symbol_home.mjs";

// Every requested-name ApplyDeityReaction will actually match. A name outside this set is not
// an error at runtime -- the cell is dropped in silence, which is indistinguishable from the
// mod simply not reacting. That is the "Clavicus" vs "Clavicus Vile" class.
export function acceptedDeityNames(repoRoot) {
  const managerPath = path.join(repoRoot, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
  if (!fs.existsSync(managerPath)) {
    return { names: new Set(), issues: [`manager source missing: ${managerPath}`] };
  }
  // Resolver-aware: the name model's RepairDeityRuntimeName call sites largely moved
  // into PDV_DevotionLedger, so a manager-only read parses a fraction of the names.
  const text = familySourceText(repoRoot, path.dirname(managerPath));
  const names = new Set();
  for (const m of text.matchAll(/RepairDeityRuntimeName\(\s*PDV_[A-Za-z0-9_]+\s*,\s*"([^"]+)"\s*\)/g)) {
    names.add(m[1]);
  }
  const daedricFn = text.match(/String Function CanonicalDaedricPathName[\s\S]*?EndFunction/);
  for (const m of (daedricFn ? daedricFn[0] : "").matchAll(/return "([^"]+)"/g)) names.add(m[1]);
  const aliasFn = text.match(/Bool Function IsQuestReactionNameMatch[\s\S]*?EndFunction/);
  for (const m of (aliasFn ? aliasFn[0] : "").matchAll(/requestedName == "([^"]+)"/g)) names.add(m[1]);

  const issues = [];
  // A floor, not a count. If the manager's shape changes enough to break these three regexes
  // the honest failure is "the parse broke", not "every deity in the matrix is now unknown".
  if (names.size < 30) {
    issues.push(`accepted-name extraction suspiciously small (${names.size}) -- manager name-model parse may have broken`);
  }
  return { names, issues };
}

// Part A of PDV_QuestReactionMatrix.md, parsed out of its Markdown tables.
//
// Two shapes. Most tags are literal. A few are namespaced with a placeholder --
// `serve_a_daedra:<prince>` in the doc means a real row writes `serve_a_daedra:hircine`. So a
// placeholder tag becomes a PREFIX rule, matching the `prefix:*` wildcard grammar
// pdv_quest_cross_gen's profileTagMatch already implements.
export function actTagVocabulary(repoRoot) {
  const docPath = path.join(repoRoot, "references", "authoring", "PDV_QuestReactionMatrix.md");
  if (!fs.existsSync(docPath)) {
    return { literals: new Set(), prefixes: new Set(), issues: [`matrix doc missing: ${docPath}`] };
  }
  const text = fs.readFileSync(docPath, "utf8");
  // Bounded to Part A on purpose: later parts quote tags inside prose and inside deity
  // profiles, and scraping those would silently widen the vocabulary to whatever anyone
  // happened to mention.
  const start = text.search(/^##\s+Part A\b/m);
  if (start < 0) return { literals: new Set(), prefixes: new Set(), issues: ["Part A heading not found"] };
  const rest = text.slice(start + 1);
  const end = rest.search(/^##\s+Part B\b/m);
  const partA = end < 0 ? rest : rest.slice(0, end);

  const literals = new Set();
  const prefixes = new Set();
  for (const m of partA.matchAll(/^\|\s*`([a-z0-9_]+(?::[a-z0-9_<>]+)?)`\s*\|/gim)) {
    const tag = m[1];
    const colon = tag.indexOf(":");
    if (colon > 0 && tag.slice(colon + 1).startsWith("<")) prefixes.add(tag.slice(0, colon));
    else literals.add(tag);
  }

  const issues = [];
  if (literals.size < 25) {
    issues.push(`act-tag extraction suspiciously small (${literals.size} literals) -- Part A table parse may have broken`);
  }
  return { literals, prefixes, issues };
}

// The Daedric slugs a namespaced tag may actually carry, read from the "Canonical Prince
// slugs" roster in Part B-2 of PDV_QuestReactionMatrix.md.
//
// WHY THIS IS NEEDED SEPARATELY FROM isKnownActTag. Part A defines the tag as
// `serve_a_daedra:<prince>`, so any suffix at all satisfies the PREFIX check -- and a wrong
// suffix is the worst possible failure, because it matches no Part B profile and therefore
// produces no fan-out, no reaction and no error. A judging pass emitted
// `serve_a_daedra:clavicus_vile` (the slug is `clavicus`) and `serve_a_daedra:umbra` (not a
// Prince at all) and both sailed through a green lint on 2026-08-09.
//
// WHY IT NO LONGER HARVESTS THE DATA. This function used to scrape slugs out of the shipped
// CSVs as well as the doc, on the reasoning that a harvest cannot rot into a list that
// disagrees with the data. It cannot -- but it also cannot DISAGREE with the data, which is
// the entire job. A typo became "known" the moment it was committed: the harvest learned it,
// then validated it, and the row it came from silently fanned out to nobody. That is how
// `serve_a_daedra:dagon` and `serve_a_daedra:mehrunesdagon` both passed a green lint while
// naming the same Prince. The roster is now DECLARED in Part B and this reads only that, so
// a new slug costs one deliberate table row -- which is the review the harvest skipped.
//
// Still parsed, never hardcoded here: a hardcoded copy would be pinning, not verifying.
//
// Scoped to the table's own rows on purpose. The prose around it names the slugs this pass
// REJECTED (`dagon`, `molag_bal`, `sheogorath_fire`, `clavicus_vile`), and a doc-wide scrape
// would re-legalise every one of them.
export function daedricSlugs(repoRoot) {
  const slugs = new Set();
  const issues = [];

  const docPath = path.join(repoRoot, "references", "authoring", "PDV_QuestReactionMatrix.md");
  if (!fs.existsSync(docPath)) return { slugs, issues: [`matrix doc missing: ${docPath}`] };
  const text = fs.readFileSync(docPath, "utf8");

  const start = text.search(/^####\s+Canonical Prince slugs\b/m);
  if (start < 0) {
    return { slugs, issues: ['Part B-2 "Canonical Prince slugs" roster not found -- the slug check cannot run'] };
  }
  // Ends at the next heading of any level, so adding a section after the table cannot widen
  // the vocabulary to whatever that section happens to mention. Slicing past the END of the
  // heading line, not past its first character: the Part A/Part B parsers get away with
  // `start + 1` because they look for `^##` and leave `# ...` behind, but this looks for any
  // `^#{2,6}` and would match the remainder of its own heading, yielding an empty roster.
  const afterHeading = text.indexOf("\n", start);
  const rest = afterHeading < 0 ? "" : text.slice(afterHeading + 1);
  const end = rest.search(/^#{2,6}\s/m);
  const roster = end < 0 ? rest : rest.slice(0, end);

  // `| Mehrunes Dagon | `mehrunesdagon` |` -- the second column only.
  for (const m of roster.matchAll(/^\|[^|\n]+\|\s*`([a-z0-9_]+)`\s*\|/gm)) slugs.add(m[1]);

  if (slugs.size < 10) {
    issues.push(`Prince slug roster suspiciously small (${slugs.size}) -- the Part B-2 table parse may have broken`);
  }
  return { slugs, issues };
}

export function isKnownActTag(tag, vocab) {
  if (vocab.literals.has(tag)) return true;
  const colon = tag.indexOf(":");
  return colon > 0 && vocab.prefixes.has(tag.slice(0, colon));
}

// Returns null when fine, or a reason string. Separate from isKnownActTag so a caller can
// report "not a tag" and "not a Prince" as the different problems they are.
export function badDaedricSlug(tag, known) {
  const colon = tag.indexOf(":");
  if (colon < 0) return null;
  const prefix = tag.slice(0, colon);
  const suffix = tag.slice(colon + 1);
  if (suffix === "*" || suffix.startsWith("<")) return null;
  const reviewedScopedSlugs = new Map([
    ["restore_faction_home", new Set(["blades", "dark_brotherhood"])],
    ["persecute_religious_worship", new Set(["talos"])],
    ["recover_stolen_divine_relic", new Set(["nocturnal"])],
  ]);
  const scoped = reviewedScopedSlugs.get(prefix);
  if (scoped) {
    if (scoped.has(suffix)) return null;
    return `"${suffix}" is not an approved ${prefix} slug (${[...scoped].sort().join(", ")})`;
  }
  // Only the three Prince-owned namespaces use the canonical Prince-slug
  // roster. Other reviewed namespaces deliberately carry non-Prince values,
  // e.g. persecute_religious_worship:talos and
  // restore_faction_home:dark_brotherhood.
  if (!["serve_a_daedra", "acquire_daedric_artifact", "destroy_reject_daedra"].includes(prefix)) return null;
  if (known.has(suffix)) return null;
  return `"${suffix}" is not a known Daedric slug (${[...known].sort().join(", ")})`;
}

// The same check for the Part D faucet lane, which is allowed one thing quest rows are not:
// a COMPOUND act, `<rosterslug>_<qualifier>`. Sheogorath has two distinct faucets -- bearing
// the Wabbajack (`serve_a_daedra:sheogorath`) and firing it (`serve_a_daedra:sheogorath_fire`)
// -- and the second shares the first's anti-farm bucket through FAUCET_CAP_TAG_ALIASES in
// pdv_quest_matrix_compile.mjs while keeping its own valence and intensity.
//
// The rule still catches the drift it was written for, because the base has to be a real
// Prince: `molag_bal` bases to "molag" and `mehrunes_dagon` to "mehrunes", and neither is in
// the roster. Both were live faucet slugs until 2026-08-09, when they were normalised to
// `molagbal` / `mehrunesdagon` so the faucet and the quest matrix would stop keeping two
// separate daily cap buckets for the same act on the same god.
export function badFaucetDaedricSlug(tag, known) {
  const colon = tag.indexOf(":");
  if (colon < 0) return null;
  const suffix = tag.slice(colon + 1);
  if (suffix === "*" || suffix.startsWith("<")) return null;
  if (known.has(suffix)) return null;
  const under = suffix.indexOf("_");
  if (under > 0 && known.has(suffix.slice(0, under))) return null;
  return `"${suffix}" is not a known Daedric slug, nor <slug>_<qualifier> over one `
    + `(${[...known].sort().join(", ")})`;
}
