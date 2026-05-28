import fs from "node:fs";
import path from "node:path";

const RECORD_HEADER_SIZE = 24;
const GROUP_HEADER_SIZE = 24;
const COMPRESSED_RECORD_FLAG = 0x00040000;

export function canApplyExistingMessagePayloadPatch(patchRequest = {}, existingPath = "") {
  const outputName = safeOutputName(patchRequest.output_name);
  if (!outputName || !existingPath) {
    return false;
  }
  if (!samePluginName(path.basename(existingPath), outputName)) {
    return false;
  }
  const records = Array.isArray(patchRequest.records) ? patchRequest.records : [];
  return records.length > 0 && records.every(isMessagePayloadRecord);
}

export function applyExistingMessagePayloadPatch(patchRequest = {}, options = {}) {
  const existingPath = path.resolve(options.existingPath || "");
  const outputName = safeOutputName(patchRequest.output_name);
  if (!outputName) {
    return blocked("Patch output_name must be a simple plugin filename.");
  }
  if (!samePluginName(path.basename(existingPath), outputName)) {
    return blocked("Existing plugin path does not match patch output_name.", { existingPath, outputName });
  }
  if (!canApplyExistingMessagePayloadPatch(patchRequest, existingPath)) {
    return blocked("Existing-plugin writer only supports MESG set_message_payload records.");
  }
  if (!fs.existsSync(existingPath)) {
    return {
      status: "FAIL",
      message: "Existing generated plugin was not found.",
      existingPath
    };
  }

  const backupRoot = path.resolve(options.backupRoot || path.join(process.cwd(), "generated", "payload-writer-backups"));
  fs.mkdirSync(backupRoot, { recursive: true });
  const backupPath = path.join(backupRoot, `${outputName}.${timestampForPath(new Date())}.bak`);
  fs.copyFileSync(existingPath, backupPath, fs.constants.COPYFILE_EXCL);

  try {
    const original = fs.readFileSync(existingPath);
    let current = Buffer.from(original);
    const touchedRecords = [];
    for (const record of patchRequest.records) {
      const target = parseFormIdTarget(record.formid);
      if (!target || !samePluginName(target.plugin, outputName)) {
        return blocked("MESG payload record formid must target the generated output plugin.", {
          formid: record.formid,
          outputName,
          backupPath
        });
      }
      const rewrite = rewriteMessagePayloadRecord(current, {
        localFormId: target.localFormId,
        payload: record.set_message_payload
      });
      if (!rewrite.changed) {
        return blocked("Target MESG record was not found in the generated plugin.", {
          formid: record.formid,
          outputName,
          backupPath
        });
      }
      current = rewrite.buffer;
      touchedRecords.push(rewrite.record);
    }

    fs.writeFileSync(existingPath, current);
    return {
      status: "PASS",
      message: "Existing generated MESG payload patch completed.",
      output_name: outputName,
      output_path: existingPath,
      backup_path: backupPath,
      touchedRecords
    };
  } catch (error) {
    return {
      status: "FAIL",
      message: "Existing generated MESG payload patch failed.",
      output_name: outputName,
      output_path: existingPath,
      backup_path: backupPath,
      error: {
        name: error?.name || "Error",
        message: error?.message || String(error)
      }
    };
  }
}

export function rewriteMessageRecordPayload(recordPayload, messagePayload = {}) {
  const subrecords = parseSubrecords(recordPayload);
  const title = messagePayload.title;
  const text = messagePayload.text;
  const buttons = Array.isArray(messagePayload.buttons) ? messagePayload.buttons : null;
  const output = [];
  let insertedTitle = false;
  let insertedText = false;
  let insertedButtons = false;

  for (const subrecord of subrecords) {
    if (subrecord.type === "FULL") {
      if (title !== undefined && !insertedTitle) {
        output.push(makeStringSubrecord("FULL", title));
        insertedTitle = true;
      } else if (title === undefined) {
        output.push(subrecord.raw);
      }
      continue;
    }
    if (subrecord.type === "DESC") {
      if (text !== undefined && !insertedText) {
        output.push(makeStringSubrecord("DESC", text));
        insertedText = true;
      } else if (text === undefined) {
        output.push(subrecord.raw);
      }
      continue;
    }
    if (subrecord.type === "ITXT") {
      if (buttons === null) {
        output.push(subrecord.raw);
      }
      continue;
    }

    output.push(subrecord.raw);

    if (subrecord.type === "EDID") {
      if (title !== undefined && !insertedTitle) {
        output.push(makeStringSubrecord("FULL", title));
        insertedTitle = true;
      }
      if (text !== undefined && !insertedText) {
        output.push(makeStringSubrecord("DESC", text));
        insertedText = true;
      }
    }

    if (subrecord.type === "DNAM" && buttons !== null && !insertedButtons) {
      output.push(...buttons.map((button) => makeStringSubrecord("ITXT", button?.text ?? button?.Text ?? button)));
      insertedButtons = true;
    }
  }

  if (title !== undefined && !insertedTitle) {
    output.push(makeStringSubrecord("FULL", title));
  }
  if (text !== undefined && !insertedText) {
    output.push(makeStringSubrecord("DESC", text));
  }
  if (buttons !== null && !insertedButtons) {
    output.push(...buttons.map((button) => makeStringSubrecord("ITXT", button?.text ?? button?.Text ?? button)));
  }

  return Buffer.concat(output);
}

function rewriteMessagePayloadRecord(buffer, options) {
  return rewriteContainer(buffer, 0, buffer.length, options);
}

function rewriteContainer(buffer, start, end, options) {
  let offset = start;
  const chunks = [];
  let changed = false;
  let matchedRecord = null;

  while (offset < end) {
    const type = readAscii(buffer, offset, 4);
    if (type === "GRUP") {
      const size = buffer.readUInt32LE(offset + 4);
      const groupEnd = offset + size;
      if (size < GROUP_HEADER_SIZE || groupEnd > end) {
        throw new Error(`Invalid GRUP size at ${offset}.`);
      }
      const child = rewriteContainer(buffer, offset + GROUP_HEADER_SIZE, groupEnd, options);
      if (child.changed) {
        const header = Buffer.from(buffer.subarray(offset, offset + GROUP_HEADER_SIZE));
        header.writeUInt32LE(GROUP_HEADER_SIZE + child.buffer.length, 4);
        chunks.push(header, child.buffer);
        changed = true;
        matchedRecord = child.record;
      } else {
        chunks.push(buffer.subarray(offset, groupEnd));
      }
      offset = groupEnd;
      continue;
    }

    const size = buffer.readUInt32LE(offset + 4);
    const recordEnd = offset + RECORD_HEADER_SIZE + size;
    if (recordEnd > end) {
      throw new Error(`Invalid ${type} record size at ${offset}.`);
    }
    if (type === "MESG" && (buffer.readUInt32LE(offset + 12) & 0x00ffffff) === options.localFormId) {
      const flags = buffer.readUInt32LE(offset + 8);
      if ((flags & COMPRESSED_RECORD_FLAG) !== 0) {
        throw new Error("Compressed MESG records are not supported by the proof-scoped payload writer.");
      }
      const payload = rewriteMessageRecordPayload(buffer.subarray(offset + RECORD_HEADER_SIZE, recordEnd), options.payload);
      const header = Buffer.from(buffer.subarray(offset, offset + RECORD_HEADER_SIZE));
      header.writeUInt32LE(payload.length, 4);
      chunks.push(header, payload);
      changed = true;
      matchedRecord = {
        recordType: type,
        formId: `0x${buffer.readUInt32LE(offset + 12).toString(16).padStart(8, "0")}`,
        localFormId: `0x${options.localFormId.toString(16).padStart(6, "0")}`,
        previousSize: size,
        newSize: payload.length
      };
    } else {
      chunks.push(buffer.subarray(offset, recordEnd));
    }
    offset = recordEnd;
  }

  if (offset !== end) {
    throw new Error(`Container parse ended at ${offset}, expected ${end}.`);
  }
  return {
    changed,
    record: matchedRecord,
    buffer: changed ? Buffer.concat(chunks) : buffer.subarray(start, end)
  };
}

function parseSubrecords(payload) {
  const result = [];
  let offset = 0;
  while (offset < payload.length) {
    const type = readAscii(payload, offset, 4);
    const size = payload.readUInt16LE(offset + 4);
    const end = offset + 6 + size;
    if (end > payload.length) {
      throw new Error(`Invalid ${type} subrecord size at ${offset}.`);
    }
    result.push({
      type,
      data: payload.subarray(offset + 6, end),
      raw: payload.subarray(offset, end)
    });
    offset = end;
  }
  return result;
}

function makeStringSubrecord(type, value) {
  const text = Buffer.from(`${value ?? ""}\0`, "utf8");
  if (text.length > 0xffff) {
    throw new Error(`${type} payload exceeds proof-scoped writer limit.`);
  }
  const header = Buffer.alloc(6);
  header.write(type, 0, 4, "ascii");
  header.writeUInt16LE(text.length, 4);
  return Buffer.concat([header, text]);
}

function parseFormIdTarget(value) {
  if (typeof value !== "string") {
    return null;
  }
  const match = /^([^:]+):([0-9a-fA-F]{1,8})$/.exec(value.trim());
  if (!match) {
    return null;
  }
  const raw = Number.parseInt(match[2], 16);
  if (!Number.isFinite(raw)) {
    return null;
  }
  return {
    plugin: match[1],
    localFormId: raw & 0x00ffffff
  };
}

function isMessagePayloadRecord(record) {
  if (!record || record.op !== "override" || typeof record.formid !== "string") {
    return false;
  }
  const allowed = new Set(["op", "formid", "set_message_payload"]);
  if (Object.keys(record).some((key) => !allowed.has(key))) {
    return false;
  }
  return record.set_message_payload && typeof record.set_message_payload === "object" && !Array.isArray(record.set_message_payload);
}

function safeOutputName(value) {
  if (typeof value !== "string" || !value.trim()) {
    return null;
  }
  const name = value.trim();
  if (name.includes("/") || name.includes("\\") || path.basename(name) !== name) {
    return null;
  }
  if (!/\.esp$/i.test(name)) {
    return null;
  }
  return name;
}

function samePluginName(left, right) {
  return String(left || "").toLowerCase() === String(right || "").toLowerCase();
}

function blocked(message, extra = {}) {
  return {
    status: "UNSAFE_BLOCKED",
    message,
    ...extra
  };
}

function readAscii(buffer, offset, length) {
  return buffer.subarray(offset, offset + length).toString("ascii");
}

function timestampForPath(date) {
  return date.toISOString().replace(/[:.]/g, "-");
}
