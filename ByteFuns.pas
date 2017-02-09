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

unit ByteFuns;

interface

uses
  SysUtils, Math, Windows;  //, Variants;

type
  TByteArray = array of Byte;

function BytesAnd(Arr1, Arr2: TByteArray): TByteArray;
function BytesEqual(Arr1, Arr2: TByteArray): boolean;
procedure BytesReverse(Arr: TByteArray);
function BytesToStr(Bytes: TByteArray): AnsiString;
function StrToBytes(S: AnsiString): TByteArray;
function BytesToSafeArray(Bytes: TByteArray): Variant;
function SafeArrayToBytes(Arr: Variant): TByteArray;
function BytesToHex(Bytes: TByteArray): AnsiString;
function StrToHex(S: AnsiString): AnsiString;

implementation

//------------------------------------------------------------------------------
//                         byte array functions
//------------------------------------------------------------------------------
function BytesEqual(Arr1, Arr2: TByteArray): boolean;
var
  i: integer;
begin
  Result := false;
  if Length(Arr2) <> Length(Arr1) then Exit;
  for i:=0 to High(Arr1) do if Arr2[i] <> Arr1[i] then Exit;
  Result := true;
end;


//the length of Arr1 and Arr2 must be verified
//before this function is called
function BytesAnd(Arr1, Arr2: TByteArray): TByteArray;
var
  i: integer;
begin
  SetLength(Result, Min(Length(Arr1), Length(Arr2)));
  for i:=0 to High(Arr1) do Result[i] := Arr1[i] and Arr2[i];
end;



procedure BytesReverse(Arr: TByteArray);
var
  B: Byte;
  i: integer;
begin
  if Length(Arr) < 2 then Exit;

  for i:=0 to (Length(Arr) div 2)-1 do
    begin
    B := Arr[i];
    Arr[i] := Arr[High(Arr)-i];
    Arr[High(Arr)-i] := B;
    end;
end;


function BytesToStr(Bytes: TByteArray): AnsiString;
var
  Len: integer;
begin
  Len := Length(Bytes);
  SetLength(Result, Len);
  if Len > 0 then Move(Bytes[0], Result[1], Len);
end;


function StrToBytes(S: AnsiString): TByteArray;
var
  Len: integer;
begin
  Len := Length(S);
  SetLength(Result, Len);
  if Len > 0 then Move(S[1], Result[0], Len);
end;


function BytesToSafeArray(Bytes: TByteArray): Variant;
var
  P: PByte;
begin
  if Bytes = nil then
    begin
    Result := Unassigned;
    Exit;
    end;

  Result := VarArrayCreate([0, High(Bytes)], varByte);

  P := VarArrayLock(Result);
  try
    Move(Bytes[0], P^, Length(Bytes));
  finally
    VarArrayUnlock(Result);
  end;
end;


function SafeArrayToBytes(Arr: Variant): TByteArray;
var
  P: PByte;
  Len: integer;
begin
  Result := nil;
  if VarArrayDimCount(Arr) <> 1 then Exit;
  if VarArrayLowBound(Arr, 1) <> 0 then Exit;

  Len := VarArrayHighBound(Arr, 1) + 1;
  SetLength(Result, Len);
  if Result = nil then Exit;

  P := VarArrayLock(Arr);
  try
    Move(P^, Result[0], Len);
  finally
    VarArrayUnlock(Arr);
  end;
end;


function BytesToHex(Bytes: TByteArray): AnsiString;
var
  i: integer;
begin
  Result := '';
  if Bytes = nil then Exit;

  for i:=0 to High(Bytes) do Result := Result + AnsiString(IntToHex(Bytes[i], 2));
end;


function StrToHex(S: AnsiString): AnsiString;
begin
  Result := BytesToHex(StrToBytes(S));
end;



end.

