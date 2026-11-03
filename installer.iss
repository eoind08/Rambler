[Setup]
AppId=ce71dfa7-e271-4ae7-a72c-77d1238dc1c5
AppName=Rambler
AppVersion=0.1.0
AppPublisher=eoind08
AppPublisherURL=https://github.com/eoind08/Rambler
DefaultDirName={autopf}\Rambler
DefaultGroupName=Rambler
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
WizardStyle=modern
SetupIconFile=assets\ramblerlogo.ico
UninstallDisplayIcon={app}\Rambler.exe
OutputDir=dist
OutputBaseFilename=Rambler-Setup-0.1.0
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile=LICENSE.txt
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Files]
Source: "dist\Rambler\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\Rambler"; Filename: "{app}\Rambler.exe"
Name: "{autodesktop}\Rambler"; Filename: "{app}\Rambler.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\Rambler.exe"; Description: "Launch Rambler"; Flags: nowait postinstall skipifsilent