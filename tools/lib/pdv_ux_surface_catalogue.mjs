import fs from "node:fs";

export const UX_SURFACE_SCHEMA = "pdv.ux-surface-catalogue.v1";

export function readUxSurfaceCatalogue(filePath) {
  return JSON.parse(fs.readFileSync(filePath, "utf8"));
}

export function validateUxSurfaceCatalogue(catalogue) {
  const errors = [];
  if (catalogue?.schema !== UX_SURFACE_SCHEMA) errors.push(`schema must be ${UX_SURFACE_SCHEMA}`);
  const families = new Set((catalogue?.families ?? []).map((row) => row.id));
  const ids = new Set();
  const required = ["id", "family", "title", "status", "mockType", "pdvUse", "pause", "input", "persistence", "capacity", "dependency", "implementationCost", "recommendedFor", "caution", "fallback", "implementationRoute", "sourceUrl"];
  for (const [index, row] of (catalogue?.templates ?? []).entries()) {
    for (const key of required) if (!row[key]) errors.push(`templates[${index}] missing ${key}`);
    if (ids.has(row.id)) errors.push(`duplicate template id ${row.id}`);
    ids.add(row.id);
    if (!families.has(row.family)) errors.push(`${row.id}: unknown family ${row.family}`);
    if (!/^surface\.template\.[a-z0-9-]+$/.test(row.id ?? "")) errors.push(`${row.id}: invalid stable template id`);
    if (!/^https:\/\//.test(row.sourceUrl ?? "")) errors.push(`${row.id}: sourceUrl must be https`);
  }
  return errors;
}

export function renderUxSurfaceCatalogueCsv(catalogue) {
  const keys = ["template_id", "family", "title", "status", "pdv_use", "pause_behavior", "input", "persistence", "capacity", "dependency", "implementation_cost", "recommended_for", "caution", "fallback", "implementation_route", "source_url", "owner_decision", "owner_variant", "owner_notes"];
  const rows = catalogue.templates.map((row) => ({
    template_id: row.id,
    family: row.family,
    title: row.title,
    status: row.status,
    pdv_use: row.pdvUse,
    pause_behavior: row.pause,
    input: row.input,
    persistence: row.persistence,
    capacity: row.capacity,
    dependency: row.dependency,
    implementation_cost: row.implementationCost,
    recommended_for: row.recommendedFor,
    caution: row.caution,
    fallback: row.fallback,
    implementation_route: row.implementationRoute,
    source_url: row.sourceUrl,
    owner_decision: "",
    owner_variant: "",
    owner_notes: "",
  }));
  return `${keys.map(csvCell).join(",")}\n${rows.map((row) => keys.map((key) => csvCell(row[key])).join(",")).join("\n")}\n`;
}

export function renderUxSurfaceLibraryPenpotSvg(catalogue) {
  const width = 2400;
  const cardWidth = 440;
  const cardHeight = 168;
  const columnGap = 20;
  const rowGap = 18;
  const columns = 5;
  const sectionGap = 28;
  let y = 78;
  const sectionSvg = [];
  const cardSvg = [];
  for (const family of catalogue.families) {
    const templates = catalogue.templates.filter((row) => row.family === family.id);
    const rows = Math.ceil(templates.length / columns);
    const height = 64 + rows * cardHeight + Math.max(0, rows - 1) * rowGap + 24;
    sectionSvg.push(`<g id="surface-family-${esc(family.id)}"><rect x="40" y="${y}" width="2320" height="${height}" rx="18" fill="#111827" stroke="#334155" stroke-width="2"/><text x="62" y="${y + 30}" fill="#93c5fd" font-family="Inter,Arial,sans-serif" font-size="20" font-weight="700">${esc(family.title)}</text><text x="62" y="${y + 49}" fill="#94a3b8" font-family="Inter,Arial,sans-serif" font-size="11">${esc(family.summary)}</text></g>`);
    templates.forEach((template, index) => {
      const column = index % columns;
      const row = Math.floor(index / columns);
      const x = 60 + column * (cardWidth + columnGap);
      const cardY = y + 64 + row * (cardHeight + rowGap);
      cardSvg.push(renderTemplateCard(template, x, cardY, cardWidth, cardHeight));
    });
    y += height + sectionGap;
  }
  const height = y + 12;
  return `<?xml version="1.0" encoding="UTF-8"?>\n<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}"><rect width="${width}" height="${height}" fill="#0b1020"/><text x="40" y="34" fill="#f8fafc" font-family="Inter,Arial,sans-serif" font-size="25" font-weight="700">PDV Skyrim UI/UX Surface Library</text><text x="560" y="33" fill="#94a3b8" font-family="Inter,Arial,sans-serif" font-size="12">Duplicate and alter mock groups in Penpot. Exact prose remains in the copy exchange.</text>${sectionSvg.join("")}${cardSvg.join("")}</svg>\n`;
}

function renderTemplateCard(template, x, y, width, height) {
  const color = statusColor(template.status);
  const title = truncate(template.title, 34);
  const dependency = wrapText(`Dependency: ${template.dependency}`, 36, 2);
  const fit = wrapText(template.recommendedFor, 42, 2);
  return `<g id="surface-template-${esc(template.id.replace(/[^a-z0-9_-]/gi, "-"))}" data-template-id="${esc(template.id)}"><desc>${esc(template.recommendedFor)} Caution: ${esc(template.caution)}</desc><rect x="${x}" y="${y}" width="${width}" height="${height}" rx="12" fill="#172033" stroke="${color}" stroke-width="2"/><text x="${x + 14}" y="${y + 17}" fill="${color}" font-family="Inter,Arial,sans-serif" font-size="9">${esc(template.id)}</text><text x="${x + 14}" y="${y + 38}" fill="#f8fafc" font-family="Inter,Arial,sans-serif" font-size="15" font-weight="700">${esc(title)}</text>${renderMock(template.mockType, x + 14, y + 50, template.id)}<text x="${x + 170}" y="${y + 61}" fill="#cbd5e1" font-family="Inter,Arial,sans-serif" font-size="10">${esc(template.status)} / cost ${esc(template.implementationCost)}</text>${dependency.map((line, index) => `<text x="${x + 170}" y="${y + 79 + index * 13}" fill="#94a3b8" font-family="Inter,Arial,sans-serif" font-size="9">${esc(line)}</text>`).join("")}<text x="${x + 170}" y="${y + 111}" fill="#7dd3fc" font-family="Inter,Arial,sans-serif" font-size="9">Best fit</text>${fit.map((line, index) => `<text x="${x + 170}" y="${y + 125 + index * 13}" fill="#cbd5e1" font-family="Inter,Arial,sans-serif" font-size="9">${esc(line)}</text>`).join("")}<text x="${x + 170}" y="${y + 157}" fill="#94a3b8" font-family="Inter,Arial,sans-serif" font-size="9">${esc(truncate(`${template.pause} / ${template.input}`, 47))}</text></g>`;
}

function renderMock(type, x, y, id) {
  const group = `mock-${esc(id.replace(/[^a-z0-9_-]/gi, "-"))}`;
  const frame = `<rect x="${x}" y="${y}" width="140" height="104" rx="8" fill="#0f172a" stroke="#475569"/>`;
  const line = (dx, dy, w, color = "#64748b", h = 4) => `<rect x="${x + dx}" y="${y + dy}" width="${w}" height="${h}" rx="2" fill="${color}"/>`;
  let body = "";
  if (type === "toast") body = `${line(12, 17, 88, "#e2e8f0", 6)}${line(12, 31, 113)}${line(12, 41, 82)}<circle cx="${x + 122}" cy="${y + 24}" r="7" fill="#38bdf8"/>`;
  else if (type === "dialog" || type === "tutorial") body = `${line(14, 15, 96, "#e2e8f0", 6)}${line(14, 31, 112)}${line(14, 42, 104)}${line(14, 53, 86)}<rect x="${x + 14}" y="${y + 72}" width="48" height="18" rx="4" fill="#334155"/><rect x="${x + 70}" y="${y + 72}" width="48" height="18" rx="4" fill="#334155"/>`;
  else if (type === "book") body = `<path d="M${x + 13},${y + 13} h52 q8,0 8,8 v70 q-8,-6 -16,-3 h-44 z" fill="#3f3527"/><path d="M${x + 127},${y + 13} h-52 q-8,0 -8,8 v70 q8,-6 16,-3 h44 z" fill="#3f3527"/>${line(22, 28, 34, "#a89b82", 3)}${line(82, 28, 34, "#a89b82", 3)}${line(22, 40, 30, "#a89b82", 3)}${line(82, 40, 30, "#a89b82", 3)}`;
  else if (type === "tooltip") body = `${line(12, 14, 86, "#e2e8f0", 6)}${line(12, 30, 115)}${line(12, 41, 98)}${line(12, 52, 108)}${line(12, 73, 45, "#38bdf8", 5)}${line(64, 73, 56, "#38bdf8", 5)}`;
  else if (type === "mcm" || type === "list") body = `<rect x="${x + 10}" y="${y + 10}" width="34" height="84" fill="#1e293b"/>${line(52, 16, 73, "#e2e8f0", 6)}${line(52, 34, 68)}${line(52, 48, 74)}${line(52, 62, 64)}${line(52, 76, 71)}`;
  else if (type === "dialogue") body = `<circle cx="${x + 28}" cy="${y + 30}" r="14" fill="#475569"/>${line(50, 17, 72, "#e2e8f0", 5)}${line(50, 31, 64)}${line(18, 65, 104, "#38bdf8", 5)}${line(29, 78, 82)}`;
  else if (type === "objective") body = `${line(14, 15, 92, "#e2e8f0", 6)}<rect x="${x + 14}" y="${y + 34}" width="12" height="12" fill="none" stroke="#38bdf8"/>${line(34, 38, 88)}<rect x="${x + 14}" y="${y + 56}" width="12" height="12" fill="none" stroke="#64748b"/>${line(34, 60, 72)}`;
  else if (type === "map") body = `<path d="M${x + 9},${y + 88} L${x + 35},${y + 38} L${x + 57},${y + 61} L${x + 88},${y + 22} L${x + 128},${y + 75}" fill="none" stroke="#64748b" stroke-width="3"/><path d="M${x + 77},${y + 38} c0,-12 18,-12 18,0 c0,9 -9,18 -9,18 c0,0 -9,-9 -9,-18" fill="#38bdf8"/>`;
  else if (type === "panel") body = `<rect x="${x + 9}" y="${y + 9}" width="122" height="18" rx="4" fill="#1e293b"/>${line(15, 16, 45, "#e2e8f0", 5)}<rect x="${x + 9}" y="${y + 35}" width="58" height="58" rx="5" fill="#1e293b"/><rect x="${x + 73}" y="${y + 35}" width="58" height="58" rx="5" fill="#1e293b"/>${line(16, 46, 38, "#38bdf8", 5)}${line(80, 46, 38, "#38bdf8", 5)}`;
  else if (type === "choice") body = `<rect x="${x + 8}" y="${y + 17}" width="38" height="70" rx="5" fill="#1e293b"/><rect x="${x + 51}" y="${y + 17}" width="38" height="70" rx="5" fill="#1e293b"/><rect x="${x + 94}" y="${y + 17}" width="38" height="70" rx="5" fill="#1e293b"/>${line(14, 27, 25, "#38bdf8", 4)}${line(57, 27, 25, "#38bdf8", 4)}${line(100, 27, 25, "#38bdf8", 4)}`;
  else if (type === "timeline") body = `<line x1="${x + 24}" y1="${y + 15}" x2="${x + 24}" y2="${y + 91}" stroke="#64748b" stroke-width="3"/><circle cx="${x + 24}" cy="${y + 27}" r="6" fill="#38bdf8"/><circle cx="${x + 24}" cy="${y + 53}" r="6" fill="#38bdf8"/><circle cx="${x + 24}" cy="${y + 79}" r="6" fill="#38bdf8"/>${line(40, 23, 78)}${line(40, 49, 68)}${line(40, 75, 82)}`;
  else if (type === "widget") body = `<circle cx="${x + 35}" cy="${y + 52}" r="22" fill="#1e293b" stroke="#38bdf8" stroke-width="4"/>${line(68, 33, 53, "#e2e8f0", 5)}${line(68, 49, 61)}${line(68, 65, 44)}`;
  else if (type === "wheel") body = `<circle cx="${x + 70}" cy="${y + 52}" r="40" fill="#1e293b" stroke="#64748b"/><circle cx="${x + 70}" cy="${y + 52}" r="17" fill="#0f172a"/><path d="M${x + 70},${y + 12} L${x + 70},${y + 35} M${x + 110},${y + 52} L${x + 87},${y + 52} M${x + 70},${y + 92} L${x + 70},${y + 69} M${x + 30},${y + 52} L${x + 53},${y + 52}" stroke="#38bdf8" stroke-width="3"/>`;
  else if (type === "bar") body = `${line(14, 28, 96, "#e2e8f0", 5)}<rect x="${x + 14}" y="${y + 48}" width="112" height="14" rx="7" fill="#1e293b"/><rect x="${x + 14}" y="${y + 48}" width="73" height="14" rx="7" fill="#38bdf8"/>${line(14, 76, 60)}`;
  else body = `${line(14, 20, 95)}${line(14, 36, 110)}${line(14, 52, 76)}`;
  return `<g id="${group}">${frame}${body}</g>`;
}

function statusColor(status) {
  if (status === "used") return "#38bdf8";
  if (status === "candidate" || status === "limited-use") return "#4ade80";
  if (status === "conditional") return "#fbbf24";
  return "#c084fc";
}

function wrapText(value, width, maxLines) {
  const words = String(value ?? "").split(/\s+/).filter(Boolean);
  const lines = [""];
  for (const word of words) {
    const current = lines[lines.length - 1];
    if (`${current} ${word}`.trim().length <= width) lines[lines.length - 1] = `${current} ${word}`.trim();
    else if (lines.length < maxLines) lines.push(word);
    else { lines[lines.length - 1] = `${truncate(lines[lines.length - 1], width - 1)}...`; break; }
  }
  return lines;
}

function truncate(value, length) {
  const text = String(value ?? "");
  return text.length <= length ? text : `${text.slice(0, Math.max(0, length - 3))}...`;
}

function esc(value) {
  return String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function csvCell(value) {
  const text = value == null ? "" : String(value).replace(/\r\n/g, "\n");
  return `"${text.replace(/"/g, '""')}"`;
}
