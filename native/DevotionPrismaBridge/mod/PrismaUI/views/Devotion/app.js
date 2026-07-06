(() => {
  const thresholds = [
    { label: "Seeker", value: 25 },
    { label: "Devoted", value: 50 },
    { label: "Champion", value: 85 },
  ];
  const svgNamespace = "http://www.w3.org/2000/svg";
  const symbolAliases = {
    auriel: "auri-el",
    "auri el": "auri-el",
    auriEl: "auri-el",
    azurah: "azura",
    baandar: "baan-dar",
    "baan dar": "baan-dar",
    "curse-werewolf": "hircine",
    system: "journal",
  };
  const gallerySymbols = [
    ["kyne", "Kyne"],
    ["talos", "Talos"],
    ["auri-el", "Auri-El"],
    ["akatosh", "Akatosh"],
    ["arkay", "Arkay"],
    ["dibella", "Dibella"],
    ["julianos", "Julianos"],
    ["mara", "Mara"],
    ["stendarr", "Stendarr"],
    ["zenithar", "Zenithar"],
    ["yffre", "Y'ffre"],
    ["zen", "Z'en"],
    ["baan-dar", "Baan Dar"],
    ["azura", "Azurah"],
    ["boethiah", "Boethiah"],
    ["mephala", "Mephala"],
    ["shor", "Shor"],
    ["tsun", "Tsun"],
    ["stuhn", "Stuhn"],
    ["kynareth", "Kynareth"],
    ["magnus", "Magnus"],
    ["xarxes", "Xarxes"],
    ["trinimac", "Trinimac"],
    ["khenarthi", "Khenarthi"],
    ["rajhin", "Rajhin"],
    ["alkosh", "Alkosh"],
    ["sithis", "Sithis"],
    ["tuwhacca", "Tu'whacca"],
    ["hoonding", "HoonDing"],
    ["leki", "Leki"],
    ["lunar", "Lunar"],
    ["hist", "Hist"],
    ["ancestor", "Ancestor"],
    ["malacath", "Malacath"],
    ["sect", "Sect"],
    ["branch", "Branch"],
    ["dawn", "Dawn"],
    ["journal", "Journal"],
  ];
  const symbolSpecs = {
    journal: [
      ["path", { d: "M11 14v23c5 -2 9 -2 13 1V15c-4 -3 -8 -3 -13 -1Z" }],
      ["path", { d: "M24 15v23c4 -3 8 -3 13 -1V14c-5 -2 -9 -2 -13 1Z" }],
      ["path", { d: "M15 20h5M15 26h5M28 20h5M28 26h5", class: "symbol-thin" }],
    ],
    dawn: [
      ["path", { d: "M8 33h32" }],
      ["path", { d: "M15 33a9 9 0 0 1 18 0" }],
      ["path", { d: "M24 10v7M12 18l5 5M36 18l-5 5" }],
    ],
    kyne: [
      ["path", { d: "M10 29c7 -10 16 -13 28 -7" }],
      ["path", { d: "M14 34c7 -5 14 -5 23 0" }],
      ["path", { d: "M24 10v13M20 15l4 -5 4 5" }],
    ],
    talos: [
      ["path", { d: "M24 8v30" }],
      ["path", { d: "M16 18h16" }],
      ["path", { d: "M19 38h10" }],
      ["path", { d: "M18 13l6 -5 6 5" }],
    ],
    "auri-el": [
      ["circle", { cx: "24", cy: "24", r: "8" }],
      ["path", { d: "M24 7v7M24 34v7M7 24h7M34 24h7M12 12l5 5M31 31l5 5M36 12l-5 5M17 31l-5 5" }],
    ],
    akatosh: [
      ["path", { d: "M15 9h18M15 39h18M17 11c0 8 14 8 14 18M31 37c0 -8 -14 -8 -14 -18" }],
      ["path", { d: "M19 24h10", class: "symbol-thin" }],
    ],
    arkay: [
      ["circle", { cx: "24", cy: "24", r: "13" }],
      ["path", { d: "M24 11v26M14 24h20" }],
    ],
    dibella: [
      ["path", { d: "M24 17c3 -7 10 -7 11 -1 1 6 -7 10 -11 18 -4 -8 -12 -12 -11 -18 1 -6 8 -6 11 1Z" }],
      ["circle", { cx: "24", cy: "24", r: "3", class: "symbol-thin" }],
    ],
    julianos: [
      ["path", { d: "M24 8l4 12 12 4 -12 4 -4 12 -4 -12 -12 -4 12 -4 4 -12Z" }],
      ["path", { d: "M24 17v14M17 24h14", class: "symbol-thin" }],
    ],
    mara: [
      ["path", { d: "M11 25c8 -13 18 -13 26 0" }],
      ["path", { d: "M15 25v12h18V25" }],
      ["path", { d: "M20 37v-8h8v8" }],
    ],
    stendarr: [
      ["path", { d: "M24 8l14 6v10c0 8 -6 14 -14 17 -8 -3 -14 -9 -14 -17V14l14 -6Z" }],
      ["path", { d: "M24 15v17M17 23h14" }],
    ],
    zenithar: [
      ["path", { d: "M15 32h18l4 6H11l4 -6Z" }],
      ["path", { d: "M18 19l8 -8 5 5 -8 8" }],
      ["path", { d: "M14 23l8 8" }],
    ],
    yffre: [
      ["path", { d: "M24 38 C18 38 12 34 11 28" }],
      ["path", { d: "M24 38 C30 38 36 34 37 28" }],
      ["path", { d: "M24 38 V20" }],
      ["path", { d: "M24 20 C16 20 10 16 10 10 C10 8 12 8 14 10 C16 12 18 14 24 14" }],
      ["path", { d: "M24 20 C32 20 38 16 38 10 C38 8 36 8 34 10 C32 12 30 14 24 14" }],
      ["circle", { cx: "24", cy: "14", r: "3", class: "symbol-thin" }],
    ],
    zen: [
      ["path", { d: "M24 12 V32" }],
      ["path", { d: "M18 32 H30" }],
      ["path", { d: "M14 20 H34" }],
      ["path", { d: "M14 20 L12 28 H20 L18 20", class: "symbol-thin" }],
      ["path", { d: "M34 20 L32 28 H40 L38 20", class: "symbol-thin" }],
      ["circle", { cx: "24", cy: "12", r: "2" }],
    ],
    "baan-dar": [
      ["path", { d: "M16 14 C12 16 10 20 10 24 C10 34 16 38 24 38 C32 38 38 34 38 24 C38 20 36 16 32 14 Z" }],
      ["path", { d: "M24 10 V38" }],
      ["path", { d: "M14 22 C14 20 16 19 18 20", class: "symbol-thin" }],
      ["circle", { cx: "30", cy: "22", r: "2.5" }],
      ["path", { d: "M27 18 C28 17 32 17 33 18", class: "symbol-thin" }],
      ["path", { d: "M18 10 C20 8 28 8 30 10" }],
    ],
    lunar: [
      ["path", { d: "M30 10 a14 14 0 1 0 0 28 a10 14 0 1 1 0 -28 Z" }],
      ["circle", { cx: "19", cy: "24", r: "4", class: "symbol-thin" }],
    ],
    hist: [
      ["path", { d: "M24 40 V22" }],
      ["path", { d: "M24 40 C18 40 13 38 11 34", class: "symbol-thin" }],
      ["path", { d: "M24 40 C30 40 35 38 37 34", class: "symbol-thin" }],
      ["path", { d: "M14 22 A10 10 0 0 1 34 22" }],
      ["path", { d: "M17 26 A7 7 0 0 1 31 26", class: "symbol-thin" }],
      ["circle", { cx: "24", cy: "14", r: "2.5" }],
    ],
    ancestor: [
      ["path", { d: "M14 16 Q24 8 34 16 Q34 34 24 40 Q14 34 14 16 Z" }],
      ["circle", { cx: "19", cy: "22", r: "1.8" }],
      ["circle", { cx: "29", cy: "22", r: "1.8" }],
      ["path", { d: "M24 26 V32", class: "symbol-thin" }],
      ["path", { d: "M18 14 Q24 11 30 14", class: "symbol-thin" }],
    ],
    malacath: [
      ["path", { d: "M16 38 C10 28 14 18 24 16" }],
      ["path", { d: "M24 16 L24 8 M16 10 H32 V14 H16 Z" }],
      ["path", { d: "M24 16 V30", class: "symbol-thin" }],
    ],
    sect: [
      ["path", { d: "M12 36 C20 30 30 18 36 12" }],
      ["path", { d: "M36 36 C28 30 18 18 12 12" }],
      ["circle", { cx: "24", cy: "24", r: "2.4" }],
    ],
    branch: [
      ["path", { d: "M10 34 C20 30 30 24 38 12" }],
      ["path", { d: "M22 25 q8 -10 14 -7 q-5 9 -14 7 Z", class: "symbol-thin" }],
      ["path", { d: "M16 30 q4 5 8 0", class: "symbol-thin" }],
    ],
    azura: [
      ["path", { d: "M24 6 L27 18 L39 14 L30 23 L42 28 L29 28 L33 40 L24 31 L15 40 L19 28 L6 28 L18 23 L9 14 L21 18 Z" }],
      ["path", { d: "M10 34 A14 14 0 0 0 38 34", class: "symbol-thin" }],
    ],
    boethiah: [
      ["path", { d: "M24 42 V12" }],
      ["path", { d: "M20 16 L24 10 L28 16" }],
      ["path", { d: "M24 38 C16 36 16 30 24 28 C32 26 32 20 24 18 C18 16 20 12 26 12", class: "symbol-thin" }],
      ["circle", { cx: "26", cy: "12", r: "1.3" }],
    ],
    mephala: [
      ["path", { d: "M24 8 V40 M10 16 L38 32 M38 16 L10 32 M8 24 H40" }],
      ["path", { d: "M24 14 A10 10 0 0 1 34 24 A10 10 0 0 1 24 34 A10 10 0 0 1 14 24 A10 10 0 0 1 24 14", class: "symbol-thin" }],
    ],
    shor: [
      ["path", { d: "M24 40 C8 28 11 14 18 12 C22 11 24 14 24 17 C24 14 26 11 30 12 C37 14 40 28 24 40 Z" }],
      ["path", { d: "M18 22 L24 30 L30 22", class: "symbol-thin" }],
    ],
    tsun: [
      ["path", { d: "M24 9 V41" }],
      ["path", { d: "M24 13 L12 16 L16 24 L24 20 Z" }],
      ["path", { d: "M24 13 L36 16 L32 24 L24 20 Z" }],
    ],
    stuhn: [
      ["path", { d: "M24 8 L37 13 V24 C37 32 31 38 24 41 C17 38 11 32 11 24 V13 Z" }],
      ["circle", { cx: "21", cy: "22", r: "3", class: "symbol-thin" }],
      ["path", { d: "M23 24 L30 31 M27 31 H30 V28", class: "symbol-thin" }],
    ],
    kynareth: [
      ["path", { d: "M10 22 C16 28 20 28 24 23 C28 28 32 28 38 22" }],
      ["path", { d: "M24 23 V31" }],
      ["path", { d: "M16 34 V39 M24 35 V41 M32 34 V39", class: "symbol-thin" }],
    ],
    magnus: [
      ["circle", { cx: "24", cy: "22", r: "7" }],
      ["path", { d: "M24 6 V11 M24 33 V38 M8 22 H13 M35 22 H40 M13 11 L16 14 M35 11 L32 14" }],
      ["path", { d: "M18 40 L24 28 L30 40", class: "symbol-thin" }],
    ],
    xarxes: [
      ["path", { d: "M14 12 C12 12 12 16 14 16 H32 C30 16 30 12 32 12 C36 12 36 36 32 36 H14 C12 36 12 32 14 32" }],
      ["path", { d: "M30 10 L36 22", class: "symbol-thin" }],
      ["path", { d: "M18 22 H27 M18 27 H24", class: "symbol-thin" }],
    ],
    trinimac: [
      ["path", { d: "M24 18 V42" }],
      ["path", { d: "M19 24 L24 18 L29 24" }],
      ["circle", { cx: "24", cy: "12", r: "5" }],
      ["path", { d: "M29.0 12.0 L32.0 12.0", class: "symbol-thin" }],
      ["path", { d: "M27.5 15.5 L29.7 17.7", class: "symbol-thin" }],
      ["path", { d: "M24.0 17.0 L24.0 20.0", class: "symbol-thin" }],
      ["path", { d: "M20.5 15.5 L18.3 17.7", class: "symbol-thin" }],
      ["path", { d: "M19.0 12.0 L16.0 12.0", class: "symbol-thin" }],
      ["path", { d: "M20.5 8.5 L18.3 6.3", class: "symbol-thin" }],
      ["path", { d: "M24.0 7.0 L24.0 4.0", class: "symbol-thin" }],
      ["path", { d: "M27.5 8.5 L29.7 6.3", class: "symbol-thin" }],
    ],
    khenarthi: [
      ["path", { d: "M10 30 C18 26 22 26 24 22 C26 26 30 26 38 30" }],
      ["path", { d: "M24 22 V10" }],
      ["path", { d: "M21 14 L24 10 L27 14" }],
      ["path", { d: "M14 36 Q24 32 34 36", class: "symbol-thin" }],
    ],
    rajhin: [
      ["path", { d: "M24 30 C18 30 16 24 20 22 C18 18 22 16 24 19 C26 16 30 18 28 22 C32 24 30 30 24 30 Z" }],
      ["circle", { cx: "16", cy: "18", r: "2.6" }],
      ["circle", { cx: "22", cy: "13", r: "2.6" }],
      ["circle", { cx: "30", cy: "13", r: "2.6" }],
      ["circle", { cx: "34", cy: "18", r: "2.6" }],
    ],
    alkosh: [
      ["path", { d: "M10 30 C10 18 18 14 26 16 C30 12 36 12 40 14 C36 16 36 20 38 22 C40 28 34 34 26 32" }],
      ["circle", { cx: "30", cy: "20", r: "1.5" }],
      ["path", { d: "M20 24 Q26 28 32 26", class: "symbol-thin" }],
      ["path", { d: "M14 30 L11 34 M18 31 L16 36", class: "symbol-thin" }],
    ],
    sithis: [
      ["circle", { cx: "24", cy: "24", r: "14", class: "symbol-thin" }],
      ["path", { d: "M24 12 C16 18 16 30 24 36 C30 31 30 17 24 12 Z" }],
    ],
    tuwhacca: [
      ["path", { d: "M12 40 V20 A12 12 0 0 1 36 20 V40" }],
      ["path", { d: "M24 16 L26 21 L31 21 L27 24 L29 29 L24 26 L19 29 L21 24 L17 21 L22 21 Z", class: "symbol-thin" }],
    ],
    hoonding: [
      ["path", { d: "M12 12 L28 24 L12 36" }],
      ["path", { d: "M22 12 L38 24 L22 36" }],
    ],
    leki: [
      ["path", { d: "M24 6 V40" }],
      ["path", { d: "M19 12 H29" }],
      ["path", { d: "M14 22 C22 18 26 26 34 22", class: "symbol-thin" }],
    ],
  };

  const nodes = {
    title: document.getElementById("pdv-title"),
    status: document.getElementById("pdv-status"),
    mark: document.getElementById("pdv-mark"),
    summary: document.getElementById("pdv-summary"),
    patron: document.getElementById("pdv-patron"),
    patronNote: document.getElementById("pdv-patron-note"),
    instrument: document.getElementById("pdv-instrument"),
    instrumentArt: document.getElementById("pdv-instrument-art"),
    tierLabel: document.getElementById("pdv-tier-label"),
    pietyBar: document.getElementById("pdv-piety-bar"),
    pietyText: document.getElementById("pdv-piety-text"),
    nextText: document.getElementById("pdv-next-text"),
    todayDelta: document.getElementById("pdv-today-delta"),
    todayMood: document.getElementById("pdv-today-mood"),
    driftLabel: document.getElementById("pdv-drift-label"),
    dawnStatus: document.getElementById("pdv-dawn-status"),
    relations: document.getElementById("pdv-relations"),
    acts: document.getElementById("pdv-acts"),
    rites: document.getElementById("pdv-rites"),
    debug: document.getElementById("pdv-debug"),
    symbolGallery: document.getElementById("pdv-symbol-gallery"),
    symbolGrid: document.getElementById("pdv-symbol-grid"),
    toasts: document.getElementById("pdv-toasts"),
    demoControls: document.getElementById("pdv-demo-controls"),
    startupModal: document.getElementById("pdv-startup-modal"),
    startupTitle: document.getElementById("pdv-startup-title"),
    startupSummary: document.getElementById("pdv-startup-summary"),
    startupOptions: document.getElementById("pdv-startup-options"),
    startupOptionTitle: document.getElementById("pdv-startup-option-title"),
    startupOptionSummary: document.getElementById("pdv-startup-option-summary"),
    startupOptionDescription: document.getElementById("pdv-startup-option-description"),
    startupAdvisory: document.getElementById("pdv-startup-advisory"),
    startupMode: document.getElementById("pdv-startup-mode"),
    startupConfirm: document.getElementById("pdv-startup-confirm"),
    startupClose: document.getElementById("pdv-startup-close"),
    journalModal: document.getElementById("pdv-journal-modal"),
    journalTitle: document.getElementById("pdv-journal-title"),
    journalSummary: document.getElementById("pdv-journal-summary"),
    journalPath: document.getElementById("pdv-journal-path"),
    journalBy: document.getElementById("pdv-journal-by"),
    journalEmblem: document.getElementById("pdv-journal-emblem"),
    journalInstrument: document.getElementById("pdv-journal-instrument"),
    journalFoot: document.getElementById("pdv-journal-foot"),
    journalEntries: document.getElementById("pdv-journal-entries"),
    journalClose: document.getElementById("pdv-journal-close"),
  };

  const fallbackState = {
    title: "Devotion",
    status: "Waiting",
    patron: "None",
    patronNote: "Choose a path through play, prayer, and consequence.",
    summary: "No patron has answered yet.",
    tier: 0,
    tierLabel: "None",
    piety: 0,
    pietyToday: 0,
    todayMood: "No devotional acts have settled yet.",
    driftLabel: "Quiet",
    dawnStatus: "Nothing is waiting for dawn.",
    originRace: "Unknown",
    patronState: "Unset",
    acts: ["No devotional acts have been recorded today."],
    rites: ["No rites are available yet."],
    relations: [],
    debug: {},
  };

  let state = { ...fallbackState };
  let startupState = null;
  const recentToastKeys = new Map();

  const normalizeSymbol = (value, fallback = "journal") => {
    const key = text(value, fallback).trim().toLowerCase();
    return symbolAliases[key] || key || fallback;
  };

  const makeSvgElement = (tagName, attributes = {}) => {
    const element = document.createElementNS(svgNamespace, tagName);
    Object.entries(attributes).forEach(([key, value]) => {
      element.setAttribute(key, value);
    });
    return element;
  };

  const createSymbol = (symbolName) => {
    const normalized = normalizeSymbol(symbolName);
    const spec = symbolSpecs[normalized] || symbolSpecs.journal;
    const svg = makeSvgElement("svg", {
      class: "symbol",
      viewBox: "0 0 48 48",
      preserveAspectRatio: "xMidYMid meet",
      focusable: "false",
      "aria-hidden": "true",
    });
    spec.forEach(([tagName, attributes]) => {
      svg.appendChild(makeSvgElement(tagName, attributes));
    });
    return svg;
  };

  const renderSymbol = (node, symbolName) => {
    clear(node);
    node.appendChild(createSymbol(symbolName));
  };

  const text = (value, fallback = "") => {
    if (value === undefined || value === null || value === "") {
      return fallback;
    }
    return String(value);
  };

  const symbolDisplayNames = Object.fromEntries(gallerySymbols);

  const displayName = (value, fallback = "") => {
    const raw = text(value, fallback);
    const normalized = normalizeSymbol(raw, "");
    return symbolDisplayNames[normalized] || raw;
  };

  const numberOrZero = (value) => {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : 0;
  };

  const tierName = (tier) => {
    const numeric = numberOrZero(tier);
    if (numeric >= 3) return "Champion";
    if (numeric >= 2) return "Devoted";
    if (numeric >= 1) return "Seeker";
    return "None";
  };

  const nextThresholdText = (piety) => {
    const next = thresholds.find((threshold) => piety < threshold.value);
    if (!next) {
      return "Champion path";
    }
    return `${next.label} at ${next.value}`;
  };

  const signedText = (value) => {
    const numeric = numberOrZero(value);
    const rounded = Math.round(numeric * 10) / 10;
    const rendered = Number.isInteger(rounded) ? String(rounded) : rounded.toFixed(1);
    return rounded > 0 ? `+${rendered}` : rendered;
  };

  const clamp = (value, min, max) => Math.max(min, Math.min(max, numberOrZero(value)));
  const clamp01 = (value) => clamp(value, 0, 1);

  const appendSvg = (parent, tagName, attributes = {}) => {
    const element = makeSvgElement(tagName, attributes);
    parent.appendChild(element);
    return element;
  };

  const makeInstrumentSvg = () => makeSvgElement("svg", {
    class: "instrument-svg",
    viewBox: "0 0 300 150",
    preserveAspectRatio: "xMidYMid meet",
    focusable: "false",
    "aria-hidden": "true",
  });

  const appendMoonPhase = (svg, cx, cy, r, phase, fillCls = "instrument-fill") => {
    const normalizedPhase = clamp(phase || 1, 1, 8);
    const f = (normalizedPhase - 1) / 8;
    const a = f * 2 * Math.PI;
    const lit = (1 - Math.cos(a)) / 2;
    const rx = Math.abs(r * Math.cos(a));
    const top = `${cx},${cy - r}`;
    const bottom = `${cx},${cy + r}`;
    appendSvg(svg, "circle", { cx, cy, r, class: "instrument-dark" });
    if (lit > 0.985) {
      appendSvg(svg, "circle", { cx, cy, r, class: fillCls });
    } else if (lit >= 0.015) {
      const waxing = f < 0.5;
      const outer = waxing ? `A ${r} ${r} 0 0 1 ${bottom}` : `A ${r} ${r} 0 0 0 ${bottom}`;
      const innerSweep = waxing ? (lit < 0.5 ? 0 : 1) : (lit < 0.5 ? 1 : 0);
      appendSvg(svg, "path", { d: `M ${top} ${outer} A ${rx} ${r} 0 0 ${innerSweep} ${top} Z`, class: fillCls });
    }
    appendSvg(svg, "circle", { cx, cy, r, class: "instrument-outline" });
  };

  const addInstrumentCaption = (slot, inst = {}, fallbackTitle = "Devotion") => {
    const caption = document.createElement("div");
    caption.className = "instrument-caption";
    const title = document.createElement("strong");
    title.textContent = text(inst.state || inst.tierLabel, fallbackTitle);
    const detail = document.createElement("span");
    detail.textContent = text(inst.kind, "piety");
    caption.append(title, detail);
    slot.appendChild(caption);
  };

  // Trend -> fill family. gold = rising or holding at full; grey = waning.
  const isWaning = (inst = {}) => text(inst.trend, "").toLowerCase() === "down";
  const fillClass = (inst) => (isWaning(inst) ? "instrument-fade" : "instrument-fill");
  const fillSoftClass = (inst) => (isWaning(inst) ? "instrument-fade-soft" : "instrument-fill-soft");

  // 6-pointed medieval star + fat-bottomed blood-drop path helpers (Daedric).
  const starSixPath = (cx, cy, r) => {
    let d = "";
    const inner = r * 0.4;
    for (let i = 0; i < 12; i += 1) {
      const rad = i % 2 === 0 ? r : inner;
      const a = -Math.PI / 2 + (i * Math.PI) / 6;
      d += (i === 0 ? "M" : "L") + (cx + rad * Math.cos(a)).toFixed(1) + " " + (cy + rad * Math.sin(a)).toFixed(1);
    }
    return d + "Z";
  };
  const bloodDropPath = (cx, cy, r) =>
    `M${cx} ${(cy - r * 1.8).toFixed(1)} C${cx + r * 1.15} ${cy - r * 0.2} ${cx + r * 1.05} ${cy + r * 0.9} ${cx} ${cy + r} C${cx - r * 1.05} ${cy + r * 0.9} ${cx - r * 1.15} ${cy - r * 0.2} ${cx} ${(cy - r * 1.8).toFixed(1)} Z`;

  const renderPietyInstrument = (slot, inst = {}) => {
    const svg = makeInstrumentSvg();
    const instData = inst.data || {};
    const piety = clamp(instData.piety !== undefined ? instData.piety : state.piety, 0, 85);
    const primary = clamp01(inst.primary || piety / 85);
    const fill = fillClass(inst);
    const fillWidth = Math.round(190 * primary);
    appendSvg(svg, "rect", { x: "74", y: "68", width: "190", height: "14", rx: "7", class: "instrument-track" });
    appendSvg(svg, "rect", { x: "74", y: "68", width: fillWidth, height: "14", rx: "7", class: fill });
    [1, 2, 3].forEach((tier, index) => {
      const instrumentTier = inst.tier !== undefined ? inst.tier : state.tier;
      const thresholdValue = thresholds[index] ? thresholds[index].value : 85;
      const thresholdX = Math.round(74 + 190 * clamp01(thresholdValue / 85));
      appendSvg(svg, "circle", {
        cx: thresholdX,
        cy: 105,
        r: "6",
        class: numberOrZero(instrumentTier) >= tier ? fill : "instrument-muted",
      });
    });
    appendSvg(svg, "circle", { cx: "39", cy: "75", r: "24", class: "instrument-outline" });
    // a little sun within the standing ring
    appendSvg(svg, "circle", { cx: "39", cy: "75", r: "7", class: fill });
    for (let ray = 0; ray < 8; ray += 1) {
      const angle = (Math.PI / 4) * ray;
      const cos = Math.cos(angle);
      const sin = Math.sin(angle);
      appendSvg(svg, "path", {
        d: `M${(39 + 11 * cos).toFixed(1)} ${(75 + 11 * sin).toFixed(1)} L${(39 + 16 * cos).toFixed(1)} ${(75 + 16 * sin).toFixed(1)}`,
        class: "instrument-thin",
      });
    }
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, tierName(state.tier));
  };

  const renderLunarInstrument = (slot, inst = {}) => {
    const data = inst.data || {};
    const phase = clamp(data.phase || 1, 1, 8);
    const svg = makeInstrumentSvg();
    const fill = fillClass(inst);
    appendMoonPhase(svg, 118, 80, 30, phase, fill);
    appendMoonPhase(svg, 178, 50, 14, phase, fill);
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, text(data.focus, "Lunar Lattice"));
  };

  const renderHistInstrument = (slot, inst = {}) => {
    const data = inst.data || {};
    const hist = clamp(data.hist, 0, 100);
    const people = clamp(data.people, 0, 100);
    const voidValue = clamp(data.void, 0, 100);
    const svg = makeInstrumentSvg();
    appendSvg(svg, "path", { d: "M150 126 V68", class: "instrument-outline" });
    appendSvg(svg, "path", { d: "M150 126 C120 125 98 118 82 104", class: "instrument-thin" });
    appendSvg(svg, "path", { d: "M150 126 C180 125 202 118 218 104", class: "instrument-thin" });
    const arcs = 1 + Math.round(people / 50);
    for (let i = 0; i < arcs; i += 1) {
      const radius = 36 + i * 18;
      appendSvg(svg, "path", { d: `M${150 - radius} 70 A ${radius} ${radius} 0 0 1 ${150 + radius} 70`, class: i === 0 || hist > 35 ? "instrument-outline" : "instrument-muted" });
    }
    appendSvg(svg, "circle", { cx: "150", cy: "48", r: "5", class: data.voidActive || voidValue > 60 ? "instrument-warning" : "instrument-fill" });
    if (voidValue > 0) {
      appendSvg(svg, "path", { d: `M238 42 L266 75 L238 108 Z`, class: "instrument-warning-thin" });
    }
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, "The Hist");
  };

  const renderAncestorInstrument = (slot, inst = {}) => {
    const data = inst.data || {};
    const depthValue = data.depth !== undefined ? data.depth : inst.tier;
    const depth = clamp(depthValue, 0, 3);
    const svg = makeInstrumentSvg();
    const fillSoft = fillSoftClass(inst);
    appendSvg(svg, "path", { d: "M96 124 V56 Q150 22 204 56 V124", class: "instrument-outline" });
    const xs = [120, 150, 180];
    [0, 1, 2].forEach((index) => {
      const x = xs[index] - 15;
      appendSvg(svg, "path", { d: `M${x} 72 Q${x + 15} 58 ${x + 30} 72 Q${x + 30} 104 ${x + 15} 113 Q${x} 104 ${x} 72 Z`, class: depth > index ? fillSoft : "instrument-muted" });
      appendSvg(svg, "circle", { cx: x + 9, cy: "84", r: "2", class: "instrument-dark" });
      appendSvg(svg, "circle", { cx: x + 21, cy: "84", r: "2", class: "instrument-dark" });
    });
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, "Ancestor layer");
  };

  const renderForgeInstrument = (slot, inst = {}) => {
    const svg = makeInstrumentSvg();
    const heat = clamp01(inst.primary || 0.5);
    appendSvg(svg, "path", { d: "M92 110 H208 L226 128 H74 Z", class: "instrument-fill-soft" });
    appendSvg(svg, "path", { d: "M122 102 H178 L194 112 H106 Z", class: "instrument-outline" });
    appendSvg(svg, "path", { d: `M150 ${96 - heat * 24} C128 82 136 58 150 44 C164 58 172 82 150 ${96 - heat * 24} Z`, class: heat > 0.7 ? "instrument-fill" : "instrument-outline" });
    appendSvg(svg, "path", { d: "M92 92 C70 74 72 50 92 34", class: "instrument-thin" });
    appendSvg(svg, "path", { d: "M208 92 C230 74 228 50 208 34", class: "instrument-thin" });
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, "Malacath");
  };

  const renderSectsInstrument = (slot, inst = {}) => {
    const data = inst.data || {};
    const active = text(data.sect || inst.state, "").toLowerCase();
    const svg = makeInstrumentSvg();
    ["crown", "forebear", "ash'abah"].forEach((sect, index) => {
      const x = 82 + index * 68;
      const selected = active.indexOf(sect.replace("'", "")) >= 0 || (sect === "ash'abah" && active.indexOf("ash") >= 0);
      appendSvg(svg, "path", { d: `M${x} 40 C${x + 16} 70 ${x + 12} 98 ${x} 122 C${x - 12} 98 ${x - 16} 70 ${x} 40 Z`, class: selected ? "instrument-fill-soft" : "instrument-muted" });
      appendSvg(svg, "path", { d: `M${x - 18} 120 H${x + 18}`, class: "instrument-thin" });
      if (selected) appendSvg(svg, "circle", { cx: x, cy: "82", r: "30", class: "instrument-outline" });
    });
    appendSvg(svg, "path", { d: "M60 130 C110 112 190 112 240 130", class: "instrument-thin" });
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, "Yokudan path");
  };

  const renderBranchInstrument = (slot, inst = {}) => {
    const data = inst.data || {};
    const rings = clamp(data.evidenceDays || inst.tier || 1, 1, 3);
    const svg = makeInstrumentSvg();
    appendSvg(svg, "path", { d: "M82 120 C126 100 174 70 220 30", class: "instrument-outline" });
    appendSvg(svg, "path", { d: "M174 64 q38 -28 56 -12 q-22 30 -56 12 Z", class: "instrument-fill-soft" });
    for (let i = 0; i < rings; i += 1) {
      appendSvg(svg, "path", { d: `M${88 - i * 8} 124 A ${28 + i * 8} ${20 + i * 5} 0 0 1 ${134 + i * 8} 124`, class: "instrument-thin" });
    }
    if (data.pactBound) {
      appendSvg(svg, "path", { d: "M122 100 L142 112 M138 88 L158 100 M154 76 L174 88", class: "instrument-warning-thin" });
    }
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, "Green Pact");
  };

  const renderDaedricInstrument = (slot, inst = {}) => {
    const level = clamp01(inst.primary !== undefined ? inst.primary : clamp(state.piety, 0, 85) / 85);
    const lit = Math.round(level * 5);
    const waning = isWaning(inst);
    const svg = makeInstrumentSvg();
    for (let i = 0; i < 5; i += 1) {
      const x = 70 + i * 40;
      appendSvg(svg, "path", { d: starSixPath(x, 52, 13), class: i < lit ? (waning ? "instrument-star-muted" : "instrument-star") : "instrument-muted" });
    }
    for (let i = 0; i < 5; i += 1) {
      const x = 70 + i * 40;
      appendSvg(svg, "path", { d: bloodDropPath(x, 104, 9), class: i < lit ? (waning ? "instrument-fade" : "instrument-blood") : "instrument-blood-muted" });
    }
    slot.appendChild(svg);
    addInstrumentCaption(slot, inst, "Daedric pact");
  };

  const instrumentRenderers = {
    piety: renderPietyInstrument,
    lunar: renderLunarInstrument,
    ancestor: renderAncestorInstrument,
    daedric: renderDaedricInstrument,
    // These paths now share the Nord pattern (bar + pips) per the locked design.
    hist: renderPietyInstrument,
    forge: renderPietyInstrument,
    sects: renderPietyInstrument,
    branch: renderPietyInstrument,
  };

  const pietyInstrumentFromState = () => ({
    kind: "piety",
    tier: state.tier,
    tierLabel: state.tierLabel,
    primary: clamp(state.piety, 0, 85) / 85,
    state: text(state.tierLabel, tierName(state.tier)),
    data: { piety: state.piety, pietyToday: state.pietyToday },
  });

  const renderInstrument = () => {
    if (!nodes.instrumentArt) return;
    clear(nodes.instrumentArt);
    const inst = state.instrument && typeof state.instrument === "object"
      ? state.instrument
      : pietyInstrumentFromState();
    const kind = text(inst.kind, "piety").toLowerCase();
    const renderer = instrumentRenderers[kind] || renderPietyInstrument;
    if (nodes.instrument) {
      nodes.instrument.setAttribute("data-instrument-kind", instrumentRenderers[kind] ? kind : "piety");
    }
    renderer(nodes.instrumentArt, inst);
  };

  const eventAliases = {
    piety: "favor",
    gain: "favor",
    piety_gain: "favor",
    dawn_settle: "dawn",
    dawn_settled: "dawn",
    decay: "neglect",
    warning: "neglect",
    tier_up: "tier",
    tier_change: "tier",
    rival: "rivalry",
    path_shift: "shift",
    mode_change: "shift",
    track_shift: "shift",
    daedric_boon: "daedric",
    daedric_price: "daedric",
    daedric_lapse: "daedric",
    daedric_residue: "daedric",
    curse_onset: "curse",
    curse_cure: "curse",
    curse_shift: "curse",
    substrate_act: "substrate",
    substrate_deepen: "substrate",
    substrate_thin: "substrate",
  };

  const eventName = (payload = {}) => {
    const rawName = text(payload.event || payload.type || payload.kind, "").trim().toLowerCase();
    return eventAliases[rawName] || rawName;
  };

  const normalizeToastPayload = (payload = {}) => {
    if (!payload || typeof payload === "string") {
      return payload;
    }

    const normalized = { ...payload };
    normalized.event = eventName(payload);

    if (!normalized.deity) {
      normalized.deity = text(payload.deityName || payload.patron, "");
    }
    if (!normalized.symbol) {
      normalized.symbol = text(payload.mark, "");
    }
    if (!normalized.context) {
      normalized.context = text(payload.act || payload.source || payload.label, "");
    }
    if (!normalized.message) {
      normalized.message = text(payload.text, "");
    }
    if (!normalized.tierLabel) {
      normalized.tierLabel = text(payload.tierName, "");
    }
    if (!normalized.rival) {
      normalized.rival = text(payload.rivalName, "");
    }
    if (!normalized.shiftMode) {
      normalized.shiftMode = text(payload.shiftMode || payload.mode || payload.state, "");
    }
    if (!normalized.prince) {
      normalized.prince = text(payload.prince || payload.daedra || payload.daedricPrince, "");
    }
    if (!normalized.phase) {
      normalized.phase = text(payload.phase || payload.daedricPhase, "");
    }
    if (!normalized.curse) {
      normalized.curse = text(payload.curse || payload.curseType, "");
    }
    if (!normalized.substrate) {
      normalized.substrate = text(payload.substrate, "");
    }
    if (!normalized.state) {
      normalized.state = text(payload.state, "");
    }

    return normalized;
  };

  const deityName = (payload = {}) => displayName(payload.deity, displayName(state.patron, "Devotion"));

  const possessive = (value) => {
    const name = text(value, "Devotion");
    return name.endsWith("s") ? `${name}'` : `${name}'s`;
  };

  const contextName = (payload = {}) => text(payload.context, "");

  const curseLabel = (payload = {}) => {
    const curse = text(payload.curse, "").toLowerCase();
    if (curse === "vampire") return "Vampirism";
    if (curse === "werewolf") return "Lycanthropy";
    return "The curse";
  };

  const substrateName = (payload = {}) => {
    const s = text(payload.substrate, "").toLowerCase();
    if (s === "lunar") return "The moons";
    if (s === "hist") return "The Hist";
    if (s === "ancestor") return "Your ancestors";
    if (s === "stronghold") return "The stronghold";
    if (s === "sect") return "Your sect";
    return "Your path";
  };

  const eventLanguage = {
    favor: {
      tone: "good",
      symbol: (payload) => payload.symbol || payload.mark || deityName(payload),
      title: (payload) => `${deityName(payload)} remembers`,
      message: (payload) => {
        const context = contextName(payload);
        return context ? `${context} did not pass unseen.` : "Your act did not pass unseen.";
      },
      listTitle: (payload) => contextName(payload) || "Favor remembered",
      listText: (payload) => text(payload.text || payload.message, `${deityName(payload)} took notice.`),
    },
    dawn: {
      tone: "neutral",
      symbol: () => "dawn",
      title: () => "Dawn settles",
      message: () => "Your prayers settle into practice.",
      listTitle: () => "Dawn passage",
      listText: () => "The day's signs wait for dawn.",
    },
    neglect: {
      tone: "warning",
      symbol: () => "journal",
      title: () => "Rites thinning",
      message: (payload) => `${possessive(deityName(payload))} rites have grown quiet.`,
      listTitle: () => "Rites thinning",
      listText: (payload) => `${possessive(deityName(payload))} path needs attention.`,
    },
    creed: {
      tone: "warning",
      symbol: (payload) => payload.symbol || payload.mark || deityName(payload),
      title: () => "Creed broken",
      message: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        return `${deityName(payload)} marks a breach of faith.`;
      },
      listTitle: (payload) => contextName(payload) || "Creed broken",
      listText: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        return `${possessive(deityName(payload))} path was crossed.`;
      },
    },
    tier: {
      tone: "good",
      symbol: (payload) => payload.symbol || payload.mark || deityName(payload),
      title: () => "Devotion deepens",
      message: (payload) => `${deityName(payload)} names you ${text(payload.tierLabel || payload.tierName, "faithful")}.`,
      listTitle: (payload) => text(payload.tierLabel || payload.tierName, "Tier changed"),
      listText: (payload) => `${possessive(deityName(payload))} path has deepened.`,
    },
    rivalry: {
      tone: "warning",
      symbol: (payload) => payload.symbol || payload.mark || text(payload.rivalSymbol || payload.rival, "journal"),
      title: () => "Rivalry stirs",
      message: (payload) => `${text(payload.rival || payload.rivalName, "A rival path")} turns colder toward this devotion.`,
      listTitle: () => "Rivalry stirred",
      listText: (payload) => `${text(payload.rival || payload.rivalName, "A rival path")} has taken note.`,
    },
    shift: {
      tone: () => "neutral",
      symbol: (payload) => text(payload.symbol, "journal"),
      title: (payload) => {
        const mode = displayName(payload.shiftMode, "");
        return mode ? `The path turns toward ${mode}` : "Your path shifts";
      },
      message: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const mode = displayName(payload.shiftMode, "");
        return mode
          ? `${mode} has begun to shape your practice.`
          : "Your practice has found a new shape.";
      },
      listTitle: (payload) => displayName(payload.shiftMode, "Path shift"),
      listText: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const mode = displayName(payload.shiftMode, "");
        return mode
          ? `${mode} is now the shape of your practice.`
          : "Your path has settled into a new mode.";
      },
    },
    daedric: {
      tone: (payload) => {
        const phase = text(payload.phase, "");
        if (phase === "milestone") return "good";
        if (phase === "boon") return "good";
        if (phase === "residue") return "neutral";
        return "warning";
      },
      symbol: (payload) => text(payload.symbol, "journal"),
      title: (payload) => {
        const prince = text(payload.prince, "A Daedric Prince");
        const phase = text(payload.phase, "");
        if (phase === "milestone") return `${prince} names you ${text(payload.tierLabel, "marked")}`;
        if (phase === "boon") return `${prince} is satisfied`;
        if (phase === "price") return `${prince}'s price stirs`;
        if (phase === "lapse") return `${prince}'s hold breaks`;
        if (phase === "residue") return "Residue lingers";
        return `${prince} takes note`;
      },
      message: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const phase = text(payload.phase, "");
        const prince = text(payload.prince, "The Prince");
        if (phase === "milestone") return text(payload.flavor, `${prince} marks the pact.`);
        if (phase === "boon") return "The rite was answered.";
        if (phase === "price") return `${possessive(prince)} cost is rising.`;
        if (phase === "lapse") return "The path has been released.";
        if (phase === "residue") return "The mark has not fully faded.";
        return "Something stirs in that quarter.";
      },
      listTitle: (payload) => {
        const prince = text(payload.prince, "Daedric");
        const phase = text(payload.phase, "");
        if (phase === "milestone") return `${prince}: ${text(payload.tierLabel, "milestone")}`;
        if (phase === "boon") return `${prince}: boon`;
        if (phase === "price") return `${prince}: price`;
        if (phase === "lapse") return `${prince}: lapse`;
        if (phase === "residue") return `${prince}: residue`;
        return `${prince}: contact`;
      },
      listText: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const phase = text(payload.phase, "");
        if (phase === "milestone") {
          return text(payload.flavor, "The pact deepens.");
        }
        return phase === "boon"
          ? "The rite was counted."
          : "The Prince has noticed.";
      },
    },
    curse: {
      tone: (payload) => (text(payload.phase, "") === "cure" ? "good" : "warning"),
      symbol: (payload) => text(payload.symbol, "journal"),
      title: (payload) => {
        const curse = curseLabel(payload);
        const phase = text(payload.phase, "");
        if (phase === "onset") return `${curse} takes hold`;
        if (phase === "cure") return `${curse} is lifted`;
        if (phase === "shift") return "The curse changes shape";
        return "A curse stirs";
      },
      message: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const phase = text(payload.phase, "");
        const curse = curseLabel(payload);
        if (phase === "onset") return `${curse} has taken root in your blood.`;
        if (phase === "cure") return `${curse} has been driven out.`;
        if (phase === "shift") return "One curse gives way to another.";
        return "Something has changed in your blood.";
      },
      listTitle: (payload) => {
        const curse = curseLabel(payload);
        const phase = text(payload.phase, "");
        if (phase === "cure") return `${curse}: lifted`;
        if (phase === "shift") return "Curse shifted";
        return `${curse}: onset`;
      },
      listText: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        return text(payload.phase, "") === "cure"
          ? "The mark has been lifted."
          : "The curse weighs on your devotion.";
      },
    },
    substrate: {
      tone: (payload) => (text(payload.phase, "") === "thin" ? "warning" : "good"),
      symbol: (payload) => text(payload.symbol, "journal"),
      title: (payload) => {
        const name = substrateName(payload);
        const phase = text(payload.phase, "");
        if (phase === "deepen") return `${name} deepen`;
        if (phase === "thin") return `${name} thin`;
        return `${name} answer`;
      },
      message: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const name = substrateName(payload);
        const phase = text(payload.phase, "");
        if (phase === "deepen") return `${name} hold you more strongly now.`;
        if (phase === "thin") return `${name} are slipping from you.`;
        return `${name} marked what you did.`;
      },
      listTitle: (payload) => {
        const state = text(payload.state, "");
        return state || substrateName(payload);
      },
      listText: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        return text(payload.phase, "") === "thin"
          ? `${substrateName(payload)} need tending.`
          : `${substrateName(payload)} are with you.`;
      },
    },
  };

  const resolveEventPayload = (payload = {}) => {
    const normalized = normalizeToastPayload(payload);
    if (!normalized || typeof normalized === "string") {
      return normalized;
    }

    const name = eventName(normalized);
    const language = eventLanguage[name];
    if (!language) {
      return { ...normalized };
    }

    const resolved = { ...normalized, event: name };
    const languageTone = typeof language.tone === "function" ? language.tone(normalized) : language.tone;
    resolved.tone = text(normalized.tone, languageTone);
    resolved.symbol = text(normalized.symbol, language.symbol(normalized));
    resolved.title = text(normalized.title, language.title(normalized));
    resolved.message = text(normalized.message, language.message(normalized));
    resolved.listTitle = text(normalized.listTitle || normalized.title || normalized.label, language.listTitle(normalized));
    resolved.listText = text(normalized.listText || normalized.message, language.listText(normalized));
    return resolved;
  };

  const asArray = (value) => {
    if (!value) return [];
    return Array.isArray(value) ? value : [value];
  };

  const isJournalPayload = (payload) => (
    payload &&
    payload.mode === "journal" &&
    payload.journal &&
    typeof payload.journal === "object" &&
    !Array.isArray(payload.journal)
  );

  const titleCaseJournalSegment = (segment) => String(segment).split(/(\s+|-)/).map((part) => {
    if (/^[a-z][a-z]+$/.test(part)) return `${part.charAt(0).toUpperCase()}${part.slice(1)}`;
    return part;
  }).join("");

  const normalizeJournalSurveyText = (value) => {
    const source = text(value, "");
    const raceNames = new Map([
      ["nord", "Nord"],
      ["imperial", "Imperial"],
      ["breton", "Breton"],
      ["altmer", "Altmer"],
      ["bosmer", "Bosmer"],
      ["dunmer", "Dunmer"],
      ["khajiit", "Khajiit"],
      ["argonian", "Argonian"],
      ["orc", "Orc"],
      ["redguard", "Redguard"],
    ]);
    return source.replace(/^\s*([a-z]+)(?=\s*(?:\||-|$))/i, (match, race) => {
      const label = raceNames.get(String(race).toLowerCase());
      return label ? match.replace(race, label) : match;
    });
  };

  const journalPathText = (value) => normalizeJournalSurveyText(value)
    .replace(/\s*\|\s*/g, " - ")
    .split(/(\s+-\s+)/)
    .map((part) => part.includes("-") ? part : titleCaseJournalSegment(part))
    .join("")
    .trim();

  const startupModeLabel = (mode) => {
    const normalized = text(mode, "").toLowerCase();
    if (normalized === "explicit_choice") return "Explicit choice";
    return "Info only";
  };

  const startupConfirmLabel = (confirmRequired) => (confirmRequired ? "Confirm required" : "No confirm required");

  const syncOverlayVisibility = () => {
    const overlayVisible = [nodes.startupModal, nodes.journalModal].some((node) => node && !node.hidden);
    document.body.classList.toggle("startup-visible", overlayVisible);
  };

  const overlayController = (() => {
    const overlayNode = (name) => {
      if (name === "startup") return nodes.startupModal;
      if (name === "journal") return nodes.journalModal;
      return null;
    };
    const isOpen = (name) => {
      const node = overlayNode(name);
      return Boolean(node && !node.hidden);
    };
    const closeAll = () => {
      [nodes.startupModal, nodes.journalModal].forEach((node) => {
        if (node) node.hidden = true;
      });
      syncOverlayVisibility();
    };
    const close = (name) => {
      const node = overlayNode(name);
      if (node) {
        node.hidden = true;
      }
      syncOverlayVisibility();
    };
    const open = (name) => {
      closeAll();
      const node = overlayNode(name);
      if (node) {
        node.hidden = false;
      }
      syncOverlayVisibility();
    };
    return { close, closeAll, isOpen, open };
  })();

  const hideAllOverlays = () => overlayController.closeAll();
  const hideStartup = () => overlayController.close("startup");
  const hideJournal = () => overlayController.close("journal");

  const closeStartupFromView = () => {
    hideStartup();
  };

  const closeJournalFromView = () => {
    hideJournal();
    if (typeof window.PDVPanelClose === "function") {
      window.PDVPanelClose("journal|close");
    }
  };

  const isEscapeKey = (event) => (
    event.key === "Escape" ||
    event.key === "Esc" ||
    event.code === "Escape" ||
    event.keyCode === 27 ||
    event.which === 27
  );

  const onOverlayEsc = (event) => {
    if (!isEscapeKey(event)) return;
    if (overlayController.isOpen("journal")) {
      event.preventDefault();
      event.stopPropagation();
      closeJournalFromView();
      return;
    }
    if (overlayController.isOpen("startup")) {
      event.preventDefault();
      event.stopPropagation();
      closeStartupFromView();
    }
  };

  const JOURNAL_LABELS = { good: "Waxes", warning: "Wanes", neutral: "Holds" };

  // Frontispiece half-sun (medieval sun-in-splendour rising from the horizon).
  const buildJournalSun = () => {
    const cx = 120, cy = 128, ink = "#3a2c1a";
    const P = (a, r) => [(cx + r * Math.cos(a * Math.PI / 180)).toFixed(1), (cy - r * Math.sin(a * Math.PI / 180)).toFixed(1)];
    let straights = "", flames = "", longRays = "", spokeDots = "", spokes = "";
    const angles = [];
    for (let a = 6; a <= 174; a += 14) angles.push(a);
    angles.forEach((a, i) => {
      const [rx1, ry1] = P(a, 36), [rx2, ry2] = P(a, i % 2 === 0 ? 83 : 72);
      longRays += `<line x1="${rx1}" y1="${ry1}" x2="${rx2}" y2="${ry2}"/>`;
      if (i % 2 === 0) {
        const hw = 2.3, rb = 33, rt = 74;
        const [x1, y1] = P(a - hw, rb), [x2, y2] = P(a, rt), [x3, y3] = P(a + hw, rb);
        straights += `M${x1} ${y1}L${x2} ${y2}L${x3} ${y3}Z`;
      } else {
        const rb = 33, rt = 60, w = 4.2;
        const [blx, bly] = P(a - w, rb), [brx, bry] = P(a + w, rb), [tx, ty] = P(a, rt);
        const [clx, cly] = P(a - 3, rb + (rt - rb) * 0.62), [crx, cry] = P(a + 6, rb + (rt - rb) * 0.48);
        flames += `M${blx} ${bly}Q${clx} ${cly} ${tx} ${ty}Q${crx} ${cry} ${brx} ${bry}Z`;
        [39, 45, 51].forEach((r) => {
          const [dx, dy] = P(a, r);
          spokeDots += `<circle cx="${dx}" cy="${dy}" r="1.35"/>`;
        });
      }
    });
    [30, 60, 90, 120, 150].forEach((a) => {
      const [sx, sy] = P(a, 28);
      spokes += `<line x1="${cx}" y1="${cy}" x2="${sx}" y2="${sy}"/>`;
    });
    const disc = `M${cx - 30} ${cy} A30 30 0 0 1 ${cx + 30} ${cy} Z`;
    const innerArc = `M${cx - 21} ${cy} A21 21 0 0 1 ${cx + 21} ${cy}`;
    const outerArc = `M${cx - 30} ${cy} A30 30 0 0 1 ${cx + 30} ${cy}`;
    return `<svg viewBox="0 0 240 150" width="100%" height="100%" aria-hidden="true">`
      + `<defs><linearGradient id="pdv-bod-sun" x1="0" y1="0" x2="0" y2="1">`
      + `<stop offset="0" stop-color="#f7df8b"/><stop offset="0.42" stop-color="#d6ab43"/><stop offset="1" stop-color="#a87f27"/></linearGradient></defs>`
      + `<g stroke="${ink}" stroke-width="2.2" stroke-linecap="round" opacity="0.9">${longRays}</g>`
      + `<g stroke="${ink}" stroke-width="1.4" stroke-linejoin="round">`
      + `<path d="${flames}" fill="url(#pdv-bod-sun)"/><path d="${straights}" fill="url(#pdv-bod-sun)"/><path d="${disc}" fill="url(#pdv-bod-sun)"/></g>`
      + `<g stroke="${ink}" stroke-width="1" stroke-linecap="round" opacity="0.45">${spokes}</g>`
      + `<g fill="${ink}" opacity="0.82">${spokeDots}</g>`
      + `<path d="${outerArc}" fill="none" stroke="${ink}" stroke-width="1.15" opacity="0.62"/>`
      + `<path d="${innerArc}" fill="none" stroke="${ink}" stroke-width="1" opacity="0.52"/>`
      + `<line x1="${cx - 88}" y1="${cy}" x2="${cx + 88}" y2="${cy}" stroke="${ink}" stroke-width="1.8" stroke-linecap="round"/></svg>`;
  };

  // Carved Elder Futhark rune per entry: Tiwaz (waxing) / merkstave (waning) /
  // Isa (holds), with rank-notches for magnitude. Tone carried by glyph + label.
  const journalRune = (valence, magnitude) => {
    const stone = "#d3c39a", edge = "#9c8a62";
    const tone = valence === "good" ? "#3f6b3a" : valence === "warning" ? "#9a2f2a" : "#6b5942";
    let rune = valence === "good"
      ? "M24 11V40 M24 11L12 23 M24 11L36 23"
      : valence === "warning"
      ? "M24 11V40 M24 40L12 28 M24 40L36 28"
      : "M24 9V42";
    if (valence !== "neutral" && magnitude > 0) {
      const ys = valence === "good" ? [37, 31, 25] : [15, 20, 25];
      for (let i = 0; i < Math.min(magnitude, 3); i += 1) rune += ` M15 ${ys[i]}L33 ${ys[i]}`;
    }
    const box = "M5 7c0-2 1-3 3-3l32 0c2 0 3 1 3 3l0 37c0 2-1 3-3 3l-32 0c-2 0-3-1-3-3Z";
    return `<svg width="42" height="46" viewBox="0 0 51 54" aria-hidden="true">`
      + `<path d="${box}" fill="${stone}" stroke="${edge}" stroke-width="1.4"/>`
      + `<path d="${rune}" fill="none" stroke="rgba(0,0,0,0.5)" stroke-width="4.6" stroke-linecap="square"/>`
      + `<path d="${rune}" fill="none" stroke="${tone}" stroke-width="2.7" stroke-linecap="square"/></svg>`;
  };

  // 1-3 weight from an explicit field, else bucketed from the favour amount.
  const journalMagnitude = (entry) => {
    const explicit = entry.m !== undefined ? entry.m : entry.magnitude !== undefined ? entry.magnitude : entry.weight;
    if (explicit !== undefined && explicit !== null && explicit !== "") {
      return Math.max(1, Math.min(3, Math.round(numberOrZero(explicit))));
    }
    const amount = Math.abs(numberOrZero(entry.amount));
    if (amount >= 4) return 3;
    if (amount >= 2) return 2;
    return 1;
  };

  // Byline adapts to the active path when no single patron applies.
  const journalByline = () => {
    const patron = text(state.patron, "");
    if (patron && patron !== "None") return `kept for ${patron}`;
    const kind = text(state.instrument && state.instrument.kind, "").toLowerCase();
    if (kind === "lunar") return "kept beneath the moons";
    if (kind === "hist") return "kept within the Hist";
    if (kind === "ancestor") return "kept among the ancestors";
    if (kind === "daedric") return "kept by the terms of the pact";
    return "a record kept since the path began";
  };

  const renderJournalPietyGauge = (slot, inst = {}) => {
    const instData = inst.data || {};
    const piety = clamp(instData.piety !== undefined ? instData.piety : state.piety, 0, 85);
    const tier = numberOrZero(inst.tier !== undefined ? inst.tier : state.tier);
    const pct = (value) => `${Math.round((value / 85) * 1000) / 10}%`;
    const gauge = document.createElement("div");
    gauge.className = "bod-gauge";
    gauge.setAttribute("aria-hidden", "true");
    const track = document.createElement("div");
    track.className = "bod-gauge__track";
    const fill = document.createElement("span");
    fill.className = isWaning(inst) ? "bod-gauge__fill is-waning" : "bod-gauge__fill";
    fill.style.width = pct(piety);
    track.appendChild(fill);
    gauge.appendChild(track);
    thresholds.forEach((threshold, index) => {
      const pip = document.createElement("span");
      pip.className = tier >= index + 1 ? "bod-gauge__pip full" : "bod-gauge__pip";
      pip.style.left = pct(threshold.value);
      gauge.appendChild(pip);
    });
    slot.append(gauge);
  };

  // The Book of Days always uses its book-styled standing gauge; cultural lane
  // detail lives in the path line above, not in substrate-specific instruments.
  const renderJournalStanding = (instOverride) => {
    if (!nodes.journalInstrument) return;
    clear(nodes.journalInstrument);
    const fromOverride = instOverride && typeof instOverride === "object" ? instOverride : null;
    const fromState = state.instrument && typeof state.instrument === "object" ? state.instrument : null;
    const inst = fromOverride || fromState || pietyInstrumentFromState();
    const labelEl = document.querySelector("#pdv-journal-modal .bod-standing-label");
    if (labelEl) {
      clear(labelEl);
      labelEl.classList.add("is-tiered");
      const tier = numberOrZero(inst.tier !== undefined ? inst.tier : state.tier);
      labelEl.appendChild(document.createTextNode("Standing \u2014 "));
      const em = document.createElement("em");
      em.textContent = text(inst.tierLabel, tierName(tier));
      labelEl.appendChild(em);
    }
    renderJournalPietyGauge(nodes.journalInstrument, inst);
  };

  const journalEntryNode = (entry) => {
    const requested = text(entry.valence, "neutral");
    const valence = JOURNAL_LABELS[requested] ? requested : "neutral";
    const magnitude = valence === "neutral" ? 0 : journalMagnitude(entry);
    const li = document.createElement("li");
    li.className = `bod-leaf v-${valence}`;
    const mark = document.createElement("div");
    mark.className = "bod-leaf__mark";
    mark.setAttribute("aria-hidden", "true");
    const symbolMark = document.createElement("div");
    symbolMark.className = "bod-leaf__symbol";
    renderSymbol(symbolMark, text(entry.symbol, "journal"));
    const signal = document.createElement("div");
    signal.className = "bod-leaf__signal";
    signal.innerHTML = journalRune(valence, magnitude);
    const label = document.createElement("span");
    label.className = "bod-mark-label";
    label.textContent = JOURNAL_LABELS[valence];
    mark.append(symbolMark, signal, label);
    const body = document.createElement("div");
    body.className = "bod-leaf__body";
    const titleEl = document.createElement("p");
    titleEl.className = "bod-leaf__title";
    titleEl.textContent = text(entry.title, "A moment noted");
    const textEl = document.createElement("p");
    textEl.className = "bod-leaf__text";
    textEl.textContent = text(entry.text, "");
    body.append(titleEl, textEl);
    li.append(mark, body);
    return li;
  };

  const fitJournalBook = () => {
    const scaler = document.getElementById("pdv-journal-scaler");
    if (!scaler) return;
    const designWidth = 1264;
    const designHeight = 756;
    const margin = 20;
    const s = Math.min(1, (window.innerWidth - margin * 2) / designWidth, (window.innerHeight - margin * 2) / designHeight);
    const x = Math.max(margin, (window.innerWidth - designWidth * s) / 2) + 42 * s;
    const y = Math.max(margin, (window.innerHeight - designHeight * s) / 2) + 10 * s;
    scaler.style.transform = `translate(${x}px, ${y}px) scale(${s})`;
  };
  window.addEventListener("resize", () => {
    if (nodes.journalModal && !nodes.journalModal.hidden) fitJournalBook();
  });

  const renderJournal = (journal = {}) => {
    if (!nodes.journalModal) return;
    hideAllOverlays();

    if (nodes.journalTitle) nodes.journalTitle.textContent = text(journal.title, "Book of Days");
    if (nodes.journalBy) nodes.journalBy.textContent = text(journal.by, journalByline());
    if (nodes.journalSummary) nodes.journalSummary.textContent = text(journal.summary, "Faith, conduct, and consequence leave their marks here.");
    if (nodes.journalPath) {
      // Concise path status. Standing detail lives in the meter and entries below.
      const survey = journalPathText(journal.survey);
      nodes.journalPath.textContent = survey;
      nodes.journalPath.hidden = !survey;
    }
    if (nodes.journalFoot) {
      const foot = text(journal.foot, "Press Esc or the close button to close.");
      nodes.journalFoot.textContent = foot.includes("Book of Days key") ? "Press Esc or the close button to close." : foot;
    }
    if (nodes.journalEmblem) nodes.journalEmblem.innerHTML = buildJournalSun();
    renderJournalStanding(journal.instrument || journal.standing);

    const entries = asArray(journal.entries).filter(Boolean);
    clear(nodes.journalEntries);

    if (!entries.length) {
      appendEmpty(nodes.journalEntries, "No devotional acts have been recorded yet.");
    } else {
      let lastDate = null;
      entries.forEach((entry) => {
        const dateKey = text(entry.date, "");
        if (dateKey && dateKey !== lastDate) {
          const divider = document.createElement("li");
          divider.className = "bod-date";
          divider.innerHTML = `<span class="bod-date__ln"></span><span class="bod-date__dt"></span><span class="bod-date__ln"></span>`;
          divider.querySelector(".bod-date__dt").textContent = dateKey;
          nodes.journalEntries.appendChild(divider);
          lastDate = dateKey;
        }
        nodes.journalEntries.appendChild(journalEntryNode(entry));
      });
    }

    const chronicleEl = document.getElementById("pdv-journal-chronicle");
    if (chronicleEl) chronicleEl.hidden = false;

    overlayController.open("journal");
    fitJournalBook();
  };

  const renderStartupDetails = (option) => {
    if (!option) return;
    const detailMark = nodes.startupOptionTitle.parentElement.querySelector(".startup-detail-mark");
    if (detailMark) {
      detailMark.remove();
    }
    nodes.startupOptionTitle.textContent = text(option.title, "Path");
    nodes.startupOptionSummary.textContent = text(option.summary, "");
    nodes.startupOptionDescription.textContent = text(option.description, "");
    nodes.startupAdvisory.classList.remove("is-disabled");
  };

  const renderStartup = (startup = {}) => {
    if (!nodes.startupModal) return;
    hideAllOverlays();
    startupState = startup;

    const options = asArray(startup.options).filter(Boolean);
    const fallbackOption = options[0] || {
      option_id: "startup_context",
      title: "Startup context",
      summary: text(startup.summary, ""),
      description: text(startup.summary, ""),
    };
    const defaultOptionId = text(startup.default_option_id, fallbackOption.option_id);
    let selectedOption = options.find((option) => text(option.option_id, "") === defaultOptionId) || fallbackOption;

    nodes.startupTitle.textContent = text(startup.title, "Race startup");
    nodes.startupSummary.textContent = text(startup.summary, "Your startup context is loading.");
    nodes.startupAdvisory.textContent = text(startup.advisory_line, "");
    nodes.startupMode.textContent = startupModeLabel(startup.startup_mode);
    nodes.startupConfirm.textContent = startupConfirmLabel(Boolean(startup.confirm_required));

    clear(nodes.startupOptions);
    options.forEach((option) => {
      const button = document.createElement("button");
      button.type = "button";
      button.className = "startup-option";
      button.dataset.optionId = text(option.option_id, "");

      const title = document.createElement("strong");
      title.textContent = text(option.title, "Path");
      const summary = document.createElement("span");
      summary.textContent = text(option.summary, "");
      button.append(title, summary);

      button.addEventListener("click", () => {
        selectedOption = option;
        renderStartupDetails(selectedOption);
        nodes.startupOptions.querySelectorAll(".startup-option").forEach((candidate) => {
          candidate.classList.toggle("is-active", candidate.dataset.optionId === text(option.option_id, ""));
        });
      });

      if (text(option.option_id, "") === text(selectedOption.option_id, "")) {
        button.classList.add("is-active");
      }

      nodes.startupOptions.appendChild(button);
    });

    renderStartupDetails(selectedOption);
    overlayController.open("startup");
  };

  const medallionOptionStatus = (option = {}) => {
    if (option.selectable === true) return "Ready to choose";
    return text(option.disabled_reason || option.disabledReason, "Not ready yet");
  };

  const renderMedallionDetails = (medallion, option) => {
    if (!option) return;
    const detail = nodes.startupOptionTitle.parentElement;
    let mark = detail.querySelector(".startup-detail-mark");
    if (!mark) {
      mark = document.createElement("div");
      mark.className = "startup-detail-mark";
      detail.insertBefore(mark, nodes.startupOptionTitle);
    }

    renderSymbol(mark, text(option.symbol, "journal"));
    nodes.startupOptionTitle.textContent = text(option.title, "Devotion");
    nodes.startupOptionSummary.textContent = text(option.summary, "");
    nodes.startupOptionDescription.textContent = text(option.description, "");
    nodes.startupAdvisory.textContent = option.selectable === true
      ? text(medallion.advisory_line, "Choosing is only safe for live, scorable entries.")
      : medallionOptionStatus(option);
    nodes.startupAdvisory.classList.toggle("is-disabled", option.selectable !== true);
    nodes.startupConfirm.textContent = option.selectable === true ? "Selectable" : "Pending";
  };

  const createMedallionOptionButton = (option, selectedOption, onSelect) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "startup-option has-symbol";
    button.dataset.optionId = text(option.option_id || option.optionId, "");
    button.setAttribute("aria-disabled", option.selectable === true ? "false" : "true");

    if (option.selectable !== true) {
      button.classList.add("is-disabled");
    }

    const mark = document.createElement("span");
    mark.className = "list-symbol";
    renderSymbol(mark, text(option.symbol, "journal"));

    const content = document.createElement("span");
    const title = document.createElement("strong");
    title.textContent = text(option.title, "Devotion");
    const summary = document.createElement("span");
    summary.textContent = option.selectable === true
      ? text(option.summary, "")
      : medallionOptionStatus(option);
    content.append(title, summary);
    button.append(mark, content);

    button.addEventListener("click", () => onSelect(option));

    if (text(option.option_id || option.optionId, "") === text(selectedOption.option_id || selectedOption.optionId, "")) {
      button.classList.add("is-active");
    }

    return button;
  };

  const renderMedallion = (medallion = {}) => {
    if (!nodes.startupModal) return;
    hideAllOverlays();
    startupState = medallion;

    const sections = asArray(medallion.sections).filter(Boolean);
    const options = sections.flatMap((section) => asArray(section.entries || section.options).filter(Boolean));
    const fallbackOption = options[0] || {
      option_id: "medallion_context",
      title: "Devotion",
      summary: text(medallion.summary, ""),
      description: text(medallion.summary, ""),
      symbol: "journal",
      selectable: false,
      disabled_reason: "No medallion entries are available yet.",
    };
    const activeOptionId = text(medallion.active_option_id || medallion.default_option_id, "");
    let selectedOption = options.find((option) => text(option.option_id || option.optionId, "") === activeOptionId)
      || options.find((option) => option.selectable === true)
      || fallbackOption;

    nodes.startupTitle.textContent = text(medallion.title, "Medallion");
    nodes.startupSummary.textContent = text(medallion.summary, "Choose from the roster your people can name.");
    nodes.startupMode.textContent = "Medallion";

    clear(nodes.startupOptions);
    sections.forEach((section) => {
      const sectionNode = document.createElement("section");
      sectionNode.className = "medallion-section";

      const heading = document.createElement("h4");
      heading.textContent = text(section.title, "Roster");
      sectionNode.appendChild(heading);

      asArray(section.entries || section.options).filter(Boolean).forEach((option) => {
        const button = createMedallionOptionButton(option, selectedOption, (nextOption) => {
          selectedOption = nextOption;
          renderMedallionDetails(medallion, selectedOption);
          nodes.startupOptions.querySelectorAll(".startup-option").forEach((candidate) => {
            candidate.classList.toggle("is-active", candidate.dataset.optionId === text(nextOption.option_id || nextOption.optionId, ""));
          });
        });
        sectionNode.appendChild(button);
      });

      nodes.startupOptions.appendChild(sectionNode);
    });

    renderMedallionDetails(medallion, selectedOption);
    overlayController.open("startup");
  };

  const clear = (node) => {
    while (node.firstChild) {
      node.removeChild(node.firstChild);
    }
  };

  const appendEmpty = (node, message) => {
    clear(node);
    const item = document.createElement("li");
    item.className = "empty";
    item.textContent = message;
    node.appendChild(item);
  };

  const appendSymbolMark = (node, symbolName) => {
    const mark = document.createElement("span");
    mark.className = "list-symbol";
    renderSymbol(mark, symbolName);
    node.appendChild(mark);
  };

  const renderList = (node, items, emptyMessage) => {
    clear(node);
    const list = asArray(items).filter(Boolean);
    if (!list.length) {
      appendEmpty(node, emptyMessage);
      return;
    }

    list.forEach((item) => {
      const li = document.createElement("li");
      if (typeof item === "string") {
        li.textContent = item;
      } else {
        const displayItem = resolveEventPayload(item);
        const tone = text(displayItem.tone, "");
        const symbol = text(displayItem.symbol || displayItem.mark, "");
        li.className = `list-item${tone ? ` is-${tone}` : ""}${symbol ? " has-symbol" : ""}`;
        if (symbol) {
          appendSymbolMark(li, symbol);
        }

        const content = document.createElement("span");
        content.className = "list-content";

        const title = document.createElement("strong");
        title.textContent = text(displayItem.listTitle || displayItem.title || displayItem.label, "");
        content.appendChild(title);

        const details = document.createElement("span");
        const amount = displayItem.amount === undefined ? "" : `(${signedText(displayItem.amount)})`;
        const message = text(displayItem.listText || displayItem.text || displayItem.message, "");
        details.textContent = [message, amount].filter(Boolean).join(" ");
        content.appendChild(details);
        li.appendChild(content);
      }
      node.appendChild(li);
    });
  };

  const renderRelations = (relations) => {
    clear(nodes.relations);
    const items = asArray(relations).filter(Boolean);
    if (!items.length) {
      const paragraph = document.createElement("p");
      paragraph.className = "empty";
      paragraph.textContent = "No rivalries or cultural stance notes are active.";
      nodes.relations.appendChild(paragraph);
      return;
    }

    const list = document.createElement("ul");
    list.className = "relation-list";
    items.forEach((item) => {
      const li = document.createElement("li");
      const displayItem = typeof item === "string" ? item : resolveEventPayload(item);
      const tone = typeof displayItem === "string" ? "" : text(displayItem.tone, "");
      li.className = `relation-item${tone ? ` is-${tone}` : ""}`;
      li.textContent = typeof displayItem === "string"
        ? displayItem
        : text(displayItem.listText || displayItem.text || displayItem.label || displayItem.message, "");
      list.appendChild(li);
    });
    nodes.relations.appendChild(list);
  };

  const renderDebug = (payload) => {
    clear(nodes.debug);
    const debug = {
      Patron: payload.patron,
      Tier: payload.tierLabel || tierName(payload.tier),
      Piety: payload.piety,
      Today: payload.pietyToday,
      Origin: payload.originRace,
      State: payload.patronState,
      ...payload.debug,
    };

    Object.entries(debug).forEach(([key, value]) => {
      const item = document.createElement("div");
      item.className = "debug-item";

      const label = document.createElement("span");
      label.className = "debug-key";
      label.textContent = key;

      const output = document.createElement("div");
      output.className = "debug-value";
      output.textContent = text(value, "None");

      item.append(label, output);
      nodes.debug.appendChild(item);
    });
  };

  // --- Devotion dashboard (Today tab): per-god feedback + filters ---
  // Filters are client-side only over the cached payload; never a Papyrus round-trip.
  const dashboardFilter = { dir: "all", sys: "all", god: null };

  const setupDashboardFilters = () => {
    const bar = document.getElementById("pdv-dashboard-filters");
    if (!bar || bar.dataset.wired === "1") return;
    bar.dataset.wired = "1";
    bar.addEventListener("click", (event) => {
      const button = event.target.closest("[data-filter-group]");
      if (!button) return;
      const group = button.dataset.filterGroup;
      dashboardFilter[group] = button.dataset.filter;
      bar.querySelectorAll(`[data-filter-group="${group}"]`).forEach((other) => {
        other.classList.toggle("is-active", other === button);
      });
      renderDashboard(state.dashboard);
    });
  };

  const DASH_STATE_LABELS = { gaining: "Gaining", steady: "Steady", starving: "Starving", neglected: "Needs attention" };
  const DASH_STATE_VALENCE = { gaining: "good", steady: "neutral", starving: "warning", neglected: "warning" };

  // A god's SYSTEM (patron / pantheon / watching / neglected) is a different axis
  // from its STATE. patron/pantheon are the ordinary cases and read fine without a
  // tag, so only the distinguished relationships get a kicker badge: a pre-pact
  // Prince you are building toward ("watching"), and a neglected god. (The manager
  // currently only emits "watching" here -- neglect is carried through god.state --
  // but "neglected" is declared in the systems array, so we surface it too.)
  const DASH_SYSTEM_BADGES = {
    watching: { label: "Watching", tone: "watching" },
    neglected: { label: "Neglected", tone: "warning" },
  };

  const dashboardGodMatches = (god) => {
    const stateKey = text(god.state, "steady");
    if (dashboardFilter.god && text(god.god) !== dashboardFilter.god) return false;
    if (dashboardFilter.sys === "patron" && text(god.system) !== "patron") return false;
    if (dashboardFilter.sys === "pantheon" && text(god.system) !== "pantheon") return false;
    if (dashboardFilter.sys === "neglected" && stateKey !== "neglected") return false;
    if (dashboardFilter.dir === "gain" && !(numberOrZero(god.pietyToday) > 0)) return false;
    if (dashboardFilter.dir === "loss" && !(numberOrZero(god.pietyToday) < 0 || stateKey === "starving" || stateKey === "neglected")) return false;
    return true;
  };

  const DASH_DIR_GLYPH = { gain: "\u25B2", loss: "\u25BC", neutral: "\u25AC" };

  // Roll a god's raw recent-driver ring up by reason: one row per action, with a
  // summed count and signed net. (Papyrus sends count:1 entries; we aggregate here.)
  const groupDrivers = (drivers) => {
    const agg = {};
    const order = [];
    asArray(drivers).filter(Boolean).forEach((driver) => {
      const reason = text(driver.reason, "An act of devotion");
      if (!agg[reason]) { agg[reason] = { reason, count: 0, net: 0 }; order.push(reason); }
      agg[reason].count += numberOrZero(driver.count) || 1;
      agg[reason].net += numberOrZero(driver.net);
    });
    return order.map((key) => agg[key]);
  };

  const driverPassesDir = (net) => {
    if (dashboardFilter.dir === "gain") return net > 0;
    if (dashboardFilter.dir === "loss") return net < 0;
    return true;
  };

  const driverValence = (net) => (net > 0 ? "gain" : net < 0 ? "loss" : "neutral");

  // One ledger row: trend glyph + action + xcount + diverging net bar + signed net.
  // Gain/loss is carried four ways (glyph, bar side, sign, colour) -- never colour alone.
  const renderDriverRow = (driver, scale) => {
    const dir = driverValence(driver.net);
    const row = document.createElement("li");
    row.className = `driver is-${dir}`;

    const trend = document.createElement("span");
    trend.className = "driver__trend";
    trend.setAttribute("aria-hidden", "true");
    trend.textContent = DASH_DIR_GLYPH[dir];
    row.appendChild(trend);

    const label = document.createElement("span");
    label.className = "driver__label";
    label.textContent = driver.reason;
    row.appendChild(label);

    const count = document.createElement("span");
    count.className = "driver__count";
    count.textContent = `\u00D7${driver.count}`;
    row.appendChild(count);

    const bar = document.createElement("span");
    bar.className = "driver__bar";
    const width = scale > 0 ? Math.max(6, Math.round((Math.abs(driver.net) / scale) * 100)) : 0;
    const neg = document.createElement("span");
    neg.className = "driver__bar-neg";
    neg.style.width = dir === "loss" ? `${width}%` : "0%";
    const pos = document.createElement("span");
    pos.className = "driver__bar-pos";
    pos.style.width = dir === "gain" ? `${width}%` : "0%";
    bar.append(neg, pos);
    row.appendChild(bar);

    const net = document.createElement("span");
    net.className = "driver__net";
    net.textContent = dir === "neutral" ? "0" : signedText(driver.net);
    const sr = document.createElement("span");
    sr.className = "sr-only";
    sr.textContent = dir === "gain" ? " gained" : dir === "loss" ? " lost" : " neutral";
    net.appendChild(sr);
    row.appendChild(net);
    return row;
  };

  const renderGodBlock = (god, allDrivers, visibleDrivers, scale) => {
    const stateKey = text(god.state, "steady");
    const valence = DASH_STATE_VALENCE[stateKey] || "neutral";
    const focused = dashboardFilter.god === text(god.god);

    const block = document.createElement("article");
    block.className = `god v-${valence}${focused ? " is-focused" : ""}`;

    const head = document.createElement("button");
    head.type = "button";
    head.className = "god__head";
    head.setAttribute("aria-pressed", focused ? "true" : "false");
    head.addEventListener("click", () => {
      const key = text(god.god);
      dashboardFilter.god = dashboardFilter.god === key ? null : key;
      renderDashboard(state.dashboard);
    });

    const mark = document.createElement("span");
    mark.className = "god__mark";
    renderSymbol(mark, text(god.symbol, "journal"));
    head.appendChild(mark);

    const identity = document.createElement("span");
    identity.className = "god__identity";

    // Kicker badge for a distinguished relationship (watching Prince / neglected
    // god). Sits above the name so it reads as "what this god is", not a metric.
    const systemBadge = DASH_SYSTEM_BADGES[text(god.system)];
    if (systemBadge) {
      block.classList.add(`sys-${systemBadge.tone}`);
      const badge = document.createElement("span");
      badge.className = `god__badge is-${systemBadge.tone}`;
      badge.textContent = systemBadge.label;
      identity.appendChild(badge);
    }

    const name = document.createElement("strong");
    name.className = "god__name";
    name.textContent = displayName(god.god, text(god.god, "A god"));
    identity.appendChild(name);

    const meta = document.createElement("span");
    meta.className = "god__meta";
    const acts = allDrivers.reduce((s, d) => s + d.count, 0);
    const metaState = document.createElement("span");
    metaState.className = `god__meta-state is-${valence}`;
    metaState.textContent = DASH_STATE_LABELS[stateKey] || "Steady";
    const metaStanding = document.createElement("span");
    metaStanding.textContent = `${tierName(god.tier)} \u00B7 ${numberOrZero(god.piety)} piety`;
    const metaActs = document.createElement("span");
    metaActs.textContent = `${acts} driver${acts === 1 ? "" : "s"}`;
    meta.append(metaState, metaStanding, metaActs);
    identity.appendChild(meta);
    head.appendChild(identity);

    const netToday = numberOrZero(god.pietyToday);
    const total = document.createElement("span");
    total.className = `god__net is-${driverValence(netToday)}`;
    const totalValue = document.createElement("strong");
    totalValue.textContent = netToday === 0 ? "0" : signedText(netToday);
    const totalLabel = document.createElement("span");
    totalLabel.textContent = "net today";
    total.append(totalValue, totalLabel);
    head.appendChild(total);

    block.appendChild(head);

    const list = document.createElement("ul");
    list.className = "god__drivers";
    if (!visibleDrivers.length) {
      const empty = document.createElement("li");
      empty.className = "driver is-empty";
      empty.textContent = (stateKey === "neglected" || stateKey === "starving")
        ? "Nothing has fed this god lately."
        : (dashboardFilter.dir === "all" ? "Recent acts will show here." : "No matching drivers.");
      list.appendChild(empty);
    } else {
      visibleDrivers.forEach((driver) => list.appendChild(renderDriverRow(driver, scale)));
    }
    block.appendChild(list);
    return block;
  };

  const renderDashboard = (dashboard = {}) => {
    const host = document.getElementById("pdv-dashboard-gods");
    const countNode = document.getElementById("pdv-dashboard-count");
    const setCount = (txt) => { if (countNode) countNode.textContent = txt; };
    if (!host) return;
    clear(host);

    const gods = asArray(dashboard.gods).filter(Boolean);
    if (!gods.length) {
      const empty = document.createElement("p");
      empty.className = "dashboard__empty";
      empty.textContent = "No god has answered yet. Act, pray, and this will fill.";
      host.appendChild(empty);
      setCount("");
      return;
    }

    const filtered = gods.filter(dashboardGodMatches);
    if (!filtered.length) {
      const empty = document.createElement("p");
      empty.className = "dashboard__empty";
      empty.textContent = "Nothing matches this filter.";
      host.appendChild(empty);
      setCount(`0 of ${gods.length} gods`);
      return;
    }

    const prepared = filtered.map((god) => {
      const all = groupDrivers(god.drivers);
      const visible = all
        .filter((d) => driverPassesDir(d.net))
        .sort((a, b) => Math.abs(b.net) - Math.abs(a.net));
      return { god, all, visible };
    });
    const scale = prepared.reduce((max, { visible }) =>
      visible.reduce((m, d) => Math.max(m, Math.abs(d.net)), max), 0);

    let shownDrivers = 0;
    prepared.forEach(({ god, all, visible }) => {
      shownDrivers += visible.length;
      host.appendChild(renderGodBlock(god, all, visible, scale));
    });

    setCount(filtered.length === gods.length
      ? `${gods.length} god${gods.length === 1 ? "" : "s"} \u00B7 ${shownDrivers} driver${shownDrivers === 1 ? "" : "s"}`
      : `${filtered.length} of ${gods.length} gods`);
  };

  // --- Weekly tab: seven-day rollup per god ---
  // Reads dashboard.gods[].week (array of daily net piety, oldest->newest, up to 7).
  // Degrades gracefully to "recent" when the bridge has not sent week data yet.
  const WEEK_DAY_LABELS = ["6d", "5d", "4d", "3d", "2d", "Yest", "Today"];

  const weeklyNet = (god) => {
    const week = asArray(god.week).map(numberOrZero);
    if (week.length) return week.reduce((s, n) => s + n, 0);
    return numberOrZero(god.pietyToday);
  };

  const renderWeekly = (dashboard = {}) => {
    const host = document.getElementById("pdv-weekly");
    const countNode = document.getElementById("pdv-weekly-count");
    if (!host) return;
    clear(host);

    const gods = asArray(dashboard.gods).filter(Boolean);
    if (!gods.length) {
      const empty = document.createElement("p");
      empty.className = "dashboard__empty";
      empty.textContent = "The week's record will gather here as you act.";
      host.appendChild(empty);
      if (countNode) countNode.textContent = "";
      return;
    }

    const sorted = gods.slice().sort((a, b) => Math.abs(weeklyNet(b)) - Math.abs(weeklyNet(a)));
    const scale = sorted.reduce((m, g) =>
      asArray(g.week).map(numberOrZero).reduce((mm, n) => Math.max(mm, Math.abs(n)), m), 0);

    sorted.forEach((god) => {
      const net = weeklyNet(god);
      const valence = net > 0 ? "good" : net < 0 ? "warning" : "neutral";
      const card = document.createElement("article");
      card.className = `god wk-god v-${valence}`;

      const head = document.createElement("div");
      head.className = "god__head wk-god__head";

      const mark = document.createElement("span");
      mark.className = "god__mark";
      renderSymbol(mark, text(god.symbol, "journal"));
      head.appendChild(mark);

      const identity = document.createElement("span");
      identity.className = "god__identity";
      const name = document.createElement("strong");
      name.className = "god__name";
      name.textContent = displayName(god.god, text(god.god, "A god"));
      identity.appendChild(name);
      const meta = document.createElement("span");
      meta.className = "god__meta";
      meta.textContent = `${tierName(god.tier)} \u00B7 ${numberOrZero(god.piety)} piety`;
      identity.appendChild(meta);
      head.appendChild(identity);

      const total = document.createElement("span");
      total.className = `god__net is-${driverValence(net)}`;
      const tv = document.createElement("strong");
      tv.textContent = net === 0 ? "0" : signedText(net);
      const tl = document.createElement("span");
      tl.textContent = "net / 7 days";
      total.append(tv, tl);
      head.appendChild(total);
      card.appendChild(head);

      const week = asArray(god.week).map(numberOrZero).slice(-7);
      if (week.length) {
        const labels = WEEK_DAY_LABELS.slice(WEEK_DAY_LABELS.length - week.length);
        const spark = document.createElement("div");
        spark.className = "wk-spark";
        spark.setAttribute("aria-hidden", "true");
        week.forEach((n, idx) => {
          const dir = driverValence(n);
          const col = document.createElement("div");
          col.className = `wk-spark__col is-${dir}`;
          col.title = `${labels[idx] || ""}: ${signedText(n)}`;
          const track = document.createElement("div");
          track.className = "wk-spark__track";
          const fill = document.createElement("div");
          fill.className = "wk-spark__fill";
          fill.style.height = scale > 0 ? `${Math.max(n === 0 ? 0 : 8, Math.round((Math.abs(n) / scale) * 46))}%` : "0%";
          track.appendChild(fill);
          const lab = document.createElement("span");
          lab.className = "wk-spark__day";
          lab.textContent = labels[idx] || "";
          col.append(track, lab);
          spark.appendChild(col);
        });
        card.appendChild(spark);
      }

      const drivers = groupDrivers(god.drivers)
        .sort((a, b) => Math.abs(b.net) - Math.abs(a.net))
        .slice(0, 4);
      if (drivers.length) {
        const list = document.createElement("ul");
        list.className = "god__drivers wk-god__drivers";
        drivers.forEach((d) => {
          const dir = driverValence(d.net);
          const li = document.createElement("li");
          li.className = `driver is-${dir}`;
          const g = document.createElement("span");
          g.className = "driver__trend";
          g.setAttribute("aria-hidden", "true");
          g.textContent = DASH_DIR_GLYPH[dir];
          const lbl = document.createElement("span");
          lbl.className = "driver__label";
          lbl.textContent = d.count > 1 ? `${d.reason} \u00D7${d.count}` : d.reason;
          const v = document.createElement("span");
          v.className = "driver__net";
          v.textContent = dir === "neutral" ? "0" : signedText(d.net);
          li.append(g, lbl, v);
          list.appendChild(li);
        });
        card.appendChild(list);
      }
      host.appendChild(card);
    });

    if (countNode) {
      const hasWeek = sorted.some((g) => asArray(g.week).length);
      countNode.textContent = `${sorted.length} god${sorted.length === 1 ? "" : "s"} \u00B7 ${hasWeek ? "last 7 days" : "recent"}`;
    }
  };

  const render = (payload = {}) => {
    state = { ...fallbackState, ...payload };
    const piety = Math.max(0, Math.min(200, numberOrZero(state.piety)));
    const pietyPercent = Math.min(100, Math.round((piety / 85) * 100));
    const patronName = text(state.patron, "None");

    nodes.title.textContent = text(state.title, patronName === "None" ? "Devotion" : patronName);
    nodes.status.textContent = text(state.status, "Live");
    renderSymbol(nodes.mark, state.symbol || state.mark || patronName || "journal");
    nodes.summary.textContent = text(state.summary, "No patron has answered yet.");
    nodes.patron.textContent = patronName;
    nodes.patronNote.textContent = text(state.patronNote, "Choose a path through play, prayer, and consequence.");
    nodes.tierLabel.textContent = text(state.tierLabel, tierName(state.tier));
    nodes.pietyBar.style.width = `${pietyPercent}%`;
    nodes.pietyText.textContent = text(state.pietyLabel, `${piety} piety`);
    nodes.nextText.textContent = text(state.nextText, nextThresholdText(piety));
    nodes.todayDelta.textContent = signedText(state.pietyToday);
    nodes.todayMood.textContent = text(state.todayMood, fallbackState.todayMood);
    nodes.driftLabel.textContent = text(state.driftLabel, fallbackState.driftLabel);
    nodes.dawnStatus.textContent = text(state.dawnStatus, fallbackState.dawnStatus);

    renderInstrument();
    renderRelations(state.relations);
    renderList(nodes.acts, state.acts || state.recentActs, "No devotional acts have been recorded today.");
    renderList(nodes.rites, state.rites, "No rites are available yet.");
    setupDashboardFilters();
    renderDashboard(state.dashboard);
    renderWeekly(state.dashboard);
    renderDebug(state);
  };

  const removeToast = (toast) => {
    if (toast.parentElement) {
      toast.parentElement.removeChild(toast);
    }
  };

  const MIN_TOAST_DURATION_MS = 1800;
  const DEFAULT_TOAST_DURATION_MS = 5600;

  const showToast = (toastPayload = {}) => {
    const copy = resolveEventPayload(toastPayload);
    const toastKey = [
      text(copy.event, ""),
      text(copy.symbol || copy.mark, ""),
      text(copy.title, ""),
      text(copy.message || copy.text, ""),
    ].join("|");
    const now = Date.now();
    if (toastKey && recentToastKeys.has(toastKey) && now - recentToastKeys.get(toastKey) < 2200) {
      return;
    }
    recentToastKeys.set(toastKey, now);
    recentToastKeys.forEach((seenAt, key) => {
      if (now - seenAt > 10000) {
        recentToastKeys.delete(key);
      }
    });

    const toast = document.createElement("section");
    const tone = text(copy.tone, "neutral");
    const duration = Math.max(MIN_TOAST_DURATION_MS, numberOrZero(copy.duration) || DEFAULT_TOAST_DURATION_MS);

    toast.className = `toast is-${tone}`;
    toast.style.setProperty("--toast-life", `${duration}ms`);
    toast.setAttribute("role", "status");
    toast.setAttribute("aria-atomic", "true");

    const mark = document.createElement("div");
    mark.className = "toast__mark";
    renderSymbol(mark, copy.symbol || copy.mark || state.symbol || state.mark || state.patron || "journal");

    const body = document.createElement("div");
    const title = document.createElement("p");
    title.className = "toast__title";
    title.textContent = text(copy.title, "Devotion");

    const message = document.createElement("p");
    message.className = "toast__text";
    message.textContent = text(copy.message || copy.text, "Your path is remembered.");

    body.append(title, message);
    toast.append(mark, body);
    nodes.toasts.prepend(toast);

    window.setTimeout(() => removeToast(toast), duration + 700);
  };

  const scheduleToast = (toastPayload = {}, delay = 0) => {
    window.setTimeout(() => {
      window.requestAnimationFrame(() => showToast(toastPayload));
    }, delay);
  };

  const handlePayload = (payload) => {
    if (payload.toast) {
      scheduleToast(payload.toast);
    }

    asArray(payload.toasts).forEach((toast, index) => {
      scheduleToast(toast, index * 700);
    });

    if (payload.startup) {
      renderStartup(payload.startup);
    }

    if (payload.medallion) {
      renderMedallion(payload.medallion);
    }

    if (isJournalPayload(payload)) {
      renderJournal(payload.journal);
    }

    if (payload.mode === "toast") {
      return;
    }

    if (payload.mode === "startup" || payload.mode === "medallion" || payload.mode === "journal") {
      return;
    }

    render(payload);
  };

  const handleOverlayPayload = (payload) => {
    // Overlay payloads are runtime surfaces: toasts, Book of Days, startup, or medallion.
    // They must never reveal the focused dashboard shell. The native bridge has to
    // Show() the shared Prisma view for toasts, so clear any stale panel-visible state
    // before rendering the overlay.
    document.body.classList.remove("panel-visible");
    document.removeEventListener("keydown", onPanelEsc, true);

    if (payload.journalClose) {
      hideJournal();
      return;
    }

    if (payload.toast) {
      scheduleToast(payload.toast);
    }

    asArray(payload.toasts).forEach((toast, index) => {
      scheduleToast(toast, index * 700);
    });

    if (payload.startup) {
      renderStartup(payload.startup);
    }

    if (payload.medallion) {
      renderMedallion(payload.medallion);
    }

    if (isJournalPayload(payload)) {
      renderJournal(payload.journal);
    }
  };

  document.querySelectorAll(".tab").forEach((tab) => {
    tab.addEventListener("click", () => {
      const selected = tab.dataset.tab;
      document.querySelectorAll(".tab").forEach((candidate) => {
        const active = candidate.dataset.tab === selected;
        candidate.classList.toggle("is-active", active);
        candidate.setAttribute("aria-selected", active ? "true" : "false");
      });
      document.querySelectorAll(".tab-panel").forEach((panel) => {
        panel.classList.toggle("is-active", panel.dataset.panel === selected);
      });
    });
  });

  const renderSymbolGallery = () => {
    clear(nodes.symbolGrid);
    gallerySymbols.forEach(([symbolName, labelText]) => {
      const swatch = document.createElement("div");
      swatch.className = "symbol-swatch";

      const mark = document.createElement("div");
      mark.className = "symbol-swatch__mark";
      renderSymbol(mark, symbolName);

      const label = document.createElement("span");
      label.className = "symbol-swatch__label";
      label.textContent = labelText;

      swatch.append(mark, label);
      nodes.symbolGrid.appendChild(swatch);
    });
  };

  const parsePayload = (payloadText) => {
    if (typeof payloadText !== "string") {
      return payloadText || {};
    }

    const textPayload = payloadText || "{}";
    try {
      return JSON.parse(textPayload);
    } catch (error) {
      const normalizedPayload = textPayload.replace(/\b(true|false)\b/gi, (match) => match.toLowerCase());
      if (normalizedPayload === textPayload) {
        throw error;
      }

      return JSON.parse(normalizedPayload);
    }
  };

  // --- Focused panel close: the in-view X button + ESC route to the bridge's
  // PDVPanelClose listener (C++ Unfocus + Hide). The main panel is a FOCUSED view, so
  // unlike the non-focused Book of Days these in-view affordances actually work.
  // closeDevotionPanel also hides the shell locally so the panel disappears immediately.
  const onPanelEsc = (event) => {
    if (isEscapeKey(event)) {
      event.preventDefault();
      closeDevotionPanel();
    }
  };
  function closeDevotionPanel() {
    document.removeEventListener("keydown", onPanelEsc, true);
    overlayController.closeAll();
    document.body.classList.remove("panel-visible");
    if (typeof window.PDVPanelClose === "function") {
      window.PDVPanelClose("main|close");
    }
  }
  let panelCloseButtonWired = false;
  const bindPanelClose = () => {
    // Re-adding the same listener+capture is idempotent; removed again on close.
    document.addEventListener("keydown", onPanelEsc, true);
    if (panelCloseButtonWired) return;
    const closeButton = document.getElementById("pdv-panel-close");
    if (closeButton) {
      panelCloseButtonWired = true;
      closeButton.addEventListener("click", () => closeDevotionPanel());
    }
  };

  let bridgeReceived = false;

  window.PDVBridge = {
    receiveJson(payloadText) {
      bridgeReceived = true;
      try {
        const payload = parsePayload(payloadText);
        overlayController.closeAll();
        document.body.classList.add("panel-visible");
        bindPanelClose();
        handlePayload(payload);
      } catch (error) {
        nodes.status.textContent = "Bad JSON";
        appendEmpty(nodes.acts, error instanceof Error ? error.message : "Could not parse payload.");
      }
    },
    receiveOverlayJson(payloadText) {
      bridgeReceived = true;
      try {
        const payload = parsePayload(payloadText);
        handleOverlayPayload(payload);
      } catch (error) {
        showToast({
          symbol: "journal",
          tone: "warning",
          title: "Prisma payload",
          message: error instanceof Error ? error.message : "Could not parse payload.",
        });
      }
    },
    showToast,
    render,
  };

  window.ReceivePDVJson = (payloadText) => window.PDVBridge.receiveJson(payloadText);
  window.ReceivePDVOverlayJson = (payloadText) => window.PDVBridge.receiveOverlayJson(payloadText);

  // --- Phase 0 choice panel (round-trip plumbing proof) ---------------------
  // Renders a blocking choice grid and returns the pick to C++ by calling the
  // PDVChoiceResult listener the bridge registers via RegisterJSListener. The
  // result string is "<menu>|<index>" or "<menu>|cancel". ESC, the Cancel
  // button, and any bad payload all resolve to cancel so the player is never
  // trapped. Inline styles keep this self-contained (no index.html/css edits).
  const renderChoicePanel = (choice) => {
    const menu = text(choice.menu, "choice");
    const options = Array.isArray(choice.options) ? choice.options : [];
    console.log("PDV choice render: menu=" + menu + " options=" + options.length);

    const stale = document.getElementById("pdv-choice-overlay");
    if (stale) stale.remove();

    let done = false;
    const onKey = (event) => {
      if (event.key === "Escape") {
        event.preventDefault();
        finish("cancel");
      }
    };
    function finish(token) {
      if (done) return;
      done = true;
      document.removeEventListener("keydown", onKey, true);
      const node = document.getElementById("pdv-choice-overlay");
      if (node) node.remove();
      if (typeof window.PDVChoiceResult === "function") {
        window.PDVChoiceResult(menu + "|" + token);
      }
    }

    const overlay = document.createElement("div");
    overlay.id = "pdv-choice-overlay";
    overlay.setAttribute("style", [
      "position:fixed", "top:0", "left:0", "right:0", "bottom:0", "z-index:99999",
      "display:flex", "align-items:center", "justify-content:center",
      "background:rgba(0,0,0,0.55)", "font-family:'IM Fell English',serif",
      "color:#f3e9d2"
    ].join(";"));

    const card = document.createElement("div");
    card.setAttribute("style", [
      "max-width:760px", "width:80%", "padding:28px 32px",
      "background:rgba(20,16,10,0.96)", "border:1px solid #6b5836",
      "border-radius:10px", "box-shadow:0 8px 40px rgba(0,0,0,0.6)",
      "text-align:center"
    ].join(";"));

    const heading = document.createElement("h2");
    heading.textContent = text(choice.title, "Choose");
    heading.setAttribute("style", "margin:0 0 8px;font-size:26px;");
    const prompt = document.createElement("p");
    prompt.textContent = text(choice.prompt, "");
    prompt.setAttribute("style", "margin:0 0 20px;opacity:0.85;");
    card.append(heading, prompt);

    const grid = document.createElement("div");
    // 3-up grid; 5 options wrap to a 3+2 layout automatically.
    grid.setAttribute("style", [
      "display:grid", "grid-template-columns:repeat(3,1fr)",
      "gap:12px", "margin-bottom:18px"
    ].join(";"));
    options.forEach((option, position) => {
      const index = Number.isInteger(option.index) ? option.index : position;
      const button = document.createElement("button");
      button.type = "button";
      button.textContent = text(option.label, "Option " + index);
      button.setAttribute("style", [
        "padding:14px 12px", "background:rgba(60,48,28,0.9)",
        "border:1px solid #8a7038", "border-radius:8px", "color:#f3e9d2",
        "font-family:inherit", "font-size:16px", "cursor:pointer"
      ].join(";"));
      button.addEventListener("click", () => finish(String(index)));
      grid.appendChild(button);
    });
    card.appendChild(grid);

    const cancel = document.createElement("button");
    cancel.type = "button";
    cancel.textContent = text(choice.cancelLabel, "Not yet (Esc)");
    cancel.setAttribute("style", [
      "padding:10px 18px", "background:transparent", "border:1px solid #6b5836",
      "border-radius:8px", "color:#cdbb95", "font-family:inherit",
      "font-size:14px", "cursor:pointer"
    ].join(";"));
    cancel.addEventListener("click", () => finish("cancel"));
    card.appendChild(cancel);

    overlay.appendChild(card);
    document.body.appendChild(overlay);
    document.addEventListener("keydown", onKey, true);
  };

  window.ReceivePDVChoice = (payloadText) => {
    try {
      const payload = parsePayload(payloadText);
      const choice = (payload && payload.choice) ? payload.choice : payload;
      renderChoicePanel(choice || {});
    } catch (error) {
      console.error("PDV choice payload error: " + (error && error.message));
      if (typeof window.PDVChoiceResult === "function") {
        window.PDVChoiceResult("choice|cancel");
      }
    }
  };

  if (nodes.startupClose) {
    nodes.startupClose.addEventListener("click", () => closeStartupFromView());
  }

  if (nodes.journalClose) {
    nodes.journalClose.addEventListener("click", () => closeJournalFromView());
  }

  window.addEventListener("keydown", onOverlayEsc, true);
  document.addEventListener("keydown", onOverlayEsc, true);
  window.addEventListener("keyup", onOverlayEsc, true);
  document.addEventListener("keyup", onOverlayEsc, true);

  const demoToasts = {
    favor: { event: "favor", deity: "Kyne", symbol: "kyne", context: "The clean hunt" },
    dawn: { event: "dawn" },
    neglect: { event: "neglect", deity: "Kyne" },
    tier: { event: "tier", deity: "Kyne", symbol: "kyne", tierLabel: "Devoted" },
    rivalry: { event: "rivalry", rival: "Auri-El", rivalSymbol: "auri-el" },
    shift_khajiit: { event: "shift", shiftMode: "Khenarthi", symbol: "khenarthi" },
    shift_argonian: { event: "shift", shiftMode: "Hist Strained", symbol: "hist" },
    shift_orc: { event: "shift", shiftMode: "Stronghold", symbol: "malacath" },
    shift_redguard: { event: "shift", shiftMode: "Crown" },
    shift_bosmer: { event: "shift", shiftMode: "Old Contract", symbol: "yffre" },
    daedric_boon: { event: "daedric", prince: "Hircine", phase: "milestone", tierLabel: "Seeker", symbol: "hircine", flavor: "Hircine's hunt-sense is in you.", boonText: "+15% Stamina regeneration", priceText: "-10% Health regeneration" },
    daedric_price: { event: "daedric", prince: "Hircine", phase: "price", symbol: "hircine", context: "Stigma has been rising." },
    daedric_lapse: { event: "daedric", prince: "Hircine", phase: "lapse", symbol: "hircine" },
    daedric_residue: { event: "daedric", prince: "Hircine", phase: "residue", symbol: "hircine" },
    curse_onset_vampire: { event: "curse", phase: "onset", curse: "vampire", symbol: "curse-vampire", context: "Sovngarde is closed while the thirst remains." },
    curse_cure_vampire: { event: "curse", phase: "cure", curse: "vampire", symbol: "curse-vampire", context: "The road opens again. The scar remains." },
    curse_onset_werewolf: { event: "curse", phase: "onset", curse: "werewolf", symbol: "curse-werewolf", context: "The hunt pulls against Sovngarde." },
    curse_shift: { event: "curse", phase: "shift", curse: "vampire", symbol: "curse-vampire" },
    substrate_lunar: { event: "substrate", substrate: "lunar", phase: "act", symbol: "lunar", state: "Lattice: steady" },
    substrate_deepen: { event: "substrate", substrate: "hist", phase: "deepen", symbol: "hist", state: "Hist: strong" },
    substrate_thin: { event: "substrate", substrate: "ancestor", phase: "thin", symbol: "ancestor", state: "Ancestor layer: quiet" },
  };

  const demoMedallionPayload = {
    mode: "medallion",
    medallion: {
      race_id: "altmer",
      title: "Altmer Medallion",
      summary: "The medallion shows the native roster. Only live, scorable entries can be chosen.",
      active_option_id: "auri-el",
      advisory_line: "A selectable entry is already wired into the live devotion roster.",
      sections: [
        {
          section_id: "native",
          title: "Native worship",
          entries: [
            {
              option_id: "auri-el",
              title: "Auri-El",
              summary: "The founding light and ancestral ascent.",
              description: "Auri-El is live and scorable in the current deity roster.",
              symbol: "auri-el",
              kind: "god",
              selectable: true,
            },
            {
              option_id: "syrabane",
              title: "Syrabane",
              summary: "Magic, craft, and survival through wisdom.",
              description: "Syrabane belongs in the Altmer native roster, but is not yet a live scoring patron.",
              symbol: "syrabane",
              kind: "god",
              selectable: false,
              disabled_reason: "Awaiting live deity record and scoring path.",
            },
            {
              option_id: "trinimac",
              title: "Trinimac",
              summary: "Warrior order and unbroken nobility.",
              description: "Trinimac belongs in the Altmer native roster, but is not yet a live scoring patron.",
              symbol: "trinimac",
              kind: "god",
              selectable: false,
              disabled_reason: "Awaiting live deity record and scoring path.",
            },
          ],
        },
      ],
    },
  };

  window.PDVDemo = () => {
    window.PDVBridge.receiveJson({
      title: "Kyne",
      status: "Live",
      symbol: "kyne",
      patron: "Kyne",
      patronNote: "Native Nord practice. Clean hunts, open sky, and storms strengthen this path.",
      summary: "Kyne's favor is steady; the day's acts lean toward reverence rather than routine.",
      tier: 2,
      tierLabel: "Devoted",
      piety: 72,
      pietyToday: 8,
      originRace: "Nord",
      patronState: "Active patron",
      acts: [
        { event: "favor", deity: "Kyne", symbol: "kyne", context: "Clean hunt", text: "Honored Kyne without waste.", amount: 4 },
        { event: "favor", deity: "Kyne", symbol: "dawn", context: "Open sky", text: "Rested beneath weather and stars.", amount: 3 },
        { event: "favor", deity: "Kyne", symbol: "journal", context: "Mercy noted", text: "Spared a fleeing animal.", amount: 1 }
      ],
      todayMood: "The day leans toward reverence rather than routine.",
      driftLabel: "Settling",
      dawnStatus: "At dawn, today's signs will fold into Kyne's ledger.",
      rites: [
        { symbol: "dawn", title: "Dawn prayer", text: "Pray before taking the road." },
        { symbol: "kyne", title: "Clean hunt", text: "Take only what the day requires." },
        { symbol: "journal", title: "Weather rite", text: "Stand in the weather without complaint." }
      ],
      relations: [
        { tone: "good", text: "Native practice: Nord rites answer clearly." },
        { event: "rivalry", rival: "Auri-El", listText: "Auri-El reverence remains distant from this path." }
      ],
      debug: {
        "Patron FormID": "0x04000D62",
        "Origin Global": 1,
        "Last Event": "SleepOutside"
      },
      dashboard: { gods: demoTrackingGods, systems: ["patron", "pantheon", "watching", "neglected"] },
      toasts: [demoToasts.favor, demoToasts.dawn, demoToasts.neglect, demoToasts.tier, demoToasts.rivalry]
    });
  };

  window.PDVDemoMedallion = () => {
    window.PDVBridge.receiveOverlayJson(demoMedallionPayload);
  };

  // End-to-end tracking demo: proves ALL new work renders in BOTH Prisma spaces.
  // Uses the exact manager payload contract (GetDashboardJson gods/drivers +
  // BuildJournalPayloadJson entries). PDVDemoLedger() -> the interactive sortable
  // panel (Today tab) with the new 6f rite drivers + a watching Prince + a
  // neglected god. PDVDemoChronicle() -> the Book of Days Chronicle only.
  const demoTrackingGods = [
    { god: "Kyne", symbol: "kyne", system: "patron", state: "gaining", pietyToday: 6, piety: 72, tier: 2,
      week: [3, -1, 4, 0, 2, 1, 6],
      drivers: [ { reason: "Clean hunt", count: 2, net: 4, dir: "gain" }, { reason: "Rested beneath open sky", count: 1, net: 3, dir: "gain" } ] },
    { god: "Malacath", symbol: "malacath", system: "pantheon", state: "gaining", pietyToday: 0.5, piety: 14, tier: 1,
      week: [0, 0, 1, 2, 0, 1, 0.5],
      drivers: [ { reason: "Took up the Trial of Iron", count: 1, net: 0.5, dir: "gain" } ] },
    { god: "Auri-El", symbol: "auri-el", system: "pantheon", state: "gaining", pietyToday: 0.5, piety: 22, tier: 1,
      week: [1, 0, 0, 2, 0, 1, 0.5],
      drivers: [ { reason: "Set a Discipline of Return", count: 1, net: 0.5, dir: "gain" } ] },
    { god: "Tu'whacca", symbol: "tu-whacca", system: "pantheon", state: "gaining", pietyToday: 0.5, piety: 9, tier: 0,
      week: [0, 0, 0, 1, 0, 0, 0.5],
      drivers: [ { reason: "Took up the Remembering of Names", count: 1, net: 0.5, dir: "gain" } ] },
    { god: "Mephala", symbol: "daedric", system: "watching", state: "steady", pietyToday: 0, piety: 6, tier: 0,
      week: [0, 0, 1, 0, 0, 1, 0],
      drivers: [ { reason: "A Prince takes notice", count: 1, net: 0, dir: "gain" } ] },
    { god: "Stendarr", symbol: "journal", system: "pantheon", state: "neglected", pietyToday: -2, piety: 3, tier: 0,
      week: [1, 0, -1, 0, -2, -1, -2],
      drivers: [ { reason: "The path goes quiet", count: 1, net: -2, dir: "loss" } ] }
  ];

  window.PDVDemoLedger = () => {
    window.PDVBridge.receiveJson({
      title: "Kyne", status: "Live", symbol: "kyne", patron: "Kyne", originRace: "Nord",
      patronState: "Active patron", tier: 2, tierLabel: "Devoted", piety: 72, pietyToday: 6,
      dashboard: { gods: demoTrackingGods, systems: ["patron", "pantheon", "watching", "neglected"] }
    });
  };

  window.PDVDemoChronicle = () => {
    window.PDVBridge.receiveJson({
      mode: "journal",
      journal: {
        title: "Book of Days", page: 0,
        summary: "Old Gods, Divines, and chosen roads leave their marks here.",
        survey: "Nord - Broad Old Ways",
        dashboard: { gods: demoTrackingGods },
        entries: [
          { date: "17th of Last Seed", title: "The Trial of Iron", text: "You took up a discipline in the Trial of Iron. The Code is held in iron.", symbol: "malacath", valence: "good", magnitude: 1 },
          { date: "17th of Last Seed", title: "The Remembering of Names", text: "You remembered a name of the old line. The dead are kept in the telling.", symbol: "tu-whacca", valence: "good", magnitude: 1 },
          { date: "16th of Last Seed", title: "The Disciplines of Return", text: "You set a discipline of the Return. The road back is walked daily.", symbol: "auri-el", valence: "good", magnitude: 1 },
          { date: "15th of Last Seed", title: "A Prince Takes Notice", text: "Mephala's attention has gathered around you.", symbol: "daedric", valence: "neutral", magnitude: 1 },
          { date: "14th of Last Seed", title: "The Path Goes Quiet", text: "Stendarr has gone unanswered. The favor wanes.", symbol: "journal", valence: "warning", magnitude: 2 }
        ]
      }
    });
  };

  render(fallbackState);

  const enableDemo = () => {
    if (enableDemo.done) return;
    enableDemo.done = true;
    nodes.demoControls.hidden = false;
    nodes.symbolGallery.hidden = false;
    renderSymbolGallery();
    nodes.demoControls.addEventListener("click", (event) => {
      const button = event.target.closest("[data-demo-toast]");
      if (button) {
        showToast(demoToasts[button.dataset.demoToast]);
        return;
      }

      const medallionButton = event.target.closest("[data-demo-medallion]");
      if (medallionButton) {
        window.PDVDemoMedallion();
      }
    });
    window.setTimeout(() => window.PDVDemo(), 60);
  };

  // ?demo (any form the host preserves) shows the demo immediately. Do not auto-fall
  // back to the dashboard when no bridge payload arrives: in-game overlay toasts can
  // create a cold Prisma view before the first focused panel payload, and an automatic
  // demo fallback would make a gameplay toast look like the panel opened itself.
  const demoRequested = window.location.search.toLowerCase().includes("demo")
    || window.location.hash.toLowerCase().includes("demo")
    || /[?&#]demo\b/i.test(window.location.href);
  if (demoRequested) {
    enableDemo();
  }
})();
