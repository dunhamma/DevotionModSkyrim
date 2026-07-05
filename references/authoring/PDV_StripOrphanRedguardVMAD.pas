{
  PDV_StripOrphanRedguardVMAD

  Removes four orphaned ScriptObjectProperty entries from the PDV__ManagerQuest
  quest record VMAD in Devotion.esp. These properties were dropped from the
  compiled PDV__ManagerQuest.pex script (superseded by the *_Sect_*_Entry
  variants), so the engine logs "cannot find property" warnings at every game
  load. Removing the dead VMAD entries silences the warnings with no gameplay
  effect (they point at nothing the script reads).

  Orphans removed (Redguard neglect-notice Message properties, never re-declared):
    PDV_Notif_Redguard_AncestorLayer_NeglectTexture
    PDV_Notif_Redguard_Crown_NeglectTexture
    PDV_Notif_Redguard_Forebear_NeglectTexture
    PDV_Notif_Redguard_AshAbah_NeglectTexture

  Confirmed present 2026-07-05 via houseCARL: QUST 00C325:Devotion.esp,
  VMAD\Scripts[PDV__ManagerQuest]\Properties indices 84-87 (of 419).

  Safety:
    - Targets Devotion.esp only.
    - Pass 1 verifies a live sibling property (PDV_Notif_Redguard_Sect_Crown_Entry)
      is present before ANY removal, so it never edits the wrong record or a
      VMAD of an unexpected shape. If the sibling is absent it aborts with NO
      changes marked.
    - Idempotent: removes only the four named orphans if present; a re-run on an
      already-clean plugin marks nothing modified.

  Run: launch SSEEdit through MO2 on the Devotion Dev profile, load Devotion.esp
  (+ masters), right-click any record -> Apply Script -> this script -> OK.
  On close, SAVE Devotion.esp when prompted (SSEEdit writes Devotion.esp.backup
  automatically). Verify with houseCARL that the Properties count dropped 419->415
  and the four names are gone, or that Papyrus.0.log no longer logs NeglectTexture.
}
unit PDV_StripOrphanRedguardVMAD;

const
  TargetPlugin = 'Devotion.esp';
  ManagerEditorId = 'PDV__ManagerQuest';
  ManagerScriptName = 'PDV__ManagerQuest';
  LiveSiblingProperty = 'PDV_Notif_Redguard_Sect_Crown_Entry';

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

function PropertyNameAt(aProperties: IInterface; aIndex: integer): string;
begin
  Result := Trim(GetElementEditValues(ElementByIndex(aProperties, aIndex), 'propertyName'));
end;

function HasProperty(aProperties: IInterface; const aName: string): boolean;
var
  i: integer;
begin
  Result := False;
  if not Assigned(aProperties) then
    Exit;
  for i := 0 to Pred(ElementCount(aProperties)) do
    if SameText(PropertyNameAt(aProperties, i), aName) then begin
      Result := True;
      Exit;
    end;
end;

function IsOrphanName(const aName: string): boolean;
begin
  Result :=
    SameText(aName, 'PDV_Notif_Redguard_AncestorLayer_NeglectTexture') or
    SameText(aName, 'PDV_Notif_Redguard_Crown_NeglectTexture') or
    SameText(aName, 'PDV_Notif_Redguard_Forebear_NeglectTexture') or
    SameText(aName, 'PDV_Notif_Redguard_AshAbah_NeglectTexture');
end;

function Initialize: integer;
var
  f, rec, scripts, scriptEntry, props: IInterface;
  i, s, removed, siblingSeen: integer;
  scriptName, pName: string;
begin
  Result := 1;
  try
    f := FindLoadedFile(TargetPlugin);
    if not Assigned(f) then
      raise Exception.Create(TargetPlugin + ' is not loaded in this SSEEdit session.');

    rec := MainRecordByEditorID(GroupBySignature(f, 'QUST'), ManagerEditorId);
    if not Assigned(rec) then
      raise Exception.Create('Quest record not found: ' + ManagerEditorId + ' in ' + TargetPlugin);

    scripts := ElementByPath(rec, 'VMAD\Scripts');
    if not Assigned(scripts) then
      raise Exception.Create(ManagerEditorId + ' has no VMAD\Scripts.');

    { Pass 1 -- verify we are on the right record before mutating anything. }
    siblingSeen := 0;
    for s := 0 to Pred(ElementCount(scripts)) do begin
      scriptEntry := ElementByIndex(scripts, s);
      scriptName := Trim(GetElementEditValues(scriptEntry, 'scriptName'));
      if not SameText(scriptName, ManagerScriptName) then
        Continue;
      props := ElementByName(scriptEntry, 'Properties');
      if HasProperty(props, LiveSiblingProperty) then
        siblingSeen := siblingSeen + 1;
    end;

    if siblingSeen = 0 then
      raise Exception.Create('Live sibling ' + LiveSiblingProperty + ' not found on any ' + ManagerScriptName + ' script entry; aborting with NO changes (wrong record or unexpected VMAD shape).');

    { Pass 2 -- remove the orphans, iterating downto for index safety. }
    removed := 0;
    for s := 0 to Pred(ElementCount(scripts)) do begin
      scriptEntry := ElementByIndex(scripts, s);
      scriptName := Trim(GetElementEditValues(scriptEntry, 'scriptName'));
      if not SameText(scriptName, ManagerScriptName) then
        Continue;
      props := ElementByName(scriptEntry, 'Properties');
      if not Assigned(props) then
        Continue;
      for i := Pred(ElementCount(props)) downto 0 do begin
        pName := PropertyNameAt(props, i);
        if IsOrphanName(pName) then begin
          AddMessage('Removing orphan VMAD property: ' + pName);
          RemoveByIndex(props, i, True);
          removed := removed + 1;
        end;
      end;
    end;

    if removed > 0 then begin
      MarkModifiedRecursive(rec);
      AddMessage('PDV_StripOrphanRedguardVMAD: removed ' + IntToStr(removed) + ' orphan property/properties from ' + ManagerEditorId + '. SAVE ' + TargetPlugin + ' on exit.');
    end else
      AddMessage('PDV_StripOrphanRedguardVMAD: no orphan properties present (already clean). Nothing to save.');

    Result := 0;
  except
    on Ex: Exception do begin
      AddMessage('PDV_StripOrphanRedguardVMAD FAILED: ' + Ex.Message);
      Result := 1;
    end;
  end;
end;

end.
