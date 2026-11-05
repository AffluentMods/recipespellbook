; Windows installer (Inno Setup 6). Build the app first, then from the repo root:
;   $env:APP_VERSION = (Select-String '^version:' pubspec.yaml).Line.Split(' ')[1].Split('+')[0]
;   & "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" windows\installer.iss
; Output: build\RecipeSpellbook-Setup.exe
;
; The wizard art in windows\installer\ comes from generate_wizard_images.py there. It has no
; version number in it, so it only needs making again when the logo changes.
;
; Not code-signed yet, so Windows SmartScreen warns the first time someone runs it. Once Azure
; Artifact Signing is set up, sign the output with signtool (/fd SHA256 and a timestamp server).

#define AppVersion GetEnv("APP_VERSION")
#if AppVersion == ""
  #define AppVersion "0.0.0"
#endif
#define AppName "Recipe Spellbook"
#define AppExe "recipespellbook.exe"
#define AppURL "https://recipespellbook.app"
#define BuildDir "..\build\windows\x64\runner\Release"
; The Microsoft Store package: its family name, and what opens it.
#define StorePackageFamily "AffluentLabs.RecipeSpellbook_a13075jvne08e"
#define StoreAppTarget "shell:AppsFolder\" + StorePackageFamily + "!recipespellbook"

; The app needs the Visual C++ runtime, which Windows does not ship. The build puts it next to
; the exe (windows\CMakeLists.txt); an installer made from a build without it would install an
; app that does not start on a PC that never had the runtime, so it is not made at all.
#define RuntimeDir AddBackslash(SourcePath) + BuildDir + "\"
#if !FileExists(RuntimeDir + "msvcp140.dll") || !FileExists(RuntimeDir + "vcruntime140.dll") || !FileExists(RuntimeDir + "vcruntime140_1.dll")
  #error The Visual C++ runtime (msvcp140.dll, vcruntime140.dll, vcruntime140_1.dll) is not in the build folder. Build the app again with "flutter build windows --release".
#endif

[Setup]
; Keep this AppId forever: it is how upgrades find the existing install.
AppId={{6F1C2B7E-3D4A-4E9B-9B51-7A2E8C5D4F10}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName={#AppName} {#AppVersion}
AppPublisher=Affluent Labs
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}/download
AppCopyright=© 2026 Affluent Labs LLC. All rights reserved.
VersionInfoVersion={#AppVersion}.0
VersionInfoCompany=Affluent Labs
VersionInfoDescription={#AppName} setup
VersionInfoProductName={#AppName}
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
; A first install shows the folder page; an upgrade reuses the folder it is in.
DisableDirPage=auto
DisableWelcomePage=no
DisableReadyPage=yes
OutputDir=..\build
OutputBaseFilename=RecipeSpellbook-Setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName={#AppName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
WizardSizePercent=110,110
WizardImageFile=installer\wizard_image.bmp
WizardSmallImageFile=installer\wizard_small_image.bmp
WizardImageStretch=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; Installs for everyone by default, as every earlier version did, so an upgrade lands on top of
; the existing copy; the dialog still lets someone install just for themselves.
PrivilegesRequiredOverridesAllowed=dialog
; Offers to close a running Recipe Spellbook, so its files are not in use.
CloseApplications=yes
RestartApplications=no
; Setup speaks the Windows display language when it has a translation for it.
ShowLanguageDialog=no
LanguageDetectionMethod=uilanguage

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"

[Messages]
english.WelcomeLabel1=Welcome to Recipe Spellbook
english.WelcomeLabel2=Every recipe you've saved, in one book: import from links and other apps, plan your meals and build shopping lists that sort themselves by aisle.%n%nThis installs [name/ver] on your computer.
english.FinishedHeadingLabel=You're all set
english.FinishedLabelNoIcons=Recipe Spellbook {#AppVersion} is installed and ready.
english.FinishedLabel=Recipe Spellbook {#AppVersion} is installed and ready. Open it to start your first cookbook.
english.SelectDirLabel3=Setup will install Recipe Spellbook in this folder.
english.SelectDirBrowseLabel=Click Next to continue, or Browse to pick a different folder.
english.ConfirmUninstall=Remove %1 from this PC?%n%nYour recipes and photos are kept in your Documents folder, so they are still there if you install it again.

; No language prefix: these show in English whatever language Setup speaks.
[CustomMessages]
StoreCopyFound=Recipe Spellbook from the Microsoft Store is already on this PC, and the Store keeps it up to date.%n%nBoth copies use the same recipes, so you only need one, and they should not be open at the same time.%n%nInstall this copy anyway?
WhatsNew=See what's new in {#AppVersion}

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; Linker leftovers (.lib, .exp, .pdb) and a Store package left in the build folder are not part of the app.
Source: "{#BuildDir}\*"; DestDir: "{app}"; Excludes: "*.lib,*.exp,*.pdb,*.msix"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExe}"; Comment: "Every recipe you've saved, in one book"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Comment: "Every recipe you've saved, in one book"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,{#AppName}}"; Flags: nowait postinstall skipifsilent
Filename: "{#AppURL}/changelog"; Description: "{cm:WhatsNew}"; Flags: postinstall shellexec skipifsilent unchecked

[Registry]
; recipespellbook:// links (the website's "Open in app" buttons) open the app. HKA is HKLM for an
; install for everyone and HKCU for one just for this user; uninstall removes the whole key. A link
; clicked while the app is open goes to that window (windows\runner\main.cpp).
Root: HKA; Subkey: "Software\Classes\recipespellbook"; ValueType: string; ValueName: ""; ValueData: "URL:{#AppName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\recipespellbook"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKA; Subkey: "Software\Classes\recipespellbook\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\{#AppExe},0"
Root: HKA; Subkey: "Software\Classes\recipespellbook\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"" ""%1"""

[UninstallDelete]
Type: dirifempty; Name: "{app}"

[Code]

// Whether Recipe Spellbook from the Microsoft Store is installed for this Windows account:
// Windows keeps a folder for each installed package under its family name.
function StoreCopyInstalled(): Boolean;
begin
  Result := DirExists(ExpandConstant('{localappdata}\Packages\{#StorePackageFamily}'));
end;

// The Store copy and this one share the recipe database in Documents. Say so before installing
// a second copy, and open the Store one instead when that is what the person wants.
function InitializeSetup(): Boolean;
var
  ResultCode: Integer;
begin
  Result := True;
  if WizardSilent or not StoreCopyInstalled() then
    Exit;
  if SuppressibleMsgBox(CustomMessage('StoreCopyFound'), mbConfirmation, MB_YESNO, IDYES) = IDNO then
  begin
    Exec(ExpandConstant('{win}\explorer.exe'), '{#StoreAppTarget}', '', SW_SHOWNORMAL, ewNoWait, ResultCode);
    Result := False;
  end;
end;
