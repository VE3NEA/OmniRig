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

unit CmdQue;

interface

uses
  SysUtils, Classes, RigCmds, ByteFuns;

type
  TCommandKind = (ckInit, ckWrite, ckStatus, ckCustom);
  TExchangePhase = (phSending, phReceiving, phIdle);

  TQueueItem = class(TCollectionItem)
  public
    Code: TByteArray;
    Kind: TCommandKind;

    Param: TRigParam;     //param of Set comand
    Number: integer;      //ordinal number of Init or Status command
    CustSender: Pointer;  //COM object that sent custom command

    ReplyLength: integer;
    ReplyEnd: AnsiString;

    function NeedsReply: boolean;
  end;
  

  TCommandQueue = class(TCollection)
  private
    function GetItem(Index: Integer): TQueueItem;
    procedure SetItem(Index: Integer; Value: TQueueItem);
  public
    Phase:TExchangePhase;

    constructor Create;
    function Add: TQueueItem;
    function HasStatusCommands: boolean;

    function CurrentCmd: TQueueItem;
    property Items[index: integer]: TQueueItem read GetItem write SetItem; default;
  end;


implementation

{ TQueueItem }

function TQueueItem.NeedsReply: boolean;
begin
  Result := (ReplyLength > 0) or (ReplyEnd <> '');
end;



{ TCommandQueue }

constructor TCommandQueue.Create;
begin
  inherited Create(TQueueItem);
end;


function TCommandQueue.GetItem(Index: Integer): TQueueItem;
begin
  Result := TQueueItem(inherited GetItem(Index));
end;


procedure TCommandQueue.SetItem(Index: Integer; Value: TQueueItem);
begin
  inherited SetItem(Index, Value);
end;


function TCommandQueue.Add: TQueueItem;
begin
  Result := TQueueItem(inherited Add);
end;


function TCommandQueue.HasStatusCommands: boolean;
var
  i: integer;
begin
  Result := true;
  for i:=0 to Count-1 do if Items[i].Kind = ckStatus then Exit;
  Result := false;
end;





{
procedure TCommandQueue.AddCommand(ACode: TByteArray; ALen: integer;
  AEnd: TByteArray; AKind: TCommandKind);
begin
  with Add do
    begin
    Code := ACode;
    Param := AParam;
    ReplyLength := ALen;
    SetLength(ReplyEnd, Length(AEnd));
    Move(AEnd[0], ReplyEnd[1], Length(AEnd));
    Kind := AKind;
    end;
end;
}

function TCommandQueue.CurrentCmd: TQueueItem;
begin
  Result := Items[0];
end;

end.

