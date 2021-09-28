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

unit RigSett;

interface

uses
  SysUtils, Classes, RigObj, IniFiles, Math;

type
  TRigSettings = class
  public
    RigType,
    Port,
    BaudRate,
    DataBits,
    Parity,
    StopBits,
    RtsMode, DtrMode,
    PollMs,
    TimeoutMs: integer;

    offset50,
    offset144,
    offset222,
    offset432,
    offset903,
    offset1296,
    offset2G,
    offset3G,
    offset5G,
    offset10G,
    offset24G : Int64;

    procedure FromIni(AIni: TIniFile; ASection: string);
    procedure ToIni(AIni: TIniFile; ASection: string);
    function Text: string;

    procedure FromControls;
    procedure ToControls;

    procedure FromRig(ARig: TRig);
    procedure ToRig(ARig: TRig);
  end;


implementation

uses
  Main, RigCmds, AlComPrt;


//------------------------------------------------------------------------------
//                               helper funs
//------------------------------------------------------------------------------
function BaudRateToIndex(Rate: integer): integer;
begin
  Result := Max(0, MainForm.BaudRateComboBox.Items.IndexOf(IntToStr(Rate)));
end;


function IndexToBaudRate(Idx: integer): integer;
begin
  Result := StrToIntDef(MainForm.BaudRateComboBox.Items[Idx], 9600);
end;





//------------------------------------------------------------------------------
//                               TRigSettings
//------------------------------------------------------------------------------
{ TRigSettings }

procedure TRigSettings.FromIni(AIni: TIniFile; ASection: string);
var
  RigName: string;
begin
  RigName := AIni.ReadString(ASection, 'RigType', 'NONE');
  RigType := Max(0, MainForm.RigTypes.IndexOf(RigName));
  Port := AIni.ReadInteger(ASection, 'Port', Port);
  BaudRate := AIni.ReadInteger(ASection, 'BaudRate', 6);
  DataBits := AIni.ReadInteger(ASection, 'DataBits', 3);
  Parity := AIni.ReadInteger(ASection, 'Parity', 0);
  StopBits := AIni.ReadInteger(ASection, 'StopBits', 0);

  RtsMode := AIni.ReadInteger(ASection, 'RtsMode', 1);
  DtrMode := AIni.ReadInteger(ASection, 'DtrMode', 1);

  offset50 := StrToInt64(AIni.ReadString(ASection, 'offset50', '22000000'));
  offset144 := StrToInt64(AIni.ReadString(ASection, 'offset144', '116000000'));
  offset222 := StrToInt64(AIni.ReadString(ASection, 'offset222', '194000000'));
  offset432 := StrToInt64(AIni.ReadString(ASection, 'offset432', '404000000'));
  offset903 := StrToInt64(AIni.ReadString(ASection, 'offset903', '875000000'));
  offset1296 := StrToInt64(AIni.ReadString(ASection, 'offset1296', '1268000000'));
  offset2G := StrToInt64(AIni.ReadString(ASection, 'offset2G', '2276000000'));
  offset3G := StrToInt64(AIni.ReadString(ASection, 'offset3G', '3428000000'));
  offset5G := StrToInt64(AIni.ReadString(ASection, 'offset5G', '5732000000'));
  offset10G := StrToInt64(AIni.ReadString(ASection, 'offset10G', '10340000000'));
  offset24G := StrToInt64(AIni.ReadString(ASection, 'offset24G', '24164000000'));

  //backward compatibility
  //if AIni.ReadString(ASection, 'Flow', '') = '0' then RtsMode := 2;

  PollMs := AIni.ReadInteger(ASection, 'PollMs', 500);
  TimeoutMs := AIni.ReadInteger(ASection, 'TimeoutMs', 4000);
end;


procedure TRigSettings.ToIni(AIni: TIniFile; ASection: string);
begin
  //erase the obsolete Flow entry
  AIni.EraseSection(ASection);

  AIni.WriteString(ASection, 'RigType', MainForm.RigTypes[RigType]);
  AIni.WriteInteger(ASection, 'Port', Port);
  AIni.WriteInteger(ASection, 'BaudRate', BaudRate);
  AIni.WriteInteger(ASection, 'DataBits', DataBits);
  AIni.WriteInteger(ASection, 'Parity', Parity);
  AIni.WriteInteger(ASection, 'StopBits', StopBits);
  AIni.WriteInteger(ASection, 'RtsMode', RtsMode);
  AIni.WriteInteger(ASection, 'DtrMode', DtrMode);
  AIni.WriteInteger(ASection, 'PollMs', PollMs);
  AIni.WriteInteger(ASection, 'TimeoutMs', TimeoutMs);


  AIni.WriteString(ASection, 'offset50', offset50.ToString);
  AIni.WriteString(ASection, 'offset144', offset144.ToString);
  AIni.WriteString(ASection, 'offset222', offset222.ToString);
  AIni.WriteString(ASection, 'offset432', offset432.ToString);
  AIni.WriteString(ASection, 'offset903', offset903.ToString);
  AIni.WriteString(ASection, 'offset1296', offset1296.ToString);
  AIni.WriteString(ASection, 'offset2G', offset2G.ToString);
  AIni.WriteString(ASection, 'offset3G', offset3G.ToString);
  AIni.WriteString(ASection, 'offset5G', offset5G.ToString);
  AIni.WriteString(ASection, 'offset10G', offset10G.ToString);
  AIni.WriteString(ASection, 'offset24G', offset24G.ToString);
end;


procedure TRigSettings.FromControls;
begin
  RigType := MainForm.RigComboBox.ItemIndex;
  Port := StrToIntDef(Copy(MainForm.PortComboBox.Text, 5, MAXINT), 1);
  BaudRate := MainForm.BaudRateComboBox.ItemIndex;
  DataBits := MainForm.DataBitsComboBox.ItemIndex;
  Parity := MainForm.ParityComboBox.ItemIndex;
  StopBits := MainForm.StopBitsComboBox.ItemIndex;
  RtsMode := MainForm.RtsComboBox.ItemIndex;
  DtrMode := MainForm.DtrComboBox.ItemIndex;
  PollMs := MainForm.PollSpinEdit.Value;
  TimeoutMs := MainForm.TimeoutSpinEdit.Value;
  offset50 := StrToInt64(MainForm.Box50.Text);
  offset144 := StrToInt64(MainForm.Box144.Text);
  offset222 := StrToInt64(MainForm.Box222.Text);
  offset432 := StrToInt64(MainForm.Box432.Text);
  offset903 := StrToInt64(MainForm.Box903.Text);
  offset1296 := StrToInt64(MainForm.Box1296.Text);
  offset2G := StrToInt64(MainForm.Box2G.Text);
  offset3G := StrToInt64(MainForm.Box3G.Text);
  offset5G := StrToInt64(MainForm.Box5G.Text);
  offset10G := StrToInt64(MainForm.Box10G.Text);
  offset24G := StrToInt64(MainForm.Box24G.Text);
end;


procedure TRigSettings.ToControls;
begin
  MainForm.RigComboBox.ItemIndex := RigType;
  MainForm.PortComboBox.ItemIndex :=
    Max(0, MainForm.PortComboBox.Items.IndexOf('COM ' + IntToStr(Port)));
  MainForm.BaudRateComboBox.ItemIndex := BaudRate;
  MainForm.DataBitsComboBox.ItemIndex := DataBits;
  MainForm.ParityComboBox.ItemIndex := Parity;
  MainForm.StopBitsComboBox.ItemIndex := StopBits;
  MainForm.RtsComboBox.ItemIndex := RtsMode;
  MainForm.DtrComboBox.ItemIndex := DtrMode;
  MainForm.PollSpinEdit.Value := PollMs;
  MainForm.TimeoutSpinEdit.Value := TimeoutMs;
  MainForm.Box50.Text := offset50.ToString;
  MainForm.Box144.Text := offset144.ToString;
  MainForm.Box222.Text := offset222.ToString;
  MainForm.Box432.Text := offset432.ToString;
  MainForm.Box903.Text := offset903.ToString;
  MainForm.Box1296.Text := offset1296.ToString;
  MainForm.Box2G.Text := offset2G.ToString;
  MainForm.Box3G.Text := offset3G.ToString;
  MainForm.Box5G.Text := offset5G.ToString;
  MainForm.Box10G.Text := offset10G.ToString;
  MainForm.Box24G.Text := offset24G.ToString;
end;


procedure TRigSettings.FromRig(ARig: TRig);
begin
  RigType := MainForm.RigTypes.IndexOfObject(ARig.RigCommands);
  Port := ARig.ComPort.Port;
  BaudRate := BaudRateToIndex(ARig.ComPort.BaudRate);
  DataBits := ARig.ComPort.DataBits - 5;
  Parity := Ord(ARig.ComPort.Parity);
  StopBits := Ord(ARig.ComPort.StopBits);
  RtsMode := Ord(ARig.ComPort.RtsMode);
  DtrMode := Ord(ARig.ComPort.DtrMode);
  PollMs := ARig.PollMs;
  TimeoutMs := ARig.TimeoutMs;
end;


procedure TRigSettings.ToRig(ARig: TRig);
begin
  ARig.Enabled := false;
  try
    ARig.RigCommands := MainForm.RigTypes.Objects[RigType] as TRigCommands;
    ARig.ComPort.Port := Port;
    ARig.ComPort.BaudRate := IndexToBaudRate(BaudRate);
    ARig.ComPort.DataBits := DataBits + 5;
    ARig.ComPort.Parity := TParity(Parity);
    ARig.ComPort.StopBits := TStopBits(StopBits);
    ARig.ComPort.DtrMode := TFlowControl(DtrMode);
    ARig.ComPort.RtsMode := TFlowControl(RtsMode);
    ARig.PollMs := PollMs;
    ARig.TimeoutMs := TimeoutMs;
  finally
    ARig.Enabled := true;
  end;
end;


{
COM port settings


   setting          HW          SW        NO
---------------------------------------------
RxDsrSensitivity   FALSE       FALSE     FALSE
RxDtrControl       ENABLED     ENABLED   ENABLED
RxRtsControl       HANDSHAKE   ENABLED   ENABLED
TxContinueXoff     FALSE       FALSE     FALSE
TxCtsFlow          TRUE        FALSE     FALSE
TxDsrFlow          FALSE       FALSE     FALSE
XonXoff            FALSE       TRUE      FALSE



Sig    from   TS-570     meaning
-------------------------------------
DTR    COMP            Comp is On
DSR    XCVR            Rig is On
RTS    COMP     +      Comp can receive
CTS    XCVR     +      Rig can receive
}


function TRigSettings.Text: string;
begin
  Result := Format(
    'Rig=%s|Port=COM%d|Baud=%s|Data=%s|Parity=%s|Stop=%s|RTS=%s|Dtr=%s|Poll=%d|Timeout=%d',
    [
    MainForm.RigComboBox.Items[RigType],
    Port,
    MainForm.BaudRateComboBox.Items[BaudRate],
    MainForm.DataBitsComboBox.Items[DataBits],
    MainForm.ParityComboBox.Items[Parity],
    MainForm.StopBitsComboBox.Items[StopBits],
    MainForm.RtsComboBox.Items[RtsMode],
    MainForm.DtrComboBox.Items[DtrMode],
    PollMs,
    TimeoutMs
    ]);
end;

end.

