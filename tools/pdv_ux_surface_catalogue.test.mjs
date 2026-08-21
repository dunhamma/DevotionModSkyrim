import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";
import {
  renderUxSurfaceCatalogueCsv,
  renderUxSurfaceLibraryPenpotSvg,
  renderPopupWritingLimitsCsv,
  renderPopupWritingFramesPenpotSvg,
  validateUxSurfaceCatalogue,
} from "./lib/pdv_ux_surface_catalogue.mjs";

const catalogue = JSON.parse(fs.readFileSync(new URL("../references/authoring/PDV_UXSurfaceCatalogue.json", import.meta.url), "utf8"));

test("surface catalogue has unique reviewed templates and sources", () => {
  assert.deepEqual(validateUxSurfaceCatalogue(catalogue), []);
  assert.equal(catalogue.templates.length, 20);
  assert.equal(new Set(catalogue.templates.map((row) => row.id)).size, 20);
  assert.ok(catalogue.templates.some((row) => row.id === "surface.template.prisma-timeline" && row.status === "candidate"));
  assert.ok(catalogue.templates.some((row) => row.id === "surface.template.truehud-resource" && row.implementationCost === "High"));
});

test("surface CSV keeps design decisions owner-editable", () => {
  const csv = renderUxSurfaceCatalogueCsv(catalogue);
  assert.match(csv, /"owner_decision","owner_variant","owner_notes"/);
  assert.match(csv, /"surface\.template\.quest-journal"/);
  assert.match(csv, /"https:\/\//);
  assert.equal(csv, renderUxSurfaceCatalogueCsv(catalogue));
});

test("Penpot library exposes stable editable groups and mock variants", () => {
  const svg = renderUxSurfaceLibraryPenpotSvg(catalogue);
  assert.match(svg, /PDV Skyrim UI\/UX Surface Library/);
  assert.match(svg, /data-template-id="surface\.template\.messagebox"/);
  assert.match(svg, /id="mock-surface-template-uiextensions-wheel"/);
  assert.equal(svg, renderUxSurfaceLibraryPenpotSvg(catalogue));
});

test("popup writing frames expose measured dimensions and editable copy budgets", () => {
  const csv = renderPopupWritingLimitsCsv(catalogue);
  const svg = renderPopupWritingFramesPenpotSvg(catalogue);
  assert.match(csv, /"measurement_basis"/);
  assert.match(csv, /"measured-production-css"/);
  assert.match(csv, /"owner_draft","owner_notes"/);
  assert.match(svg, /PDV Popup Writing Frames/);
  assert.match(svg, /Character figures are writing budgets, not engine truncation limits/);
  assert.match(svg, /data-template-id="surface\.template\.prisma-toast"/);
  assert.equal(csv, renderPopupWritingLimitsCsv(catalogue));
  assert.equal(svg, renderPopupWritingFramesPenpotSvg(catalogue));
});
