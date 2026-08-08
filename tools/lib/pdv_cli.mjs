// One flag guard for the whole toolchain.
//
// WHY. `f6728d1b` fixed six tools by pasting an 11-line unknown-flag check into each. The
// class was much wider than six - 55 of 113 tools took a --flag with no guard at all - and
// pasting the same block 55 more times is the same value living in 55 places, which is the
// drift this repo has a standing rule against.
//
// THE SHARP ARM. 19 of those tools take a --self-test, and the flag is spelled `--self-test`
// in 19 places and `--selftest` in one. So the wrong spelling is not a hypothetical typo, it
// is another tool's real flag. Type it and an unguarded tool ignores the argument, skips its
// fixtures and prints PASS - a green line for a self-test that never ran. Two of the 19 are
// pdv_1_0_endstate_gate and pdv_placement_gate, so this reaches the 1.0 end-state gate.
//
// SCOPE ON PURPOSE. This guards; it does not parse. Each tool keeps whatever argv reading it
// already has, because rewriting 19 tools' argument handling in one pass is a much larger
// change with a much worse failure mode than the bug being fixed. Declare the set, call the
// guard, leave the rest alone.

// Exit 2, not 1: a usage error is not the same as a gate failing, and a caller that treats
// every nonzero exit as "the check found something" would otherwise misreport a typo as a
// real finding.
const USAGE_EXIT = 2;

// Accepts `--flag` and `--flag=value`; only the name is checked. A bare `-x` is left alone
// because no tool in this repo uses short flags, and a value that merely starts with a dash
// (a negative number, say) must not be mistaken for one.
function flagNameOf(arg) {
  if (!arg.startsWith("--")) return null;
  const eq = arg.indexOf("=");
  return eq === -1 ? arg : arg.slice(0, eq);
}

export function assertKnownFlags(argv, knownFlags, options = {}) {
  const known = knownFlags instanceof Set ? knownFlags : new Set(knownFlags);
  const { toolName = "", onHelp = null } = options;

  if (onHelp && (argv.includes("--help") || argv.includes("-h"))) {
    onHelp([...known].sort());
    process.exit(0);
  }

  const unknown = argv.map(flagNameOf).filter((name) => name && !known.has(name));
  if (unknown.length) {
    const label = toolName ? `${toolName}: ` : "";
    console.error(`${label}Unknown argument${unknown.length > 1 ? "s" : ""}: ${unknown.join(", ")}`);
    console.error(`Known: ${[...known].sort().join(", ")}`);
    // Name the near-miss explicitly. The whole reason this guard exists is a typo that
    // looked like success, so telling the user what they probably meant is the point.
    for (const bad of unknown) {
      const near = [...known].find((k) => normalize(k) === normalize(bad));
      if (near) console.error(`Did you mean ${near}?`);
    }
    process.exit(USAGE_EXIT);
  }
}

function normalize(flag) {
  return flag.replace(/[^a-z0-9]/gi, "").toLowerCase();
}

// Convenience readers for tools that want them. Optional - a tool may keep using
// process.argv.includes() and only take the guard above.
export function makeFlagReader(argv) {
  return {
    has: (name) => argv.some((a) => a === name || a.startsWith(`${name}=`)),
    value: (name) => {
      const eq = argv.find((a) => a.startsWith(`${name}=`));
      if (eq) return eq.slice(name.length + 1);
      const i = argv.indexOf(name);
      if (i === -1) return null;
      const next = argv[i + 1];
      return next && !next.startsWith("--") ? next : null;
    },
  };
}
