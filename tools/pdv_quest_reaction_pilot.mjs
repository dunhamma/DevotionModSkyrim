// PDV quest-reaction matrix — COVERAGE PILOT v2 (deterministic, multi-signal).
// Holistic tagger: faction-path families + pdv_use seed + named-entity lexicons
// (Princes/artifacts/undead/beasts) + word-boundary verb/noun lexicons. Still a
// PROXY for the curated journal-read; tuned for RECALL (estimate the real pool
// ceiling). Run: node tools/pdv_quest_reaction_pilot.mjs
import { readFileSync } from "node:fs";
const CSV = "references/vanilla-gameplay/extracted/vanilla-quest-stage-readback.csv";

function parseCSV(text) {
  const rows = []; let row = [], field = "", inQ = false;
  for (let i = 0; i < text.length; i++) { const c = text[i];
    if (inQ) { if (c === '"') { if (text[i+1] === '"') { field += '"'; i++; } else inQ = false; } else field += c; }
    else if (c === '"') inQ = true;
    else if (c === ",") { row.push(field); field = ""; }
    else if (c === "\n") { row.push(field); rows.push(row); row = []; field = ""; }
    else if (c === "\r") {} else field += c; }
  if (field.length || row.length) { row.push(field); rows.push(row); }
  return rows;
}

// word-boundary matcher (cached). multi-word terms matched as loose phrase.
const reCache = new Map();
function hit(text, term) {
  let re = reCache.get(term);
  if (!re) { const esc = term.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"); re = new RegExp(`\\b${esc}\\b`, "i"); reCache.set(term, re); }
  return re.test(text);
}
const anyHit = (text, terms) => terms.some(t => hit(text, t));

// --- (1) FACTION / category path -> tag families (the big recall win) -------------
// Trimmed to PRECISE faction families only — broad ones cross-contaminated (a TG
// heist is not "Boethiah deceit"; Companions joining is not "Hircine the hunt").
// The precise per-quest valence is the read-and-judge pass's job, not this proxy.
const FACTION_TAGS = [
  [/daedric/, ["serve_a_daedra"]],                              // all serve a Daedra
  [/darkbrotherhood|\bdb\d/, ["assassination_contract", "murder_treacherous"]], // all DB = assassination
  [/thievesguild|\btg\d/, ["theft_burglary"]],                  // theft only (no blanket deceit)
  [/magesguild|winterhold|\bmg\d/, ["disciplined_study"]],      // NOT bare "college" (Bard's != Mages)
  [/civilwar|\bcw\d/, ["defy_tyranny_talos", "serve_empire_order"]], // no blanket kill tag
  [/vampire|dawnguard/, ["slay_undead"]],
  // Companions removed (flooded Talos/Malacath/Hircine); werewolf arc caught via entity lexicon.
];

// --- (2) named-entity lexicons ----------------------------------------------------
const PRINCES = {
  azura:"azura", boethiah:"boethiah", mephala:"mephala", malacath:"malacath",
  meridia:"meridia", hircine:"hircine", molagbal:"molag bal", nocturnal:"nocturnal",
  hermaeusmora:"hermaeus", dagon:"mehrunes", sheogorath:"sheogorath", namira:"namira",
  sanguine:"sanguine", clavicus:"clavicus", peryite:"peryite", vaermina:"vaermina",
};
const ARTIFACT_TERMS = ["star","ebony blade","ebony mail","ring of","rose","razor","wabbajack","skull","masque","rueful axe","spellbreaker","mace of","oghma","skeleton key","savior's hide","volendrung"];
const UNDEAD = ["draugr","undead","vampire","skeleton","wraith","ghost","lich","deathlord","reanimat","corpse","zombie","restless dead"];
const NECRO  = ["necromanc","raise the dead","reanimate","conjure the dead","bound dead"];
const BEASTS = ["wolf","bear","sabre cat","troll","mammoth","frostbite spider","skeever","elk","deer","fox","bristleback","horker","werebear"];

// --- (3) richer per-tag verb/noun lexicons (word-boundary) ------------------------
const TAG_KEYWORDS = {
  ritual_sacrifice: ["sacrifice","offering","pillar of sacrifice","offer up"],
  murder_treacherous: ["murder","assassinate","assassinated","cold blood","ambush","poison","slit","betray and kill","backstab"],
  assassination_contract: ["assassinate","contract","night mother","sithis","the silence","listener"],
  mercy_spare: ["spare","mercy","ransom","let him live","let her live","set free","release the","pardon","show mercy"],
  kill_the_helpless: ["helpless","defenseless","execute","bound prisoner","unarmed","beg for"],
  slay_undead: UNDEAD,
  the_hunt: ["hunt","hunter","prey","quarry","stalk","track the","great hunt","sinding"].concat(BEASTS),
  necromancy: NECRO,
  burial_rite: ["hall of the dead","burial","entomb","funeral","lay to rest","rites","grave","catacomb","tomb"],
  honor_the_dead: ["hall of the dead","burial","entomb","funeral","lay to rest","ancestor","honor the dead","fallen heroes"],
  desecrate_the_dead: ["rob the","loot the tomb","desecrate","grave robbing","disturb the dead"],
  forbidden_knowledge: ["forbidden","black book","oghma","apocrypha","elder scroll","hidden knowledge","secrets of"],
  disciplined_study: ["college of winterhold","spell tome","arcane","eye of magnus","research","study","tome of","enchant","master the","scholar"],
  reckless_magic: ["unleash","reckless","forbidden magic","corrupt the","wild magic"],
  theft_burglary: ["steal","stolen","thief","thieves guild","pickpocket","burglary","heist","rob ","skeleton key","fence"],
  deceit: ["deceive","deceiv","trick","betray","frame","blackmail","forge a","lie to","impersonate","con "],
  keep_secret: ["secret","conspiracy","whisper","hidden cult","cover up","silence the"],
  expose_betray_secret: ["expose the","reveal the secret","sell out","inform on"],
  protect_the_weak: ["protect","defend","rescue","save the","escort","bodyguard","guard the","shield the"],
  defend_kin_home: ["defend","homeland","our people","the stronghold","clan","kinsmen","reclaim"],
  charity: ["charity","donate","alms","the poor","beggar","orphan","give to"],
  heal_comfort: ["heal","cure the","comfort","tend to","ease the","mend"],
  marriage_family: ["marriage","amulet of mara","wedding","adopt","reconcile","spouse","betroth"],
  compassion: ["comfort","grief","mourning","console"],
  uphold_law_justice: ["bounty","bring to justice","arrest","tribunal","court","sentence","the law","captured"],
  civic_service: ["the jarl","steward","deliver","supplies","the city","the hold","militia","report to"],
  defy_tyranny_talos: ["talos","stormcloak","thalmor","ulfric","skyrim belongs","free skyrim"],
  serve_empire_order: ["the legion","imperial legion","general tullius","the empire","lawful"],
  honorable_duel: ["duel","prove yourself","trial of","arena","champion of","wager","one-on-one","face me"],
  keep_oath: ["oath","vow","sworn","pledge","blood-kin","initiation","join the","swear"],
  break_oath_betray: ["break the oath","desert","betray the","abandon the","turn against","traitor"],
  cowardice: ["flee","coward","run away","abandon your"],
  craft_forge: ["forge","smith","skyforge","largashbur","anvil","tongs","craft the"],
  master_craft_forge: ["forge","smith","skyforge","craft the","masterwork","temper"],
  honest_labor_trade: ["merchant","commission","wares","trade","mine ore","labor","deliver goods","shipment"],
  exploit_cheat: ["extort","cheat","swindle","exploit","rig the"],
  honor_the_wild: ["spriggan","grove","standing stone","wilderness","gildergreen","eldergleam","sacred grove","nature"],
  green_pact: ["valenwood","green pact","bosmer"],
  defile_nature: ["burn the forest","poison the","despoil","blight"],
  sow_chaos_madness: ["madness","chaos","pelagius","wabbajack","insane","mind of","sheogorath"],
  revel_indulge: ["mead","feast","drinking","party","tavern","debauch","sanguine","wabbajack","ale"],
  cannibalism: ["cannibal","eat the","feast on the dead","flesh of","taste of death","namira"],
  embrace_lycanthropy: ["lycanthrop","werewolf","beast blood","circle of","totems of hircine"],
  embrace_vampirism: ["vampire lord","harkon","molag bal","become a vampire","blood of"],
  spread_order_pestilence: ["plague","pestilence","afflicted","disease","peryite","the only cure"],
};

function tagsFor(name, filter, pdvUse, journal) {
  const tags = new Set();
  const f = (filter || "").toLowerCase();
  const nameJ = (name + "  " + journal).toLowerCase();
  const all = (name + "  " + filter + "  " + pdvUse + "  " + journal).toLowerCase();
  // 1) faction families
  for (const [re, ts] of FACTION_TAGS) if (re.test(f) || re.test(name.toLowerCase())) ts.forEach(t => tags.add(t));
  // 2) pdv_use seed words
  const seed = (pdvUse || "").toLowerCase();
  if (seed.includes("moral-choice")) {/* generic salience, no tag */}
  if (/arkay|stendarr/.test(seed)) tags.add("slay_undead");
  if (/vampire/.test(seed)) tags.add("embrace_vampirism");
  // 3) named entities: Princes (own quest) + artifacts
  for (const [key, term] of Object.entries(PRINCES)) {
    if (hit(all, term) || (term.includes(" ") && all.includes(term))) {
      tags.add("serve_a_daedra:" + key);
      if (anyHit(all, ARTIFACT_TERMS)) tags.add("acquire_daedric_artifact:" + key);
    }
  }
  if (anyHit(nameJ, NECRO)) tags.add("necromancy");
  // 4) per-tag lexicons (word-boundary)
  for (const [tag, kws] of Object.entries(TAG_KEYWORDS)) if (anyHit(all, kws)) tags.add(tag);
  return tags;
}

// --- profiles: each Prince's serve/acquire:<self> resolves to its named tag -------
const P = (k)=>[`serve_a_daedra:${k}`, `acquire_daedric_artifact:${k}`];
const PROFILES = {
  "Stendarr (Aedra/broad)":  { approve:["mercy_spare","protect_the_weak","slay_undead","uphold_law_justice","charity"], disapprove:["murder_treacherous","kill_the_helpless","serve_a_daedra","ritual_sacrifice"] },
  "Mara (Aedra)":            { approve:["heal_comfort","charity","marriage_family","mercy_spare","protect_the_weak","compassion"], disapprove:["murder_treacherous","ritual_sacrifice"] },
  "Arkay (Aedra)":           { approve:["honor_the_dead","burial_rite","slay_undead","cure_undeath"], disapprove:["necromancy","desecrate_the_dead","ritual_sacrifice","embrace_vampirism"] },
  "Dibella (Aedra/narrow)":  { approve:["heal_comfort","charity","marriage_family","compassion"], disapprove:["kill_the_helpless"] },
  "Zenithar (Aedra/narrow)": { approve:["honest_labor_trade","master_craft_forge","craft_forge","uphold_law_justice"], disapprove:["theft_burglary","exploit_cheat"] },
  "Julianos (Aedra)":        { approve:["disciplined_study","uphold_law_justice","forbidden_knowledge"], disapprove:["sow_chaos_madness","reckless_magic"] },
  "Talos (Nord/Imperial)":   { approve:["defy_tyranny_talos","kill_honorable_combat","honorable_duel","protect_the_weak","defend_kin_home"], disapprove:["cowardice"] },
  "Malacath (Orc)":          { approve:["keep_oath","honorable_duel","craft_forge","master_craft_forge","the_hunt","defend_kin_home","kill_honorable_combat"], disapprove:["break_oath_betray","cowardice","deceit"] },
  "Boethiah (Prince)":       { approve:["ritual_sacrifice","honorable_duel","deceit","murder_treacherous","assassination_contract","prove_by_struggle",...P("boethiah")], disapprove:["cowardice"] },
  "Mephala (Prince)":        { approve:["deceit","keep_secret","assassination_contract","theft_burglary","murder_treacherous",...P("mephala")], disapprove:["expose_betray_secret"] },
  "Hircine (Prince/curse)":  { approve:["the_hunt","embrace_lycanthropy","kill_honorable_combat","honor_the_wild",...P("hircine")], disapprove:["cure_undeath"] },
  "Sithis (Argonian/dark)":  { approve:["assassination_contract","murder_treacherous"], disapprove:["cowardice"] },
  "Namira (Prince/narrow)":  { approve:["cannibalism","desecrate_the_dead",...P("namira")], disapprove:[] },
  "Molag Bal (Prince/curse)":{ approve:["embrace_vampirism","kill_the_helpless","murder_treacherous","ritual_sacrifice",...P("molagbal")], disapprove:["mercy_spare","protect_the_weak"] },
};

const rows = parseCSV(readFileSync(CSV, "utf8"));
const header = rows[0]; const col = Object.fromEntries(header.map((h,i)=>[h,i]));
// Collapse questline sub-records: drop scene/post/conversation/handler/setup/patrol
// helper records that duplicate a parent quest, plus the internal controller types.
const NOISE = /controller|monitor|dialogue|perkexplanation|qstcontroller|managerquest|^dlc\d_wesc|\bscene\b|\bpost$|post quest$|conversations?$|mini-?scenes?|spectator|\bhandler\b|sets up|\bsetup\b|objective quest|\bpatrol\b|vigilants fighting|fighting (?:vampire|atronach|skeleton)|^player /i;
const quests = rows.slice(1).filter(r => r.length > col.quest_name && (r[col.quest_name]||"").trim() &&
  !NOISE.test((r[col.editor_id]||"")+" "+(r[col.quest_name]||"")));

const result = {}; for (const n of Object.keys(PROFILES)) result[n] = { gain:[], loss:[] };
let tagged = 0;
for (const q of quests) {
  const tags = tagsFor(q[col.quest_name]||"", q[col.quest_filter]||"", q[col.pdv_use]||"",
    [q[col.stage_log_summary], q[col.objective_summary]].join("  "));
  if (tags.size) tagged++;
  const label = (q[col.quest_name]||q[col.editor_id]).trim();
  for (const [deity, p] of Object.entries(PROFILES)) {
    if (p.approve.some(x => tags.has(x))) result[deity].gain.push(label);
    if (p.disapprove.some(x => tags.has(x))) result[deity].loss.push(label);
  }
}
console.log(`v2 detector | real named quests: ${quests.length} | salient (>=1 tag): ${tagged} (${(100*tagged/quests.length).toFixed(0)}%)\n`);
const pad=(s,n)=>(s+" ".repeat(n)).slice(0,n);
console.log(pad("Deity",28)+pad("v1.GAIN",9)+"v2.GAIN  v2.LOSS  v2.TOTAL");
console.log("-".repeat(58));
const v1 = {"Stendarr (Aedra/broad)":24,"Mara (Aedra)":19,"Arkay (Aedra)":17,"Dibella (Aedra/narrow)":8,"Zenithar (Aedra/narrow)":11,"Julianos (Aedra)":17,"Talos (Nord/Imperial)":24,"Malacath (Orc)":24,"Boethiah (Prince)":36,"Mephala (Prince)":51,"Hircine (Prince/curse)":22,"Sithis (Argonian/dark)":31,"Namira (Prince/narrow)":1,"Molag Bal (Prince/curse)":28};
for (const [d, r] of Object.entries(result)) {
  const tot = new Set([...r.gain, ...r.loss]).size;
  console.log(pad(d,28)+pad(String(v1[d]??"-"),9)+pad(String(r.gain.length),9)+pad(String(r.loss.length),9)+tot);
}

console.log("\n===== FULL MATCHED-QUEST LISTS (v2, proxy) =====");
for (const [d, r] of Object.entries(result)) {
  const g = [...new Set(r.gain)], l = [...new Set(r.loss)];
  console.log(`\n## ${d}  (gain ${g.length} | loss ${l.length})`);
  if (g.length) console.log("   GAIN: " + g.join("; "));
  if (l.length) console.log("   LOSS: " + l.join("; "));
  if (!g.length && !l.length) console.log("   (none)");
}
