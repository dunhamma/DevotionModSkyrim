import fs from "node:fs";
import path from "node:path";
import { UnsupportedFormatError, ValidationError } from "./errors.mjs";

export function readDocument(filePath) {
  const absolutePath = path.resolve(filePath);
  const ext = path.extname(absolutePath).toLowerCase();
  const raw = fs.readFileSync(absolutePath, "utf8");

  if (ext === ".json" || ext === "") {
    try {
      return {
        path: absolutePath,
        document: JSON.parse(raw)
      };
    } catch (error) {
      throw new ValidationError(`Invalid JSON in ${absolutePath}: ${error.message}`, {
        filePath: absolutePath
      });
    }
  }

  if (ext === ".yaml" || ext === ".yml") {
    throw new UnsupportedFormatError(
      "YAML manifests are reserved by the schema, but this no-dependency v1 CLI currently loads JSON only.",
      { filePath: absolutePath }
    );
  }

  throw new UnsupportedFormatError(`Unsupported document extension: ${ext}`, {
    filePath: absolutePath
  });
}

export function writeJson(filePath, value) {
  const absolutePath = path.resolve(filePath);
  fs.mkdirSync(path.dirname(absolutePath), { recursive: true });
  fs.writeFileSync(absolutePath, `${JSON.stringify(value, null, 2)}\n`, "utf8");
  return absolutePath;
}

export function maybeWriteJson(filePath, value) {
  if (!filePath || filePath === "-") {
    return null;
  }
  return writeJson(filePath, value);
}
