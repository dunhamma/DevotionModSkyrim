;/
    PDV_SacredPlace.psc
    PlayerDevotion - retired sacred-place helper (declaration-only stub)
    -----------------------------------------------------------------------
    CUT in 1.0.3. This was an early V3-skeleton design for shared location
    memory (designate a place, record visits, decay on absence, pay a bonus).
    It was never wired: DesignateLocation / RecordVisit / ProcessDecay /
    GetPlaceBonus had zero callers anywhere in the mod, and the three arrays
    they operated on are unbound on all three quest records, so even a direct
    call would have written into a None array.

    It is not missing content -- it is SUPERSEDED. Every one of its three
    quests' concepts already ships as live code elsewhere:
      - Argonian bed-of-choice -> TryArgonianBedOfChoiceSleep
      - Orc community / hearth  -> TryDeclareRestCell (shared Nord/Orc/Redguard)
      - Khajiit road homes      -> the Khajiit road-home cadence
    Wiring this back would give three race lanes two competing home systems.

    The three quest records (PDV_SacredPlace_ArgonianBedOfChoice,
    _OrcCommunity, _KhajiitRoadHomes) are LEFT IN PLACE and inert -- deleting
    them would break any reference to them. This script stays attached to
    them, so it is reduced to exactly the five properties those records
    actually BIND. That is what stops the VM loading 200 lines of unreachable
    code, and it drops the nine unbound-array findings (three arrays across
    three quests) that shipping nothing would have left declared forever.

    Do not add logic here. If a shared location-memory system is ever wanted,
    it should be designed against the live per-race systems above, not revived
    from this skeleton.
    -----------------------------------------------------------------------
/;

Scriptname PDV_SacredPlace extends Quest

; The five properties the three quest records bind. Nothing reads them.
String Property PlaceName Auto
Int Property MaxLocations = 1 Auto
Int Property RequiredOriginRace Auto

GlobalVariable Property PDV_GLO_OriginRace Auto
GlobalVariable Property PDV_GLO_DebugLevel Auto
