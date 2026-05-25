export const BACKEND_ORDER = [
  "mutagen-patch-request",
  "mo2-mcp-patch-request",
  "xedit-script-request",
  "ckpe-bridge",
  "ui-automation",
  "manual-packet"
];

export const DEFAULT_CAPABILITIES = [
  {
    kind: "vmad.attach_script",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request", "ckpe-bridge"],
    verifier: "vmad.script-properties",
    fallback: "manual-packet",
    notes: "Attaches or updates a primary VMAD script and scalar/object properties on an existing record."
  },
  {
    kind: "vmad.set_property",
    supportedBackends: ["ckpe-bridge"],
    verifier: "vmad.script-properties",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Sets one VMAD property through CK semantics."
  },
  {
    kind: "vmad.set_array_property",
    supportedBackends: ["ckpe-bridge"],
    verifier: "vmad.array-property",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Sets one VMAD array property through CK semantics."
  },
  {
    kind: "vmad.array_property",
    supportedBackends: ["ckpe-bridge"],
    verifier: "vmad.array-property",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Legacy alias for vmad.set_array_property; CKPE is the shippable backend."
  },
  {
    kind: "formlist.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request", "ckpe-bridge"],
    verifier: "formlist.contains",
    fallback: "manual-packet",
    notes: "Adds an existing form to an existing FormList."
  },
  {
    kind: "keyword.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request"],
    verifier: "record.keywords",
    fallback: "manual-packet",
    notes: "Adds keywords to records where the backend exposes keyword lists."
  },
  {
    kind: "spell.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request"],
    verifier: "record.spells",
    fallback: "manual-packet",
    notes: "Adds spells to supported records such as NPC or RACE."
  },
  {
    kind: "perk.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request"],
    verifier: "record.perks",
    fallback: "manual-packet",
    notes: "Adds perks to supported records."
  },
  {
    kind: "package.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request"],
    verifier: "record.packages",
    fallback: "manual-packet",
    notes: "Adds AI packages to supported records."
  },
  {
    kind: "inventory.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request"],
    verifier: "record.inventory",
    fallback: "manual-packet",
    notes: "Adds inventory items to supported records."
  },
  {
    kind: "condition.add",
    supportedBackends: ["mutagen-patch-request", "mo2-mcp-patch-request"],
    verifier: "record.conditions",
    fallback: "manual-packet",
    notes: "Adds conditions to supported condition carriers."
  },
  {
    kind: "record.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "record.exists",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a new record in the generated plugin through CKPE-native CK semantics."
  },
  {
    kind: "record.update",
    supportedBackends: ["ckpe-bridge"],
    verifier: "record.exists",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Updates CK-owned record fields in the generated plugin."
  },
  {
    kind: "quest.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "record.exists",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a quest record through CKPE-native CK semantics."
  },
  {
    kind: "quest.alias.add",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.quest-alias",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Adds a quest alias through CKPE-native CK semantics."
  },
  {
    kind: "quest.stage.fragment",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.quest-fragment",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Adds or updates a quest stage fragment through CKPE-native CK semantics."
  },
  {
    kind: "story_manager.node",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "ck.story-manager",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    unsafeWhen: ["Story Manager tree normalization is CK-owned until a native bridge proves the binary write path."],
    notes: "CK-only in v1."
  },
  {
    kind: "story_manager.node.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.story-manager",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a Story Manager node through CKPE-native CK semantics."
  },
  {
    kind: "quest.fragment",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "ck.quest-fragment",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    unsafeWhen: ["Fragment source visibility and ghost fragment state are CK-sensitive."],
    notes: "CK-only in v1."
  },
  {
    kind: "dialogue.scene",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "ck.dialogue-scene",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "CK-only in v1."
  },
  {
    kind: "dialogue.branch.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.dialogue-scene",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a dialogue branch through CKPE-native CK semantics."
  },
  {
    kind: "dialogue.topic.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.dialogue-scene",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a dialogue topic through CKPE-native CK semantics."
  },
  {
    kind: "dialogue.info.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.dialogue-scene",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a dialogue info record through CKPE-native CK semantics."
  },
  {
    kind: "scene.create",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.dialogue-scene",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Creates a scene through CKPE-native CK semantics."
  },
  {
    kind: "navmesh.edit",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "ck.navmesh",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "CK-only in v1."
  },
  {
    kind: "facegen.export",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "asset.facegen",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "CK-only in v1."
  },
  {
    kind: "seq.generate",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "asset.seq",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "CK-only in v1 unless a project supplies a proven command adapter."
  },
  {
    kind: "artifact.seq.generate",
    supportedBackends: ["ckpe-bridge"],
    verifier: "asset.seq",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Generates or refreshes SEQ for the generated plugin."
  },
  {
    kind: "lip.generate",
    supportedBackends: ["ckpe-bridge", "ui-automation"],
    verifier: "asset.lip",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "CK-only in v1 unless a project supplies a proven command adapter."
  },
  {
    kind: "artifact.lip.generate",
    supportedBackends: ["ckpe-bridge"],
    verifier: "asset.lip",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Generates LIP artifacts for dialogue when proven."
  },
  {
    kind: "artifact.facegen.generate",
    supportedBackends: ["ckpe-bridge"],
    verifier: "asset.facegen",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Generates FaceGen artifacts when proven."
  },
  {
    kind: "reference.place",
    supportedBackends: ["ckpe-bridge"],
    verifier: "ck.placed-reference",
    fallback: "manual-packet",
    requiresCkSemantics: true,
    notes: "Places existing base forms as CK references. Mesh/3D authoring is out of scope; CK placement still requires native proof."
  },
  {
    kind: "manual.unsupported",
    supportedBackends: [],
    verifier: "manual.review",
    fallback: "manual-packet",
    notes: "Migration fallback for operation shapes the generic authoring schema cannot represent yet."
  }
];

const DEFAULT_TIER_BY_KIND = {
  "vmad.attach_script": "safe_writer",
  "vmad.set_property": "ck_required",
  "vmad.set_array_property": "ck_required",
  "vmad.array_property": "ck_required",
  "formlist.add": "safe_writer",
  "keyword.add": "safe_writer",
  "spell.add": "safe_writer",
  "perk.add": "safe_writer",
  "package.add": "safe_writer",
  "inventory.add": "safe_writer",
  "condition.add": "safe_writer",
  "record.create": "ck_required",
  "record.update": "ck_required",
  "quest.create": "ck_required",
  "quest.alias.add": "ck_required",
  "quest.stage.fragment": "ck_required",
  "story_manager.node": "ck_required",
  "story_manager.node.create": "ck_required",
  "quest.fragment": "ck_required",
  "dialogue.scene": "ck_required",
  "dialogue.branch.create": "ck_required",
  "dialogue.topic.create": "ck_required",
  "dialogue.info.create": "ck_required",
  "scene.create": "ck_required",
  "navmesh.edit": "research_only",
  "facegen.export": "generated_artifact",
  "seq.generate": "generated_artifact",
  "lip.generate": "generated_artifact",
  "artifact.seq.generate": "generated_artifact",
  "artifact.lip.generate": "generated_artifact",
  "artifact.facegen.generate": "generated_artifact",
  "reference.place": "ck_required",
  "manual.unsupported": "manual_blocked"
};

export function createCapabilityRegistry(capabilities = DEFAULT_CAPABILITIES) {
  const byKind = new Map();
  const normalizedCapabilities = capabilities.map((capability) => ({
    tier: DEFAULT_TIER_BY_KIND[capability.kind] || "manual_blocked",
    recordFamilies: capability.recordFamilies || [],
    ...capability
  }));
  for (const capability of normalizedCapabilities) {
    byKind.set(capability.kind, capability);
  }
  return {
    all: normalizedCapabilities,
    get(kind) {
      return byKind.get(kind) || null;
    },
    explain(kind) {
      if (!kind) {
        return normalizedCapabilities;
      }
      return byKind.get(kind) || {
        kind,
        tier: "manual_blocked",
        supportedBackends: [],
        verifier: "none",
        fallback: "manual-packet",
        unknown: true,
        notes: "No capability is registered for this operation kind."
      };
    }
  };
}

export function availableBackendsForProfile(profile) {
  const backends = new Set(["manual-packet"]);
  for (const connector of profile.resourceConnectors) {
    if (connector.type === "mo2-mcp") {
      backends.add("mo2-mcp-patch-request");
    }
    if (connector.type === "mutagen") {
      backends.add("mutagen-patch-request");
    }
    if (connector.type === "xedit") {
      backends.add("xedit-script-request");
    }
    if (connector.type === "ckpe") {
      backends.add("ckpe-bridge");
    }
    if (connector.type === "windows-ui-automation") {
      backends.add("ui-automation");
    }
  }
  return [...backends];
}
