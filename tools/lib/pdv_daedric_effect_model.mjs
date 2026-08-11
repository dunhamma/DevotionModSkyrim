const TIERS = ["Seeker", "Devoted", "Champion"];

// The values intentionally reproduce the shipped contract. The important structural
// change is that actor-value families now have independent bands, even where their
// current numbers happen to match. Issue #37 can tune a family without silently
// retuning unrelated units such as resource points, armor points, or percentages.
export const DAEDRIC_MAGNITUDE_BANDS = Object.freeze({
  skillPoints: Object.freeze({ boon: [10, 18, 25], price: [-10, -18, -25] }),
  resourcePoolPoints: Object.freeze({ boon: [15, 25, 35], price: [-10, -20, -30] }),
  armorPoints: Object.freeze({ boon: [15, 25, 35], price: [-10, -20, -30] }),
  carryWeightUnits: Object.freeze({ boon: [15, 25, 35], price: [-10, -20, -30] }),
  resistancePercent: Object.freeze({ boon: [15, 25, 35], price: [-10, -20, -30] }),
  movementPercent: Object.freeze({ boon: [15, 25, 35], price: [-4, -7, -10] }),
});

export const DAEDRIC_ACTOR_VALUE_BANDS = Object.freeze({
  OneHanded: "skillPoints",
  TwoHanded: "skillPoints",
  Marksman: "skillPoints",
  Block: "skillPoints",
  Smithing: "skillPoints",
  HeavyArmor: "skillPoints",
  LightArmor: "skillPoints",
  Pickpocket: "skillPoints",
  Lockpicking: "skillPoints",
  Sneak: "skillPoints",
  Alchemy: "skillPoints",
  Speechcraft: "skillPoints",
  Alteration: "skillPoints",
  Conjuration: "skillPoints",
  Destruction: "skillPoints",
  Illusion: "skillPoints",
  Restoration: "skillPoints",
  Enchanting: "skillPoints",
  Health: "resourcePoolPoints",
  Magicka: "resourcePoolPoints",
  Stamina: "resourcePoolPoints",
  DamageResist: "armorPoints",
  CarryWeight: "carryWeightUnits",
  ResistMagic: "resistancePercent",
  ResistDisease: "resistancePercent",
  SpeedMult: "movementPercent",
});

const effect = (actorValue) => Object.freeze({ actorValue });

// This is the authoritative semantic effect model. Every Prince names the effect
// axis at every tier; exceptional multi-effect packets are declared in place instead
// of being patched later through editor-ID keyed override maps.
export const DAEDRIC_PRINCE_EFFECT_MODEL = Object.freeze({
  Azura: Object.freeze({
    boons: [effect("ResistMagic"), effect("Magicka"), effect("Magicka")],
    prices: [effect("Stamina"), effect("Stamina"), effect("Stamina")],
  }),
  Boethiah: Object.freeze({
    boons: [effect("OneHanded"), effect("DamageResist"), effect("DamageResist")],
    prices: [effect("Speechcraft"), effect("Speechcraft"), effect("Speechcraft")],
  }),
  Mephala: Object.freeze({
    boons: [effect("Sneak"), effect("Pickpocket"), effect("Pickpocket")],
    prices: [effect("Speechcraft"), effect("Speechcraft"), effect("Speechcraft")],
  }),
  Malacath: Object.freeze({
    boons: [effect("DamageResist"), effect("TwoHanded"), effect("TwoHanded")],
    prices: [effect("SpeedMult"), effect("SpeedMult"), effect("SpeedMult")],
  }),
  Meridia: Object.freeze({
    boons: [effect("Restoration"), effect("ResistDisease"), effect("ResistDisease")],
    prices: [effect("Illusion"), effect("Illusion"), effect("Illusion")],
  }),
  Nocturnal: Object.freeze({
    boons: [effect("Sneak"), effect("Lockpicking"), effect("Lockpicking")],
    prices: [effect("Restoration"), effect("Restoration"), effect("Restoration")],
  }),
  Mora: Object.freeze({
    boons: [
      effect("Alteration"),
      effect("Magicka"),
      Object.freeze({
        effects: Object.freeze([
          Object.freeze({
            magicEffectEditorId: "PDV_MGEF_Bless_Daedric_Mora_Champion_Alteration",
            actorValue: "Alteration",
            magnitude: 20,
          }),
          Object.freeze({
            magicEffectEditorId: "PDV_MGEF_Bless_Daedric_Mora_Champion_Magicka",
            actorValue: "Magicka",
            magnitude: 20,
            effectName: "Fortify Magicka",
          }),
        ]),
      }),
    ],
    prices: [effect("Stamina"), effect("Stamina"), effect("Stamina")],
  }),
  Dagon: Object.freeze({
    boons: [effect("Destruction"), effect("OneHanded"), effect("OneHanded")],
    prices: [effect("DamageResist"), effect("DamageResist"), effect("DamageResist")],
  }),
  Sheo: Object.freeze({
    boons: [effect("Illusion"), effect("Magicka"), effect("Magicka")],
    prices: [effect("Restoration"), effect("Restoration"), effect("Restoration")],
  }),
  Vile: Object.freeze({
    boons: [effect("Speechcraft"), effect("CarryWeight"), effect("CarryWeight")],
    prices: [effect("Magicka"), effect("Magicka"), effect("Magicka")],
  }),
  Vaermina: Object.freeze({
    boons: [effect("Illusion"), effect("Sneak"), effect("Sneak")],
    prices: [effect("Health"), effect("Health"), effect("Health")],
  }),
  Sanguine: Object.freeze({
    boons: [effect("Stamina"), effect("Speechcraft"), effect("Speechcraft")],
    prices: [effect("Magicka"), effect("Magicka"), effect("Magicka")],
  }),
  Namira: Object.freeze({
    boons: [effect("Sneak"), effect("Health"), effect("Health")],
    prices: [effect("Speechcraft"), effect("Speechcraft"), effect("Speechcraft")],
  }),
  Peryite: Object.freeze({
    boons: [effect("ResistDisease"), effect("Health"), effect("Health")],
    prices: [effect("Stamina"), effect("Stamina"), effect("Stamina")],
  }),
  Hircine: Object.freeze({
    boons: [effect("Stamina"), effect("Sneak"), effect("Sneak")],
    prices: [effect("Health"), effect("Health"), effect("Health")],
  }),
  Molag: Object.freeze({
    boons: [effect("Speechcraft"), effect("Illusion"), effect("Illusion")],
    prices: [effect("Health"), effect("Health"), effect("Health")],
  }),
});

function magnitudeFor(kind, actorValue, tierIndex) {
  const bandName = DAEDRIC_ACTOR_VALUE_BANDS[actorValue];
  const band = DAEDRIC_MAGNITUDE_BANDS[bandName];
  if (!band) throw new Error(`No Daedric magnitude band for actor value ${actorValue}.`);
  return band[kind][tierIndex];
}

function defaultMagicEffectEditorId(spellEditorId) {
  return spellEditorId
    .replace("PDV_Bless_", "PDV_MGEF_Bless_")
    .replace("PDV_Price_", "PDV_MGEF_Price_");
}

function packetFor({ stem, displayName, finalTextById, kind, tierIndex, declaration }) {
  const tierName = TIERS[tierIndex];
  const spellEditorId = `PDV_${kind === "boon" ? "Bless" : "Price"}_Daedric_${stem}_${tierName}`;
  const declaredEffects = declaration.effects ?? [declaration];
  const effects = declaredEffects.map((declaredEffect) => ({
    magicEffectEditorId:
      declaredEffect.magicEffectEditorId ?? defaultMagicEffectEditorId(spellEditorId),
    actorValue: declaredEffect.actorValue,
    magnitude:
      declaredEffect.magnitude ?? magnitudeFor(kind, declaredEffect.actorValue, tierIndex),
    area: 0,
    duration: 0,
    ...(declaredEffect.effectName ? { effectName: declaredEffect.effectName } : {}),
  }));
  return {
    spellEditorId,
    magicEffectEditorId: effects[0].magicEffectEditorId,
    displayName: `${displayName} ${kind === "boon" ? "Boon" : "Price"} - ${tierName}`,
    playerFacingText: finalTextById.get(spellEditorId),
    property: `${kind === "boon" ? "Boon" : "Price"}_${tierName}`,
    effects,
  };
}

export function buildPrinceSpellPackets({ stem, displayName, finalTextById }) {
  const model = DAEDRIC_PRINCE_EFFECT_MODEL[stem];
  if (!model) throw new Error(`No Daedric effect model for ${stem}.`);
  return {
    boons: model.boons.map((declaration, tierIndex) =>
      packetFor({ stem, displayName, finalTextById, kind: "boon", tierIndex, declaration })),
    prices: model.prices.map((declaration, tierIndex) =>
      packetFor({ stem, displayName, finalTextById, kind: "price", tierIndex, declaration })),
  };
}

export function validateDaedricEffectModel(expectedStems = Object.keys(DAEDRIC_PRINCE_EFFECT_MODEL)) {
  const issues = [];
  const actualStems = Object.keys(DAEDRIC_PRINCE_EFFECT_MODEL);
  const expected = new Set(expectedStems);
  for (const stem of expectedStems) {
    if (!DAEDRIC_PRINCE_EFFECT_MODEL[stem]) issues.push(`${stem}: missing effect model`);
  }
  for (const stem of actualStems) {
    if (!expected.has(stem)) issues.push(`${stem}: unexpected effect model`);
    const model = DAEDRIC_PRINCE_EFFECT_MODEL[stem];
    for (const kind of ["boons", "prices"]) {
      if (!Array.isArray(model[kind]) || model[kind].length !== TIERS.length) {
        issues.push(`${stem}.${kind}: expected exactly ${TIERS.length} tiers`);
        continue;
      }
      model[kind].forEach((declaration, tierIndex) => {
        const declaredEffects = declaration.effects ?? [declaration];
        if (!declaredEffects.length) issues.push(`${stem}.${kind}[${tierIndex}]: no effects`);
        if (declaredEffects.length > 1 && declaredEffects.some((e) => !e.magicEffectEditorId)) {
          issues.push(`${stem}.${kind}[${tierIndex}]: multi-effect packets require explicit editor IDs`);
        }
        for (const declaredEffect of declaredEffects) {
          const bandName = DAEDRIC_ACTOR_VALUE_BANDS[declaredEffect.actorValue];
          if (!bandName) issues.push(`${stem}.${kind}[${tierIndex}]: no band mapping for ${declaredEffect.actorValue}`);
          if (!DAEDRIC_MAGNITUDE_BANDS[bandName]) {
            issues.push(`${stem}.${kind}[${tierIndex}]: unknown band ${bandName}`);
          }
          const magnitude = declaredEffect.magnitude ??
            DAEDRIC_MAGNITUDE_BANDS[bandName]?.[kind === "boons" ? "boon" : "price"]?.[tierIndex];
          if (!Number.isFinite(magnitude)) issues.push(`${stem}.${kind}[${tierIndex}]: invalid magnitude`);
          if (kind === "boons" && magnitude <= 0) issues.push(`${stem}.${kind}[${tierIndex}]: boon must be positive`);
          if (kind === "prices" && magnitude >= 0) issues.push(`${stem}.${kind}[${tierIndex}]: price must be negative`);
        }
      });
    }
    const boonAxes = new Set(model.boons.flatMap((d) => (d.effects ?? [d]).map((e) => e.actorValue)));
    const priceAxes = new Set(model.prices.flatMap((d) => (d.effects ?? [d]).map((e) => e.actorValue)));
    for (const actorValue of priceAxes) {
      if (boonAxes.has(actorValue)) issues.push(`${stem}: price axis ${actorValue} overlaps a boon axis`);
    }
  }
  return issues;
}
