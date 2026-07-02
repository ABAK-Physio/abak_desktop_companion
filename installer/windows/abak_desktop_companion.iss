#define MyAppName "ABAK Desktop Companion"
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0-dev"
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
OutputBaseFilename=ABAK_Desktop_Companion_Setup_{#MyAppVersion}
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
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\ABAK Desktop Companion"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\ABAK Desktop Companion"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Lancer ABAK Desktop Companion"; Flags: nowait postinstall skipifsilent