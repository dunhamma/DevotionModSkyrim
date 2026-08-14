import crypto from "node:crypto";
import path from "node:path";

const normalize = (value) => String(value).replaceAll("\\", "/").replace(/^\.\//, "");
const digest = (bytes) => crypto.createHash("sha256").update(bytes).digest("hex");
const bytesOf = (value) => Buffer.isBuffer(value) ? value : Buffer.from(String(value), "utf8");

function xmlEscape(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

export function adapterSources(manifest) {
  return manifest.sources.filter((source) => source.delivery !== "data-only");
}

export function validatePackageContract(manifest, { assetExists = () => true } = {}) {
  const contract = manifest.packageContract;
  if (manifest.packageAssetValidation !== "generated-tree-exact-five-adapters") {
    throw new Error("Compatibility manifest has not crossed the Slice 1D-B package boundary.");
  }
  if (contract?.schema !== "pdv.quest-reaction.package.v3" || contract.version !== 1) {
    throw new Error("Quest Reaction package contract schema/version is invalid.");
  }
  for (const key of ["outputRoot", "receiptOutput", "requiredCatalogSource", "requiredCatalogDestination", "adapterDirectory", "moduleName", "packageVersion"]) {
    if (!contract[key]) throw new Error(`Quest Reaction package contract is missing ${key}.`);
  }
  if (contract.adapterOptionCount !== 5 || contract.dataOnlyOptionCount !== 0) {
    throw new Error("Quest Reaction package contract must expose five adapter options and zero data-only options.");
  }
  const dataOnly = manifest.sources.filter((source) => source.delivery === "data-only");
  const adapters = adapterSources(manifest);
  if (dataOnly.length !== 75 || adapters.length !== 5) {
    throw new Error(`Package inventory must be 75 data-only plus 5 adapters; found ${dataOnly.length}/${adapters.length}.`);
  }
  for (const source of dataOnly) {
    if (source.package?.assets?.length) throw new Error(`Data-only source ${source.sourceId} must not own installer assets.`);
  }
  const dependencies = new Set();
  const destinations = new Set();
  for (const source of adapters) {
    if (!source.package?.dependency || !source.package?.description || !Array.isArray(source.package?.assets) || !source.package.assets.length) {
      throw new Error(`Adapter ${source.sourceId} lacks dependency, description, or canonical assets.`);
    }
    const dependency = source.package.dependency.toLowerCase();
    if (dependencies.has(dependency)) throw new Error(`Duplicate adapter dependency: ${source.package.dependency}.`);
    dependencies.add(dependency);
    for (const asset of source.package.assets) {
      const sourcePath = normalize(asset.source);
      const destination = normalize(asset.destination);
      if (!sourcePath || !destination || destination.startsWith("../") || path.posix.isAbsolute(destination)) {
        throw new Error(`Adapter ${source.sourceId} has an invalid asset mapping.`);
      }
      if (sourcePath.startsWith("dist/")) throw new Error(`Adapter ${source.sourceId} reads generated dist input: ${sourcePath}.`);
      if (!assetExists(sourcePath)) throw new Error(`Adapter ${source.sourceId} asset is missing: ${sourcePath}.`);
      const installedKey = destination.toLowerCase();
      if (destinations.has(installedKey)) throw new Error(`Adapter install destination is assigned twice: ${destination}.`);
      destinations.add(installedKey);
    }
  }
}

export function renderModuleConfig(manifest) {
  const contract = manifest.packageContract;
  const options = adapterSources(manifest).map((source) => `            <plugin name="${xmlEscape(source.displayName)}">
              <description>${xmlEscape(source.package.description)}</description>
              <files>
                <folder source="${xmlEscape(`${contract.adapterDirectory}\\${source.sourceId}`)}" destination="" priority="0" />
              </files>
              <typeDescriptor>
                <dependencyType>
                  <defaultType name="NotUsable" />
                  <patterns>
                    <pattern>
                      <dependencies operator="And">
                        <fileDependency file="${xmlEscape(source.package.dependency)}" state="Active" />
                      </dependencies>
                      <type name="Recommended" />
                    </pattern>
                  </patterns>
                </dependencyType>
              </typeDescriptor>
            </plugin>`).join("\n");
  return `<?xml version="1.0" encoding="utf-8"?>
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://qconsulting.ca/fo3/ModConfig5.0.xsd">
  <moduleName>${xmlEscape(contract.moduleName)}</moduleName>
  <requiredInstallFiles>
    <folder source="required" destination="" priority="0" />
  </requiredInstallFiles>
  <installSteps order="Explicit">
    <installStep name="Optional Compatibility Adapters">
      <optionalFileGroups order="Explicit">
        <group name="Detected Adapter Plugins" type="SelectAny">
          <plugins order="Explicit">
${options}
          </plugins>
        </group>
      </optionalFileGroups>
    </installStep>
  </installSteps>
</config>
`;
}

export function renderInfo(manifest) {
  const contract = manifest.packageContract;
  return `<?xml version="1.0" encoding="utf-8"?>
<fomod>
  <Name>${xmlEscape(contract.moduleName)}</Name>
  <Author>Devotion (PDV)</Author>
  <Version>${xmlEscape(contract.packageVersion)}</Version>
  <Description>The official third-party Quest Reaction catalog installs automatically. Five small adapters appear only when their source plugins are active.</Description>
  <Groups>
    <element>Gameplay</element>
    <element>Quests and Adventures</element>
    <element>Patches</element>
  </Groups>
</fomod>
`;
}

export function buildPackageArtifacts({ manifest, officialCatalogText, readAsset }) {
  validatePackageContract(manifest, { assetExists: (relativePath) => readAsset(relativePath) !== null });
  const contract = manifest.packageContract;
  const artifacts = new Map();
  artifacts.set(normalize(path.posix.join("required", contract.requiredCatalogDestination)), bytesOf(officialCatalogText));
  for (const source of adapterSources(manifest)) {
    for (const asset of source.package.assets) {
      const content = readAsset(normalize(asset.source));
      if (content === null) throw new Error(`Adapter ${source.sourceId} asset is missing: ${asset.source}.`);
      artifacts.set(normalize(path.posix.join(contract.adapterDirectory, source.sourceId, asset.destination)), bytesOf(content));
    }
  }
  artifacts.set("fomod/ModuleConfig.xml", bytesOf(renderModuleConfig(manifest)));
  artifacts.set("fomod/info.xml", bytesOf(renderInfo(manifest)));
  artifacts.set("README.md", bytesOf(`# Devotion Quest Reaction Compatibility\n\nThe official third-party reaction catalog installs automatically. The installer offers five dependency-detected adapter options for integrations that require records or scripts. Data-only integrations need no individual checkbox.\n`));
  validatePackageArtifacts({ manifest, artifacts });
  return artifacts;
}

export function packageSnapshot(artifacts) {
  return [...artifacts.entries()].map(([filePath, content]) => {
    const bytes = bytesOf(content);
    return { path: normalize(filePath), bytes: bytes.length, sha256: digest(bytes) };
  }).sort((left, right) => left.path.localeCompare(right.path, "en"));
}

export function buildPackageReceipt({ manifest, artifacts, inputSha256 }) {
  const files = packageSnapshot(artifacts);
  const treeSha256 = digest(Buffer.from(files.map((file) => `${file.path}\0${file.bytes}\0${file.sha256}`).join("\n"), "utf8"));
  return {
    schema: "pdv.quest-reaction.package-receipt.v3",
    version: 1,
    inputSha256,
    packageRoot: normalize(manifest.packageContract.outputRoot),
    requiredCatalog: normalize(manifest.packageContract.requiredCatalogDestination),
    dataOnlySources: 75,
    adapterOptions: adapterSources(manifest).map((source) => ({ sourceId: source.sourceId, dependency: source.package.dependency })),
    files,
    treeSha256,
    proofBoundary: "Generated tree, installer simulation, bytes, and hashes only; dependency detection and gameplay require Skyrim proof.",
  };
}

export function validatePackageArtifacts({ manifest, artifacts }) {
  const contract = manifest.packageContract;
  const paths = [...artifacts.keys()].map(normalize);
  const lower = paths.map((entry) => entry.toLowerCase());
  if (new Set(lower).size !== lower.length) throw new Error("Generated package contains a case-insensitive path collision.");
  const forbidden = paths.filter((entry) => /(?:^|\/)(?:channels|queststageadapters)(?:\/|$)|PDV_QRM_|PDV_QSA_/i.test(entry));
  if (forbidden.length) throw new Error(`Generated package contains retired V1 members: ${forbidden.join(", ")}.`);
  const requiredPath = normalize(path.posix.join("required", contract.requiredCatalogDestination));
  if (paths.filter((entry) => entry === requiredPath).length !== 1) throw new Error("Official v2 catalog must be installed exactly once as required content.");
  const xml = bytesOf(artifacts.get("fomod/ModuleConfig.xml") ?? "").toString("utf8");
  const optionNames = [...xml.matchAll(/<plugin name="([^"]+)">/g)].map((match) => match[1]);
  const dependencies = [...xml.matchAll(/<fileDependency file="([^"]+)" state="Active"\s*\/>/g)].map((match) => match[1]);
  if (optionNames.length !== 5 || dependencies.length !== 5) throw new Error(`FOMOD must contain exactly five dependency-gated options; found ${optionNames.length}/${dependencies.length}.`);
  if ((xml.match(/source="required"/g) ?? []).length !== 1) throw new Error("FOMOD must contain one required package source.");
  for (const source of manifest.sources.filter((entry) => entry.delivery === "data-only")) {
    if (optionNames.includes(source.displayName)) throw new Error(`Data-only source leaked into FOMOD options: ${source.sourceId}.`);
  }

  const installed = new Map([[contract.requiredCatalogDestination.toLowerCase(), requiredPath]]);
  for (const source of adapterSources(manifest)) {
    for (const asset of source.package.assets) {
      const destination = normalize(asset.destination).toLowerCase();
      const packagedPath = normalize(path.posix.join(contract.adapterDirectory, source.sourceId, asset.destination));
      const prior = installed.get(destination);
      if (prior) throw new Error(`Install collision at ${asset.destination}: ${prior} vs ${packagedPath}.`);
      installed.set(destination, packagedPath);
      if (!artifacts.has(packagedPath)) throw new Error(`Generated adapter member is missing: ${packagedPath}.`);
    }
  }
  return { optionCount: optionNames.length, installedFiles: installed.size, collisions: 0 };
}

export function assertReceiptMatches(receipt, artifacts) {
  const actual = packageSnapshot(artifacts);
  if (JSON.stringify(receipt.files) !== JSON.stringify(actual)) throw new Error("Package receipt membership/byte hashes drifted.");
}
