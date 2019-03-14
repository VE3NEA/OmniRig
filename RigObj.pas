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

unit RigObj;

interface


uses
  Windows, SysUtils, Classes, CustRig, RigCmds, CmdQue, Math, ByteFuns;

type

  //adds command generation and interpretation to the base class

  TRig = class(TCustomRig)
  private
    //value to bytes
    function FormatValue(AValue: integer; AInfo: TParamValue): TByteArray;
    procedure ToText(Arr: TByteArray; Value: integer);
    procedure ToBcdBS(Arr: TByteArray; Value: integer);
    procedure ToBcdBU(Arr: TByteArray; Value: integer);
    procedure ToBcdLS(Arr: TByteArray; Value: integer);
    procedure ToBcdLU(Arr: TByteArray; Value: integer);
    procedure ToBinB(Arr: TByteArray; Value: integer);
    procedure ToBinL(Arr: TByteArray; Value: integer);
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    procedure ToDPIcom(Arr: TByteArray; Value: integer);
    procedure ToYaesu(Arr: TByteArray; Value: integer);
    //bytes to value
    function UnformatValue(AData: TByteArray; AInfo: TParamValue): integer;
    function FromBcdBS(AData: TByteArray): integer;
    function FromBcdBU(AData: TByteArray): integer;
    function FromBcdLS(AData: TByteArray): integer;
    function FromBcdLU(AData: TByteArray): integer;
    function FromBinB(AData: TByteArray): integer;
    function FromBinL(AData: TByteArray): integer;
    function FromText(AData: TByteArray): integer;
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    function FromDPIcom(AData: TByteArray): integer;
    function FromYaesu(AData: TByteArray): integer;

    function ValidateReply(AData: TByteArray; AMask: TBitMask): boolean;
    procedure StoreParam(Param: TRigParam); overload;
    procedure StoreParam(Param: TRigParam; Value: integer); overload;
    procedure ToTextUD(Arr: TByteArray; Value: integer);
  protected
    ChangedParams: TRigParamSet;

    //add commands to the queue
    procedure AddCommands(ACmds: TRigCommandArray; AKind: TCommandKind); override;
    //interpret reply
    procedure ProcessInitReply(ANumber: integer; AData: TByteArray); override;
    procedure ProcessStatusReply(ANumber: integer; AData: TByteArray); override;
    procedure ProcessWriteReply(AParam:TRigParam; AData: TByteArray); override;
    procedure ProcessCustomReply(ASender: Pointer; ACode, AData: TByteArray); override;
  public
    //add command to the queue
    procedure AddWriteCommand(AParam: TRigParam; AValue: integer = 0); override;
    procedure AddCustomCommand(ASender: Pointer; ACode: TByteArray; ALen: integer; AEnd: AnsiString); override;
  end;



implementation

uses
  Main, AutoApp;

{ TRig }

//------------------------------------------------------------------------------
//                          add command to queue
//------------------------------------------------------------------------------
procedure TRig.AddCommands(ACmds: TRigCommandArray; AKind: TCommandKind);
var
  i: integer;
begin
  Lock;
  try
    for i:=0 to High(ACmds) do
      with FQueue.Add do
        begin
        Code := ACmds[i].Code;
        Number := i;
        ReplyLength := ACmds[i].ReplyLength;
        ReplyEnd := BytesToStr(ACmds[i].ReplyEnd);
        Kind := AKind;
        end;
  finally
    Unlock;
  end;
end;


procedure TRig.AddCustomCommand(ASender: Pointer; ACode: TByteArray;
  ALen: integer; AEnd: AnsiString);
begin
  if ACode = nil then Exit;

  Lock;
  try
    with FQueue.Add do
      begin
      Code := ACode;
      Kind := ckCustom;
      CustSender := ASender;
      ReplyLength := ALen;
      ReplyEnd := AEnd;
      end;
  finally
    Unlock;
  end;

  PostMessage(MainForm.Handle, WM_TXQUEUE, RigNumber, 0);
end;


procedure TRig.AddWriteCommand(AParam: TRigParam; AValue: integer);
var
  Cmd: TRigCommand;
  NewCode: TByteArray;
  FmtValue: TByteArray;
begin
  MainForm.Log('RIG%d Generating Write command for %s', [RigNumber, RigCommands.ParamToStr(AParam)]);

  //is cmd supported?
  if RigCommands = nil then Exit;
  Cmd := RigCommands.WriteCmd[AParam];
  if Cmd.Code = nil then
    begin
    MainForm.Log('RIG%d {!}Write command not supported for %s',
      [RigNumber, RigCommands.ParamToStr(AParam)]);
    Exit;
    end;

  //generate cmd
  NewCode := Cmd.Code;
  FmtValue := nil;
  if Cmd.Value.Format <> vfNone then
    try
      FmtValue := FormatValue(AValue, Cmd.Value);
      if Cmd.Value.Start + Cmd.Value.Len > Length(NewCode) then
        raise Exception.Create('{!}Value too long');
      Move(FmtValue[0], NewCode[Cmd.Value.Start], Cmd.Value.Len);
    except on E: Exception do
      begin MainForm.Log('RIG% {!}Generating command: %s', [RigNumber, E.Message]); end;
    end;


  //add to queue
  Lock;
  try
    with FQueue.Add do
      begin
      Code := Copy(NewCode);
      Param := AParam;
      Kind := ckWrite;
      ReplyLength := Cmd.ReplyLength;
      ReplyEnd := BytesToStr(Cmd.ReplyEnd);
      end;
  finally
    Unlock;
  end;

  //reminder to check queue
  PostMessage(MainForm.Handle, WM_TXQUEUE, RigNumber, 0);
end;







//------------------------------------------------------------------------------
//                           interpret reply
//------------------------------------------------------------------------------
function TRig.ValidateReply(AData: TByteArray; AMask: TBitMask): boolean;
begin
  if AMask.Mask = nil then Result := true
  else if Length(AData) <> Length(AMask.Mask) then Result := false
  else if Length(AData) <> Length(AMask.Flags) then Result := false
  else Result := BytesEqual(BytesAnd(AData, AMask.Mask), AMask.Flags);

  if not Result then
    MainForm.Log('{!}RIG%d reply validation failed', [RigNumber]);
end;


procedure TRig.ProcessCustomReply(ASender: Pointer; ACode, AData: TByteArray);
begin
  Lock;
  try
    TOmniRigX(ASender).CustCommand := ACode;
    TOmniRigX(ASender).CustReply := AData;
  finally
    Unlock;
  end;

  ComNotifyCustom(RigNumber, ASender);
end;


procedure TRig.ProcessInitReply(ANumber: integer; AData: TByteArray);
begin
  ValidateReply(AData, RigCommands.InitCmd[ANumber].Validation);
end;


procedure TRig.ProcessStatusReply(ANumber: integer; AData: TByteArray);
var
  i: integer;
  Cmd: PRigCommand;
begin
  //validate reply
  Cmd := @RigCommands.StatusCmd[ANumber];
  if not ValidateReply(AData, Cmd.Validation) then Exit;

  //extract numeric values
  for i:=0 to High(Cmd.Values) do
    try
      StoreParam(Cmd.Values[i].Param, UnformatValue(AData, Cmd.Values[i]));
    except end;

  //extract bit flags
  for i:=0 to High(Cmd.Flags) do
    if (Length(AData) <> Length(Cmd.Flags[i].Mask)) or
       (Length(AData) <> Length(Cmd.Flags[i].Flags))
     then MainForm.Log('{!}RIG%d: incorrect reply length', [RigNumber])
    else if BytesEqual(BytesAnd(AData, Cmd.Flags[i].Mask), Cmd.Flags[i].Flags)
      then StoreParam(Cmd.Flags[i].Param);

  //tell clients
  if ChangedParams <> [] then
    ComNotifyParams(RigNumber, ParamsToInt(ChangedParams));
  ChangedParams := [];
end;


procedure TRig.ProcessWriteReply(AParam: TRigParam; AData: TByteArray);
begin
  ValidateReply(AData, RigCommands.WriteCmd[AParam].Validation);
end;







//------------------------------------------------------------------------------
//                                format
//------------------------------------------------------------------------------
function TRig.FormatValue(AValue: integer; AInfo: TParamValue): TByteArray;
var
  Value: integer;
begin
  Value := Round(AValue * AInfo.Mult + AInfo.Add);
  Result := nil;
  SetLength(Result, AInfo.Len);

  if (AInfo.Format in [vfBcdLU, vfBcdBU]) and (Value < 0) then
    begin
    MainForm.Log('RIG%d: {!}user passed invalid value: %d', [RigNumber, AValue]);
    Exit;
    end;

  case AInfo.Format of
    vfText:  ToText(Result, Value);
    vfBinL:  ToBinL(Result, Value);
    vfBinB:  ToBinB(Result, Value);
    vfBcdLU: ToBcdLU(Result, Value);
    vfBcdLS: ToBcdLS(Result, Value);
    vfBcdBU: ToBcdBU(Result, Value);
    vfBcdBS: ToBcdBS(Result, Value);
    vfYaesu: ToYaesu(Result, Value);
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    vfDPIcom: ToDPIcom(Result, Value);
    vfTextUD: ToTextUD(Result, Value);
    end;
end;


//ASCII codes of digits
procedure TRig.ToText(Arr: TByteArray; Value: integer);
var
  Len: integer;
  S: AnsiString;
begin
  Len := Length(Arr);
  if Value < 0 then Dec(Len);
  S := Format('%%.0%dd', [Len]);
  S := Format(S, [Value]);
  Move(S[1], Arr[0], Length(S));

//  S := StringOfChar('0', Length(Arr)) + IntToStr(Value);
//  Move(S[Length(S)-Length(Arr)+1], Arr[0], Length(Arr));
end;

// Added by RA6UAZ for Icom Marine Radio NMEA Command
procedure TRig.ToDPIcom(Arr: TByteArray; Value: integer);
var
  S: AnsiString;
  F: single;
  C: Char;
begin
  C := DecimalSeparator;
  DecimalSeparator := '.';
  F := Value / 1000000;
  S := StringOfChar('0', Length(Arr)) + FloatToStrF(F,ffFixed,10,6);
  Move(S[Length(S)-Length(Arr)+1], Arr[0], Length(Arr));
  DecimalSeparator := C;
end;


procedure TRig.ToTextUD(Arr: TByteArray; Value: integer);
var
  S: AnsiString;
begin
  S := StringOfChar('0', Length(Arr)) + IntToStr(Abs(Value));
  if Value >= 0 then Arr[0] := Ord('U') else Arr[0] := Ord('D');
  Move(S[Length(S)-Length(Arr)+2], Arr[1], High(Arr));
end;


//integer, little endian
procedure TRig.ToBinL(Arr: TByteArray; Value: integer);
begin
  Move(Value, Arr[0], Min(Length(Arr), SizeOf(Value)));
end;


//integer, big endian
procedure TRig.ToBinB(Arr: TByteArray; Value: integer);
begin
  ToBinL(Arr, Value);
  BytesReverse(Arr);
end;


//BCD big endian unsigned
procedure TRig.ToBcdBU(Arr: TByteArray; Value: integer);
var
  Chars: TByteArray;
  i: integer;
begin
  SetLength(Chars, Length(Arr) * 2);
  ToText(Chars, Value);
  for i:=0 to High(Arr) do
    Arr[i] := ((Chars[i*2] - Ord('0')) shl 4) or (Chars[i*2+1] - Ord('0'));
end;


//BCD little endian unsigned
procedure TRig.ToBcdLU(Arr: TByteArray; Value: integer);
begin
  ToBcdBU(Arr, Value);
  BytesReverse(Arr);
end;


//BCD little endian signed; sign in high byte (00 or FF)
procedure TRig.ToBcdLS(Arr: TByteArray; Value: integer);
begin
  ToBcdLU(Arr, Abs(Value));
  if Value < 0 then Arr[High(Arr)] := $FF;
end;


//BCD big endian signed
procedure TRig.ToBcdBS(Arr: TByteArray; Value: integer);
begin
  ToBcdBU(Arr, Abs(Value));
  if Value < 0 then Arr[0] := $FF;
end;


//16 bits. high bit of the 1-st byte is sign,
//the rest is integer, absolute value, big endian (not complementary!)
procedure TRig.ToYaesu(Arr: TByteArray; Value: integer);
begin
  ToBinB(Arr, Abs(Value));
  if Value < 0 then Arr[0] := Arr[0] or $80;
end;








//------------------------------------------------------------------------------
//                                unformat
//------------------------------------------------------------------------------
function TRig.UnformatValue(AData: TByteArray; AInfo: TParamValue): integer;
begin
  AData := Copy(AData, AInfo.Start, AInfo.Len);

  if (AData = nil) or (Length(AData) <> AInfo.Len) then
    begin MainForm.Log('RIG%d: {!}reply too short', [RigNumber]); Abort; end;

  case AInfo.Format of
    vfText:  Result := FromText(AData);
    vfBinL:  Result := FromBinL(AData);
    vfBinB:  Result := FromBinB(AData);
    vfBcdLU: Result := FromBcdLU(AData);
    vfBcdLS: Result := FromBcdLS(AData);
    vfBcdBU: Result := FromBcdBU(AData);
    vfBcdBS: Result := FromBcdBS(AData);
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    vfDPIcom: Result := FromDPIcom(AData);
    else{vfYaesu:} Result := FromYaesu(AData);
    end;

  Result := Round(Result * AInfo.Mult + AInfo.Add);
end;


function TRig.FromText(AData: TByteArray): integer;
var
  S: AnsiString;
begin
  SetLength(S, Length(AData));

  try
    Move(Adata[0], S[1], Length(S));
    Result := StrToInt(S);
  except
    MainForm.Log('RIG%d: {!}invalid reply', [RigNumber]);
    raise;
  end;
end;

// Added by RA6UAZ for Icom Marine Radio NMEA Command
function TRig.FromDPIcom(AData: TByteArray): integer;
var
  S: AnsiString;
  F: single;
  D: Double;
  C: Char;
  i: integer;
begin
  try
    DecimalSeparator := '.';
    SetLength(S, Length(AData));
    Move(Adata[0], S[1], Length(S));
    for i:=1 to Length(S) do
      if not (S[i] in ['0'..'9','.']) then
        begin SetLength(S, i-1); Break; end;
    Result := Round(1E6 * StrToFloat(S));
  except
    MainForm.Log('RIG%d: {!}invalid reply', [RigNumber]);
    raise;
  end;
end;


function TRig.FromBinL(AData: TByteArray): integer;
var
  B: integer;
begin
  //propagate sign if AData is less than 4 bytes
  if (AData[High(AData)] and $80) = $80 then B := -1 else B := 0;
  //copy data
  Move(AData[0], B, Min(Length(AData), SizeOf(B)));
  Result := B;
end;


function TRig.FromBinB(AData: TByteArray): integer;
begin
  BytesReverse(AData);
  Result := FromBinL(AData);
end;


function TRig.FromBcdBU(AData: TByteArray): integer;
var
  S: AnsiString;
  i: integer;
begin
  SetLength(S, Length(AData) * 2);
  for i:=0 to High(AData) do
    begin
    S[i*2+1] := AnsiChar(Ord('0') + ((AData[i] shr 4) and $0F));
    S[i*2+2] := AnsiChar(Ord('0') + (AData[i] and $0F));
    end;

  try
    Result := StrToInt(S);
  except
    MainForm.Log('RIG%d: {!}invalid BCD value', [RigNumber]);
    raise;
  end;
end;


function TRig.FromBcdLU(AData: TByteArray): integer;
begin
  BytesReverse(AData);
  Result := FromBcdBU(Adata);
end;


function TRig.FromBcdBS(AData: TByteArray): integer;
begin
  if AData[0] = 0 then Result := 1 else Result := -1;
  AData[0] := 0;
  Result := Result * FromBcdBU(AData);
end;


function TRig.FromBcdLS(AData: TByteArray): integer;
begin
  BytesReverse(AData);
  Result := FromBcdBS(AData);
end;


//16 bits. high bit of the 1-st byte is sign,
//the rest is integer, absolute value, big endian (not complementary!)
function TRig.FromYaesu(AData: TByteArray): integer;
begin

  if (AData[0] and $80) = 0 then Result := 1 else Result := -1;
  AData[0] := AData[0] and $7F;
  Result := Result * FromBinB(AData);
end;






//------------------------------------------------------------------------------
//                         store extracted param
//------------------------------------------------------------------------------
procedure TRig.StoreParam(Param: TRigParam);
var
  PParam: PRigParam;
begin
  if Param in VfoParams then PParam := @FVfo
  else if Param in SplitParams then PParam := @FSplit
  else if Param in RitOnParams then PParam := @FRit
  else if Param in XitOnParams then PParam := @FXit
  else if Param in TxParams then PParam := @FTx
  else if Param in ModeParams then PParam := @FMode
  else Exit;

  if Param = PParam^ then Exit;

  PParam^ := Param;
  Include(ChangedParams, Param);

  //unsolved problem:
  //there is no command to read the mode of the other VFO,
  //its change goes undetected.
  if (Param in ModeParams) and (Param <> LastWrittenMode)
    then LastWrittenMode := pmNone;

  MainForm.Log('RIG%d status changed: %s enabled',
    [RigNumber, RigCommands.ParamToStr(Param)]);
end;


procedure TRig.StoreParam(Param: TRigParam; Value: integer);
var
  PValue: PInteger;
begin
  case Param of
    pmFreqA:     PValue := @FFreqA;
    pmFreqB:     PValue := @FFreqB;
    pmFreq:      PValue := @FFreq;
    pmPitch:     PValue := @FPitch;
    pmRitOffset: PValue := @FRitOffset;
    else Exit;
    end;

  if Value = PValue^ then Exit;

  PValue^ := Value;
  Include(ChangedParams, Param);

  MainForm.Log('RIG%d status changed: %s = %d',
    [RigNumber, RigCommands.ParamToStr(Param), Value]);
end;


end.

