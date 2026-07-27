Scriptname TempleBlessingScript extends ObjectReference Conditional

;/
    PlayerDevotion override of the vanilla temple/shrine activation script.
    -----------------------------------------------------------------------
    WHY THIS EXISTS

    Devotion's design intent is that praying at a shrine produces NO gameplay
    effect from whatever game/overhaul is underneath -- only Devotion's own
    piety award and a Book of Days entry. Devotion already delivers that by
    overriding each Altar*Spell so its ONLY effect is the hidden
    PDV_MGEF_ShrinePrayer_* signal (magnitude 0, HideInUI).

    The stock script defeated half of that intent:

        (akActionRef As Actor).DispelAllSpells()

    DispelAllSpells strips EVERY active magic effect on the actor -- potions,
    fortify buffs, enchantment effects, standing-stone powers, the lot -- not
    just the previous shrine blessing. In stock Skyrim that cost is hidden,
    because a real blessing lands immediately afterwards. With Devotion's
    neutralized spell nothing lands, so praying became pure loss: the player
    was stripped and given nothing. Reported in testing as "praying dispelled
    my magic", and it is exactly that.

    WHAT CHANGED, AND WHAT DELIBERATELY DID NOT

    - DispelAllSpells() is REMOVED. This is the whole fix.
    - TempleBlessing.Cast(...) is KEPT and must stay. That cast is what
      delivers Devotion's PDV_MGEF_ShrinePrayer_* signal, which is what awards
      piety and writes the Book of Days entry. Removing it would silently kill
      shrine piety.
    - The two vanilla messages are no longer shown. AltarRemoveMsg announces a
      blessing removal that no longer happens, and BlessingMessage announces a
      blessing that Devotion deliberately does not grant; both would now be
      lying to the player. Devotion surfaces its own toast and journal entry.
    - Both Message properties stay DECLARED. The activator records bind them,
      so deleting the declarations would trade a silent no-op for a "property
      does not exist" warning on every shrine, every load.

    LOAD ORDER

    This is a loose script override of a vanilla-named script. It must win the
    MO2 virtual file system, i.e. Devotion must sit BELOW (higher priority
    than) anything else shipping TempleBlessingScript.pex -- notably Requiem's
    bugfix packs, which ship their own copy carrying the same DispelAllSpells
    call. A lower priority silently loses and the dispel returns.
    -----------------------------------------------------------------------
/;

Spell Property TempleBlessing  Auto

Event OnActivate(ObjectReference akActionRef)

	; No DispelAllSpells here -- see the header. Praying must not strip the
	; player's active effects.
	TempleBlessing.Cast(akActionRef, akActionRef)

EndEvent

Message Property BlessingMessage  Auto

Message Property AltarRemoveMsg  Auto
