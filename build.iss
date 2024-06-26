; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{5982780D-AF94-472B-867C-9A995FD8ACBF}
AppName=DSPBoard SDK
AppVersion=r1.0
AppVerName=DSPBoard SDK
AppPublisher=Altelec                                
DefaultDirName={%USERPROFILE}\.dsp-board-sdk
DisableDirPage=no
DisableProgramGroupPage=yes
; Remove the following line to run in administrative install mode (install for all users.)
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=
OutputDir=.\
OutputBaseFilename=dsp_board_sdk_win_x64
SolidCompression=yes
Compression=lzma2/fast
WizardStyle=modern


[Languages]
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
;DOCS
Source: ".\docs\*"; \
DestDir: "{app}\docs"; Flags: ignoreversion recursesubdirs createallsubdirs
;DOXYGEN
Source: ".\doxygen\*"; \
DestDir: "{app}\doxygen"; Flags: ignoreversion recursesubdirs createallsubdirs
;GCC
Source: ".\gcc\*";   \
DestDir: "{app}\gcc"; Flags: ignoreversion recursesubdirs createallsubdirs
;LIB
Source: ".\lib\*"; \
Excludes: "*\build, *\.git"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs
;MAKE
Source: ".\make\*"; \
DestDir: "{app}\make"; Flags: ignoreversion recursesubdirs createallsubdirs
;PACKS
Source: ".\packs\*";  \
Excludes: "\STM32CubeF4\Documentation,\STM32CubeF4\_htmresc,\STM32CubeF4\Middlewares,\STM32CubeF4\Projects,\STM32CubeF4\Utilities"; DestDir: "{app}\packs"; Flags: ignoreversion recursesubdirs createallsubdirs
;SVD
Source: ".\svd\*";  \
DestDir: "{app}\svd"; Flags: ignoreversion recursesubdirs createallsubdirs
;UTILS
Source: ".\utils\*"; \
DestDir: "{app}\utils"; Flags: ignoreversion recursesubdirs createallsubdirs
;VScode
Source: ".\vscode\*"; \
Excludes: "data.tar.gz,dsp-board-ide.desktop"; DestDir: "{app}\vscode"; Flags: ignoreversion recursesubdirs createallsubdirs
;POWERSHELL
Source: ".\powershell\*"; DestDir: "{app}\powershell"; Flags: ignoreversion recursesubdirs createallsubdirs
;Fonts
Source: ".\fonts\*"; DestDir: "{tmp}\fonts"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\DSPBoardIDE"; Filename: "{app}\vscode\Code.exe"; WorkingDir: "{app}\vscode";
Name: "{autodesktop}\DSPBoardIDE"; Filename: "{app}\vscode\Code.exe"; WorkingDir: "{app}\vscode"; Tasks: desktopicon

[Run]
Filename: "{app}\powershell\pwsh.exe"; WorkingDir: "{app}"; Parameters: "-ExecutionPolicy Unrestricted -File .\utils\tools\update_path.ps1 {app}"; Description: "SDK Path Updater"; Flags: shellexec waituntilterminated runascurrentuser;

[Registry]
;Contextual Menu
Root: HKCR; Subkey: "Directory\Background\shell\DSPBoardSDK"; ValueType: string; ValueName: ""; ValueData: "Open with DSPBoardIDE"; Flags: uninsdeletekey
Root: HKCR; Subkey: "Directory\Background\shell\DSPBoardSDK"; ValueType: string; ValueName: "Icon"; ValueData: "{app}\vscode\Code.exe"
Root: HKCR; Subkey: "Directory\Background\shell\DSPBoardSDK\command"; ValueType: expandsz; ValueName: ""; ValueData: """{app}\vscode\Code.exe"" ""%V"""

[Code]
procedure CurPageChanged(CurPageID: Integer);
var
InstallMessage: TLabel;
begin
  if CurPageID = wpInstalling then begin
    InstallMessage:= TLabel.Create(WizardForm);
    InstallMessage.AutoSize:= False;
    InstallMessage.Top := WizardForm.ProgressGauge.Top + 
     WizardForm.ProgressGauge.Height + ScaleY(8);
    InstallMessage.Height := ScaleY(200);
    InstallMessage.Left := WizardForm.ProgressGauge.Left + ScaleX(0);
    InstallMessage.Width := ScaleX(450);
    InstallMessage.Font:= WizardForm.FilenameLabel.Font;
    InstallMessage.Font.Color:= clBlack;
    InstallMessage.Font.Height:= ScaleY(12);
    InstallMessage.Transparent:= True;
    InstallMessage.WordWrap:= true;
    InstallMessage.Caption:= (
        'Se incluye:'#13#10 +
        '    •	GNU Arm Embedded Toolchain 10.3-2021.10'#13#10 +
        '    •	STM32F4 CubeIDE CMSIS Pack [1.27.1] [Reduced]'#13#10 +
        '    •	STM32F407xx Datasheet'#13#10 +
        '    •	xpack [4.3 x64] [Build Tools for Windows]'#13#10 +
        '    •	openocd [0.12.0 x64]'#13#10 +
        '    •	DSPBoard-HAL lib [dev]'#13#10 +
        '    •	Visual Studio Code [1.89.0]'#13#10 +
        '    •	PowerShell [7.4.2] x64'#13#10
    );
    InstallMessage.Parent:= WizardForm.InstallingPage; 
  end;
end;

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
var
  dirString: String;
begin
  Result := True;
  { if we're on the directory selection page and the value returned by }
  { the WizardDirValue function contains at least one space, then... }
  if (CurPageID = wpSelectDir) and (Pos(' ', WizardDirValue) > 0) then
  begin
    Result := False;
    MsgBox('El directorio de instalación no puede contener espacios. ' +
      'Por favor, seleccione otro directorio.', mbError, MB_OK);
  end;
end;

[UninstallDelete]
Type: filesandordirs; Name: "{app}\vscode"