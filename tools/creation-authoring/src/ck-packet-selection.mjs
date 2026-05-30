export function selectPacketCase(packet, caseName) {
  if (!caseName) {
    return packet;
  }
  if (!packet || typeof packet !== "object") {
    throw new Error("CK packet is required before selecting a case.");
  }
  const commands = Array.isArray(packet.commands) ? packet.commands : [];
  const matchingCommands = commands.filter((command) => command?.case === caseName);
  if (matchingCommands.length === 0) {
    const availableCases = [...new Set(commands.map((command) => command?.case).filter(Boolean))];
    const availableSuffix = availableCases.length > 0
      ? ` Available cases: ${availableCases.join(", ")}.`
      : "";
    throw new Error(`Packet case "${caseName}" was not found.${availableSuffix}`);
  }
  if (matchingCommands.length > 1) {
    throw new Error(`Packet case "${caseName}" matched ${matchingCommands.length} commands; expected exactly one.`);
  }
  return {
    ...packet,
    commands: matchingCommands
  };
}
