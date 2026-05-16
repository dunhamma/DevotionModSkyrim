#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const TARGET_PLUGIN = "D:/Wabbajack/modlists/Anvil/mods/Devotion/PlayerDevotion_Framework.esp";
const REMOVE_MASTERS = new Set([
  "PDV_ManagerPatronWirePatch.esp".toLowerCase(),
  "PDV_MCMWirePatch.esp".toLowerCase(),
]);

function readSubrecords(buffer) {
  const subrecords = [];
  let offset = 0;

  while (offset < buffer.length) {
    if (offset + 6 > buffer.length) {
      throw new Error(`Truncated subrecord header at TES4 offset ${offset}.`);
    }

    const type = buffer.toString("ascii", offset, offset + 4);
    const size = buffer.readUInt16LE(offset + 4);
    const dataStart = offset + 6;
    const dataEnd = dataStart + size;

    if (dataEnd > buffer.length) {
      throw new Error(`Subrecord ${type} overruns TES4 payload at offset ${offset}.`);
    }

    subrecords.push({
      type,
      size,
      headerStart: offset,
      dataStart,
      dataEnd,
      bytes: buffer.subarray(offset, dataEnd),
      data: buffer.subarray(dataStart, dataEnd),
    });

    offset = dataEnd;
  }

  return subrecords;
}

function formatMasters(subrecords) {
  const masters = [];
  for (let i = 0; i < subrecords.length; i += 1) {
    const subrecord = subrecords[i];
    if (subrecord.type === "MAST") {
      masters.push(subrecord.data.toString("utf8").replace(/\0+$/, ""));
    }
  }
  return masters;
}

function main() {
  const pluginPath = path.resolve(TARGET_PLUGIN);
  const original = fs.readFileSync(pluginPath);

  if (original.toString("ascii", 0, 4) !== "TES4") {
    throw new Error("Target file does not begin with a TES4 record.");
  }

  const recordDataSize = original.readUInt32LE(4);
  const recordHeaderSize = 24;
  const recordDataStart = recordHeaderSize;
  const recordDataEnd = recordDataStart + recordDataSize;

  if (recordDataEnd > original.length) {
    throw new Error("TES4 record size exceeds file length.");
  }

  const recordHeader = Buffer.from(original.subarray(0, recordHeaderSize));
  const recordData = original.subarray(recordDataStart, recordDataEnd);
  const restOfFile = original.subarray(recordDataEnd);

  const subrecords = readSubrecords(recordData);
  const removedMasters = [];
  const keptChunks = [];

  for (let i = 0; i < subrecords.length; i += 1) {
    const subrecord = subrecords[i];
    if (subrecord.type !== "MAST") {
      keptChunks.push(subrecord.bytes);
      continue;
    }

    const masterName = subrecord.data.toString("utf8").replace(/\0+$/, "");
    const next = subrecords[i + 1];
    const remove = REMOVE_MASTERS.has(masterName.toLowerCase());

    if (remove) {
      removedMasters.push(masterName);
      if (next?.type === "DATA") {
        i += 1;
      }
      continue;
    }

    keptChunks.push(subrecord.bytes);
  }

  const newRecordData = Buffer.concat(keptChunks);
  recordHeader.writeUInt32LE(newRecordData.length, 4);

  const backupPath = `${pluginPath}.bak-${new Date().toISOString().replace(/[:.]/g, "-")}`;
  fs.writeFileSync(backupPath, original);
  fs.writeFileSync(pluginPath, Buffer.concat([recordHeader, newRecordData, restOfFile]));

  const rewritten = fs.readFileSync(pluginPath);
  const rewrittenDataSize = rewritten.readUInt32LE(4);
  const rewrittenSubrecords = readSubrecords(rewritten.subarray(recordDataStart, recordDataStart + rewrittenDataSize));

  const beforeMasters = formatMasters(subrecords);
  const afterMasters = formatMasters(rewrittenSubrecords);

  console.log(JSON.stringify({
    pluginPath,
    backupPath,
    removedMasters,
    beforeMasters,
    afterMasters,
  }, null, 2));
}

main();
