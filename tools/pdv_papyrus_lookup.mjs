#!/usr/bin/env node
import process from "node:process";

import { assertKnownFlags } from "./lib/pdv_cli.mjs";

// The flags this file reads, plus any the repo documents for it. Documented-but-unread
// flags are included deliberately: rejecting one would break a published command, and a
// guard is the wrong place to discover that the doc and the code disagree.
const KNOWN_FLAGS = new Set(["--function", "--game", "--help", "--json", "--max-scripts", "--query", "--scan-concurrency", "--script"]);
assertKnownFlags(process.argv.slice(2), KNOWN_FLAGS, { toolName: "pdv_papyrus_lookup" });

const DEFAULT_GAME = "skyrimse";
const DEFAULT_MAX_SCRIPTS = 8;
const DEFAULT_SCAN_CONCURRENCY = 12;
const SITE_ROOT = "https://papyrus.bellcube.dev";

async function main(argv) {
  const options = parseArgs(argv);
  if (options.help) {
    printUsage(0);
  }

  const query = options.query || buildQueryFromParts(options.script, options.fn);
  if (!query && !options.script) {
    printUsage(1, "Provide --query, --script, or --function.");
  }

  const game = options.game || DEFAULT_GAME;
  const searchUrl = `${SITE_ROOT}/${game}/?query=${encodeURIComponent(query || options.script)}`;
  const result = {
    ok: true,
    game,
    query: query || null,
    script: options.script || null,
    function: options.fn || null,
    searchUrl,
    scriptUrl: null,
    functionUrl: null,
    functionMatches: [],
    scriptCandidates: [],
    notes: [],
  };

  try {
    if (options.script) {
      const scriptInfo = await loadScriptInfo(game, options.script);
      if (scriptInfo.ok) {
        result.scriptUrl = scriptInfo.url;
        result.scriptCandidates.push({ name: scriptInfo.scriptName, url: scriptInfo.url, exact: true });
        if (options.fn) {
          const functionMatch = scriptInfo.functions.find((item) => item.slug === slugify(options.fn));
          if (functionMatch) {
            result.functionUrl = functionMatch.url;
            result.functionMatches.push(functionMatch);
          } else {
            result.notes.push(`No exact function match for ${options.fn} on script ${scriptInfo.scriptName}.`);
          }
        }
      } else {
        result.notes.push(scriptInfo.note);
      }
    }

    if (!options.script || (!result.functionUrl && options.fn) || (!options.script && query)) {
      const searchInfo = await searchBellCube(game, query || options.script, options.maxScripts);
      result.scriptCandidates.push(...mergeCandidates(result.scriptCandidates, searchInfo.scriptCandidates));
      if (searchInfo.notes.length) {
        result.notes.push(...searchInfo.notes);
      }

      if (!result.functionUrl && options.fn) {
        const matched = await findFunctionAcrossScripts(
          game,
          options.fn,
          result.scriptCandidates,
          options.script ? options.maxScripts : result.scriptCandidates.length,
          options.scanConcurrency,
        );
        result.functionMatches.push(...mergeFunctionMatches(result.functionMatches, matched.matches));
        if (matched.matches.length === 1) {
          result.functionUrl = matched.matches[0].url;
        } else if (matched.matches.length > 1) {
          result.notes.push(`Multiple exact function matches were found for ${options.fn}. Specify --script to disambiguate.`);
        }
        if (matched.notes.length) {
          result.notes.push(...matched.notes);
        }
      } else if (!result.functionUrl && query && !options.script) {
        const matched = await findFunctionAcrossScripts(
          game,
          query,
          result.scriptCandidates,
          result.scriptCandidates.length,
          options.scanConcurrency,
        );
        result.functionMatches.push(...mergeFunctionMatches(result.functionMatches, matched.matches));
        if (matched.matches.length === 1) {
          result.functionUrl = matched.matches[0].url;
        } else if (matched.matches.length > 1) {
          result.notes.push(`Multiple exact function matches were found for ${query}. Specify --script to disambiguate.`);
        }
      }
    }
  } catch (error) {
    result.ok = false;
    result.notes.push(error.message || String(error));
  }

  if (options.json) {
    process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
    return;
  }

  printText(result);
}

async function searchBellCube(game, query, maxScripts = DEFAULT_MAX_SCRIPTS) {
  const url = `${SITE_ROOT}/${game}/?query=${encodeURIComponent(query)}`;
  const html = await fetchText(url);
  const candidates = extractSearchCandidates(html, game, query);
  const notes = [];
  if (!candidates.length) {
    notes.push(`No script candidates were found on ${url}.`);
  }
  return {
    scriptCandidates: candidates,
    notes,
  };
}

async function loadScriptInfo(game, scriptName) {
  const slug = slugify(scriptName);
  const url = `${SITE_ROOT}/${game}/script/${slug}/`;
  const response = await fetch(url);
  if (!response.ok) {
    return {
      ok: false,
      note: `Script page ${url} returned HTTP ${response.status}.`,
    };
  }

  const html = await response.text();
  const title = extractTitle(html) || scriptName;
  const functions = extractFunctionLinks(html, game, slug);
  return {
    ok: true,
    url,
    scriptName: title.replace(/\s+\|\s+.*$/, ""),
    functions,
  };
}

async function findFunctionAcrossScripts(
  game,
  functionName,
  candidates,
  maxScripts = DEFAULT_MAX_SCRIPTS,
  scanConcurrency = DEFAULT_SCAN_CONCURRENCY,
) {
  const targetSlug = slugify(functionName);
  const limited = candidates.slice(0, maxScripts);
  const matches = [];
  const notes = [];
  const batches = chunk(limited, Math.max(1, scanConcurrency));

  for (const batch of batches) {
    const inspected = await Promise.all(batch.map(async (candidate) => {
      try {
        const scriptInfo = await loadScriptInfo(game, candidate.name);
        if (!scriptInfo.ok) {
          return null;
        }
        const hit = scriptInfo.functions.find((item) => item.slug === targetSlug);
        return hit || null;
      } catch (error) {
        notes.push(`Failed to inspect ${candidate.name}: ${error.message || String(error)}`);
        return null;
      }
    }));

    for (const hit of inspected) {
      if (hit) {
        matches.push(hit);
      }
    }

    if (matches.length >= 5) {
      break;
    }
  }

  if (!matches.length) {
    notes.push(`No exact BellCube function page match found for ${functionName} in the top ${limited.length} script candidates.`);
  }

  return { matches, notes };
}

function extractSearchCandidates(html, game, query) {
  const seen = new Set();
  const matches = [...html.matchAll(new RegExp(`href="/${game}/script/([^"/?#]+)/"`, "gi"))];
  const entries = [];
  const querySlug = slugify(query);

  for (const match of matches) {
    const slug = match[1];
    const name = slug;
    const url = `${SITE_ROOT}/${game}/script/${slug}/`;
    const key = url.toLowerCase();
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    entries.push({
      name,
      url,
      exact: slug === querySlug,
      score: scoreCandidate(slug, querySlug),
    });
  }

  return entries.sort((left, right) => right.score - left.score || left.name.localeCompare(right.name));
}

function extractFunctionLinks(html, game, scriptSlug) {
  const pattern = new RegExp(`href="/${game}/script/${scriptSlug}/function/([^"/?#]+)/"`, "gi");
  const matches = [...html.matchAll(pattern)];
  const unique = new Map();
  for (const match of matches) {
    const slug = match[1];
    const url = `${SITE_ROOT}/${game}/script/${scriptSlug}/function/${slug}/`;
    unique.set(url.toLowerCase(), {
      name: slug,
      slug,
      url,
      script: scriptSlug,
    });
  }
  return [...unique.values()];
}

function extractTitle(html) {
  const match = html.match(/<title>([^<]+)<\/title>/i);
  return match ? decodeHtml(match[1]) : null;
}

function decodeHtml(value) {
  return String(value)
    .replace(/&#x27;/g, "'")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, "\"")
    .replace(/&#39;/g, "'")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">");
}

function scoreCandidate(slug, querySlug) {
  if (slug === querySlug) {
    return 100;
  }
  if (slug.includes(querySlug)) {
    return 50;
  }
  if (querySlug.includes(slug)) {
    return 25;
  }
  return 0;
}

function slugify(value) {
  return String(value || "")
    .trim()
    .toLowerCase()
    .replace(/\s+/g, "")
    .replace(/['".:()\-]/g, "");
}

function buildQueryFromParts(scriptName, functionName) {
  if (scriptName && functionName) {
    return `${scriptName} ${functionName}`;
  }
  return functionName || scriptName || "";
}

function mergeCandidates(existing, incoming) {
  const seen = new Set(existing.map((item) => item.url.toLowerCase()));
  const merged = [];
  for (const item of incoming) {
    const key = item.url.toLowerCase();
    if (!seen.has(key)) {
      seen.add(key);
      merged.push(item);
    }
  }
  return merged;
}

function mergeFunctionMatches(existing, incoming) {
  const seen = new Set(existing.map((item) => item.url.toLowerCase()));
  const merged = [];
  for (const item of incoming) {
    const key = item.url.toLowerCase();
    if (!seen.has(key)) {
      seen.add(key);
      merged.push(item);
    }
  }
  return merged;
}

function chunk(values, size) {
  const chunks = [];
  for (let index = 0; index < values.length; index += size) {
    chunks.push(values.slice(index, index + size));
  }
  return chunks;
}

async function fetchText(url) {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Fetch failed for ${url}: HTTP ${response.status}`);
  }
  return response.text();
}

function printText(result) {
  const lines = [];
  lines.push(`BellCube lookup: ${result.query || result.script || "(none)"}`);
  lines.push(`Game: ${result.game}`);
  lines.push(`Search: ${result.searchUrl}`);

  if (result.scriptUrl) {
    lines.push(`Script: ${result.scriptUrl}`);
  }
  if (result.functionUrl) {
    lines.push(`Function: ${result.functionUrl}`);
  }

  if (result.functionMatches.length) {
    lines.push("");
    lines.push("Function matches:");
    for (const item of result.functionMatches.slice(0, 10)) {
      lines.push(`- ${item.script}.${item.name} -> ${item.url}`);
    }
  }

  if (result.scriptCandidates.length) {
    lines.push("");
    lines.push("Script candidates:");
    for (const item of result.scriptCandidates.slice(0, 10)) {
      lines.push(`- ${item.name} -> ${item.url}`);
    }
  }

  if (result.notes.length) {
    lines.push("");
    lines.push("Notes:");
    for (const note of result.notes) {
      lines.push(`- ${note}`);
    }
  }

  process.stdout.write(`${lines.join("\n")}\n`);
}

function parseArgs(argv) {
  const options = {
    game: DEFAULT_GAME,
    query: "",
    script: "",
    fn: "",
    maxScripts: DEFAULT_MAX_SCRIPTS,
    scanConcurrency: DEFAULT_SCAN_CONCURRENCY,
    json: false,
    help: false,
  };

  const positional = [];
  for (let index = 0; index < argv.length; index += 1) {
    const arg = argv[index];
    if (arg === "--json") {
      options.json = true;
    } else if (arg === "--help" || arg === "-h") {
      options.help = true;
    } else if (arg === "--query") {
      options.query = requireNext(argv, ++index, "--query");
    } else if (arg.startsWith("--query=")) {
      options.query = arg.slice("--query=".length);
    } else if (arg === "--script") {
      options.script = requireNext(argv, ++index, "--script");
    } else if (arg.startsWith("--script=")) {
      options.script = arg.slice("--script=".length);
    } else if (arg === "--function") {
      options.fn = requireNext(argv, ++index, "--function");
    } else if (arg.startsWith("--function=")) {
      options.fn = arg.slice("--function=".length);
    } else if (arg === "--game") {
      options.game = requireNext(argv, ++index, "--game");
    } else if (arg.startsWith("--game=")) {
      options.game = arg.slice("--game=".length);
    } else if (arg === "--max-scripts") {
      options.maxScripts = Number.parseInt(requireNext(argv, ++index, "--max-scripts"), 10) || DEFAULT_MAX_SCRIPTS;
    } else if (arg.startsWith("--max-scripts=")) {
      options.maxScripts = Number.parseInt(arg.slice("--max-scripts=".length), 10) || DEFAULT_MAX_SCRIPTS;
    } else if (arg === "--scan-concurrency") {
      options.scanConcurrency = Number.parseInt(requireNext(argv, ++index, "--scan-concurrency"), 10) || DEFAULT_SCAN_CONCURRENCY;
    } else if (arg.startsWith("--scan-concurrency=")) {
      options.scanConcurrency = Number.parseInt(arg.slice("--scan-concurrency=".length), 10) || DEFAULT_SCAN_CONCURRENCY;
    } else if (arg.startsWith("-")) {
      printUsage(1, `Unknown option: ${arg}`);
    } else {
      positional.push(arg);
    }
  }

  if (!options.query && positional.length) {
    options.query = positional.join(" ");
  }

  return options;
}

function requireNext(argv, index, optionName) {
  if (!argv[index]) {
    printUsage(1, `${optionName} requires a value.`);
  }
  return argv[index];
}

function printUsage(exitCode, message = "") {
  if (message) {
    process.stderr.write(`${message}\n`);
  }
  process.stdout.write(
    "Usage:\n" +
    "  node .\\tools\\pdv_papyrus_lookup.mjs --query PushString\n" +
    "  node .\\tools\\pdv_papyrus_lookup.mjs --script PapyrusUtil --function PushString\n" +
    "  node .\\tools\\pdv_papyrus_lookup.mjs --script StringUtil\n" +
    "  node .\\tools\\pdv_papyrus_lookup.mjs PushString --json\n"
  );
  process.exit(exitCode);
}

await main(process.argv.slice(2));
