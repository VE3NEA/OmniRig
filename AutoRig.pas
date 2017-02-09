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

unit AutoRig;

interface

uses
  ComObj, ActiveX, OmniRig_TLB, StdVcl, RigObj, RigCmds, ByteFuns, AutoPort;
//  Variants;

type
  TRigX = class(TAutoObject, IRigX)
  protected
    function  Get_RigType: WideString; safecall;
    function  Get_ReadableParams: Integer; safecall;
    function  Get_WriteableParams: Integer; safecall;
    function  IsParamReadable(Param: RigParamX): WordBool; safecall;
    function  IsParamWriteable(Param: RigParamX): WordBool; safecall;
    function  Get_Status: RigStatusX; safecall;
    function  Get_StatusStr: WideString; safecall;
    function  Get_Freq: Integer; safecall;
    procedure Set_Freq(Value: Integer); safecall;
    function  Get_FreqA: Integer; safecall;
    procedure Set_FreqA(Value: Integer); safecall;
    function  Get_FreqB: Integer; safecall;
    procedure Set_FreqB(Value: Integer); safecall;
    function  Get_RitOffset: Integer; safecall;
    procedure Set_RitOffset(Value: Integer); safecall;
    function  Get_Pitch: Integer; safecall;
    procedure Set_Pitch(Value: Integer); safecall;
    function  Get_Vfo: RigParamX; safecall;
    procedure Set_Vfo(Value: RigParamX); safecall;
    function  Get_Split: RigParamX; safecall;
    procedure Set_Split(Value: RigParamX); safecall;
    function  Get_Rit: RigParamX; safecall;
    procedure Set_Rit(Value: RigParamX); safecall;
    function  Get_Xit: RigParamX; safecall;
    procedure Set_Xit(Value: RigParamX); safecall;
    function  Get_Tx: RigParamX; safecall;
    procedure Set_Tx(Value: RigParamX); safecall;
    function  Get_Mode: RigParamX; safecall;
    procedure Set_Mode(Value: RigParamX); safecall;
    procedure ClearRit; safecall;
    procedure SetSplitMode(RxFreq: Integer; TxFreq: Integer); safecall;
    function  FrequencyOfTone(Tone: Integer): Integer; safecall;
    procedure SendCustomCommand(Command: OleVariant; ReplyLength: Integer;
      ReplyEnd: OleVariant); safecall;
//    function GetAltFrequency: Integer; safecall;
    function GetRxFrequency: Integer; safecall;
    function GetTxFrequency: Integer; safecall;
    procedure SetSimplexMode(Freq: Integer); safecall;
    function Get_PortBits: IPortBits; safecall;
  public
    Parent: Pointer;
    FRig: TRig;
    FPortBits: TPortBits;

    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ,Main;


{ TRigX }


//------------------------------------------------------------------------------
//                              system
//------------------------------------------------------------------------------
procedure TRigX.Initialize;
begin
  inherited Initialize;

  FPortBits := TPortBits.Create;
  (FPortBits as IUnknown)._AddRef;
end;


destructor TRigX.Destroy;
begin
  (FPortBits as IUnknown)._Release;
  inherited Destroy;
end;



function TRigX.Get_RigType: WideString;
begin
  if FRig.RigCommands = nil
    then Result := 'NONE'
    else Result := FRig.RigCommands.RigType;
end;


function TRigX.Get_ReadableParams: Integer;
begin
  if FRig.RigCommands = nil
    then Result := 0
    else Result := ParamsToInt(FRig.RigCommands.ReadableParams);
end;


function TRigX.Get_WriteableParams: Integer;
begin
  if FRig.RigCommands = nil
    then Result := 0
    else Result := ParamsToInt(FRig.RigCommands.WriteableParams);
end;


function TRigX.IsParamReadable(Param: RigParamX): WordBool;
begin
  Result := (Get_ReadableParams and Param) <> 0;
end;


function TRigX.IsParamWriteable(Param: RigParamX): WordBool;
begin
  Result := (Get_WriteableParams and Param) <> 0;
end;


function TRigX.Get_Status: RigStatusX;
begin
  Result := Ord(FRig.Status);
end;


function TRigX.Get_StatusStr: WideString;
begin
  Result := FRig.GetStatusStr;
end;







//------------------------------------------------------------------------------
//                                 get
//------------------------------------------------------------------------------
function TRigX.Get_Freq: Integer;
begin
  Result := FRig.Freq;
end;


function TRigX.Get_FreqA: Integer;
begin
  Result := FRig.FreqA;
end;


function TRigX.Get_FreqB: Integer;
begin
  Result := FRig.FreqB;
end;


function TRigX.Get_RitOffset: Integer;
begin
  Result := FRig.RitOffset;
end;


function TRigX.Get_Pitch: Integer;
begin
  Result := FRig.Pitch;
end;


function TRigX.Get_Vfo: RigParamX;
begin
  Result := ParamToInt(FRig.Vfo);
end;


function TRigX.Get_Split: RigParamX;
begin
  Result := ParamToInt(FRig.Split);
end;


function TRigX.Get_Rit: RigParamX;
begin
  Result := ParamToInt(FRig.Rit);
end;


function TRigX.Get_Xit: RigParamX;
begin
  Result := ParamToInt(FRig.Xit);
end;


function TRigX.Get_Tx: RigParamX;
begin
  Result := ParamToInt(FRig.Tx);
end;


function TRigX.Get_Mode: RigParamX;
begin
  Result := ParamToInt(FRig.Mode);
end;





//------------------------------------------------------------------------------
//                                 set
//------------------------------------------------------------------------------
procedure TRigX.Set_Freq(Value: Integer);
begin
 FRig.Freq := Value;
end;

procedure TRigX.Set_FreqA(Value: Integer);
begin
 FRig.FreqA := Value;
end;

procedure TRigX.Set_FreqB(Value: Integer);
begin
 FRig.FreqB := Value;
end;

procedure TRigX.Set_RitOffset(Value: Integer);
begin
 FRig.RitOffset := Value;
end;

procedure TRigX.Set_Pitch(Value: Integer);
begin
 FRig.Pitch := Value;
end;

procedure TRigX.Set_Vfo(Value: RigParamX);
begin
 FRig.Vfo := IntToParam(Value);
end;

procedure TRigX.Set_Split(Value: RigParamX);
begin
 FRig.Split := IntToParam(Value);
end;

procedure TRigX.Set_Rit(Value: RigParamX);
begin
 FRig.Rit := IntToParam(Value);
end;

procedure TRigX.Set_Xit(Value: RigParamX);
begin
 FRig.Xit := IntToParam(Value);
end;

procedure TRigX.Set_Tx(Value: RigParamX);
begin
 FRig.Tx := IntToParam(Value);
end;

procedure TRigX.Set_Mode(Value: RigParamX);
begin
 FRig.Mode := IntToParam(Value);
end;






//------------------------------------------------------------------------------
//                                 methods
//------------------------------------------------------------------------------
procedure TRigX.ClearRit;
begin
  FRig.AddWriteCommand(pmRit0);
end;


procedure TRigX.SetSimplexMode(Freq: Integer);
var
  WrParams: TRigParamSet;
begin
  if FRig.RigCommands = nil then Exit;

  WrParams := FRig.RigCommands.WriteableParams;

  if ([pmFreqA,pmVfoAA] - WrParams) = [] then
    begin
    FRig.FreqA := Freq;
    FRig.Vfo := pmVfoAA;
    end
  else if ([pmFreqA, pmVfoA, pmSplitOff] - WrParams) = [] then
    begin
    FRig.FreqA := Freq;
    FRig.Vfo := pmVfoA;
    end
  else if ([pmFreq, pmVfoA, pmVfoB] - WrParams) = [] then
    begin
    FRig.Vfo := pmVfoB;
    FRig.Freq := Freq;
    FRig.Vfo := pmVfoA;
    FRig.Freq := Freq;
    end
  else if ([pmFreq, pmVfoEqual] - WrParams) = [] then
    begin
    FRig.Freq := Freq;
    FRig.Vfo := pmVfoEqual;
    end
  else if ([pmFreq, pmVfoSwap] - WrParams) = [] then
    begin
    FRig.Vfo := pmVfoSwap;
    FRig.Freq := Freq;
    FRig.Vfo := pmVfoSwap;
    FRig.Freq := Freq;
    end
// Added by RA6UAZ for Icom Marine Radio NMEA Command
  else if ([pmFreq, pmFreqA, pmFreqB] - WrParams) = [pmFreqA] then
    begin
    FRig.Freq := Freq;
    FRig.FreqB := Freq;
    end
else if ([pmFreq{,pmSplitOff}] - WrParams) = [] then
    begin
    FRig.Freq := Freq;
    end

  else Exit;

  FRig.Split := pmSplitOff;
  FRig.Rit := pmRitOff;
  FRig.Xit := pmXitOff;
end;



procedure TRigX.SetSplitMode(RxFreq, TxFreq: Integer);
var
  WrParams: TRigParamSet;
begin
  if FRig.RigCommands = nil then Exit;

  WrParams := FRig.RigCommands.WriteableParams;

  if ([pmFreqA,pmFreqB,pmVfoAB] - WrParams) = [] then
    begin //TS-570
    FRig.FreqA := RxFreq;
    FRig.FreqB := TxFreq;
    FRig.Vfo := pmVfoAB;
    end
  else if ([pmFreq,pmVfoEqual{,pmSplitOn}] - WrParams) = [] then
    begin //IC-746
    FRig.Freq := TxFreq;
    FRig.Vfo := pmVfoEqual;
    FRig.Freq := RxFreq;
    FRig.Split := pmSplitOn;
    end
  else if ([pmVfoB,pmFreq,pmVfoA{,pmSplitOn}] - WrParams) = [] then
    begin //FT-100D
    FRig.Vfo := pmVfoB;
    FRig.Freq := TxFreq;
    FRig.Vfo := pmVfoA;
    FRig.Freq := RxFreq;
    FRig.Split := pmSplitOn;
    end
  else if ([pmFreq,pmVfoSwap{,pmSplitOn}] - WrParams) = [] then
    begin //Ft-817 ?
    FRig.Vfo := pmVfoSwap;
    FRig.Freq := TxFreq;
    FRig.Vfo := pmVfoSwap;
    FRig.Freq := RxFreq;
    FRig.Split := pmSplitOn;
    end
  else if ([pmFreqA,pmFreqB,pmVfoA{, pmSplitOn}] - WrParams) = [] then
    begin //FT-1000 MP
    FRig.FreqA := RxFreq;
    FRig.FreqB := TxFreq;
    FRig.Vfo := pmVfoA;
    FRig.Split := pmSplitOn;
    end
// Added by RA6UAZ for Icom Marine Radio NMEA Command
  else if ([pmFreq, pmFreqA, pmFreqB] - WrParams) = [pmFreqA] then
    begin
    FRig.Freq := RxFreq;
    FRig.FreqB := TxFreq;
    end
  else Exit;

  FRig.Rit := pmRitOff;
  FRig.Xit := pmXitOff;
end;


procedure TRigX.SendCustomCommand(Command: OleVariant;
  ReplyLength: Integer; ReplyEnd: OleVariant);
var
   Cmd: TByteArray;
   Trm: AnsiString;
begin
  case VarType(Command) of
    varByte + varArray: Cmd := SafeArrayToBytes(Command);
    varOleStr: Cmd := StrToBytes(Command);
    else Exit;
    end;

  case VarType(ReplyEnd) of
    varByte + varArray: Trm := BytesToStr(SafeArrayToBytes(ReplyEnd));
    varOleStr: Trm := ReplyEnd;
    else Trm := '';
    end;

  FRig.AddCustomCommand(Parent, Cmd, ReplyLength, Trm);
end;


function TRigX.FrequencyOfTone(Tone: Integer): Integer;
begin
  FRig.Lock;
  try
    Result := Tone;
    if FRig.Mode in [pmCW_U, pmCW_L] then Dec(Result, FRig.Pitch);
    if FRig.Mode in [pmCW_L, pmSSB_L] then Result := - Result;
    Inc(Result, FRig.Freq);
  finally
    FRig.Unlock;
  end;
end;


{
function TRigX.GetAltFrequency: Integer;
begin
  Result := 0;

  FRig.Lock;
  try
    if FRig.Tx = pmTx then
      begin
      if FRig.Vfo in [pmVfoAA, pmVfoAB] then Result := FRig.FreqA
      else if FRig.Vfo in [pmVfoBA, pmVfoBB] then Result := FRig.FreqB;
      end
    else if FRig.Tx = pmRx then
      begin
      if FRig.Vfo in [pmVfoAA, pmVfoBA] then Result := FRig.FreqA
      else if FRig.Vfo in [pmVfoAB, pmVfoBB] then Result := FRig.FreqB;
      end;
  finally
    FRig.Unlock;
  end;
end;
}


function TRigX.GetRxFrequency: Integer;
var
  RdParams: TRigParamSet;
begin
  if FRig.RigCommands = nil then Exit;

  RdParams := FRig.RigCommands.ReadableParams;

  FRig.Lock;
  try
    if (pmFreqA in RdParams) and (FRig.Vfo in [pmVfoA, pmVfoAA, pmVfoAB])
      then Result := FRig.FreqA
    else if (pmFreqB in RdParams) and (FRig.Vfo in [pmVfoB, pmVfoBA, pmVfoBB])
      then Result := FRig.FreqB
    else if (FRig.Tx <> pmTx) or (FRig.Split <> pmSplitOn)
      then Result := FRig.Freq
    else Result := 0;

    //include RIT
    if FRig.Rit = pmRitOn then Inc(Result, FRig.RitOffset);
  finally
    FRig.Unlock;
  end;
end;


function TRigX.GetTxFrequency: Integer;
var
  RdParams: TRigParamSet;
begin
  if FRig.RigCommands = nil then Exit;

  RdParams := FRig.RigCommands.ReadableParams;

  FRig.Lock;
  try
    if (pmFreqA in RdParams) and (FRig.Vfo in [pmVfoAA, pmVfoBA])
      then Result := FRig.FreqA
    else if (pmFreqB in RdParams) and (FRig.Vfo in [pmVfoAB, pmVfoBB])
      then Result := FRig.FreqB
    else if FRig.Tx = pmTx
      then Result := FRig.Freq
    else Result := 0;

    //include XIT
    if FRig.Xit = pmXitOn then Inc(Result, FRig.RitOffset);
  finally
    FRig.Unlock;
  end;
end;


function TRigX.Get_PortBits: IPortBits;
begin
  Result := FPortBits;
end;




initialization
  TAutoObjectFactory.Create(ComServer, TRigX, Class_RigX,
    ciInternal, tmApartment);

end.

