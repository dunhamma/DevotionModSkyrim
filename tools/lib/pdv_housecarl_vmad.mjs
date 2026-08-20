import { callHousecarl, extractHousecarlText } from "./pdv_housecarl_stdio.mjs";

function escapeRegExp(value) {
  return String(value).replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function parsePropertyEntries(text, prefix, entries) {
  const escaped = escapeRegExp(prefix);
  const summary = new RegExp(`^\\s*${escaped}\\[(\\d+)\\]\\s*=\\s*\\[[^\\]]+\\]\\s+Name=(\\S+)`, "i");
  const field = new RegExp(`^\\s*${escaped}\\[(\\d+)\\]\\.(Name|Object|Data)\\s*=\\s*(.*)$`, "i");
  for (const line of String(text).split(/\r?\n/)) {
    let match = line.match(summary);
    if (match) {
      const index = Number(match[1]);
      const entry = entries.get(index) ?? { index };
      entry.name = match[2];
      entries.set(index, entry);
      continue;
    }
    match = line.match(field);
    if (!match) continue;
    const index = Number(match[1]);
    const entry = entries.get(index) ?? { index };
    const key = match[2].toLowerCase();
    entry[key] = match[3].trim();
    entries.set(index, entry);
  }
}

export async function readVmadScriptProperties({
  formid,
  scriptIndex = 0,
  chunkSize = 100,
  timeoutMs = 90_000,
}) {
  const prefix = `VirtualMachineAdapter.Scripts[${scriptIndex}].Properties`;
  const shape = await callHousecarl("housecarl_read_record", {
    formid,
    fields: [prefix],
    depth: 1,
    max_chars: 20_000,
  }, { timeoutMs });
  const shapeText = extractHousecarlText(shape);
  const escaped = escapeRegExp(prefix);
  const countMatch = shapeText.match(new RegExp(`${escaped}\\s*=\\s*\\[[^\\]]*?([0-9]+)\\s+item\\(s\\)\\]`, "i"));
  if (!countMatch) throw new Error(`Could not derive ${prefix} count for ${formid}.`);
  const count = Number(countMatch[1]);
  const entries = new Map();
  for (let start = 0; start < count; start += chunkSize) {
    const end = Math.min(count, start + chunkSize);
    const result = await callHousecarl("housecarl_batch_record_detail", {
      formids: [formid],
      fields: Array.from({ length: end - start }, (_, offset) => `${prefix}[${start + offset}]`),
      depth: 3,
      max_chars: 200_000,
    }, { timeoutMs });
    parsePropertyEntries(extractHousecarlText(result), prefix, entries);
  }
  if (entries.size !== count) {
    throw new Error(`Parsed ${entries.size}/${count} ${prefix} entries for ${formid}; refusing partial VMAD evidence.`);
  }
  const properties = new Map();
  const duplicates = new Map();
  const firstByKey = new Map();
  for (const entry of [...entries.values()].sort((a, b) => a.index - b.index)) {
    if (!entry.name) throw new Error(`${formid} ${prefix}[${entry.index}] has no property name.`);
    const key = entry.name.toLowerCase();
    const first = firstByKey.get(key);
    if (first) {
      const indices = duplicates.get(first.name) ?? [first.index];
      indices.push(entry.index);
      duplicates.set(first.name, indices);
    } else {
      firstByKey.set(key, entry);
    }
    properties.set(entry.name, entry);
  }
  return {
    count,
    entries: [...entries.values()].sort((a, b) => a.index - b.index),
    properties: new Map([...properties].map(([name, entry]) => [name, entry.object ?? entry.data ?? null])),
    duplicates,
  };
}
