(() => {
  const thresholds = [
    { label: "Seeker", value: 10 },
    { label: "Devoted", value: 50 },
    { label: "Champion", value: 150 },
  ];
  const svgNamespace = "http://www.w3.org/2000/svg";
  const symbolAliases = {
    auriel: "auri-el",
    "auri el": "auri-el",
    auriEl: "auri-el",
    kynareth: "kyne",
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
  };

  const nodes = {
    title: document.getElementById("pdv-title"),
    status: document.getElementById("pdv-status"),
    mark: document.getElementById("pdv-mark"),
    summary: document.getElementById("pdv-summary"),
    patron: document.getElementById("pdv-patron"),
    patronNote: document.getElementById("pdv-patron-note"),
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

    return normalized;
  };

  const deityName = (payload = {}) => text(payload.deity, text(state.patron, "Devotion"));

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
        const mode = text(payload.shiftMode, "");
        return mode ? `Path settles: ${mode}` : "Your path shifts";
      },
      message: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const mode = text(payload.shiftMode, "");
        return mode
          ? `${mode} shapes what comes next.`
          : "Your practice has found a new shape.";
      },
      listTitle: (payload) => text(payload.shiftMode, "Path shift"),
      listText: (payload) => {
        const context = contextName(payload);
        if (context) return context;
        const mode = text(payload.shiftMode, "");
        return mode
          ? `${mode} is now the shape of your practice.`
          : "Your path has settled into a new mode.";
      },
    },
    daedric: {
      tone: (payload) => {
        const phase = text(payload.phase, "");
        if (phase === "boon") return "good";
        if (phase === "residue") return "neutral";
        return "warning";
      },
      symbol: (payload) => text(payload.symbol, "journal"),
      title: (payload) => {
        const prince = text(payload.prince, "A Daedric Prince");
        const phase = text(payload.phase, "");
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
        if (phase === "boon") return "The rite was answered.";
        if (phase === "price") return `${possessive(prince)} cost is rising.`;
        if (phase === "lapse") return "The path has been released.";
        if (phase === "residue") return "The mark has not fully faded.";
        return "Something stirs in that quarter.";
      },
      listTitle: (payload) => {
        const prince = text(payload.prince, "Daedric");
        const phase = text(payload.phase, "");
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

  const startupModeLabel = (mode) => {
    const normalized = text(mode, "").toLowerCase();
    if (normalized === "explicit_choice") return "Explicit choice";
    return "Info only";
  };

  const startupConfirmLabel = (confirmRequired) => (confirmRequired ? "Confirm required" : "No confirm required");

  const hideStartup = () => {
    if (!nodes.startupModal) return;
    nodes.startupModal.hidden = true;
    document.body.classList.remove("startup-visible");
  };

  const renderStartupDetails = (option) => {
    if (!option) return;
    nodes.startupOptionTitle.textContent = text(option.title, "Path");
    nodes.startupOptionSummary.textContent = text(option.summary, "");
    nodes.startupOptionDescription.textContent = text(option.description, "");
  };

  const renderStartup = (startup = {}) => {
    if (!nodes.startupModal) return;
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
    nodes.startupModal.hidden = false;
    document.body.classList.add("startup-visible");
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

  const render = (payload = {}) => {
    state = { ...fallbackState, ...payload };
    const piety = Math.max(0, Math.min(200, numberOrZero(state.piety)));
    const pietyPercent = Math.min(100, Math.round((piety / 150) * 100));
    const patronName = text(state.patron, "None");

    nodes.title.textContent = text(state.title, patronName === "None" ? "Devotion" : patronName);
    nodes.status.textContent = text(state.status, "Live");
    renderSymbol(nodes.mark, state.symbol || state.mark || patronName || "journal");
    nodes.summary.textContent = text(state.summary, "No patron has answered yet.");
    nodes.patron.textContent = patronName;
    nodes.patronNote.textContent = text(state.patronNote, "Choose a path through play, prayer, and consequence.");
    nodes.tierLabel.textContent = text(state.tierLabel, tierName(state.tier));
    nodes.pietyBar.style.width = `${pietyPercent}%`;
    nodes.pietyText.textContent = `${piety} piety`;
    nodes.nextText.textContent = text(state.nextText, nextThresholdText(piety));
    nodes.todayDelta.textContent = signedText(state.pietyToday);
    nodes.todayMood.textContent = text(state.todayMood, fallbackState.todayMood);
    nodes.driftLabel.textContent = text(state.driftLabel, fallbackState.driftLabel);
    nodes.dawnStatus.textContent = text(state.dawnStatus, fallbackState.dawnStatus);

    renderRelations(state.relations);
    renderList(nodes.acts, state.acts || state.recentActs, "No devotional acts have been recorded today.");
    renderList(nodes.rites, state.rites, "No rites are available yet.");
    renderDebug(state);
  };

  const removeToast = (toast) => {
    if (toast.parentElement) {
      toast.parentElement.removeChild(toast);
    }
  };

  const showToast = (toastPayload = {}) => {
    const copy = resolveEventPayload(toastPayload);
    const toast = document.createElement("section");
    const tone = text(copy.tone, "neutral");
    const duration = Math.max(1800, numberOrZero(copy.duration) || 4200);

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

  const handlePayload = (payload) => {
    if (payload.toast) {
      showToast(payload.toast);
    }

    asArray(payload.toasts).forEach((toast, index) => {
      window.setTimeout(() => showToast(toast), index * 700);
    });

    if (payload.startup) {
      renderStartup(payload.startup);
    }

    if (payload.mode === "toast") {
      return;
    }

    if (payload.mode === "startup") {
      return;
    }

    render(payload);
  };

  const handleOverlayPayload = (payload) => {
    if (payload.toast) {
      showToast(payload.toast);
    }

    asArray(payload.toasts).forEach((toast, index) => {
      window.setTimeout(() => showToast(toast), index * 700);
    });

    if (payload.startup) {
      renderStartup(payload.startup);
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
      const normalizedPayload = textPayload.replace(/\b(TRUE|FALSE)\b/g, (match) => match.toLowerCase());
      if (normalizedPayload === textPayload) {
        throw error;
      }

      return JSON.parse(normalizedPayload);
    }
  };

  window.PDVBridge = {
    receiveJson(payloadText) {
      try {
        const payload = parsePayload(payloadText);
        document.body.classList.add("panel-visible");
        handlePayload(payload);
      } catch (error) {
        nodes.status.textContent = "Bad JSON";
        appendEmpty(nodes.acts, error instanceof Error ? error.message : "Could not parse payload.");
      }
    },
    receiveOverlayJson(payloadText) {
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

  if (nodes.startupClose) {
    nodes.startupClose.addEventListener("click", () => hideStartup());
  }

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
    daedric_boon: { event: "daedric", prince: "Hircine", phase: "boon", symbol: "hircine" },
    daedric_price: { event: "daedric", prince: "Hircine", phase: "price", symbol: "hircine", context: "Stigma has been rising." },
    daedric_lapse: { event: "daedric", prince: "Hircine", phase: "lapse", symbol: "hircine" },
    daedric_residue: { event: "daedric", prince: "Hircine", phase: "residue", symbol: "hircine" },
    curse_onset_vampire: { event: "curse", phase: "onset", curse: "vampire", symbol: "curse-vampire", context: "Sovngarde is closed while the thirst remains." },
    curse_cure_vampire: { event: "curse", phase: "cure", curse: "vampire", symbol: "curse-vampire", context: "The road opens again. The scar remains." },
    curse_onset_werewolf: { event: "curse", phase: "onset", curse: "werewolf", symbol: "curse-werewolf", context: "The hunt pulls against Sovngarde." },
    curse_shift: { event: "curse", phase: "shift", curse: "vampire", symbol: "curse-vampire" },
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
      toasts: [demoToasts.favor, demoToasts.dawn, demoToasts.neglect, demoToasts.tier, demoToasts.rivalry]
    });
  };

  render(fallbackState);

  if (new URLSearchParams(window.location.search).has("demo")) {
    nodes.demoControls.hidden = false;
    nodes.symbolGallery.hidden = false;
    renderSymbolGallery();
    nodes.demoControls.addEventListener("click", (event) => {
      const button = event.target.closest("[data-demo-toast]");
      if (!button) return;
      showToast(demoToasts[button.dataset.demoToast]);
    });
    window.setTimeout(() => window.PDVDemo(), 250);
  }
})();
