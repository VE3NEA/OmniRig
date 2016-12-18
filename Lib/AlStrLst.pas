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

unit AlStrLst;

interface
uses
  Windows, SysUtils, Classes, Dialogs, Controls, FileCtrl;

type
  TAlStringList = class(TStringList)
  private
    FDelimiter: Char;
    procedure SetDelimText(AText: string);
    function GetDelimText: string;
    function GetCounts(Index: integer): integer;
    procedure SetCounts(Index: integer; const Value: integer);
  public
    constructor Create;
    constructor CreateTryLoad(AFileName: TFileName; ASorted: boolean = true);
    procedure LoadFileList(Mask: string);
    procedure Subtract(Lst: TStrings);
    procedure DeleteDupes;

    function FindI(const S: string; var Index: Integer): Boolean;
    function Find(const S: string; var Index: Integer): Boolean; override;
    procedure Sort; override;
    function ValueOf(AName: string): string;
    function StringOf(AName: string): string;
    function GetCountOf(S: string): integer;
    procedure WrapLines(MaxL: integer);

    procedure AddWithCount(S: string; ACount: integer = 1);
    procedure CountsToStrings(Wid: integer);
    procedure FractionsToStrings(Wid: integer);

    property Delimiter: Char read FDelimiter write FDelimiter default '|';
    property DelimText: string read GetDelimText write SetDelimText;
    property Counts[Index: integer]: integer read GetCounts write SetCounts;
  end;

function FileToString(FileName: TFileName): string;

implementation

{ TAlStringList }

constructor TAlStringList.Create;
begin
  FDelimiter := '|';
end;


constructor TAlStringList.CreateTryLoad(AFileName: TFileName; ASorted: boolean = true);
begin
  inherited;

  if FileExists(AFileName) then LoadFromFile(AFileName);
  Sorted := ASorted;
end;



procedure TAlStringList.LoadFileList(Mask: string);
var
  Sr: TSearchRec;
  rc: integer;
begin
  Clear;
  rc := FindFirst(Mask, 0, Sr);
  try
    while rc = 0 do
      begin
      Add(Sr.Name);
      rc := FindNext(Sr);
      end;
  finally
    FindClose(sr);
  end;
end;


function TAlStringList.GetDelimText: string;
var
  i: integer;
begin
  Result := '';
  for i:=0 to Count-1 do Result := Result + Strings[i] + FDelimiter;
end;


procedure TAlStringList.SetDelimText(AText: string);
var
  P, P1: PChar;
  S: string;
begin
  BeginUpdate;
  try
    Clear;
    P := PChar(AText);
    while P^ in [#1..#31] do P := CharNext(P);
    while P^ <> #0 do
    begin
      if P^ = '"' then
        S := AnsiExtractQuotedStr(P, '"')
      else
      begin
        P1 := P;
        while (P^ >= ' ') and (P^ <> FDelimiter) do P := CharNext(P);
        SetString(S, P1, P - P1);
      end;
      Add(S);
      while P^ in [#1..#31] do P := CharNext(P);
      if P^ = FDelimiter then
        repeat
          P := CharNext(P);
        until not (P^ in [#1..#31]);
    end;
  finally
    EndUpdate;
  end;
end;


procedure TAlStringList.Subtract(Lst: TStrings);
var
  i, Idx: integer;
begin
  Sorted := true;
  for i:=0 to Lst.Count-1 do
    if Find(Lst[i], Idx) then Delete(Idx);
end;


function FileToString(FileName: TFileName): string;
var
  Fs: TFileStream;
begin
  Fs := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    with TStringStream.Create('') do
    try
      CopyFrom(Fs, 0);
      Result := DataString;
    finally
      Free;
    end;
  finally
    Fs.Free;
  end;
end;

function TAlStringList.FindI(const S: string; var Index: Integer): Boolean;
begin
  Result := inherited Find(S, Index);
end;


function TAlStringList.Find(const S: string; var Index: Integer): Boolean;
var
  L, H, I, C: Integer;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
    begin
    I := (L + H) shr 1;
    C := CompareStr(Strings[I], S);
    if C < 0 then L := I + 1 else
      begin
      H := I - 1;
      if C = 0 then Result := True;
      end;
    end;
  Index := L;
end;


function PlainCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareStr(List[Index1], List[Index2]);
end;     

procedure TAlStringList.Sort;
begin
  CustomSort(PlainCompare);
end;



procedure TAlStringList.DeleteDupes;
var
  L: TAlStringList;
  i: integer;
begin
  Sort;
  L := TAlStringList.Create;
  try
    L.Add(Strings[0]);
    for i:=1 to Count-1 do
      if Strings[i] <> Strings[i-1]
        then L.Add(Strings[i]);
    Assign(L);
  finally
    L.Free;
  end;
end;



procedure TAlStringList.AddWithCount(S: string; ACount: integer);
var
  Idx: integer;
begin
  if Find(S, Idx)
    then Objects[Idx] := TObject(Integer(Objects[Idx]) + ACount)
    else AddObject(S, TObject(ACount));
end;


procedure TAlStringList.CountsToStrings(Wid: integer);
var
  i: integer;
  Fmt: string;
begin
  Sorted := false;
  //Fmt := Format('%%0.%dd  %%s', [Wid]);
  Fmt := Format('%%%dd  %%s', [Wid]);

  for i:=0 to Count-1 do
    Strings[i] := Format(Fmt, [Integer(Objects[i]), Strings[i]]);
end;


procedure TAlStringList.FractionsToStrings(Wid: integer);
var
  i: integer;
  Fmt: string;
  Sum: integer;
begin
  Sum := 0;
  for i:=0 to Count-1 do Inc(Sum, Integer(Objects[i]));
  if Sum = 0 then Inc(Sum);

  Sorted := false;
  Fmt := Format('%%0.%df  %%s', [Wid]);
  for i:=0 to Count-1 do
    Strings[i] := Format(Fmt, [Integer(Objects[i]) / Sum, Strings[i]]);
end;


function TAlStringList.GetCounts(Index: integer): integer;
begin
  Result := Integer(Objects[Index]);
end;


function TAlStringList.GetCountOf(S: string): integer;
var
  Idx: integer;
begin
  if Find(S, Idx)
    then Result := Integer(Objects[Idx])
    else Result := 0;
end;


procedure TAlStringList.SetCounts(Index: integer; const Value: integer);
begin
  Objects[Index] := Ptr(Value);
end;



function TAlStringList.ValueOf(AName: string): string;
begin
  Result := Trim(Copy(StringOf(AName), Length(AName)+2, MAXINT));
end;


function TAlStringList.StringOf(AName: string): string;
var
  Len, Idx: integer;
  S: string;
begin
  Result := '';
  if not Sorted then Sorted := true;

  S := AName + ' ';
  Len := Length(S);

  Find(S, Idx);
  if (Idx = Count) then Exit;

  if Copy(Strings[Idx], 1, Len) = S then begin Result := Strings[Idx]; Exit; end;

  S := AName + '=';
  Find(S, Idx);
  if (Idx = Count) then Exit;

  if Copy(Strings[Idx], 1, Len) = S then Result := Strings[Idx];
end;


procedure TAlStringList.WrapLines(MaxL: integer);
var
  i, p: integer;
  S: string;
  SplitPos: integer;
begin
  i := 0;
  while i < Count do
    begin
    if Length(Strings[i]) > MaxL then
      begin
      S := Strings[i];
      SplitPos := 0;
      for p:=MaxL+1 downto 2 do
        if S[p] = ' ' then begin SplitPos := p; Break; end;

      if SplitPos > 0
        then begin Strings[i] := Copy(S, 1, p-1); System.Delete(S, 1, p); end
        else begin Strings[i] := Copy(S, 1, MaxL); System.Delete(S, 1, MaxL); end;

      if S <> '' then Insert(i+1, S);
      end;

    Inc(i);
    end;
end;



end.
