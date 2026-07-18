ScriptName PDV_TIF_OWWH_S61 extends TopicInfo Hidden
{PDV Devotion dialogue-hook fragment. Sets outcome stage(s) for the quest-reaction matrix.}

Function Fragment_0(ObjectReference akSpeakerRef)
    GetOwningQuest().SetStage(61)
EndFunction
