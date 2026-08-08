ScriptName PDV_TIF_SMB_S45 extends TopicInfo Hidden
{PDV Devotion dialogue-hook fragment. Sets outcome stage(s) for the quest-reaction matrix.}

Function Fragment_0(ObjectReference akSpeakerRef)
    GetOwningQuest().SetStage(35)
    GetOwningQuest().SetStage(45)
EndFunction
