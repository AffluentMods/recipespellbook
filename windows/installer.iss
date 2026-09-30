; Windows installer (Inno Setup 6). Build the app first, then from the repo root:
;   $env:APP_VERSION = (Select-String '^version:' pubspec.yaml).Line.Split(' ')[1].Split('+')[0]
;   & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer.iss
; Output: build\RecipeSpellbook-Setup.exe

#define AppVersion GetEnv("APP_VERSION")
#if AppVersion == ""
  #define AppVersion "0.0.0"
#endif

[Setup]
; Keep this AppId forever — it's how upgrades find the existing install.
AppId={{6F1C2B7E-3D4A-4E9B-9B51-7A2E8C5D4F10}
AppName=Recipe Spellbook
AppVersion={#AppVersion}
AppVerName=Recipe Spellbook {#AppVersion}
AppPublisher=AffluentLabs
AppPublisherURL=https://recipespellbook.app
AppSupportURL=https://recipespellbook.app/feedback
DefaultDirName={autopf}\Recipe Spellbook
DefaultGroupName=Recipe Spellbook
DisableProgramGroupPage=yes
OutputDir=..\build
OutputBaseFilename=RecipeSpellbook-Setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\recipespellbook.exe
UninstallDisplayName=Recipe Spellbook
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequiredOverridesAllowed=dialog
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\Recipe Spellbook"; Filename: "{app}\recipespellbook.exe"
Name: "{autodesktop}\Recipe Spellbook"; Filename: "{app}\recipespellbook.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\recipespellbook.exe"; Description: "{cm:LaunchProgram,Recipe Spellbook}"; Flags: nowait postinstall skipifsilent
