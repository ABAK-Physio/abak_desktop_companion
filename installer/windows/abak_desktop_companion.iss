// The caller must supply the verified staging directory from build_windows_release.ps1.
#ifndef MySourceDir
#error MySourceDir is required. Run scripts/build_windows_installer.bat.
#endif

#if !FileExists(MySourceDir + "\ABAKDocumentControls.exe")
#error Document service missing from the prepared distribution.
#endif
#if !FileExists(MySourceDir + "\ABAKDocumentControlsPolicy.exe")
#error Document policy helper missing from the prepared distribution.
#endif
#if !FileExists(MySourceDir + "\data\DocumentControls\setup.ps1")
#error Document service setup script missing from the prepared distribution.
#endif
#if !FileExists(MySourceDir + "\abak_desktop_companion.exe")
#error Prepared application executable missing from MySourceDir.
#endif

#define MyAppName "ABAK Desktop Companion"
#define MyArtifactName "ABAK_Desktop_Companion"

#ifndef MyAppVersion
#define MyAppVersion "0.0.0-dev"
#endif

#ifndef MyBuildNumber
#define MyBuildNumber "0"
#endif

#define MyAppPublisher "ABAK Physio"
#define MyAppExeName "abak_desktop_companion.exe"

[Setup]
AppId={{ABAK-DESKTOP-COMPANION-001}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\ABAK Desktop Companion
DefaultGroupName=ABAK Desktop Companion
DisableProgramGroupPage=yes
OutputDir=..\..\build\installer
OutputBaseFilename={#MyArtifactName}_{#MyAppVersion}_{#MyBuildNumber}_Windows_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "desktopicon"; Description: "Créer une icône sur le Bureau"; GroupDescription: "Icônes supplémentaires :"; Flags: unchecked

[Files]
; Development rebuilds may keep the same version: replace changed private files.
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: replacesameversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\ABAK Desktop Companion"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\ABAK Desktop Companion"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer ABAK Desktop Companion"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; This unconditional entry only removes an empty application directory.
; Runtime-dependent cleanup belongs in CurUninstallStepChanged: Check on
; UninstallDelete is evaluated by Setup while recording the uninstall log.
Type: dirifempty; Name: "{app}"

[Code]
var
  AbakDocumentServiceRemoved: Boolean;
  AbakRemoveVitaleModule: Boolean;
  AbakVitaleModuleRemoved: Boolean;
  AbakVitaleRestartRequired: Boolean;
  AbakVitaleUninstaller: String;

function AbakDeleteGeneratedFile(Name: String): Boolean;
var
  Path: String;
begin
  Path := ExpandConstant('{app}\') + Name;
  Result := True;
  if not FileExists(Path) then
    Exit;
  Result := DeleteFile(Path);
  if Result then
    Log('ABAK: generated file removed: ' + Path)
  else
    Log('ABAK: generated file could not be removed: ' + Path);
end;

procedure AbakCleanGeneratedFiles;
var
  AllRemoved: Boolean;
begin
  { Called only after setup.ps1 -Mode Remove has exited successfully and
    closed its transcript. Never delete application data or unknown files. }
  AllRemoved := True;
  if not AbakDeleteGeneratedFile('document_controls_installation.json') then
    AllRemoved := False;
  if not AbakDeleteGeneratedFile('document-controls-installation.log') then
    AllRemoved := False;
  if not AllRemoved then
    SuppressibleMsgBox('Certains fichiers techniques de Companion n''ont pas ' +
      'pu être supprimés. Consultez le dossier d''installation.',
      mbError, MB_OK, IDOK);
end;

function AbakSelectVitaleRemoval: Boolean;
var
  ChoiceForm: TSetupForm;
  Information: TNewStaticText;
  RemoveModule: TNewCheckBox;
  ContinueButton, CancelButton: TNewButton;
begin
  { CreateCustomForm changed signature in Inno Setup 6.6. }
#if VER >= 0x06060000
  ChoiceForm := CreateCustomForm(560, 206, True, True);
#else
  ChoiceForm := CreateCustomForm;
  ChoiceForm.ClientWidth := ScaleX(560);
  ChoiceForm.ClientHeight := ScaleY(206);
#endif
  try
    ChoiceForm.Caption := 'Désinstallation de Companion';
    ChoiceForm.BorderStyle := bsDialog;
    ChoiceForm.Position := poScreenCenter;

    Information := TNewStaticText.Create(ChoiceForm);
    Information.Parent := ChoiceForm;
    Information.AutoSize := False;
    Information.WordWrap := True;
    Information.SetBounds(ScaleX(20), ScaleY(20), ScaleX(520), ScaleY(46));
    Information.Caption := 'Companion va être désinstallé. Vos données patients, ' +
      'documents et sauvegardes seront conservés.';

    RemoveModule := TNewCheckBox.Create(ChoiceForm);
    RemoveModule.Parent := ChoiceForm;
    RemoveModule.SetBounds(ScaleX(20), ScaleY(76), ScaleX(520), ScaleY(28));
    RemoveModule.Caption := 'Supprimer également le module ABAK Carte Vitale';
    RemoveModule.Checked := True;

    Information := TNewStaticText.Create(ChoiceForm);
    Information.Parent := ChoiceForm;
    Information.AutoSize := False;
    Information.WordWrap := True;
    Information.SetBounds(ScaleX(20), ScaleY(112), ScaleX(520), ScaleY(38));
    Information.Caption := 'Décochez cette option pour conserver le module, ' +
      'par exemple si vous prévoyez de réinstaller Companion.';

    ContinueButton := TNewButton.Create(ChoiceForm);
    ContinueButton.Parent := ChoiceForm;
    ContinueButton.SetBounds(ScaleX(318), ScaleY(164), ScaleX(110), ScaleY(26));
    ContinueButton.Caption := 'Continuer';
    ContinueButton.Default := True;
    ContinueButton.ModalResult := mrOk;

    CancelButton := TNewButton.Create(ChoiceForm);
    CancelButton.Parent := ChoiceForm;
    CancelButton.SetBounds(ScaleX(438), ScaleY(164), ScaleX(102), ScaleY(26));
    CancelButton.Caption := 'Annuler';
    CancelButton.Cancel := True;
    CancelButton.ModalResult := mrCancel;

    Result := ChoiceForm.ShowModal = mrOk;
    if Result then
      AbakRemoveVitaleModule := RemoveModule.Checked;
  finally
    ChoiceForm.Free;
  end;
end;

function InitializeUninstall: Boolean;
begin
  Result := True;
  AbakDocumentServiceRemoved := False;
  AbakRemoveVitaleModule := False;
  AbakVitaleModuleRemoved := False;
  AbakVitaleRestartRequired := False;
  { The Vitale module uses this fixed Program Files location. Do not infer
    installation merely from its parent directory, and never delete it by hand. }
  AbakVitaleUninstaller := ExpandConstant('{autopf}\ABAK\Vitale\unins000.exe');
  if not FileExists(AbakVitaleUninstaller) then begin
    Log('ABAK Vitale: uninstaller absent; optional removal skipped.');
    Exit;
  end;
  { An unattended Companion uninstall preserves the independently installed
    module: no interactive choice, and no implicit consent on its behalf. }
  if not UninstallSilent then
    Result := AbakSelectVitaleRemoval;
end;

procedure AbakUninstallVitale;
var
  Code: Integer;
  Failure: String;
begin
  if not AbakRemoveVitaleModule then
    Exit;
  { Recheck immediately before execution: the module may have been removed
    after the choice dialog was displayed. Absence is never an error. }
  if not FileExists(AbakVitaleUninstaller) then begin
    Log('ABAK Vitale: uninstaller no longer present; optional removal skipped.');
    Exit;
  end;

  Failure := '';
  if not Exec(AbakVitaleUninstaller,
    '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART', '', SW_HIDE,
    ewWaitUntilTerminated, Code) then
    Failure := 'Impossible de lancer le désinstalleur Carte Vitale : ' +
      SysErrorMessage(Code)
  else if (Code <> 0) and (Code <> 3010) then
    Failure := 'Le désinstalleur Carte Vitale a retourné le code ' + IntToStr(Code) + '.'
  else begin
    AbakVitaleModuleRemoved := True;
    AbakVitaleRestartRequired := Code = 3010;
    Log('ABAK Vitale: uninstaller completed successfully.');
  end;

  if Failure <> '' then begin
    Log(Failure);
    SuppressibleMsgBox(Failure + #13#10#13#10 +
      'La désinstallation de Companion se poursuit. Le module Carte Vitale ' +
      'pourra être désinstallé séparément.', mbError, MB_OK, IDOK);
  end;
end;

function UninstallNeedRestart: Boolean;
begin
  Result := AbakVitaleRestartRequired;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  Code: Integer;
  Helper: String;
begin
  Result := '';
  Helper := ExpandConstant('{app}\ABAKDocumentControlsPolicy.exe');
  if FileExists(Helper) then begin
    if not Exec(Helper, 'stop', '', SW_HIDE, ewWaitUntilTerminated, Code) then
      Result := 'Impossible de préparer la mise à jour des contrôles documentaires.'
    else if Code <> 0 then
      Result := 'Le service documentaire ne peut pas être arrêté. Fermez Companion et réessayez.';
  end;
end;

function AbakConfigureDocumentService(Mode: String): Boolean;
var
  Code: Integer;
  Parameters: String;
begin
  Parameters := '-NoProfile -NonInteractive -ExecutionPolicy Bypass -File "' +
    ExpandConstant('{app}\data\DocumentControls\setup.ps1') +
    '" -ApplicationDirectory "' + ExpandConstant('{app}') + '" -Mode ' + Mode;
  Result := Exec(ExpandConstant('{sys}\WindowsPowerShell\v1.0\powershell.exe'),
    Parameters, '', SW_HIDE, ewWaitUntilTerminated, Code);
  if Result then Result := Code = 0;
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then begin
    if not AbakConfigureDocumentService('Install') then
      RaiseException('Installation des contrôles documentaires interrompue. Consultez document-controls-installation.log dans le dossier de Companion.');
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if CurUninstallStep = usUninstall then begin
    if not AbakConfigureDocumentService('Remove') then
      RaiseException('Le service documentaire ne peut pas être supprimé. Consultez document-controls-installation.log avant de réessayer.');
    AbakDocumentServiceRemoved := True;
    AbakUninstallVitale;
    AbakCleanGeneratedFiles;
  end else if CurUninstallStep = usPostUninstall then begin
    { RemoveDir only removes empty directories. Unrelated files are kept. }
    if AbakDocumentServiceRemoved then
      if DirExists(ExpandConstant('{app}')) then
        if not RemoveDir(ExpandConstant('{app}')) then
          Log('ABAK: application directory retained because it is not empty or is in use.');
    if AbakVitaleModuleRemoved then begin
      if DirExists(ExpandConstant('{autopf}\ABAK\Vitale')) then
        if not RemoveDir(ExpandConstant('{autopf}\ABAK\Vitale')) then
          Log('ABAK Vitale: resource directory retained because it is not empty or is in use.');
      if DirExists(ExpandConstant('{autopf}\ABAK')) then
        if not RemoveDir(ExpandConstant('{autopf}\ABAK')) then
          Log('ABAK Vitale: parent directory retained because it is not empty or is in use.');
    end;
  end;
end;
