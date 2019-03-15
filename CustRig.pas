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

unit CustRig;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms, AlComPrt, RigCmds, SyncObjs,
  CmdQue, ByteFuns, StrUtils;



const
  MAX_TIMEOUT = 6;
  WM_TXQUEUE = WM_USER + 1;
  WM_COMSTATUS = WM_USER + 2;
  WM_COMPARAMS = WM_USER + 3;
  WM_COMCUSTOM = WM_USER + 4;
  NEVER = 999999;
  DinMS = 1 / 86400000;

type
  TRigCtlStatus = (stNotConfigured, stDisabled, stPortBusy, stNotResponding,
    stOnLine);


  TCustomRig = class
  private
    FEnabled: boolean;
    FOnline: boolean;
    FCritSect: TCriticalSection;
    FRigCommands: TRigCommands;
    FNextStatusTime, FDeadLineTime: TDateTime;

    procedure SetEnabled(const Value: boolean);
    function GetStatus: TRigCtlStatus;

    procedure RecvEvent(Sender: TObject);
    procedure SentEvent(Sender: TObject);
    procedure CtsDsrEvent(Sender: TObject);

    procedure SetFreq(const Value: Int64);
    procedure SetFreqA(const Value: Int64);
    procedure SetFreqB(const Value: Int64);
    procedure SetRitOffset(const Value: integer);
    procedure SetPitch(const Value: integer);
    procedure SetVfo(const Value: TRigParam);
    procedure SetSplit(const Value: TRigParam);
    procedure SetRit(const Value: TRigParam);
    procedure SetXit(const Value: TRigParam);
    procedure SetTx(const Value: TRigParam);
    procedure SetMode(const Value: TRigParam);
    procedure SetRigCommands(const Value: TRigCommands);
    function GetSplit: TRigParam;

  protected
    FQueue: TCommandQueue;

    FFreq: Int64;
    FFreqA: Int64;
    FFreqB: Int64;
    FRitOffset: integer;
    FPitch: integer;
    FVfo: TRigParam;
    FSplit: TRigParam;
    FRit: TRigParam;
    FXit: TRigParam;
    FTx: TRigParam;
    FMode: TRigParam;

    //these commands are implemented in the descendant class,
    //just to keep them in a separate file
    procedure AddCommands(ACmds: TRigCommandArray; AKind: TCommandKind);
      virtual; abstract;

    procedure ProcessInitReply(ANumber: Int64; AData: TByteArray);
      virtual; abstract;
    procedure ProcessStatusReply(ANumber: integer; AData: TByteArray);
      virtual; abstract;
    procedure ProcessWriteReply(AParam:TRigParam; AData: TByteArray);
      virtual; abstract;
    procedure ProcessCustomReply(ASender: Pointer; ACode, AData: TByteArray);
      virtual; abstract;

  public
    RigNumber: integer;
    PollMs, TimeoutMs: integer;
    ComPort: TAlCommPort;
    LastWrittenMode: TRigParam;

    constructor Create;
    destructor Destroy; override;

    procedure AddWriteCommand(AParam: TRigParam; AValue: Int64 = 0);
      virtual; abstract;
    procedure AddCustomCommand(ASender: Pointer; ACode: TByteArray;
      ALen: integer; AEnd: AnsiString); virtual; abstract;

    procedure Lock;
    procedure UnLock;
    procedure Start;
    procedure Stop;
    procedure TimerTick;
    procedure CheckQueue;
    procedure ForceVfo(const Value: TRigParam);

    function GetStatusStr: AnsiString;


    property RigCommands: TRigCommands read FRigCommands write SetRigCommands;
    property Enabled: boolean read FEnabled write SetEnabled;
    property Status: TRigCtlStatus read GetStatus;

    //current rig parameters
    property Freq: Int64 read FFreq write SetFreq;
    property FreqA: Int64 read FFreqA write SetFreqA;
    property FreqB: Int64 read FFreqB write SetFreqB;
    property Pitch: integer read FPitch write SetPitch;
    property RitOffset: integer read FRitOffset write SetRitOffset;
    property Vfo: TRigParam read FVfo write SetVfo;
    property Split: TRigParam read GetSplit write SetSplit;
    property Rit: TRigParam read FRit write SetRit;
    property Xit: TRigParam read FXit write SetXit;
    property Tx: TRigParam read FTx write SetTx;
    property Mode: TRigParam read FMode write SetMode;
  end;

implementation

uses
   Main, AutoApp;


{ TCustomRig }

//------------------------------------------------------------------------------
//                                 system
//------------------------------------------------------------------------------
constructor TCustomRig.Create;
begin
  FCritSect := TCriticalSection.Create;
  FQueue := TCommandQueue.Create;

  ComPort := TAlCommPort.Create;
  ComPort.OnReceived := RecvEvent;
  ComPort.OnSent := SentEvent;
  ComPort.OnCtsDsr := CtsDsrEvent;
end;


destructor TCustomRig.Destroy;
begin
  //no COM clients left, locking unnecessary
  Stop;
  ComPort.Free;
  FQueue.Free;
  FCritSect.Free;

  inherited;
end;






//------------------------------------------------------------------------------
//                                 status
//------------------------------------------------------------------------------
function TCustomRig.GetStatus: TRigCtlStatus;
begin
  Lock;
  try
    if RigCommands = nil then Result := stNotConfigured
    else if not FEnabled then Result := stDisabled
    else if not ComPort.Open then Result := stPortBusy
    else if not FOnline then Result := stNotResponding
    else Result := stOnLine;
  finally
    UnLock;
  end;
end;


function TCustomRig.GetStatusStr: AnsiString;
const
  StatusStr: array[TRigCtlStatus] of AnsiString =
    ('Rig is not configured', 'Rig is disabled', 'Port is not available',
     'Rig is not responding', 'On-line');
begin
  Result := StatusStr[GetStatus];
end;







//------------------------------------------------------------------------------
//                                 Comm port
//------------------------------------------------------------------------------
procedure TCustomRig.SetEnabled(const Value: boolean);
begin
  if FEnabled = Value then Exit;

  //check for valid RigCommands
  if Value and (RigCommands = nil) then Exit;

  if Value then Start else Stop;
  ComNotifyStatus(RigNumber);
  LastWrittenMode := pmNone;
end;


procedure TCustomRig.Start;
begin
  if RigCommands = nil then Exit;

  MainForm.Log('Starting RIG%d', [RigNumber]);

  Lock;
  try
    if FEnabled then Exit;
    FEnabled := true;
    FQueue.Clear;
    FQueue.Phase := phIdle;
    FDeadLineTime := NEVER;

    AddCommands(RigCommands.InitCmd, ckInit);
    AddCommands(RigCommands.StatusCmd, ckStatus);
    try ComPort.Open := true; except end;
  finally
    Unlock;
  end;

  CheckQueue;
  if ComPort.Open
    then CheckQueue
    else MainForm.Log('RIG%d {!} Unable to open port', [RigNumber]);

  //    else Timer.Enabled := true;
end;


procedure TCustomRig.Stop;
begin
  if not FEnabled then Exit;

  MainForm.Log('Stopping RIG%d', [RigNumber]);

  Lock;
  try
    FEnabled := false;
    FOnline := false;
    FQueue.Clear;
    FQueue.Phase := phIdle;
    ComPort.Open := false;
  finally
    Unlock;
  end;
end;


procedure TCustomRig.SentEvent(Sender: TObject);
begin
  MainForm.Log('RIG%d data sent, %d bytes in TX buffer', [RigNumber, ComPort.TxQueue]);

  if ComPort.TxQueue > 0 then Exit;

  Lock;
  try
    //are we here by mistake?
    if (not ComPort.Open) or (FQueue.Phase <> phSending) or (FQueue.Count = 0)
      then Exit;

    if FQueue.CurrentCmd.NeedsReply
      then
        //prepare to receive reply
        begin
        FQueue.Phase := phReceiving;
        FDeadLineTime := Now + DinMS * TimeoutMs;
        end
      else
        //send next cmd if queue not empty
        begin
        FQueue.Delete(0);
        FQueue.Phase := phIdle;
        FDeadLineTime := NEVER;
        CheckQueue;
        end;
  finally
    Unlock;
  end;
end;


procedure TCustomRig.RecvEvent(Sender: TObject);
var
  Data: TByteArray;
begin
  Lock;
  try
    //read data
    Data := nil;

    if ComPort.RxBuffer <> '' then  Data := StrToBytes(ComPort.RxBuffer);
    ComPort.PurgeRx;

    //some COM ports do not send EV_TXEMPTY

    if (FQueue.Phase = phSending) {and (ComPort.TxQueue = 0)} then
      begin
      FQueue.Phase := phReceiving;
      MainForm.Log('RIG%d %d bytes in TX buffer, accepting reply', [RigNumber, ComPort.TxQueue]);
      end;


    if FQueue.Phase = phReceiving
      then MainForm.Log('RIG%d reply received: %s',
              [RigNumber, BytesToHex(Data)])
      else MainForm.Log('RIG%d {!}unexpected data received: %s',
              [RigNumber, BytesToHex(Data)]);

    //are we in the right state?
    if (not ComPort.Open) or (FQueue.Phase <> phReceiving) or (FQueue.Count = 0)
      then Exit;

    //process data
    try
      with FQueue.CurrentCmd do
        case Kind of
          ckInit:   ProcessInitReply(Number, Data);
          ckWrite:  ProcessWriteReply(Param, Data);
          ckStatus: ProcessStatusReply(Number, Data);
          ckCustom: ProcessCustomReply(CustSender, Code, Data);
          end;
    except on E: Exception do
      begin MainForm.Log('RIG% {!}Processing reply: %s', [RigNumber, E.Message]); end;
    end;

    //we are receiving data, therefore we are online
    if not FOnline then
      begin
      FOnline := true;
      ComNotifyStatus(RigNumber);
      end;

    //send next command if queue not empty
    FQueue.Delete(0);
    FQueue.Phase := phIdle;
    FDeadLineTime := NEVER;
    CheckQueue;
  finally
    Unlock;
  end;
end;


procedure TCustomRig.CtsDsrEvent(Sender: TObject);
const
  BoolStr: array[boolean] of string = ('OFF', 'ON');
begin
  MainForm.Log('RIG%d ctrl bits: CTS=%s DSR=%s RLS=%s',
    [RigNumber,
     BoolStr[ComPort.CtsBit],
     BoolStr[ComPort.DsrBit],
     BoolStr[ComPort.RlsdBit]]);
end;







//------------------------------------------------------------------------------
//                                  queue
//------------------------------------------------------------------------------
procedure TCustomRig.Lock;
begin
  FCritSect.Enter;
end;


procedure TCustomRig.UnLock;
begin
  FCritSect.Leave;
end;


procedure TCustomRig.CheckQueue;
var
  S: AnsiString;
begin
  Lock;
  if ComPort.Open and (FQueue.Phase = phIdle) and (FQueue.Count > 0) then
    try
      //anything in rx buffer?
      if ComPort.RxBuffer <> '' then
        begin
        MainForm.Log('RIG%d {!}unexpected bytes in RX buffer: %s',
              [RigNumber, StrToHex(ComPort.RxBuffer)]);
        ComPort.PurgeRx;
        end;

      //prepare port for receiving reply
      with FQueue[0] do
        begin
        ComPort.RxBlockSize := ReplyLength;
        ComPort.RxBlockTerminator :=  ReplyEnd;
        if ReplyEnd <> '' then ComPort.RxBlockMode := rbTerminator
        else if ReplyLength > 0 then ComPort.RxBlockMode := rbBlockSize
        else ComPort.RxBlockMode := rbChar;
        end;

      //log
      case FQueue[0].Kind of
        ckInit: S := 'init';
        ckWrite: S := FRigCommands.ParamToStr(FQueue[0].Param);
        ckStatus: S := 'status';
        ckCustom: S := 'custom';
        end;
      MainForm.Log('RIG%d sending %s command: %s',
        [RigNumber, S, BytesToHex(FQueue[0].Code)]);
      //send command
      FQueue.Phase := phSending;
      FDeadLineTime := Now + DinMS * TimeoutMs;
      with FQueue[0] do ComPort.Send(BytesToStr(Code));
      //{!} debug
      MainForm.Log('RIG%d ComPort.Send called, %d bytes in TX buffer', [RigNumber, ComPort.TxQueue]);
    finally
      Unlock;
    end;
end;


procedure TCustomRig.TimerTick;
begin
  Lock;
  try
    if not FEnabled then Exit;

    //try to open port
    if not ComPort.Open then try ComPort.Open := true; except end;

    //refresh params
    if ComPort.Open and (Now > FNextStatusTime) then
      begin
      if FQueue.HasStatusCommands
        then
          MainForm.Log('RIG%d Status commands already in queue', [RigNumber])
        else
          begin
          MainForm.Log('RIG%d Adding status commands to queue', [RigNumber]);
          AddCommands(RigCommands.StatusCmd, ckStatus);
          end;

      FNextStatusTime := Now + DinMS * PollMs;
      end;

    //on-line timeout occurred
    if Now > FDeadLineTime then
      begin
      //switch off-line
      if FOnline then
        begin
        FOnline := false;
        ComNotifyStatus(RigNumber);
        LastWrittenMode := pmNone;
        end;

      //cancel pending operation
      case FQueue.Phase of
        phSending:
          begin
          MainForm.Log('RIG%d {!}send timeout, %d bytes still in TX buffer',
            [RigNumber, ComPort.TxQueue]);
          //do not send the remaining part
          ComPort.PurgeTx;
          //send the same cmd again
          FQueue.Phase := phIdle;
          FDeadLineTime := NEVER;
          end;
        phReceiving:
          begin
          MainForm.Log('RIG%d {!}recv timeout. RX Buffer: "%s"',
            [RigNumber, StrToHex(ComPort.RxBuffer)]);
          //waste partial reply
          ComPort.PurgeRx;
          ComPort.RxBlockMode := rbChar;
          //consider current cmd unreplied
          FQueue.Delete(0);
          //allow next cmd
          FQueue.Phase := phIdle;
          FDeadLineTime := NEVER;
          end;
        end;
      end;
  finally
    Unlock;
  end;

  CheckQueue;
end;







//------------------------------------------------------------------------------
//                               set param
//------------------------------------------------------------------------------
procedure TCustomRig.SetRigCommands(const Value: TRigCommands);
begin
  FRigCommands := Value;
  ComNotifyRigType(RigNumber);
end;

procedure TCustomRig.SetFreq(const Value: Int64);
begin
  if Enabled then AddWriteCommand(pmFreq, Value);
end;


procedure TCustomRig.SetFreqA(const Value: Int64);
begin
  if Enabled and (Value <> FFreqA) then AddWriteCommand(pmFreqA, Value);
end;


procedure TCustomRig.SetFreqB(const Value: Int64);
begin
  if Enabled and (Value <> FFreqB) then AddWriteCommand(pmFreqB, Value);
end;

procedure TCustomRig.SetMode(const Value: TRigParam);
begin
  if Enabled and (Value in ModeParams) then AddWriteCommand(Value);
end;

procedure TCustomRig.SetPitch(const Value: integer);
begin
  if not Enabled then Exit;
  AddWriteCommand(pmPitch, Value);
  //remember the pitch that we set if we cannot read it back from the rig
  if not (pmPitch in RigCommands.ReadableParams) then FPitch := Value;
end;

procedure TCustomRig.SetRitOffset(const Value: integer);
begin
  if Enabled and (Value <> FRitOffset) then AddWriteCommand(pmRitOffset, Value);
end;

procedure TCustomRig.SetRit(const Value: TRigParam);
begin
  if Enabled and (Value in RitOnParams) and (Value <> FRit) then AddWriteCommand(Value);
end;

procedure TCustomRig.SetSplit(const Value: TRigParam);
begin
  if not (Enabled and (Value in SplitParams)) then Exit;

  if (Value in RigCommands.WriteableParams) and (Value <> Split) then AddWriteCommand(Value)

  else if Value = pmSplitOn then
    begin
    if Vfo = pmVfoAA then Vfo := pmVfoAB
    else if Vfo = pmVfoBB then Vfo := pmVfoBA;
    end

  else
    begin
    if Vfo = pmVfoAB then Vfo := pmVfoAA
    else if Vfo = pmVfoBA then Vfo := pmVfoBB;
    end
end;

procedure TCustomRig.SetTx(const Value: TRigParam);
begin
  if Enabled and (Value in TxParams) then AddWriteCommand(Value);
end;

procedure TCustomRig.SetVfo(const Value: TRigParam);
begin
  if Enabled and (Value in VfoParams) and (Value <> FVfo) then AddWriteCommand(Value);
end;

procedure TCustomRig.ForceVfo(const Value: TRigParam);
begin
  if Enabled then AddWriteCommand(Value);
end;

procedure TCustomRig.SetXit(const Value: TRigParam);
begin
  if Enabled and (Value in XitOnParams) and (Value <> Xit) then AddWriteCommand(Value);
end;






function TCustomRig.GetSplit: TRigParam;
begin
  Result := FSplit;
  if Result <> pmNone then Exit;

  if Vfo in [pmVfoAA, pmVfoBB] then Result := pmSplitOff
  else if Vfo in [pmVfoAB, pmVfoBA] then Result := pmSplitOn;
end;

end.

