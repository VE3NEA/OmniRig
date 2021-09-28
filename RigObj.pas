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
    ExtMicroFreq : Int64;
    //value to bytes
    function FormatValue(AValue: Int64; AInfo: TParamValue): TByteArray;
//w3sz convert from IF freq to RF freq
    function ToRFfreq(Value: Integer) : Int64;  //W3SZ
    //maybe these are OK as integers
    procedure ToText(Arr: TByteArray; Value: Int64);
    procedure ToBcdBS(Arr: TByteArray; Value: Int64);
    procedure ToBcdBU(Arr: TByteArray; Value: Int64);
    procedure ToBcdLS(Arr: TByteArray; Value: Int64);
    procedure ToBcdLU(Arr: TByteArray; Value: Int64);
    procedure ToBinB(Arr: TByteArray; Value: Int64);
    procedure ToBinL(Arr: TByteArray; Value: Int64);
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    procedure ToDPIcom(Arr: TByteArray; Value: Int64);
    procedure ToYaesu(Arr: TByteArray; Value: Int64);
    //bytes to value
    function UnformatValue(AData: TByteArray; AInfo: TParamValue): Int64;
    function FromBcdBS(AData: TByteArray): Int64;
    function FromBcdBU(AData: TByteArray): Int64;
    function FromBcdLS(AData: TByteArray): Int64;
    function FromBcdLU(AData: TByteArray): Int64;
    function FromBinB(AData: TByteArray): Int64;
    function FromBinL(AData: TByteArray): Int64;
    function FromText(AData: TByteArray): Int64;
//w3sz convert from RF freq to IF freq
    function ToIFfreq(Value : Int64) : Int64;     //W3SZ
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    function FromDPIcom(AData: TByteArray): Int64;
    function FromYaesu(AData: TByteArray): Int64;
    function ValidateReply(AData: TByteArray; AMask: TBitMask): boolean;
    procedure StoreParam(Param: TRigParam); overload;
    procedure StoreParam(Param: TRigParam; Value: Int64); overload;
    procedure ToTextUD(Arr: TByteArray; Value: Int64);
    procedure ToFloat(Arr: TByteArray; Value: Int64);
    function FromFloat(AData: TByteArray): Int64;
  protected
    ChangedParams: TRigParamSet;

    //add commands to the queue
    procedure AddCommands(ACmds: TRigCommandArray; AKind: TCommandKind); override;
    //interpret reply
    procedure ProcessInitReply(ANumber: Int64; AData: TByteArray); override;
    procedure ProcessStatusReply(ANumber: Integer; AData: TByteArray); override;
    procedure ProcessWriteReply(AParam:TRigParam; AData: TByteArray); override;
    procedure ProcessCustomReply(ASender: Pointer; ACode, AData: TByteArray); override;
  public
    //add command to the queue
    procedure AddWriteCommand(AParam: TRigParam; AValue: Int64 = 0); override;
    procedure AddCustomCommand(ASender: Pointer; ACode: TByteArray; ALen: Integer; AEnd: AnsiString); override;
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


procedure TRig.AddWriteCommand(AParam: TRigParam; AValue: Int64);
var
  Cmd: TRigCommand;
  NewCode: TByteArray;
  FmtValue: TByteArray;
  strval: string;
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
    with FQueue.AddBeforeStatusCommands do
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


procedure TRig.ProcessInitReply(ANumber: Int64; AData: TByteArray);
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
function TRig.FormatValue(AValue: Int64; AInfo: TParamValue): TByteArray;
var
  Value: Int64;
  initLen: Integer;
  finalLen: Integer;
  diffLen: Integer;
  Value2: Int64;
  newSize:Integer;
begin
  Value := Round(AValue * AInfo.Mult + AInfo.Add);
  MainForm.Log('FormatValue Value is ' + Value.ToString);
  initLen := Value.size;

  Value2 := ToRFfreq(Value);
  MainForm.IF2RF_RF.Text := Value2.ToString;
  finalLen := Value2.Size;
  diffLen := finalLen - initLen;
  MainForm.Log('size difference is ' + diffLen.ToString);
  Result := nil;
  newSize := AInfo.Len;// + diffLen;
  SetLength(Result, newSize);

  if (AInfo.Format in [vfBcdLU, vfBcdBU]) and (Value2 < 0) then
    begin
    MainForm.Log('RIG%d: {!}user passed invalid value: %d', [RigNumber, AValue]);
    Exit;
    end;

  case AInfo.Format of
    vfText:  ToText(Result, Value2);
    vfBinL:  ToBinL(Result, Value2);
    vfBinB:  ToBinB(Result, Value2);
    vfBcdLU: ToBcdLU(Result, Value2);
    vfBcdLS: ToBcdLS(Result, Value2);
    vfBcdBU: ToBcdBU(Result, Value2);
    vfBcdBS: ToBcdBS(Result, Value2);
    vfYaesu: ToYaesu(Result, Value2);
    vfDPIcom: ToDPIcom(Result, Value2);
    vfTextUD: ToTextUD(Result, Value2);
    vfFloat: ToFloat(Result, Value2);
    end;
end;

//w3sz convert from IF freq to RF freq
function TRig.ToRFfreq(Value: Integer) : Int64;  //W3SZ
var
  RFfreq : Int64;
  offset : Int64;
begin
  RFfreq := Value;
  offset := 0;
  if ExtMicroFreq < 50000000 then offset := 0
  else if ExtMicroFreq < 143000000 then offset := MainForm.Sett1.offset50
  else if ExtMicroFreq < 219000000 then offset := MainForm.Sett1.offset144
  else if ExtMicroFreq < 419000000 then offset := MainForm.Sett1.offset222
  else if ExtMicroFreq < 899000000 then offset := MainForm.Sett1.offset432
  else if ExtMicroFreq < 1239000000 then offset := MainForm.Sett1.offset903
  else if ExtMicroFreq < 2299000000 then offset := MainForm.Sett1.offset1296
  else if ExtMicroFreq < 3299000000 then offset := MainForm.Sett1.offset2G
  else if ExtMicroFreq < 5649000000 then offset := MainForm.Sett1.offset3G
  else if ExtMicroFreq < 9999000000 then offset := MainForm.Sett1.offset5G
  else if ExtMicroFreq < 23999000000 then offset := MainForm.Sett1.offset10G
  else if ExtMicroFreq < 46999000000 then offset := MainForm.Sett1.offset24G;

  RFfreq := Value + offset;
  MainForm.IF2RF_LO.Text := offset.ToString;
  MainForm.IF2RF_IF.Text := Value.ToString;

  MainForm.Log('offset = ' + offset.ToString + sLineBreak + 'Value = ' + Value.ToString + sLineBreak + 'RFfreq = ' + RFfreq.ToString);
  Result := RFfreq;
end;

//ASCII codes of digits
procedure TRig.ToText(Arr: TByteArray; Value: Int64);
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
procedure TRig.ToDPIcom(Arr: TByteArray; Value: Int64);
var
  S: AnsiString;
  F: single;
begin
  {$IFNDEF VER200}FormatSettings.{$ENDIF}  DecimalSeparator := '.';
  F := Value / 1000000;
  S := StringOfChar('0', Length(Arr)) + FloatToStrF(F,ffFixed,10,6);
  Move(S[Length(S)-Length(Arr)+1], Arr[0], Length(Arr));
end;


procedure TRig.ToTextUD(Arr: TByteArray; Value: Int64);
var
  S: AnsiString;
begin
  S := StringOfChar('0', Length(Arr)) + IntToStr(Abs(Value));
  if Value >= 0 then Arr[0] := Ord('U') else Arr[0] := Ord('D');
  Move(S[Length(S)-Length(Arr)+2], Arr[1], High(Arr));
end;


//integer, little endian
procedure TRig.ToBinL(Arr: TByteArray; Value: Int64);
begin
  Move(Value, Arr[0], Min(Length(Arr), SizeOf(Value)));
end;


//integer, big endian
procedure TRig.ToBinB(Arr: TByteArray; Value: Int64);
begin
  ToBinL(Arr, Value);
  BytesReverse(Arr);
end;


//BCD big endian unsigned
procedure TRig.ToBcdBU(Arr: TByteArray; Value: Int64);
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
procedure TRig.ToBcdLU(Arr: TByteArray; Value: Int64);
begin
  ToBcdBU(Arr, Value);
  BytesReverse(Arr);
end;


//BCD little endian signed; sign in high byte (00 or FF)
procedure TRig.ToBcdLS(Arr: TByteArray; Value: Int64);
begin
  ToBcdLU(Arr, Abs(Value));
  if Value < 0 then Arr[High(Arr)] := $FF;
end;


//BCD big endian signed
procedure TRig.ToBcdBS(Arr: TByteArray; Value: Int64);
begin
  ToBcdBU(Arr, Abs(Value));
  if Value < 0 then Arr[0] := $FF;
end;


//16 bits. high bit of the 1-st byte is sign,
//the rest is integer, absolute value, big endian (not complementary!)
procedure TRig.ToYaesu(Arr: TByteArray; Value: Int64);
begin
  ToBinB(Arr, Abs(Value));
  if Value < 0 then Arr[0] := Arr[0] or $80;
end;

procedure TRig.ToFloat(Arr: TByteArray; Value: integer);
var
  S: AnsiString;
begin
  {$IFNDEF VER200}FormatSettings.{$ENDIF}  DecimalSeparator := '.';
  S := Format('%.2f', [Length(Arr), Value]);
  Move(S[1], Arr[0], Length(Arr));
end;








//------------------------------------------------------------------------------
//                                unformat
//------------------------------------------------------------------------------
function TRig.UnformatValue(AData: TByteArray; AInfo: TParamValue): Int64;
  var
    AnsiStr : AnsiString;
begin
  AData := Copy(AData, AInfo.Start, AInfo.Len);
  SetString(AnsiStr, PAnsiChar(@AData[0]), Length(AData));
     MainForm.Log('AData by W3SZ is: %s', [AnsiStr]);
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
    vfDPIcom: Result := FromDPIcom(AData);
    vfFloat: Result := FromFloat(AData);
    else{vfYaesu:} Result := FromYaesu(AData);
    end;

  Result := Round(Result * AInfo.Mult + AInfo.Add);
end;


function TRig.FromText(AData: TByteArray): Int64;
var
  S: AnsiString;
  oldResult: Int64;
begin
  SetLength(S, Length(AData));
    MainForm.Log('Entered TRig.FromText');
    MainForm.RF2IF_RF.Text := 'Entered TRig.FromText';
  try
    Move(Adata[0], S[1], Length(S));
    oldResult := StrToInt64(S);
    Result := ToIFfreq(oldResult);
    MainForm.Log('Result by W3SZ is: %s', [IntToStr(oldResult)]);
    MainForm.Log('IFFreq by W3SZ is: %s', [IntToStr(Result)]);
  except
    MainForm.Log('RIG%d: {!}invalid reply', [RigNumber]);
    raise;
  end;
end;

//convert from External Radio Microwave Frequency to IF Frequency for SDR/HDSDR
//input External Radio Microwave Frequency 'Value', output Result = IFfreq
function TRig.ToIFfreq(Value : Int64) : Int64;
var
  IFfreq : Int64;
  offset : Int64;
begin
if Value > 0  then
  begin
  IFfreq := Value;
  offset := 0;
  if Value < 50000000 then offset := 0
  else if Value < 143000000 then offset := MainForm.Sett1.offset50
  else if Value < 219000000 then offset := MainForm.Sett1.offset144
  else if Value < 419000000 then offset := MainForm.Sett1.offset222
  else if Value < 899000000 then offset := MainForm.Sett1.offset432
  else if Value < 1239000000 then offset := MainForm.Sett1.offset903
  else if Value < 2299000000 then offset := MainForm.Sett1.offset1296
  else if Value < 3299000000 then offset := MainForm.Sett1.offset2G
  else if Value < 5649000000 then offset := MainForm.Sett1.offset3G
  else if Value < 9999000000 then offset := MainForm.Sett1.offset5G
  else if Value < 23999000000 then offset := MainForm.Sett1.offset10G
  else if Value < 46999000000 then offset := MainForm.Sett1.offset24G;

  IFfreq := Value - offset;
  ExtMicroFreq := Value;

  MainForm.RF2IF_RF.Text := Value.ToString;
  MainForm.RF2IF_LO.Text := offset.ToString;
  MainForm.RF2IF_IF.Text := IFfreq.ToString;
  MainForm.Log(' From_Rig_offset = ' + offset.ToString + sLineBreak + 'From_Rig_Value = ' + ExtMicroFreq.ToString + sLineBreak + 'From_Rig_IFfreq = ' + IFfreq.ToString);

  Result := IFfreq;
  end
  else
  begin
    Result :=Value;
  end;
end;


// Added by RA6UAZ for Icom Marine Radio NMEA Command
function TRig.FromDPIcom(AData: TByteArray): Int64;
var
  S: AnsiString;
  i: integer;
begin
  try
    {$IFNDEF VER200}FormatSettings.{$ENDIF}DecimalSeparator := '.';
    SetLength(S, Length(AData));
    Move(Adata[0], S[1], Length(S));
    for i:=1 to Length(S) do
      if not (S[i] in ['0'..'9','.', ' ']) then
        begin SetLength(S, i-1); Break; end;
    Result := Round(1E6 * StrToFloat(Trim(S)));
  except
    MainForm.Log('RIG%d: {!}invalid reply', [RigNumber]);
    raise;
  end;
end;


function TRig.FromBinL(AData: TByteArray): Int64;
var
  B: integer;
begin
  //propagate sign if AData is less than 4 bytes
  if (AData[High(AData)] and $80) = $80 then B := -1 else B := 0;
  //copy data
  Move(AData[0], B, Min(Length(AData), SizeOf(B)));
  Result := B;
end;


function TRig.FromBinB(AData: TByteArray): Int64;
begin
  BytesReverse(AData);
  Result := FromBinL(AData);
end;


function TRig.FromBcdBU(AData: TByteArray): Int64;
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
    Result := StrToInt64(S);
  except
    MainForm.Log('RIG%d: {!}invalid BCD value', [RigNumber]);
    raise;
  end;
end;


function TRig.FromBcdLU(AData: TByteArray): Int64;
begin
  BytesReverse(AData);
  Result := FromBcdBU(Adata);
end;


function TRig.FromBcdBS(AData: TByteArray): Int64;
begin
  if AData[0] = 0 then Result := 1 else Result := -1;
  AData[0] := 0;
  Result := Result * FromBcdBU(AData);
end;


function TRig.FromBcdLS(AData: TByteArray): Int64;
begin
  BytesReverse(AData);
  Result := FromBcdBS(AData);
end;


//16 bits. high bit of the 1-st byte is sign,
//the rest is Int64, absolute value, big endian (not complementary!)
function TRig.FromYaesu(AData: TByteArray): Int64;
begin

  if (AData[0] and $80) = 0 then Result := 1 else Result := -1;
  AData[0] := AData[0] and $7F;
  Result := Result * FromBinB(AData);
end;


function TRig.FromFloat(AData: TByteArray): integer;
var
  S: AnsiString;
begin
  try
    SetLength(S, Length(AData));
    Move(Adata[0], S[1], Length(S));
    {$IFNDEF VER200}FormatSettings.{$ENDIF}    DecimalSeparator := '.';
    Result := Round(StrToFloat(Trim(S)));
  except
    MainForm.Log('RIG%d: {!}invalid reply', [RigNumber]);
    raise;
  end;
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


procedure TRig.StoreParam(Param: TRigParam; Value: Int64);
var
  PValue: PInt64;
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

  //unsolved problem:
  //there is no command to read the mode of the other VFO,
  //its change goes undetected.
  if (Param in ModeParams) and (Param <> LastWrittenMode)
    then LastWrittenMode := pmNone;

  MainForm.Log('RIG%d status changed: %s = %d',
    [RigNumber, RigCommands.ParamToStr(Param), Value]);
end;


end.

