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

unit RigCmds;

interface

uses
  SysUtils, Classes, IniFiles, TypInfo, AlStrLst, Math, ByteFuns;

type
  PRigParam = ^TRigParam;
  TRigParam = (pmNone, 
    pmFreq, pmFreqA, pmFreqB, pmPitch, pmRitOffset, pmRit0,
    pmVfoAA, pmVfoAB, pmVfoBA, pmVfoBB, pmVfoA, pmVfoB, pmVfoEqual, pmVfoSwap,
    pmSplitOn, pmSplitOff,
    pmRitOn, pmRitOff,
    pmXitOn, pmXitOff,
    pmRx, pmTx,
    pmCW_U, pmCW_L, pmSSB_U, pmSSB_L, pmAM, pmFM, pmRTTY, pmPSK);

  TRigParamSet = set of TRigParam;

const
  NumericParams = [pmFreq..pmRitOffset];
  VfoParams = [pmVfoAA..pmVfoSwap];
  SplitParams = [pmSplitOn, pmSplitOff];
  RitOnParams = [pmRitOn, pmRitOff];
  XitOnParams = [pmXitOn, pmXitOff];
  TxParams = [pmRx, pmTx];
  ModeParams = [pmCW_U, pmCW_L, pmSSB_U, pmSSB_L, pmAM, pmFM, pmRTTY, pmPSK];


type
  TValueFormat = (
    vfNone,
    vfText,   //asc codes
    vfBinL,   //integer, little endian
    vfBinB,   //integer, big endian
    vfBcdLU,  //BCD little endian unsigned
    vfBcdLS,  //BCD little endian signed; sign in high byte (00 or FF)
    vfBcdBU,  //big endian
    vfBcdBS,  //big endian
    vfYaesu,  //format invented by Yaesu
// Added by RA6UAZ for Icom Marine Radio NMEA Command
    vfDPIcom,  //format Decimal point by Icom
    vfTextUD); //Yaesu: text, but sign is U for + and D for -


  TParamValue = record
    Start, Len: integer;  //insert or extract bytes, Start is a 0-based index
    Format: TValueFormat; //encode or decode according to this format
    Mult, Add: Single;    //linear transformation before encoding or after decoding
    Param: TRigParam;     //param to insert or to report
    end;


  TBitMask = record
    Mask: TByteArray;   //do bitwise AND with this mask
    Flags: TByteArray;  //compare result to these bits
    Param: TRigParam;   //report this param if bits match
    end;


  PRigCommand = ^TRigCommand;
  TRigCommand = record
    //what to send
    Code: TByteArray;
    Value: TParamValue;
    //what to wait for
    ReplyLength: integer;
    ReplyEnd: TByteArray;
    Validation: TBitMask;
    //what to extract
    Values: array of TParamValue;
    Flags: array of TBitMask;
    end;

  TRigCommandArray = array of TRigCommand;

  TRigCommands = class
  private
    FIni: TIniFile;
    FSection, FEntry: AnsiString;
    FList: TAlStringList;
    WasError: boolean;

    procedure LoadInitCmd;
    procedure LoadStatusCmd;
    procedure LoadWriteCmd;

    procedure Log(AMessage: AnsiString; ShowValue: boolean = true);

    function StrToParam(S: AnsiString; ShowInLog: boolean = true): TRigParam;
    function StrToFmt(S: AnsiString): TValueFormat;
    function StrToBytes(S: AnsiString): TByteArray;
    function StrToMask(S: AnsiString): TBitMask;

    procedure Clear(var Rec: TRigCommand); overload;
    procedure Clear(var Rec: TParamValue); overload;
    procedure Clear(var Rec: TBitMask); overload;

    function LoadCommon: TRigCommand;
    function LoadValue: TParamValue;

    procedure ValidateEntryNames(Names: array of AnsiString);
    procedure ValidateMask(AMask: TBitMask; ALen: integer; AEnd: TByteArray);
    procedure ValidateValue(AValue: TParamValue; ALen: integer);

    procedure ListSupportedParams;
  public
    RigType: AnsiString;
    InitCmd: TRigCommandArray;
    WriteCmd: array [TRigParam] of TRigCommand;
    StatusCmd: TRigCommandArray;
    ReadableParams: TRigParamSet;
    WriteableParams: TRigParamSet;
    FLog: TStringList;

    constructor Create;
    destructor Destroy; override;
    procedure FromIni(AFileName: TFileName);
    function ParamToStr(Param: TRigParam): AnsiString;
    function ParamListToStr(Params: TRigParamSet): AnsiString;
  end;


function ParamsToInt(Params: TRigParamSet): integer;
function ParamToInt(Param: TRigParam): integer;
function IntToParam(Int: integer): TRigParam;



implementation


{ TRigCommands }

//------------------------------------------------------------------------------
//                              system
//------------------------------------------------------------------------------
constructor TRigCommands.Create;
begin
  FLog := TStringList.Create;
  FList := TAlStringList.Create;
end;


destructor TRigCommands.Destroy;
begin
  FList.Free;
  FLog.Free;
  inherited;
end;


procedure TRigCommands.Log(AMessage: AnsiString; ShowValue: boolean = true);
var
  Value: AnsiString;
begin
  if ShowValue and (FEntry <> '')
    then Value := 'in "' + AnsiString(FIni.ReadString(FSection, FEntry, '')) + '"'
    else Value := '';

  FLog.Add(Format('[%s].%s:  %s %s', [FSection, FEntry, AMessage, Value]));

  WasError := true;
end;







//------------------------------------------------------------------------------
//                            clear record
//------------------------------------------------------------------------------
procedure TRigCommands.Clear(var Rec: TRigCommand);
begin
  Rec.Code := nil;
  Clear(Rec.Value);
  Rec.ReplyLength := 0;
  Rec.ReplyEnd := nil;
  Clear(Rec.Validation);
  Rec.Values := nil;
  Rec.Flags := nil;
end;


procedure TRigCommands.Clear(var Rec: TParamValue);
begin
  FillChar(Rec, SizeOf(Rec), 0);
end;


procedure TRigCommands.Clear(var Rec: TBitMask);
begin
  Rec.Mask := nil;
  Rec.Flags := nil;
  Rec.Param := pmNone;
end;






//------------------------------------------------------------------------------
//                                load
//------------------------------------------------------------------------------
procedure TRigCommands.FromIni(AFileName: TFileName);
var
  L: TStringList;
  i: integer;
  p: TRigParam;
begin
  FLog.Clear;

  RigType := ChangeFileExt(ExtractFileName(AFileName), '');

  //clear arrays
  InitCmd := nil;
  StatusCmd := nil;
  for p:=Low(TRigParam) to High(TRigParam) do Clear(WriteCmd[p]);

  //read ini
  FIni := TIniFile.Create(AFileName);
    try
      L := TStringList.Create;
      try
        FIni.ReadSections(L);
        for i:=0 to L.Count-1 do
          begin
          FSection := L[i];
          WasError := false;
          if Copy(UpperCase(L[i]), 1, 4) = 'INIT' then
            LoadInitCmd
          else if Copy(UpperCase(L[i]), 1, 6) = 'STATUS' then
            LoadStatusCmd
          else
            LoadWriteCmd;
          end;
      finally
        L.Free;
      end;
    finally
      FIni.Free;
    end;

  ListSupportedParams;
end;


//load fields that are common to all commands
function TRigCommands.LoadCommon: TRigCommand;
begin
   Clear(Result);

  try
    FEntry := 'Command';
    Result.Code := StrToBytes(FIni.ReadString(FSection, FEntry, ''));
  except Log('invalid byte string'); end;

  if Result.Code = nil then
    Log('command code is missing');

  try
    FEntry := 'ReplyLength';
    Result.ReplyLength := FIni.ReadInteger(FSection, FEntry, 0);
    if Result.ReplyLength < 0 then
      Abort;
  except Log('invalid integer'); end;

  try
    FEntry := 'ReplyEnd';
    Result.ReplyEnd := StrToBytes(FIni.ReadString(FSection, FEntry, ''));
  except Log('invalid byte string'); end;

  try
    FEntry := 'Validate';
    Result.Validation := StrToMask(FIni.ReadString(FSection, FEntry, ''));
  except Log('invalid mask'); end;
  ValidateMask(Result.Validation, Result.ReplyLength, Result.ReplyEnd);
end;


//Value=5|5|vfBcdL|1|0[|pmXXX]
function TRigCommands.LoadValue: TParamValue;
begin
  DecimalSeparator := '.';
  FillChar(Result, SizeOf(Result), 0);
  FList.DelimText := FIni.ReadString(FSection, FEntry, '');

  case FList.Count of
    0: Exit;
    5: ;
    6: Result.Param := StrToParam(FList[5]);
    else Log('invalid syntax');
    end;

  try Result.Start := StrToInt(FList[0]);
  except
    Log('invalid Start value'); end;

  try Result.Len := StrToInt(FList[1]);
  except
    Log('invalid Length value'); end;

  Result.Format := StrToFmt(FList[2]);

  try Result.Mult := StrToFloat(FList[3]);
  except
    Log('invalid Multiplier value'); end;

  try Result.Add := StrToFloat(FList[4]);
  except
    Log('invalid Add value'); end;
end;


procedure TRigCommands.LoadInitCmd;
var
  Cmd: TRigCommand;
begin
  ValidateEntryNames(['COMMAND', 'REPLYLENGTH', 'REPLYEND', 'VALIDATE']);
  if FList.Count = 0 then Exit;

  Cmd := LoadCommon;

  FEntry := 'Value';
  if Cmd.Value.Format <> vfNone then
    begin
      Log('value is not allowed in INIT');
      Exit;
    end;
  if WasError then
    Exit;
  SetLength(InitCmd, Length(InitCmd)+1);
  InitCmd[High(InitCmd)] := Cmd;
end;


procedure TRigCommands.LoadWriteCmd;
var
  Cmd: TRigCommand;
  Param: TRigParam;
begin
  FEntry := '';
  Param := StrToParam(FSection);
  if WasError then Exit;

  ValidateEntryNames(['COMMAND', 'REPLYLENGTH', 'REPLYEND', 'VALIDATE', 'VALUE']);
  if FList.Count = 0 then
    Exit;

  Cmd := LoadCommon;
  FEntry := 'Value';
  Cmd.Value := LoadValue;
  ValidateValue(Cmd.Value, Length(Cmd.Code));
  if Cmd.Value.Param <> pmNone then
    Log('parameter name is not allowed');

  if (Param in NumericParams) and (Cmd.Value.Len = 0)
  then
    Log('Value is missing');

  if (not (Param in NumericParams)) and (Cmd.Value.Len > 0) then
    Log('parameter does not require a value', false);


  if not WasError then
    WriteCmd[Param] := Cmd;
end;


procedure TRigCommands.LoadStatusCmd;
var
  Cmd: TRigCommand;
  L: TStringList;
  Flag: TBitMask;
  Value: TParamValue;
  i: integer;
begin
  ValidateEntryNames(['COMMAND', 'REPLYLENGTH', 'REPLYEND', 'VALIDATE', 'VALUE*', 'FLAG*']);
  if FList.Count = 0 then Exit;

  //common fields
  Cmd := LoadCommon;

  FEntry := '';
  if (Cmd.ReplyLength = 0) and (Cmd.ReplyEnd = nil) then
    Log('ReplyLength or ReplyEnd must be specified');

  //values and flags to extract from a reply

  Cmd.Values := nil;
  Cmd.Flags := nil;
  L := TStringList.Create;
  try
    //list of entries in the section
    FIni.ReadSection(FSection, L);

    for i:=0 to L.Count-1 do
      if UpperCase(Copy(L[i], 1, 5)) = 'VALUE' then
        begin
        FEntry := L[i];
        Value := LoadValue;
        ValidateValue(Value, Max(Cmd.ReplyLength, Length(Cmd.Validation.Mask)));
        if Value.Param = pmNone then
          Log('parameter name is missing')
        else if not (Value.Param in NumericParams) then
          Log('parameter must be of numeric type');

        SetLength(Cmd.Values, Length(Cmd.Values)+1);
        Cmd.Values[High(Cmd.Values)] := Value;
        end
      else if UpperCase(Copy(L[i], 1, 4)) = 'FLAG' then
        begin
        FEntry := L[i];
        Flag := StrToMask(FIni.ReadString(FSection, FEntry, ''));
        ValidateMask(Flag, Cmd.ReplyLength, Cmd.ReplyEnd);

        SetLength(Cmd.Flags, Length(Cmd.Flags)+1);
        Cmd.Flags[High(Cmd.Flags)] := Flag;
        end
  finally
    L.Free;
  end;

  if (Cmd.Values = nil) and (Cmd.Flags = nil) then
    Log('at least one ValueNN or FlagNN must be defined');


  if WasError then
    Exit;
  SetLength(StatusCmd, Length(StatusCmd)+1);
  StatusCmd[High(StatusCmd)] := Cmd;
end;






//------------------------------------------------------------------------------
//                        conversion functions
//------------------------------------------------------------------------------
function TRigCommands.StrToFmt(S: AnsiString): TValueFormat;
var
 i: integer;
begin
  Result := vfNone; //please the paranoid compiler
  i := GetEnumValue(TypeInfo(TValueFormat), S);
  if i > -1 then
    Result := TValueFormat(i)
  else
    Log('invalid format name');
end;


function TRigCommands.StrToParam(S: AnsiString; ShowInLog: boolean): TRigParam;
var
 i: integer;
begin
  Result := pmNone;
  i := GetEnumValue(TypeInfo(TRigParam), S);

  if i > -1 then
    Result := TRigParam(i)
  else if ShowInLog then
    Log('invalid parameter name', false);
end;


function TRigCommands.ParamToStr(Param: TRigParam): AnsiString;
begin
  Result := GetEnumName(TypeInfo(TRigParam), integer(Param));
end;


function TRigCommands.StrToBytes(S: AnsiString): TByteArray;
var
  i: integer;
begin
  //blank
  Result := nil;
  S := Trim(S);
  if Length(S) < 2 then
    Exit;

  //asc
  if S[1] = '(' then
    begin
    if S[Length(S)] <> ')' then
      Abort;
    SetLength(Result, Length(S)-2);
    Move(S[2], Result[0], Length(Result));
    end

  //hex
  else if S[1] in ['0'..'9', 'A'..'F'] then
    begin
    for i:=Length(S) downto 1 do
      if S[i] = '.' then
        Delete(S, i, 1);
      if Length(S) mod 2 <> 0 then
        Abort;
      SetLength(Result, Length(S) div 2);
      for i:=0 to High(Result) do
        Result[i] := StrToInt('$' + Copy(S, 1 + i*2, 2));
    end

  //all other
  else Abort;
end;


function FlagsFromMask(AMask: TByteArray; Char1: Char): TByteArray;
var
  i: integer;
begin
  Result := Copy(AMask);
  if Char1 = '(' then
     for i:=0 to High(AMask) do
       if AMask[i] = Ord('.') then
       begin
         AMask[i] := 0; Result[i] := 0;
       end
       else
         AMask[i] := $FF
       else
         for i:=0 to High(AMask) do
           if AMask[i] <> 0 then
             AMask[i] := $FF;
end;




//Flag1 =".......................0.............."|pmRitOff
//Flag1 =13.00.00.00.00.00.00.00|00.00.00.00.00.00.00.00|pmVfoAA
//Validation=FEFEE05EFBFD
//Validation=FFFFFFFF.FF.0000000000.FF|FEFEE05E.03.0000000000.FD

function TRigCommands.StrToMask(S: AnsiString): TBitMask;
begin
  Result.Param := pmNone;
  Result.Mask := nil;
  Result.Flags := nil;
  if S = '' then Exit;

  //extract mask
  FList.DelimText := S;
  Result.Mask := StrToBytes(FList[0]);
  if Result.Mask = nil then
    Abort;

  case FList.Count of
    1: //just mask, infer flags
      Result.Flags := FlagsFromMask(Result.Mask, FList[0][1]);

    2: //mask|param or mask|flags
      begin
      Result.Param := StrToParam(FList[1], false);
      if Result.Param <> pmNone
        then Result.Flags := FlagsFromMask(Result.Mask, FList[0][1])
        else Result.Flags := StrToBytes(FList[1]);
      end;

    3: //mask|flags|param
      begin
        Result.Flags := StrToBytes(FList[1]);
        Result.Param := StrToParam(FList[2]);
      end;

    else //invalid number of '|'
       Abort;
    end;
end;





//------------------------------------------------------------------------------
//                             validation
//------------------------------------------------------------------------------
procedure TRigCommands.ValidateMask(AMask: TBitMask; ALen: integer; AEnd: TByteArray);
var
  Ending: TByteArray;
begin
  Ending := nil; //please the compiler


  if (AMask.Mask = nil) and (AMask.Flags = nil) and (AMask.Param = pmNone)
    then Exit; //empty mask, that's fine


  if (AMask.Mask = nil) or (AMask.Flags = nil)
    then Log('incorrect mask length')

  else if Length(AMask.Mask) <> Length(AMask.Flags)
    then Log('incorrect mask length')

  else if (ALen > 0) and (Length(AMask.Mask) <> ALen)
    then Log('mask length <> ReplyLength')

  else if not BytesEqual(BytesAnd(AMask.Flags, AMask.Flags), AMask.Flags)
    then Log('mask hides valid bits')

  //syntax is different for validation masks and flag masks
  else if UpperCase(FEntry) = 'VALIDATE'
    then
      begin
      if AMask.Param <> pmNone
        then Log('parameter name is not allowed');

      Ending := Copy(AMask.Flags, Length(AMask.Flags)-Length(AEnd), MAXINT);
      if not BytesEqual(Ending, AEnd)
        then Log('mask does not end with ReplyEnd');
      end
    else
      begin
      if AMask.Param = pmNone then
        Log('parameter name is missing');
      if AMask.Mask = nil then
        Log('mask is blank');
      end;
end;


procedure TRigCommands.ValidateValue(AValue: TParamValue; ALen: integer);
begin
  if AValue.Param = pmNone then Exit;

  if ALen = 0 then ALen := MAXINT;

  with AValue do
    begin
    if (Start < 0) or (Start >= ALen) then
      Log('invalid Start value');
    if (Len < 0) or (Start+Len > ALen) then
      Log('invalid Length value');
    if Mult <= 0 then
      Log('invalid Multiplier value');
    end;
end;


procedure TRigCommands.ValidateEntryNames(Names: array of AnsiString);
var
  i, j: integer;
  S1, S2: AnsiString;
  Ok: boolean;
begin
  FIni.ReadSection(FSection, FList);

  for i:=0 to FList.Count-1 do
    begin
    Ok := false;
    for j:=0 to High(Names) do
      begin
      FEntry := FList[i];
      S1 := UpperCase(FList[i]);
      S2 := Names[j];
      if S2[Length(S2)] = '*' then
        begin
          Delete(S2, Length(S2), 1);
          S1 := Copy(S1, 1, Length(S2));
        end;
      Ok := Ok or (S1 = S2);
      end;
    if not Ok then
      Log('invalid entry name', false);
    end;
end;






//------------------------------------------------------------------------------
//                          supported params
//------------------------------------------------------------------------------
procedure TRigCommands.ListSupportedParams;
var
  i, j: integer;
  p: TRigParam;
begin
  ReadableParams := [];
  WriteableParams := [];

  for i:=0 to High(StatusCmd) do
    begin
    for j:=0 to High(StatusCmd[i].Values) do
      Include(ReadableParams, StatusCmd[i].Values[j].Param);
    for j:=0 to High(StatusCmd[i].Flags) do
      Include(ReadableParams, StatusCmd[i].Flags[j].Param);
    end;

  for p:=Low(TRigParam) to High(TRigParam) do
    if WriteCmd[p].Code <> nil then
      Include(WriteableParams, p);
end;


function TRigCommands.ParamListToStr(Params: TRigParamSet): AnsiString;
var
  p: TRigParam;
begin
  Result := '';
  for p:=Low(TRigParam) to High(TRigParam) do
    if p in Params then
      Result := Result + ParamToStr(p) + ',';
  Delete(Result, Length(Result), 1);
end;


function ParamsToInt(Params: TRigParamSet): integer;
var
  Par: TRigParam;
begin
  Result := 0;
  for Par:=Low(TRigParam) to High(TRigParam) do
    if Par in Params then
      Result := Result or (1 shl Ord(Par));
end;


function ParamToInt(Param: TRigParam): integer;
begin
  Result := 1 shl Ord(Param);
end;


function IntToParam(Int: integer): TRigParam;
begin
  for Result:=Low(TRigParam) to High(TRigParam) do
    if (1 shl Ord(Result)) = Int then
      Exit;
  Result := pmNone;
end;



end.

