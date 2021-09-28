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

unit AlComPrt;

interface

uses
  Windows, SysUtils, Classes, Forms, Math;

const
  BUF_SIZE = 1024;

  NewTimeouts: TCommTimeouts = (
    //read returns immediately
    ReadIntervalTimeout: MAXWORD;
    ReadTotalTimeoutMultiplier: 0;
    ReadTotalTimeoutConstant: 0;
    //write waits infinitely
    WriteTotalTimeoutMultiplier: 0;
    WriteTotalTimeoutConstant: 0);


type
  TStopBits = (sbOne, sbOne_5, sbTwo);
  TParity = (ptNone, ptOdd, ptEven, ptMark, ptSpace);
  TFlowControl = (fcLow, fcHigh, fcHandShake);
  TRxBlockMode = (rbChar, rbBlockSize, rbTerminator);


  TAlCommPort = class;

  TPortThread = class (TThread)
  private
    FPapa: TAlCommPort;
    FWaitEvents: array[0..1] of THandle;
    WtOverlapped: TOverLapped; //overlapped struct for WaitCommEvent
    constructor Create(Papa: TAlCommPort);
    procedure Stop;
  protected
    procedure Execute; override;
  end;


  TAlCommPort = class
  private
    FPortHandle: THandle;
    FDcb: TDCB;
    FOldTimeouts: TCommTimeouts;
    FThread: TPortThread;
    WrOverlapped: TOverLapped; //overlapped struct for WriteFile
    RdOverLapped: TOverLapped; //overlapped struct for ReadFile
    FOnReceived: TNotifyEvent;
    FOnError: TNotifyEvent;
    FOnSent: TNotifyEvent;
    //remember what was set via SetDtrBit, SetRtsBit
    FLastDtrBit, FLastRtsBit: boolean;
    FRtsMode: TFlowControl;
    FDtrMode: TFlowControl;
    FOnCtsDsr: TNotifyEvent;

    procedure SetBaudRate(const Value: integer);
    procedure SetDataBits(const Value: integer);
    procedure SetParity(const Value: TParity);
    procedure SetStopBits(const Value: TStopBits);

    function GetBaudRate: integer;
    function GetDataBits: integer;
    function GetParity: TParity;
    function GetStopBits: TStopBits;

    procedure SetOpen(const Value: boolean);
    procedure OpenPort;
    procedure ClosePort;

    procedure DataFromPort;
    procedure FireErrEvent;
    procedure FireTxEvent;
    procedure FireRxEvent;
    procedure FireCtsDsrEvent;
    function GetOpen: boolean;
    function GetCtsBit: boolean;
    function GetDsrBit: boolean;
    function GetDtrBit: boolean;
    function GetRtsBit: boolean;
    function GetRlsdBit: boolean;
    procedure SetDtrBit(const Value: boolean);
    procedure SetRtsBit(const Value: boolean);
    procedure SetDtrMode(const Value: TFlowControl);
    procedure SetRtsMode(const Value: TFlowControl);
  public
    Port: integer;
    RxBuffer: AnsiString;
    TimeStamp: Int64;

    RxBlockMode: TRxBlockMode;
    RxBlockSize: integer;
    RxBlockTerminator: AnsiString;

    constructor Create;
    destructor Destroy; override;
    procedure PurgeRx;
    procedure PurgeTx;
    procedure Send(Msg: AnsiString);
    function TxQueue: integer;

    property BaudRate: integer read GetBaudRate write SetBaudRate;
    property DataBits: integer read GetDataBits write SetDataBits;
    property StopBits: TStopBits read GetStopBits write SetStopBits;
    property Parity: TParity read GetParity write SetParity;
    property DtrMode: TFlowControl read FDtrMode write SetDtrMode;
    property RtsMode: TFlowControl read FRtsMode write SetRtsMode;

    property Open: boolean read GetOpen write SetOpen;

    property RtsBit: boolean read GetRtsBit write SetRtsBit;
    property DtrBit: boolean read GetDtrBit write SetDtrBit;
    property CtsBit: boolean read GetCtsBit;
    property DsrBit: boolean read GetDsrBit;
    property RlsdBit: boolean read GetRlsdBit; //(receive-line-signal-detect

    property OnError: TNotifyEvent read FOnError write FOnError;
    property OnSent: TNotifyEvent read FOnSent write FOnSent;
    property OnReceived: TNotifyEvent read FOnReceived write FOnReceived;
    property OnCtsDsr: TNotifyEvent read FOnCtsDsr write FOnCtsDsr;
  end;

implementation


{ TPortThread }

constructor TPortThread.Create(Papa: TAlCommPort);
begin
  inherited Create(true);
  FPapa := Papa;
  //events
  FWaitEvents[0] := CreateEvent(nil, true, false, nil);
  FWaitEvents[1] := CreateEvent(nil, true, false, nil);

  //overlapped struct
  FillChar(WtOverlapped, SizeOf(WtOverlapped), 0);
  WtOverlapped.hEvent := FWaitEvents[1];

  //do not replace with Start, does not work
  Resume;
end;


procedure TPortThread.Stop;
begin
  SetEvent(FWaitEvents[0]);
  WaitFor;
  FPapa.FThread := nil;
  Free;
end;


procedure TPortThread.Execute;
var
  Occurred: DWORD;
begin
  Priority := tpTimeCritical;

  while not Terminated do
    begin
    //ask system to report events
    WaitCommEvent(FPapa.FPortHandle, Occurred, @WtOverlapped);

    //wait for events
    case WaitForMultipleObjects(2, @FWaitEvents, false, INFINITE) of
      //stop event
      WAIT_OBJECT_0:
        begin
        CloseHandle(FWaitEvents[0]);
        CloseHandle(FWaitEvents[1]);
        Terminate;
        end;

      //port event
      WAIT_OBJECT_0 + 1:
        begin
        //timestamp the event
        QueryPerformanceCounter(FPapa.TimeStamp);
        //handle the event
        try
          if (Occurred and EV_ERR) > 0 then Synchronize(FPapa.FireErrEvent);
          if (Occurred and EV_TXEMPTY) > 0 then Synchronize(Fpapa.FireTxEvent);
          if (Occurred and EV_RXCHAR) > 0 then Synchronize(Fpapa.DataFromPort);
          if (Occurred and (EV_CTS or EV_DSR or EV_RLSD)) > 0 then Synchronize(Fpapa.FireCtsDsrEvent);
        except Application.HandleException(Self); end;
        end;
      end;
    end;
end;







{ TAlCommPort }

//------------------------------------------------------------------------------
//                                 system
//------------------------------------------------------------------------------
constructor TAlCommPort.Create;
begin
  //fill in DCB
  FillChar(FDcb, SizeOf(FDcb), 0);
  FDcb.DCBlength := SizeOf(FDcb);
  FDcb.XonLim := BUF_SIZE div 2;
  FDcb.XoffLim := MulDiv(BUF_SIZE, 3, 4);
  FDcb.XonChar := #17;  //$11
  FDcb.XoffChar := #19; //$13

  //set default comm paraams
  Port := 1;
  BaudRate := 19200;
  DataBits := 8;
  StopBits := sbOne;
  Parity := ptNone;

  FDtrMode := fcLow;
  RtsMode := fcLow;

  FPortHandle := INVALID_HANDLE_VALUE;
end;


destructor TAlCommPort.Destroy;
begin
  Open := false;
  inherited;

end;





//------------------------------------------------------------------------------
//                                 get/set
//------------------------------------------------------------------------------
function TAlCommPort.GetBaudRate: integer;
begin
  Result := FDcb.BaudRate;
end;

function TAlCommPort.GetDataBits: integer;
begin
  Result := FDcb.ByteSize;
end;

function TAlCommPort.GetParity: TParity;
begin
  Result := TParity(FDcb.Parity);
end;

function TAlCommPort.GetStopBits: TStopBits;
begin
  Result := TStopBits(FDcb.StopBits);
end;

procedure TAlCommPort.SetBaudRate(const Value: integer);
begin
  FDcb.BaudRate := Value;
end;

procedure TAlCommPort.SetDataBits(const Value: integer);
begin
  FDcb.ByteSize := Max(5, Min(8, Value));
end;

procedure TAlCommPort.SetParity(const Value: TParity);
begin
  FDcb.Parity := Ord(Value);
end;

procedure TAlCommPort.SetStopBits(const Value: TStopBits);
begin
  FDcb.StopBits := Ord(Value);
end;







//------------------------------------------------------------------------------
//                             open/close
//------------------------------------------------------------------------------
procedure TAlCommPort.SetOpen(const Value: boolean);
begin
  if Value = Open then Exit;
  if Value then OpenPort else ClosePort;
end;

procedure TAlCommPort.OpenPort;
var
  PortName: AnsiString;
begin
  //open port
  PortName := AnsiString(Format('\\.\COM%d', [Port]));
  FPortHandle := CreateFileA(PAnsiChar(PortName), GENERIC_READ or GENERIC_WRITE,
    0, nil, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, 0);
  if FPortHandle = INVALID_HANDLE_VALUE then Exit;

  try
    //set port params
    if not SetupComm(FPortHandle, BUF_SIZE, BUF_SIZE) then Abort;
    if not SetCommState(FPortHandle, FDcb) then Abort;
    if not GetCommTimeouts(FPortHandle, FOldTimeouts) then Abort;
    if not SetCommTimeouts(FPortHandle, NewTimeouts) then Abort;
    if not SetCommMask(FPortHandle, EV_TXEMPTY or	EV_RXCHAR	or EV_ERR or EV_CTS or EV_DSR or EV_RLSD) then Abort;
    //start sending/receiving
    FThread := TPortThread.Create(Self);
  except
    //could not configure port, close it
    CloseHandle(FPortHandle);
    FPortHandle := INVALID_HANDLE_VALUE;
  end;
end;



procedure TAlCommPort.ClosePort;
begin
  PurgeRx;
  PurgeTx;
  if FThread <> nil then FThread.Stop;
  SetCommTimeouts(FPortHandle, FOldTimeouts);
  CloseHandle(FPortHandle);
  FPortHandle := INVALID_HANDLE_VALUE;
end;






//------------------------------------------------------------------------------
//                             read/write
//------------------------------------------------------------------------------
procedure TAlCommPort.PurgeRx;
begin
  PurgeComm(FPortHandle, PURGE_RXCLEAR or PURGE_RXABORT);
  RxBuffer := '';
end;


procedure TAlCommPort.PurgeTx;
begin
   PurgeComm(FPortHandle, PURGE_TXCLEAR or PURGE_TXABORT);
end;      


procedure TAlCommPort.DataFromPort;
var
  OldCnt, Cnt: Cardinal;
  Fire: boolean;
  Errors: DWORD;
  ComStat: TComStat;
begin
  //read rx count
  ClearCommError(FPortHandle, Errors, @ComStat);
  Cnt := ComStat.cbInQue;
  if Cnt = 0 then Exit;

  //read bytes
  OldCnt := Length(RxBuffer);
  SetLength(RxBuffer, OldCnt + Cnt);
  FillChar(RdOverLapped, SizeOf(RdOverLapped), 0);
  ReadFile(FPortHandle, RxBuffer[OldCnt+1], Cnt, Cnt, @RdOverLapped);

  //fire rx event according to RxBlockMode
  case RxBlockMode of
    rbBlockSize: Fire := Length(RxBuffer) >= RxBlockSize;
    rbTerminator: Fire := Pos(RxBlockTerminator, RxBuffer) > 0;
    else {rbChar:} Fire := true;
    end;

  //purge buffer
  if Fire then
    begin
    FireRxEvent;
    RxBuffer := '';
    end;
end;


procedure TAlCommPort.Send(Msg: AnsiString);
var
  Cnt: DWORD;
begin
  if Msg = '' then Exit;
  FillChar(WrOverlapped, SizeOf(WrOverlapped), 0);
  WriteFile(FPortHandle, Msg[1], Length(Msg), Cnt, @WrOverlapped);

  case GetLastError of
    ERROR_SUCCESS: FireTxEvent;
    ERROR_IO_PENDING: Exit;
    else FireErrEvent;
  end;
end;





//------------------------------------------------------------------------------
//                             fire events
//------------------------------------------------------------------------------
procedure TAlCommPort.FireErrEvent;
begin
  if Assigned(FOnError) then FOnError(Self);
end;


procedure TAlCommPort.FireTxEvent;
begin
  if Assigned(FOnSent) then FOnSent(Self);
end;


procedure TAlCommPort.FireRxEvent;
begin
  if Assigned(FOnReceived) then FOnReceived(Self);
end;


procedure TAlCommPort.FireCtsDsrEvent;
begin
  if Assigned(FOnCtsDsr) then FOnCtsDsr(Self);
end;




function TAlCommPort.TxQueue: integer;
var
  Errors: DWORD;
  ComStat: TComStat;
begin
  ClearCommError(FPortHandle, Errors, @ComStat);
  Result := ComStat.cbOutQue;
end;

function TAlCommPort.GetOpen: boolean;
begin
  Result := FPortHandle <> INVALID_HANDLE_VALUE;
end;






//------------------------------------------------------------------------------
//                             control bits
//------------------------------------------------------------------------------
function TAlCommPort.GetCtsBit: boolean;
var
  ModemStat: DWORD;
begin
  GetCommModemStatus(FPortHandle, ModemStat);
  Result := (ModemStat and MS_CTS_ON) <> 0;
end;

function TAlCommPort.GetDsrBit: boolean;
var
  ModemStat: DWORD;
begin
  GetCommModemStatus(FPortHandle, ModemStat);
  Result := (ModemStat and MS_DSR_ON) <> 0;
end;

function TAlCommPort.GetDtrBit: boolean;
begin
  Result := FLastDtrBit;
end;

function TAlCommPort.GetRtsBit: boolean;
begin
  Result := FLastRtsBit;
end;

function TAlCommPort.GetRlsdBit: boolean;
var
  ModemStat: DWORD;
begin
  GetCommModemStatus(FPortHandle, ModemStat);
  Result := (ModemStat and MS_RLSD_ON) <> 0;
end;


procedure TAlCommPort.SetDtrBit(const Value: boolean);
begin
  if FDtrMode = fcHandShake then Exit;

  if Value
    then EscapeCommFunction(FPortHandle, SETDTR)
    else EscapeCommFunction(FPortHandle, CLRDTR);

  FLastDtrBit := Value;
end;

procedure TAlCommPort.SetRtsBit(const Value: boolean);
begin
  if FRtsMode = fcHandShake then Exit;

  if Value
    then EscapeCommFunction(FPortHandle, SETRTS)
    else EscapeCommFunction(FPortHandle, CLRRTS);

  FLastRtsBit := Value;
end;









//------------------------------------------------------------------------------
//                              control mode
//------------------------------------------------------------------------------

//flow control flags

// 1                    <- LSB
// 0
// X  obey CTS
// 0
//------------
// X  DTR
// X  DTR
// 0
// 0
//------------
// 0
// 0
// 0
// 0
//------------
// X  RTS
// X  RTS
// 0
// 0                    <- MSB

const
  DTRFLAGS: array[TFlowControl] of LongInt = ($0000, $0010, $0024);
  RTSFLAGS: array[TFlowControl] of LongInt = ($0000, $1000, $2004);
  OTHERFLAGS = $0001;


procedure TAlCommPort.SetDtrMode(const Value: TFlowControl);
begin
  FDtrMode := Value;
  FDcb.Flags := DTRFLAGS[FDtrMode] or RTSFLAGS[FRtsMode] or OTHERFLAGS;
end;

procedure TAlCommPort.SetRtsMode(const Value: TFlowControl);
begin
  FRtsMode := Value;
  FDcb.Flags := DTRFLAGS[FDtrMode] or RTSFLAGS[FRtsMode] or OTHERFLAGS;
end;



end.

