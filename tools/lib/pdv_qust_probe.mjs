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
// Stage/objective depth is NOT probed in bulk on purpose. read_plugin_file can enumerate a
// type cheaply but only returns fields for ONE record at a time, so stage depth would cost
// a call per quest - thousands across three modlists. That belongs in the Phase 1b
// shortlist read, and `probeQuestDetail` below is here for exactly that.

import fs from "node:fs";
import path from "node:path";
import { openHousecarl, extractHousecarlText, resolveHousecarlExe } from "./pdv_housecarl_stdio.mjs";

// A plugin can legitimately define hundreds of quests; Lucien has 48 and Val Serano 66.
// Cap high enough that "showing first N" never truncates a real answer silently.
const ENUMERATE_LIMIT = 2000;

export function cacheKeyFor(absPath) {
  const st = fs.statSync(absPath);
  return `${absPath}|${st.size}|${Math.floor(st.mtimeMs)}`;
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

// Phase 1b helper: stage/objective depth for ONE quest. Deliberately not called in bulk.
export async function probeQuestDetail(session, absPath, formidToken) {
  const raw = await session.call("housecarl_read_plugin_file", {
    plugin: absPath,
    formid: formidToken,
    fields: ["Stages", "Objectives", "Name"],
    depth: 1,
  });
  return extractHousecarlText(raw);
}
