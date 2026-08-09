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

// Every requested-name ApplyDeityReaction will actually match. A name outside this set is not
// an error at runtime -- the cell is dropped in silence, which is indistinguishable from the
// mod simply not reacting. That is the "Clavicus" vs "Clavicus Vile" class.
export function acceptedDeityNames(repoRoot) {
  const managerPath = path.join(repoRoot, "live-source", "Scripts", "Source", "PDV__ManagerQuest.psc");
  if (!fs.existsSync(managerPath)) {
    return { names: new Set(), issues: [`manager source missing: ${managerPath}`] };
  }
  const text = fs.readFileSync(managerPath, "utf8");
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

export function isKnownActTag(tag, vocab) {
  if (vocab.literals.has(tag)) return true;
  const colon = tag.indexOf(":");
  return colon > 0 && vocab.prefixes.has(tag.slice(0, colon));
}
