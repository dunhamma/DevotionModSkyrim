// Structural QUST probe for the candidate queue.
//
// WHY THIS EXISTS. The queue classified content-vs-noise from mod FOLDER NAMES alone, and
// names are wrong in both directions. `Lucien - Immersive Fully Voiced Male Follower` was
// discarded because "Voiced" also appears in `VIGILANT - ElevenLabs Voiced`; it defines 48
// quests. `Val Serano - Pirate Follower and Quest Adventure` was queued as real work on the
// strength of a doc that called it a verified negative; it defines ~62. A name cannot tell
// you whether a plugin carries content. Its records can.
//
// WHAT IT REPORTS, AND WHAT IT DELIBERATELY DOES NOT. This returns EVIDENCE, not a verdict:
// the count of QUST records a plugin DEFINES plus their editor ids. It does not decide the
// bucket. Devotion's own ARR discovery waves already adjudicated framework, controller,
// generated and appearance-only quests as non-content, and Lucien is the case in point -
// of its 48, several are `JRLucienMapMarker`, `JRLucienRiding`, `JRLucienCatchUp`. Auto-
// classifying on QUST presence would re-queue exactly what those waves ruled out.
//
// Stage/objective depth is NOT probed in bulk by `probePlugins` on purpose. read_plugin_file
// can enumerate a type cheaply but only returns fields for ONE record at a time, so stage
// depth costs a call per quest - thousands across three modlists. That belongs in the Phase
// 1b shortlist read, which is `probeQuestStages` / `digestQuests` at the bottom of this file:
// they run over a BOUNDED work list and write their output to disk, never into a caller's
// context.

import fs from "node:fs";
import path from "node:path";
import { openHousecarl, extractHousecarlText, resolveHousecarlExe } from "./pdv_housecarl_stdio.mjs";

// A plugin can legitimately define hundreds of quests; Lucien has 48 and Val Serano 66.
// Cap high enough that "showing first N" never truncates a real answer silently.
const ENUMERATE_LIMIT = 2000;

// The trailing schema token is load-bearing. When the shape of a cached record changes, every
// entry written under the old shape must MISS rather than be served back missing its new
// fields -- a half-populated cache hit is a silent wrong answer, and nobody remembers to
// delete a cache file by hand. Bump it whenever parseQustEnumeration's return changes.
const ENUM_SCHEMA = "e2";

export function cacheKeyFor(absPath) {
  const st = fs.statSync(absPath);
  return `${absPath}|${st.size}|${Math.floor(st.mtimeMs)}|${ENUM_SCHEMA}`;
}

export function loadCache(cacheFile) {
  if (!cacheFile || !fs.existsSync(cacheFile)) return new Map();
  try {
    return new Map(Object.entries(JSON.parse(fs.readFileSync(cacheFile, "utf8"))));
  } catch {
    return new Map(); // a corrupt cache is a cache miss, never a failure
  }
}

export function saveCache(cacheFile, cache) {
  if (!cacheFile) return;
  fs.mkdirSync(path.dirname(cacheFile), { recursive: true });
  fs.writeFileSync(cacheFile, `${JSON.stringify(Object.fromEntries(cache), null, 2)}\n`, "utf8");
}

// Parse `read_plugin_file --type=QUST` output.
//
// Rows look like:  `  093567:AX ValSerano.esp  type=Quest  editorid=Val000`
// The FormID's suffix names the DEFINING master, so a row whose suffix is the probed file
// itself is a definition and anything else is an override this plugin merely carries. That
// distinction is the whole point: 4 of Val Serano's 66 rows are vanilla overrides.
//
// The "declared master(s) NOT installed anywhere" line is IGNORED and must stay ignored. It
// resolves against houseCARL's ACTIVE instance, not the file's own master list, so probing
// an ARR plugin while pointed at Anvil reports masters missing that are installed fine in
// ARR. That produced a false alarm on the Authoria patch on 2026-08-08.
export function parseQustEnumeration(text, pluginBasename) {
  const rows = [];
  for (const line of text.split("\n")) {
    const m = line.match(/^\s+([0-9A-Fa-f]{6}):(.+?)\s+type=Quest\s+editorid=(.*)$/);
    if (m) rows.push({ formid: m[1], definedIn: m[2].trim(), editorId: m[3].trim() });
  }
  const target = pluginBasename.toLowerCase();
  const defined = rows.filter((r) => r.definedIn.toLowerCase() === target);
  const truncated = /showing first \d+/.test(text);
  return {
    qustDefined: defined.length,
    qustOverridden: rows.length - defined.length,
    editorIds: defined.map((r) => r.editorId).filter((x) => x && x !== "<none>"),
    // The FormID and the EditorID paired as the enumeration line had them. A downstream
    // caller must never rebuild this pairing from two separate lists: they are only
    // reliably joined here, and a mispaired FormID is a row that silently watches the
    // wrong quest forever.
    definedRecords: defined
      .filter((r) => r.editorId && r.editorId !== "<none>")
      .map((r) => ({ formid: `${r.formid}:${r.definedIn}`, editorId: r.editorId })),
    truncated,
  };
}

// Probe many plugins over ONE long-lived houseCARL session.
//
// Absolute paths on purpose: read_plugin_file reads the file straight off disk, so no MO2
// instance is consulted and the shared, persisted instance pointer is never moved. That
// pointer is global to this machine and a switch here would silently change another
// workspace's next session.
export async function probePlugins(absPaths, options = {}) {
  const { cacheFile = null, noCache = false, onProgress = () => {} } = options;
  const cache = noCache ? new Map() : loadCache(cacheFile);
  const results = new Map();

  const todo = [];
  for (const p of absPaths) {
    let key;
    try {
      key = cacheKeyFor(p);
    } catch {
      results.set(p, { error: "file not readable", qustDefined: 0, editorIds: [] });
      continue;
    }
    const hit = cache.get(key);
    if (hit) results.set(p, { ...hit, cached: true });
    else todo.push({ p, key });
  }

  if (todo.length === 0) {
    return { results, probed: 0, cached: results.size, degraded: false };
  }

  // No usable server is a DEGRADED run, not a failure. The queue has to stay usable on a
  // machine without houseCARL; it just has to SAY so rather than quietly answering
  // names-only, because names alone are what produced the misclassifications this exists
  // to catch.
  //
  // Two ways it can be unusable, and both must degrade the same:
  //   - no candidate exe on disk (resolveHousecarlExe throws)
  //   - PDV_HOUSECARL_EXE points at something that will not run. That override is returned
  //     WITHOUT an existence check, so the failure only surfaces when the first call to the
  //     spawned process rejects.
  const degradeAll = (reason) => {
    for (const { p } of todo) {
      if (!results.has(p)) results.set(p, { unprobed: true, reason, qustDefined: null, editorIds: [] });
    }
    return { results, probed: 0, cached: results.size - todo.length, degraded: true, reason };
  };

  try {
    resolveHousecarlExe();
  } catch (error) {
    return degradeAll(error.message.split("\n")[0]);
  }

  const session = openHousecarl();
  let probed = 0;
  try {
    for (const { p, key } of todo) {
      let record;
      try {
        const raw = await session.call("housecarl_read_plugin_file", {
          plugin: p,
          type: "QUST",
          limit: ENUMERATE_LIMIT,
        });
        record = parseQustEnumeration(extractHousecarlText(raw), path.basename(p));
      } catch (error) {
        const message = String(error.message ?? error).split("\n")[0];
        // Nothing probed yet and the session is already failing: the server is unusable
        // rather than this one plugin being unreadable. Degrade instead of stamping the
        // same error onto all 748 rows.
        if (probed === 0) {
          session.close();
          return degradeAll(`houseCARL unusable: ${message}`);
        }
        record = { error: message, qustDefined: null, editorIds: [] };
      }
      results.set(p, record);
      if (!record.error) cache.set(key, record);
      probed += 1;
      onProgress(probed, todo.length, p);
    }
  } finally {
    session.close();
  }

  if (!noCache) saveCache(cacheFile, cache);
  return { results, probed, cached: results.size - probed, degraded: false };
}

// ---------------------------------------------------------------------------------------
// Phase 1b: stage/objective depth.
//
// DEPTH IS THE WHOLE GAME HERE, and the original helper had it wrong. At depth 1 houseCARL
// answers `Stages = [list: 0 item(s)] -- pass depth=2 to expand`: not the stages, and not
// even a correct COUNT. Anything built on it would have read every quest in the load order
// as empty and called that a finding. Measured 2026-08-09 against 0Kaidan.esp/K01:
//
//   depth 3  -> Stages[i].Index, Stages[i].Flags
//   depth 4  -> + LogEntries counts, Objectives[i].DisplayText
//   depth 5  -> + LogEntries[0].Entry -- the journal text, which is the point
//
// So DETAIL_DEPTH is 5, and text format is deliberate: format:"json" carries the same
// content at roughly twice the bytes, and we parse it ourselves either way.
const DETAIL_DEPTH = 5;

// Generous: a 40-stage quest with long journal entries runs past the default cut, and a
// SILENT truncation here would read as "that quest has no terminal stage".
const DETAIL_MAX_CHARS = 200_000;

export async function probeQuestStages(session, absPath, formidToken, options = {}) {
  const { depth = DETAIL_DEPTH, keepRaw = false } = options;
  const raw = await session.call("housecarl_read_plugin_file", {
    plugin: absPath,
    formid: formidToken,
    fields: ["Name", "Stages", "Objectives"],
    depth,
    max_chars: DETAIL_MAX_CHARS,
  });
  const text = extractHousecarlText(raw);
  const digest = parseQuestDetail(text, { formidToken, pluginBasename: path.basename(absPath) });
  if (keepRaw) digest.raw = text;
  return digest;
}

// Deprecated alias. Kept for one release so an existing caller does not silently keep
// receiving empty stage lists, but pointed at the correct depth.
export async function probeQuestDetail(session, absPath, formidToken) {
  const digest = await probeQuestStages(session, absPath, formidToken, { keepRaw: true });
  return digest.raw;
}

// Parse a depth-5 read into the digest a judge actually needs. Pure: no session, no I/O, so
// it can be exercised against a fixture string without houseCARL present.
//
// The fields dropped are dropped on purpose -- `Flags = 0`, `(null link)`, `(absent)`,
// empty Conditions and Objectives[i].Targets[*] are ~half the payload and carry nothing a
// judge uses. What survives is: which stages exist, which carry journal text, which carry
// only an objective, and which one completes the quest.
export function parseQuestDetail(text, { formidToken, pluginBasename } = {}) {
  const nameMatch = text.match(/^\s*Name = (.*)$/m);
  const rawName = nameMatch ? nameMatch[1].trim() : "";
  const editorMatch = text.match(/editorid=(\S+)/);

  const stagesByIdx = new Map();
  const ensure = (i) => {
    if (!stagesByIdx.has(i)) {
      stagesByIdx.set(i, { index: null, flags: [], hasFragment: false, log: [], objective: null });
    }
    return stagesByIdx.get(i);
  };

  for (const m of text.matchAll(/^\s*Stages\[(\d+)\]\.Index = (\d+)\s*$/gm)) {
    ensure(Number(m[1])).index = Number(m[2]);
  }
  for (const m of text.matchAll(/^\s*Stages\[(\d+)\]\.Flags = (.+)$/gm)) {
    const v = m[2].trim();
    if (v && v !== "0") ensure(Number(m[1])).flags = v.split(/\s*,\s*/).filter(Boolean);
  }
  // CompleteQuest lives on the LOG ENTRY, not on the stage. Reading it off Stages[i].Flags
  // finds nothing and every quest looks like it has no terminal.
  for (const m of text.matchAll(/^\s*Stages\[(\d+)\]\.LogEntries\[\d+\]\.Flags = (.+)$/gm)) {
    const v = m[2].trim();
    if (v && v !== "0") {
      const s = ensure(Number(m[1]));
      for (const f of v.split(/\s*,\s*/)) if (f && !s.flags.includes(f)) s.flags.push(f);
    }
  }
  for (const m of text.matchAll(/^\s*Stages\[(\d+)\]\.LogEntries\[\d+\]\.Entry = (.*)$/gm)) {
    const entry = m[2].trim();
    if (entry && entry !== "(absent)") ensure(Number(m[1])).log.push(entry);
  }
  for (const m of text.matchAll(/^\s*Stages\[(\d+)\]\.LogEntries\[\d+\]\.(SCHR|SCTX) = (.*)$/gm)) {
    if (m[3].trim() !== "(absent)") ensure(Number(m[1])).hasFragment = true;
  }

  // Objectives join to stages by Index, not by array position.
  const objectivesByIndex = new Map();
  const objIdx = new Map();
  for (const m of text.matchAll(/^\s*Objectives\[(\d+)\]\.Index = (\d+)\s*$/gm)) {
    objIdx.set(Number(m[1]), Number(m[2]));
  }
  for (const m of text.matchAll(/^\s*Objectives\[(\d+)\]\.DisplayText = (.*)$/gm)) {
    const t = m[2].trim();
    const at = objIdx.get(Number(m[1]));
    if (t && t !== "(absent)" && at != null) objectivesByIndex.set(at, t);
  }

  const stages = [...stagesByIdx.values()]
    .filter((s) => s.index != null)
    .sort((a, b) => a.index - b.index)
    .map((s) => {
      const objective = objectivesByIndex.get(s.index) ?? null;
      return {
        index: s.index,
        flags: s.flags,
        isStartUp: s.flags.includes("StartUpStage"),
        isComplete: s.flags.includes("CompleteQuest"),
        hasFragment: s.hasFragment,
        log: s.log,
        objective,
        // Decides RUNTIME-VERIFY mechanically instead of leaving it to a judge's mood.
        evidenceTier: s.log.length ? "A" : objective ? "B" : "C",
      };
    });

  const matchedObjectiveIndices = new Set(stages.map((s) => s.index));
  const unmatchedObjectives = [...objectivesByIndex.entries()]
    .filter(([at]) => !matchedObjectiveIndices.has(at))
    .map(([at, textValue]) => ({ atIndex: at, text: textValue }));

  const flaggedTerminals = stages.filter((s) => s.isComplete).map((s) => s.index);
  const loggedStageCount = stages.filter((s) => s.evidenceTier !== "C").length;

  // A quest with no journal text, no objectives and no Name is the JRLucienMapMarker /
  // KaiCompJorrvaskr family the ARR waves already ruled non-content. Classifying it here is
  // the single biggest saving in the pipeline: Lucien's 48 quests collapse to a handful
  // BEFORE any judging happens. It is evidence, not a verdict -- a human still rules.
  let structuralClass = "content";
  if (stages.length === 0) structuralClass = "empty";
  else if (loggedStageCount === 0 && !rawName) structuralClass = "framework";
  else if (loggedStageCount === 0) structuralClass = "framework";

  return {
    formid: formidToken ?? null,
    plugin: pluginBasename ?? null,
    editorId: editorMatch ? editorMatch[1] : null,
    name: rawName && rawName !== "(absent)" ? rawName : null,
    readStatus: "ok",
    error: null,
    structuralClass,
    stageCount: stages.length,
    loggedStageCount,
    // Falls back to the highest index when no stage carries CompleteQuest, and SAYS which it
    // did -- several shipped channels cite "terminal lacks CompleteQuest flag" by hand.
    terminalStages: flaggedTerminals.length ? flaggedTerminals : stages.length ? [stages[stages.length - 1].index] : [],
    terminalInferred: flaggedTerminals.length === 0 && stages.length > 0,
    truncated: /truncated: showing/.test(text),
    stages,
    unmatchedObjectives,
  };
}

// Bulk driver. Mirrors probePlugins' contract exactly, including its degrade rule: a server
// that is unusable degrades the whole run with ONE reason rather than stamping the same
// error onto every row.
export async function digestQuests(workList, options = {}) {
  const {
    cacheFile = null,
    noCache = false,
    flushEvery = 25,
    onProgress = () => {},
  } = options;
  const cache = noCache ? new Map() : loadCache(cacheFile);
  const digests = new Map();
  const failures = [];

  const todo = [];
  for (const item of workList) {
    let key;
    try {
      const st = fs.statSync(item.pluginPath);
      // The trailing schema token means a change to the digest SHAPE re-reads everything
      // without anyone having to remember to delete a cache file by hand.
      key = `${item.pluginPath}|${st.size}|${Math.floor(st.mtimeMs)}|${item.formid}|d5v1`;
    } catch {
      digests.set(item.workId, { ...item, readStatus: "error", error: "plugin not readable", stages: [] });
      failures.push({ ...item, error: "plugin not readable" });
      continue;
    }
    const hit = cache.get(key);
    if (hit) digests.set(item.workId, { ...hit, cached: true });
    else todo.push({ item, key });
  }

  if (todo.length === 0) {
    return { digests, read: 0, cached: digests.size, failed: failures.length, failures, degraded: false };
  }

  const degradeAll = (reason) => {
    for (const { item } of todo) {
      if (!digests.has(item.workId)) {
        digests.set(item.workId, { ...item, readStatus: "error", error: reason, stages: [] });
      }
    }
    return { digests, read: 0, cached: digests.size - todo.length, failed: todo.length, failures, degraded: true, reason };
  };

  try {
    resolveHousecarlExe();
  } catch (error) {
    return degradeAll(error.message.split("\n")[0]);
  }

  const session = openHousecarl();
  let read = 0;
  try {
    for (const { item, key } of todo) {
      let digest;
      try {
        digest = await probeQuestStages(session, item.pluginPath, item.formid);
        digest = { ...item, ...digest };
      } catch (error) {
        const message = String(error.message ?? error).split("\n")[0];
        if (read === 0) {
          session.close();
          return degradeAll(`houseCARL unusable: ${message}`);
        }
        digest = { ...item, readStatus: "error", error: message, stages: [] };
        failures.push({ ...item, error: message });
      }
      digests.set(item.workId, digest);
      // Errors are never cached, so a retry is a plain re-run with no flag.
      if (digest.readStatus === "ok") cache.set(key, digest);
      read += 1;
      // Flushed mid-run: a hard crash at quest 700 costs at most `flushEvery` reads, not 700.
      if (!noCache && read % flushEvery === 0) saveCache(cacheFile, cache);
      onProgress(read, todo.length, item);
    }
  } finally {
    session.close();
  }

  if (!noCache) saveCache(cacheFile, cache);
  return { digests, read, cached: digests.size - read, failed: failures.length, failures, degraded: false };
}
