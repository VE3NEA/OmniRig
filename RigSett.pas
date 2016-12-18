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

