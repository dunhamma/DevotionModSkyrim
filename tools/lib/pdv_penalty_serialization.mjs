export function parseRecordBlocks(source) {
  const text = String(source ?? "");
  const headers = [...text.matchAll(/^type=(\S+)\s+formid=(\S+)\s+editorid=(\S+)\s+winner=/gm)];
  return headers.map((match, index) => {
    const start = match.index;
    const end = headers[index + 1]?.index ?? text.length;
    const body = text.slice(start, end);
    const fields = new Map();
    for (const fieldMatch of body.matchAll(/^\s{2}(.+?)\s*=\s*(.*?)\r?$/gm)) {
      fields.set(fieldMatch[1].trim(), fieldMatch[2].trim());
    }
    return {
      type: match[1],
      formId: match[2],
      editorId: match[3],
      fields,
      body,
    };
  });
}

export function parseFlags(value) {
  return String(value ?? "")
    .split(",")
    .map((flag) => flag.trim())
    .filter((flag) => flag && flag.toLowerCase() !== "none");
}

export function classifyPenaltyPair({ magnitude, flags }) {
  const numericMagnitude = Number(magnitude);
  const normalizedFlags = new Set([...flags].map((flag) => String(flag).toLowerCase()));
  const recover = normalizedFlags.has("recover");
  const detrimental = normalizedFlags.has("detrimental");

  if (!Number.isFinite(numericMagnitude)) {
    return { status: "FAIL", code: "INVALID_MAGNITUDE", encoding: "invalid" };
  }
  if (numericMagnitude === 0) {
    return { status: "FAIL", code: "ZERO_MAGNITUDE", encoding: "invalid" };
  }
  if (!recover) {
    return { status: "FAIL", code: "MISSING_RECOVER", encoding: "non-reverting" };
  }
  if (numericMagnitude < 0 && detrimental) {
    return { status: "FAIL", code: "DOUBLE_NEGATIVE", encoding: "negative+detrimental" };
  }
  if (numericMagnitude > 0 && !detrimental) {
    return { status: "FAIL", code: "POSITIVE_BUFF", encoding: "positive+non-detrimental" };
  }
  return {
    status: "PASS",
    code: "VALID",
    encoding: detrimental ? "positive+detrimental" : "negative+non-detrimental",
  };
}

export function extractSpellEffectPairs(spellBlock) {
  const pairs = [];
  for (const [key, baseEffect] of spellBlock.fields) {
    const match = key.match(/^Effects\[(\d+)\]\.BaseEffect$/);
    if (!match) continue;
    const index = Number(match[1]);
    pairs.push({
      index,
      baseEffect,
      magnitude: spellBlock.fields.get(`Effects[${index}].Data.Magnitude`) ?? "missing",
    });
  }
  return pairs.sort((left, right) => left.index - right.index);
}
