//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//                               Omni-Rig
//
//               Copyright (c) 2003 Alex Shovkoplyas, VE3NEA
//
//                           ve3nea@dxatlas.com
//------------------------------------------------------------------------------

unit Main;


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, CustRig, RigObj, RigSett, IniFiles, RigCmds,
  AppEvnts, ComServ, AutoApp, AlStrLst, Spin, ShellApi, WinSpool,
  ShlObj;

type
  TMainForm = class(TForm)
    Panel1: TPanel;
    OkBtn: TButton;
    CancelBtn: TButton;
    TabControl1: TTabControl;
    ApplicationEvents1: TApplicationEvents;
    Timer1: TTimer;
    Panel2: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label10: TLabel;
    PortComboBox: TComboBox;
    BaudRateComboBox: TComboBox;
    DataBitsComboBox: TComboBox;
    ParityComboBox: TComboBox;
    StopBitsComboBox: TComboBox;
    RtsComboBox: TComboBox;
    RigComboBox: TComboBox;
    Panel3: TPanel;
    Image1: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    PollSpinEdit: TSpinEdit;
    TimeoutSpinEdit: TSpinEdit;
    Label13: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label11: TLabel;
    DtrComboBox: TComboBox;
    RightArraowBtn: TButton;
    LeftArrowBtn: TButton;
    procedure OkBtnClick(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TabControl1Changing(Sender: TObject;
      var AllowChange: Boolean);
    procedure TabControl1Change(Sender: TObject);
    procedure ApplicationEvents1Message(var Msg: tagMSG; var Handled: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormHide(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Label15Click(Sender: TObject);
    procedure Label17Click(Sender: TObject);
    procedure RightArraowBtnClick(Sender: TObject);
    procedure LeftArrowBtnClick(Sender: TObject);
    procedure TabControl1DrawTab(Control: TCustomTabControl; TabIndex: Integer;
      const Rect: TRect; Active: Boolean);
  private
    FLog: TFileStream;
    FLogMode: integer;

    procedure LoadRigCommands;
    procedure LoadSettings;
    procedure CleanRigTypes;
    procedure SaveSettings;
    procedure ListComPorts;
    procedure ListBaudRates;
    procedure WmTxQueue(var Msg: TMessage); message WM_TXQUEUE;

    procedure WmComStatus(var Msg: TMessage); message WM_COMSTATUS;
    procedure WmComParams(var Msg: TMessage); message WM_COMPARAMS;
    procedure WmComCustom(var Msg: TMessage); message WM_COMCUSTOM;

    procedure OpenLog;
    procedure CloseLog;
    procedure WMQueryEndSession(var Msg: TMessage); message WM_QUERYENDSESSION;
  public
    RigTypes: TAlStringList;

    Rig1: TRig;
    Rig2: TRig;
    Rig3: TRig;
    Rig4: TRig;
    Sett1: TRigSettings;
    Sett2: TRigSettings;
    Sett3: TRigSettings;
    Sett4: TRigSettings;
    SettTemp: TRigSettings;
    SetBothModes: boolean;

    currentTabIndex: integer;


    procedure ForceForeground;
    function GetVersion: integer;
    procedure Log(Msg: AnsiString); overload;
    procedure Log(Msg: AnsiString; const Args: array of const); overload;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

//------------------------------------------------------------------------------
//                                  sys
//------------------------------------------------------------------------------
procedure TMainForm.FormCreate(Sender: TObject);
begin
  if ComServer.StartMode = smAutomation then Application.ShowMainForm := false;

  OpenLog;

  RigTypes := TAlStringList.Create;
  Rig1 := TRig.Create;
  Rig2 := TRig.Create;
  Rig3 := TRig.Create;
  Rig4 := TRig.Create;
  Sett1 := TRigSettings.Create;
  Sett2 := TRigSettings.Create;
  Sett3 := TRigSettings.Create;
  Sett4 := TRigSettings.Create;
  SettTemp := TRigSettings.Create;

  Sett1.Port := 0;
  Sett2.Port := 1;
  Sett3.Port := 2;
  Sett4.Port := 3;
  Rig1.RigNumber := 1;
  Rig2.RigNumber := 2;
  Rig3.RigNumber := 3;
  Rig4.RigNumber := 4;

  currentTabIndex := 0;

  ListComPorts;
  ListBaudRates;
  LoadRigCommands;
  LoadSettings;

  Sett1.ToRig(Rig1);
  Sett2.ToRig(Rig2);
  Sett3.ToRig(Rig3);
  Sett4.ToRig(Rig4);

  Rig1.Enabled := true;
  Rig2.Enabled := true;
  Rig3.Enabled := true;
  Rig4.Enabled := true;

  Panel2.Align := alClient;
  Width := 230;
  Label9.Caption := Format('Version %d.%d', [HiWord(GetVersion), LoWord(GetVersion)]);


  {!}if ComServer <> nil then ComServer.UIInteractive := false;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  CloseLog;

  Rig1.Free;
  Rig2.Free;
  Rig3.Free;
  Rig4.Free;
  Sett1.Free;
  Sett2.Free;
  Sett3.Free;
  Sett4.Free;
  SettTemp.Free;

  for i:=0 to RigTypes.Count-1 do RigTypes.Objects[i].Free;
  RigTypes.Free;
end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := (ComServer = nil) or (ComServer.ObjectCount = 0);

  if not CanClose then Hide;
end;


procedure TMainForm.ListComPorts;
var
  i: integer;
  PortName: string;

  Siz, Cnt: Cardinal;
  Ports: array[0..255] of TPortInfo1;
begin
{!} Exit;


  PortComboBox.Items.Clear;

  if not EnumPorts(nil, 1, @Ports, SizeOf(Ports), Siz, Cnt) then Exit;
  for i:=0 to Cnt-1 do
    begin
    PortName := Ports[i].pName;
    SetLength(PortName, Length(PortName)-1); //delete ":" at the end
    if Copy(PortName, 1, 3) = 'COM' then
      PortComboBox.Items.Add(PortName);
    end;

  Log('COM ports found: ' + PortComboBox.Items.CommaText);

{
  when this opens COM2, my rig switches to TX mode

  PortComboBox.Items.Clear;
  for i:=1 to 16 do
    begin
    PortName := '\\.\COM' + IntToStr(i);
    Port := CreateFile(PChar(PortName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
    if (Port <> INVALID_HANDLE_VALUE) or (GetLastError = ERROR_ACCESS_DENIED)
      then PortComboBox.Items.Add('COM' + IntToStr(i));
    CloseHandle(Port);
    end;
  Log('COM ports found: ' + PortComboBox.Items.CommaText);
}
end;


procedure TMainForm.ListBaudRates;
const
  //standard baud rates defined in Windows.pas as constants
  BaudRates: array[0..14] of integer = (CBR_110, CBR_300, CBR_600, CBR_1200,
    CBR_2400, CBR_4800, CBR_9600, CBR_14400, CBR_19200, CBR_38400, CBR_56000,
    CBR_57600, CBR_115200, CBR_128000, CBR_256000);
var
  i: integer;
begin
  BaudRateComboBox.Items.Clear;
  for i:=0 to High(BaudRates) do
    BaudRateComboBox.Items.Add(IntToStr(BaudRates[i]));
end;


procedure TMainForm.Timer1Timer(Sender: TObject);
begin
  Rig1.TimerTick;
  Rig2.TimerTick;
  Rig3.TimerTick;
  Rig4.TimerTick;
end;



//------------------------------------------------------------------------------
//                            load/save INI
//------------------------------------------------------------------------------
function GetAfreetDataFolder: TFileName;
begin
  SetLength(Result, MAX_PATH);
  SHGetSpecialFolderPath(Application.Handle, @Result[1], CSIDL_APPDATA, true);
  Result := PChar(Result) + '\Afreet\';
end;


function GetIniName: TFileName;
var
  AppName: TFileName;
begin
  if (GetVersion and $FF) < 6 //6.0 = Vista
    then
      Result := ChangeFileExt(ParamStr(0), '.ini')
    else
      begin
      Result := GetAfreetDataFolder + 'Products\';
      AppName := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
      Result := Result + AppName + '\';
      try ForceDirectories(Result); except end;
      Result := Result + AppName + '.ini';
      end;
end;


procedure TMainForm.CleanRigTypes;
var
  i: integer;
begin
  for i:=0 to RigTypes.Count-1 do
    RigTypes[i] := ChangeFileExt(RigTypes[i], '');
  RigTypes.Sort;

  RigTypes.Insert(0, 'NONE');
end;


procedure TMainForm.LoadRigCommands;
var
  Cmds: TRigCommands;
  i: integer;
  Dir: TFileName;
begin
  //list supported rig types
  Dir := ExtractFilePath(ParamStr(0)) + 'Rigs\';
  RigTypes.LoadFileList(Dir + '*.ini');

  //load commands for each type
  for i:=RigTypes.Count-1 downto 0 do
    try
      Log('Loading commands from "%s"', [RigTypes[i]]);

      Cmds := TRigCommands.Create;
      Cmds.FromIni(Dir + RigTypes[i]);

      if Cmds.FLog.Count > 0 then Log('Errors:'#13#10 + Cmds.FLog.Text);

      if Cmds.FLog.Count = 0
        then RigTypes.Objects[i] := Cmds
        else begin RigTypes.Delete(i); Cmds.Free; end;
    except on E: Exception do
      begin
      Log(E.Message);
      end;
    end;

  CleanRigTypes;
  RigComboBox.Items := RigTypes;
end;


procedure TMainForm.LoadSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniName);
  try
    Sett1.FromIni(Ini, 'RIG1');
    Log('RIG 1 settings: ' + Sett1.Text);
    Sett2.FromIni(Ini, 'RIG2');
    Log('RIG 2 settings: ' + Sett2.Text);
    Sett3.FromIni(Ini, 'RIG3');
    Log('RIG 3 settings: ' + Sett3.Text);
    Sett4.FromIni(Ini, 'RIG4');
    Log('RIG 4 settings: ' + Sett4.Text);
    SetBothModes := Ini.ReadBool('General', 'SetBothModes', false);
  finally
    Ini.Free;
  end;
end;


procedure TMainForm.SaveSettings;
var
  Ini: TIniFile;
begin
  Ini := TIniFile.Create(GetIniName);
  try
    Sett1.ToIni(Ini, 'RIG1');
    Sett2.ToIni(Ini, 'RIG2');
    Sett3.ToIni(Ini, 'RIG3');
    Sett4.ToIni(Ini, 'RIG4');
  finally
    Ini.Free;
  end;
end;






//------------------------------------------------------------------------------
//                           user interface
//------------------------------------------------------------------------------
procedure TMainForm.FormShow(Sender: TObject);
var
  i: integer;
begin
  TabControl1.TabIndex := 0;
  Panel2.Visible := true;
  Panel3.Visible := false;

  Sett1.FromRig(Rig1);
  Sett2.FromRig(Rig2);
  Sett3.FromRig(Rig3);
  Sett4.FromRig(Rig4);
  Sett1.ToControls;

  ComNotifyVisible;
end;


procedure TMainForm.FormHide(Sender: TObject);
begin
  ComNotifyVisible;
end;


procedure TMainForm.TabControl1Changing(Sender: TObject;
  var AllowChange: Boolean);
begin
  case TabControl1.TabIndex of
    0: Sett1.FromControls;
    1: Sett2.FromControls;
    2: Sett3.FromControls;
    3: Sett4.FromControls;
  end;
end;


procedure TMainForm.TabControl1DrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
  var
  h,L: Integer;
begin
  Control.Canvas.Font.Color:=clBlack;
  if TabIndex=0 then begin
    Control.Canvas.Brush.Color:=RGB(0,255,0);
  end;
  if TabIndex=1 then begin
    Control.Canvas.Brush.Color:=RGB(0,255,0);
  end;
  Control.Canvas.Pen.Style:=psClear;
  Control.Canvas.Rectangle(Rect);
  Control.Canvas.TextOut(Rect.Left+5,5,(Control as TTabControl).Tabs[TabIndex]);
end;

procedure TMainForm.TabControl1Change(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0: Sett1.ToControls;
    1: Sett2.ToControls;
    2: Sett3.ToControls;
    3: Sett4.ToControls;
  end;

  Panel2.Visible := TabControl1.TabIndex in [0,1,2,3];
  Panel3.Visible := TabControl1.TabIndex = 4;
end;


procedure TMainForm.OkBtnClick(Sender: TObject);
begin
  case TabControl1.TabIndex of
    0: Sett1.FromControls;
    1: Sett2.FromControls;
    2: Sett3.FromControls;
    3: Sett4.FromControls;
  end;

  Log('RIG 1 settings: ' + Sett1.Text);
  Log('RIG 2 settings: ' + Sett2.Text);
  Log('RIG 3 settings: ' + Sett3.Text);
  Log('RIG 4 settings: ' + Sett4.Text);

  Sett1.ToRig(Rig1);
  Sett2.ToRig(Rig2);
  Sett3.ToRig(Rig3);
  Sett4.ToRig(Rig4);
  SaveSettings;

  Close;
end;


procedure TMainForm.CancelBtnClick(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.RightArraowBtnClick(Sender: TObject);
begin

  //from current control to temp settings
  settTemp.FromControls;

  //from right rig to current settings
  case TabControl1.TabIndex of
    0: Sett2.ToControls;
    1: Sett3.ToControls;
    2: Sett4.ToControls;
    3: Sett1.ToControls;
  end;
  case TabControl1.TabIndex of
    0: Sett1.FromControls;
    1: Sett2.FromControls;
    2: Sett3.FromControls;
    3: Sett4.FromControls;
  end;

  //from temp settings to right control
  settTemp.ToControls;
  case TabControl1.TabIndex of
    0: Sett2.FromControls;
    1: Sett3.FromControls;
    2: Sett4.FromControls;
    3: Sett1.FromControls;
  end;

  TabControl1.TabIndex := (TabControl1.TabIndex+1) mod 4;
  Panel2.Visible := TabControl1.TabIndex in [0,1,2,3];

end;

procedure TMainForm.LeftArrowBtnClick(Sender: TObject);
begin
    //from current control to temp settings
  settTemp.FromControls;

  //from left rig to current settings
  case TabControl1.TabIndex of
    0: Sett4.ToControls;
    1: Sett1.ToControls;
    2: Sett2.ToControls;
    3: Sett3.ToControls;
  end;
  case TabControl1.TabIndex of
    0: Sett1.FromControls;
    1: Sett2.FromControls;
    2: Sett3.FromControls;
    3: Sett4.FromControls;
  end;

  //from temp settings to left control
  settTemp.ToControls;
  case TabControl1.TabIndex of
    0: Sett4.FromControls;
    1: Sett1.FromControls;
    2: Sett2.FromControls;
    3: Sett3.FromControls;
  end;

  TabControl1.TabIndex := (TabControl1.TabIndex+3) mod 4;
  Panel2.Visible := TabControl1.TabIndex in [0,1,2,3];
end;


//------------------------------------------------------------------------------
//                           single instance
//------------------------------------------------------------------------------
procedure TMainForm.ForceForeground;
var
  CurrThreadID, ActiveThreadID: THandle;
begin
  Show;
  //to bring our own window to foreground,
  //we attach temporarily to the active thread
  CurrThreadID := GetCurrentThreadId;
  ActiveThreadID := GetWindowThreadProcessId(GetForegroundWindow, nil);
  AttachThreadInput(CurrThreadID, ActiveThreadID, true);
  try SetForegroundWindow(Application.Handle);
  finally AttachThreadInput(CurrThreadID, ActiveThreadID, false); end;
end;


procedure TMainForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  //another instance is asking us to show window
  with Msg do
    Handled := (Message = WM_USER) and (WParam = 73) and (LParam = 88);

  if Handled then ForceForeground;
end;


function TMainForm.GetVersion: integer;
var
  Dummy: DWord;
  Buf: array of Byte;
  Info: PVSFixedFileInfo;
  Len: UINT;
begin
  Result := 0;
  SetLength(Buf, GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy));
  if Length(Buf) = 0 then Exit;
  if not GetFileVersionInfo(PChar(ParamStr(0)), 0, Length(Buf), @Buf[0]) then Exit;
  if not VerQueryValue(@Buf[0], '\', Pointer(Info), Len) then Exit;
  if Len < SizeOf(TVSFixedFileInfo) then Exit;
  Result := Info.dwFileVersionMS;
end;

procedure TMainForm.WmTxQueue(var Msg: TMessage);
begin
  case Msg.WParam of
    1: Rig1.CheckQueue;
    2: Rig2.CheckQueue;
    3: Rig3.CheckQueue;
    4: Rig4.CheckQueue;
    end;
end;



var
  H: THandle;


procedure TMainForm.Button1Click(Sender: TObject);
var
  Cfg: tCOMMCONFIG;
begin
Cfg.dwSize := sizeof(cfg);
CommConfigDialog('COM1', handle, Cfg);
end;

//------------------------------------------------------------------------------
//                           debugging  log
//------------------------------------------------------------------------------
procedure TMainForm.OpenLog;
begin
  //is logging enabled?
  with TIniFile.Create(GetIniName)do
    try FLogMode := ReadInteger('Debug', 'Log', 0); finally Free; end;
  if FLogMode = 0 then Exit;

  //create log file
  try
    FLog := TFileStream.Create(ChangeFileExt(GetIniName, '.log'),
      fmCreate or fmShareDenyWrite);
  except end;

  Log('Omni-Rig started: Version %d.%d', [HiWord(GetVersion), LoWord(GetVersion)]);
end;




procedure TMainForm.CloseLog;
begin
  Log('Omni-Rig stopped');
  FreeAndNil(FLog);
end;


procedure TMainForm.Log(Msg: AnsiString; const Args: array of const);
begin
  Log(Format(Msg, Args));
end;


procedure TMainForm.Log(Msg: AnsiString);
var
  S: AnsiString;
begin
  //logging disabled
  if (FLog = nil) or (FLogMode = 0) then Exit;

  //close/reopen log
  if FLogMode = 2 then
    begin
    FreeAndNil(FLog);
    try
      FLog := TFileStream.Create(ChangeFileExt(GetIniName, '.log'),
        fmOpenReadWrite	or fmShareDenyWrite);
      FLog.Seek(0, soFromEnd);
    except end;
    end;

  S := FormatDateTime('hh:nn:ss.zzz  ', Now) + Msg;
  if Copy(S, Length(S)-1, 2) <> #13#10 then S := S + #13#10;
  FLog.WriteBuffer(PAnsiChar(S)^, Length(S));
end;


procedure TMainForm.WmComStatus(var Msg: TMessage);
begin
  DoComNotifyStatus(Msg.WParam);
end;

procedure TMainForm.WmComParams(var Msg: TMessage);
begin
  DoComNotifyParams(Msg.WParam, Msg.LParam);
end;

procedure TMainForm.WmComCustom(var Msg: TMessage);
begin
  DoComNotifyCustom(Msg.WParam, Pointer(Msg.LParam));
end;








procedure TMainForm.Label15Click(Sender: TObject);
begin
  ShellExecute(GetDesktopWindow, 'open',
    'http://www.dxatlas.com/OmniRig', '', '', SW_SHOWNORMAL);
end;

procedure TMainForm.Label17Click(Sender: TObject);
begin
  ShellExecute(Application.Handle, nil,
    'mailto:ve3nea@dxatlas.com?subject=OmniRig', '', '', SW_SHOWNORMAL);
end;

procedure TMainForm.WMQueryEndSession(var Msg: TMessage);
begin
  if ComServer <> nil then ComServer.UIInteractive := false;
  inherited;
end;









initialization
  H := FindWindow('TApplication', 'Omni-Rig');
  if H <> 0 then begin PostMessage(H, WM_USER, 73, 88); Halt; end;

  CreateMutex(nil, False, 'OMNIRIG');




end.


