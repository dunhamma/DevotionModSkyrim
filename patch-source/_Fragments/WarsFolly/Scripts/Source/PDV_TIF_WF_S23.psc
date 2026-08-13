ScriptName PDV_TIF_WF_S23 extends TopicInfo Hidden
{PDV Devotion dialogue-hook fragment. Sets outcome stage(s) for the quest-reaction matrix.}

Function Fragment_0(ObjectReference akSpeakerRef)
    GetOwningQuest().SetStage(10)
    GetOwningQuest().SetStage(23)
EndFunction
