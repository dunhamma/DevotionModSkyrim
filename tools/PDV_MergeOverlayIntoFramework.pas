{
  Merge temporary PDV overlay VMAD back into PlayerDevotion_Framework.esp.

  Scope:
  - PDV__ManagerQuest: fold PDV_GLO_PatronDeity into the real script entry and
    remove blank / duplicate local script residue.
  - PDV_MCM: copy attached PDV_MCM VMAD from the temporary overlay.

  This script is intended to run in SSEEdit with the Devotion Dev profile loaded.
}
unit PDV_MergeOverlayIntoFramework;

const
  FrameworkName = 'PlayerDevotion_Framework.esp';
  ManagerPatchName = 'PDV_ManagerPatronWirePatch.esp';
  McmPatchName = 'PDV_MCMWirePatch.esp';

var
  FrameworkFile: IInterface;
  ManagerPatchFile: IInterface;
  McmPatchFile: IInterface;

function FindLoadedFile(const aFileName: string): IInterface;
var
  i: integer;
  f: IInterface;
begin
  Result := Nil;
  for i := 0 to Pred(FileCount) do begin
    f := FileByIndex(i);
    if SameText(GetFileName(f), aFileName) then begin
      Result := f;
      Exit;
    end;
  end;
end;

function RequireLoadedFile(const aFileName: string): IInterface;
begin
  Result := FindLoadedFile(aFileName);
  if not Assigned(Result) then
    raise Exception.Create('Required file is not loaded: ' + aFileName);
end;

function RequireQuestRecord(aFile: IInterface; const aEditorId: string): IInterface;
begin
  Result := MainRecordByEditorID(GroupBySignature(aFile, 'QUST'), aEditorId);
  if not Assigned(Result) then
    raise Exception.Create('Required quest record not found: ' + aEditorId + ' in ' + GetFileName(aFile));
end;

function FindPropertyByName(aProperties: IInterface; const aPropertyName: string): IInterface;
var
  i: integer;
  prop: IInterface;
begin
  Result := Nil;
  if not Assigned(aProperties) then
    Exit;

  for i := 0 to Pred(ElementCount(aProperties)) do begin
    prop := ElementByIndex(aProperties, i);
    if SameText(GetElementEditValues(prop, 'propertyName'), aPropertyName) then begin
      Result := prop;
      Exit;
    end;
  end;
end;

function FindScriptByName(aScripts: IInterface; const aScriptName: string): IInterface;
var
  i: integer;
  scriptEntry: IInterface;
begin
  Result := Nil;
  if not Assigned(aScripts) then
    Exit;

  for i := 0 to Pred(ElementCount(aScripts)) do begin
    scriptEntry := ElementByIndex(aScripts, i);
    if SameText(GetElementEditValues(scriptEntry, 'scriptName'), aScriptName) then begin
      Result := scriptEntry;
      Exit;
    end;
  end;
end;

procedure ReplaceVmad(aTargetRecord, aSourceRecord: IInterface);
begin
  if not ElementExists(aSourceRecord, 'VMAD') then
    raise Exception.Create('Source record has no VMAD: ' + Name(aSourceRecord));

  if ElementExists(aTargetRecord, 'VMAD') then
    RemoveElement(aTargetRecord, 'VMAD');

  Add(aTargetRecord, 'VMAD', True);
  ElementAssign(ElementByPath(aTargetRecord, 'VMAD'), LowInteger, ElementByPath(aSourceRecord, 'VMAD'), False);
  MarkModifiedRecursive(aTargetRecord);
end;

procedure CopyPropertyIfMissing(aTargetProperties, aSourceProperty: IInterface);
var
  propName: string;
begin
  propName := GetElementEditValues(aSourceProperty, 'propertyName');
  if propName = '' then
    raise Exception.Create('Source property has no propertyName.');

  if Assigned(FindPropertyByName(aTargetProperties, propName)) then
    Exit;

  ElementAssign(aTargetProperties, HighInteger, aSourceProperty, False);
end;

procedure NormalizeManagerRecord;
var
  baseRecord, overlayRecord: IInterface;
  scripts, overlayScripts, scriptEntry, mainScript, patronScript: IInterface;
  mainProperties, patronProperties, patronProperty: IInterface;
  i: integer;
  scriptName: string;
begin
  baseRecord := RequireQuestRecord(FrameworkFile, 'PDV__ManagerQuest');
  overlayRecord := RequireQuestRecord(ManagerPatchFile, 'PDV__ManagerQuest');

  scripts := ElementByPath(baseRecord, 'VMAD\Scripts');
  if not Assigned(scripts) then
    raise Exception.Create('PDV__ManagerQuest has no VMAD\Scripts in the framework.');

  overlayScripts := ElementByPath(overlayRecord, 'VMAD\Scripts');
  if not Assigned(overlayScripts) then
    raise Exception.Create('PDV__ManagerQuest overlay has no VMAD\Scripts.');

  mainScript := Nil;
  patronScript := Nil;

  for i := 0 to Pred(ElementCount(scripts)) do begin
    scriptEntry := ElementByIndex(scripts, i);
    scriptName := GetElementEditValues(scriptEntry, 'scriptName');
    if SameText(scriptName, 'PDV__ManagerQuest') then begin
      if not Assigned(mainScript) then
        mainScript := scriptEntry;
    end;
  end;

  for i := 0 to Pred(ElementCount(overlayScripts)) do begin
    scriptEntry := ElementByIndex(overlayScripts, i);
    scriptName := GetElementEditValues(scriptEntry, 'scriptName');
    if SameText(scriptName, 'PDV__ManagerQuest') then begin
      if Assigned(FindPropertyByName(ElementByName(scriptEntry, 'Properties'), 'PDV_GLO_PatronDeity')) then
        patronScript := scriptEntry;
    end;
  end;

  if not Assigned(mainScript) then
    raise Exception.Create('Unable to locate main PDV__ManagerQuest script entry.');
  if not Assigned(patronScript) then
    raise Exception.Create('Unable to locate overlay patron-property PDV__ManagerQuest script entry.');

  mainProperties := ElementByName(mainScript, 'Properties');
  patronProperties := ElementByName(patronScript, 'Properties');
  patronProperty := FindPropertyByName(patronProperties, 'PDV_GLO_PatronDeity');

  if not Assigned(mainProperties) then
    raise Exception.Create('Main PDV__ManagerQuest script has no Properties container.');
  if not Assigned(patronProperty) then
    raise Exception.Create('Overlay patron script did not contain PDV_GLO_PatronDeity.');

  CopyPropertyIfMissing(mainProperties, patronProperty);

  for i := Pred(ElementCount(scripts)) downto 0 do begin
    scriptEntry := ElementByIndex(scripts, i);
    scriptName := Trim(GetElementEditValues(scriptEntry, 'scriptName'));

    if scriptName = '' then begin
      AddMessage('Removing blank local script entry from PDV__ManagerQuest.');
      RemoveByIndex(scripts, i, True);
      Continue;
    end;

    if SameText(scriptName, 'PDV__ManagerQuest') and not Equals(scriptEntry, mainScript) then
      raise Exception.Create('Framework already has a duplicate PDV__ManagerQuest script entry; aborting to avoid unsafe save.');
  end;

  MarkModifiedRecursive(baseRecord);
  AddMessage('Merged manager overlay into framework.');
end;

procedure MergeMcmRecord;
var
  baseRecord, overlayRecord: IInterface;
begin
  baseRecord := RequireQuestRecord(FrameworkFile, 'PDV_MCM');
  overlayRecord := RequireQuestRecord(McmPatchFile, 'PDV_MCM');

  ReplaceVmad(baseRecord, overlayRecord);
  AddMessage('Merged PDV_MCM VMAD into framework.');
end;

function Initialize: integer;
begin
  Result := 1;
  try
    FrameworkFile := RequireLoadedFile(FrameworkName);
    ManagerPatchFile := RequireLoadedFile(ManagerPatchName);
    McmPatchFile := RequireLoadedFile(McmPatchName);

    NormalizeManagerRecord;
    MergeMcmRecord;
    SortMasters(FrameworkFile);

    AddMessage('PDV overlay merge-back completed.');
    Result := 0;
  except
    on Ex: Exception do begin
      AddMessage('PDV overlay merge-back FAILED: ' + Ex.Message);
      Result := 1;
    end;
  end;
end;

end.
