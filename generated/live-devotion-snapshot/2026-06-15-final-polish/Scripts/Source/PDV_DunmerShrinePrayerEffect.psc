Scriptname PDV_DunmerShrinePrayerEffect extends ActiveMagicEffect
{Attached to PDV_MGEF_DunmerShrineCure, the PDV cure effect that replaces vanilla cure-disease
 on the three DLC2 Good Daedra altar spells (Azura/Boethiah/Mephala). When the Solstheim shrine
 casts its neutralized cure spell on activation, this fires and routes the Dunmer outdoor-shrine
 twilight signal. The manager gates Dunmer origin + the dawn/dusk window + the once-per-window/day
 cap (TryAwardDunmerTwilightWindowSignal), so routing here is unconditional. EventBus is resolved
 at runtime via PDV_FragmentBridge so the effect needs no baked property.}

Event OnEffectStart(Actor akTarget, Actor akCaster)
    PDV_EventBus bus = PDV_FragmentBridge.ResolveEventBusService()
    if bus
        bus.RouteDunmerOutdoorGoodDaedraShrine("dlc2_shrine_blessing_effect")
    endIf
EndEvent
