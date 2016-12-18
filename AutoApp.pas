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

unit AutoApp;

interface

uses
  Windows, SysUtils, ComObj, ActiveX, AxCtrls, Classes, OmniRig_TLB, StdVcl,
  AutoRig, CustRig, ByteFuns, RigObj, ScrFctry;

type
  //TOmniRigX = class(TAutoObject, IConnectionPointContainer, IOmniRigX)
  TOmniRigX = class(TScriptableAutoObject, IConnectionPointContainer, IOmniRigX)

  private
    FConnectionPoints: TConnectionPoints;
    FConnectionPoint: TConnectionPoint;
    FSinkList: TList;
    FEvents: IOmniRigXEvents;

    RigX1, RigX2: TRigX;
  public
    CustCommand, CustReply: TByteArray;

    procedure Initialize; override;
    destructor Destroy; override;
    procedure CheckShutdown(var Shutdown: Boolean);
  protected
    property ConnectionPoints: TConnectionPoints read FConnectionPoints
      implements IConnectionPointContainer;
    procedure EventSinkChanged(const EventSink: IUnknown); override;
    function Get_Rig1: IRigX; safecall;
    function Get_Rig2: IRigX; safecall;
    function Get_DialogVisible: WordBool; safecall;
    procedure Set_DialogVisible(Value: WordBool); safecall;
    function Get_InterfaceVersion: Integer; safecall;
    function Get_SoftwareVersion: Integer; safecall;
end;


var
  ObjList: TList;

//this event is fired immediately
procedure ComNotifyVisible;
procedure ComNotifyRigType(RigNumber: integer);
//send message to fire com event later
procedure ComNotifyStatus(RigNumber: integer);
procedure ComNotifyParams(RigNumber: integer; Params: integer);
procedure ComNotifyCustom(RigNumber: integer; Sender: Pointer);
//fire event in response to message
procedure DoComNotifyStatus(RigNumber: integer);
procedure DoComNotifyParams(RigNumber, Params: integer);
procedure DoComNotifyCustom(RigNumber: integer; Sender: Pointer);


implementation

uses
  ComServ, Main;


//------------------------------------------------------------------------------
//                                init
//------------------------------------------------------------------------------
procedure TOmniRigX.CheckShutdown(var Shutdown: Boolean);
begin
  //The [x] button hides main form instead of closing app
  //if COM clients are connected. Now it's time to close.
  Shutdown := Shutdown or not MainForm.Visible;
end;


procedure TOmniRigX.EventSinkChanged(const EventSink: IUnknown);
begin
  FEvents := EventSink as IOmniRigXEvents;
  if FConnectionPoint <> nil then FSinkList := FConnectionPoint.SinkList;
end;


procedure TOmniRigX.Initialize;
begin
  //standard stuff
  inherited Initialize;
  FConnectionPoints := TConnectionPoints.Create(Self);
  if AutoFactory.EventTypeInfo <> nil then
    FConnectionPoint := FConnectionPoints.CreateConnectionPoint(
      AutoFactory.EventIID, ckSingle, EventConnect)
  else FConnectionPoint := nil;

  //create COM object for Rig 1
  RigX1 := TRigX.Create;
  Get_Rig1._AddRef;
  RigX1.FRig := MainForm.Rig1;
  RigX1.Parent := Self;
  RigX1.FPortBits.FPort := MainForm.Rig1.ComPort;

  //create COM object for Rig 2
  RigX2 := TRigX.Create;
  Get_Rig2._AddRef;
  RigX2.FRig := MainForm.Rig2;
  RigX2.Parent := Self;
  RigX2.FPortBits.FPort := MainForm.Rig2.ComPort;

  ObjList.Add(Self);
  ComServer.OnLastRelease := CheckShutdown;
end;


destructor TOmniRigX.Destroy;
begin
  ObjList.Remove(Self);
  FreeAndNil(FConnectionPoints);
  RigX1.Free;
  RigX2.Free;
  inherited;
end;






//------------------------------------------------------------------------------
//                           interface methods
//------------------------------------------------------------------------------

//1.0 - initial release
//1.1 - PortBits added
//1.1+ - SentCustomCommand accepts strings
//1.1++ - SetSplitMode tries more commands
//1.1+++ - GetRxFreq, &GetTxFreeq corrected


function TOmniRigX.Get_InterfaceVersion: Integer;
begin
  Result := $0101;
end;

function TOmniRigX.Get_SoftwareVersion: Integer;
begin
  Result := MainForm.GetVersion;
end;


function TOmniRigX.Get_Rig1: IRigX;
begin
  Result := RigX1;
end;


function TOmniRigX.Get_Rig2: IRigX;
begin
  Result := RigX2;
end;


function TOmniRigX.Get_DialogVisible: WordBool;
begin
  Result := MainForm.Visible;
end;

procedure TOmniRigX.Set_DialogVisible(Value: WordBool);
begin
  if Value
    then MainForm.ForceForeground
    else MainForm.Hide;
end;








//------------------------------------------------------------------------------
//                                events
//------------------------------------------------------------------------------

//fire event immediately

procedure ComNotifyVisible;
var
  i: integer;
begin
  for i:=ObjList.Count-1 downto 0 do
    with TOmniRigX(ObjList[i]) do
      if FEvents <> nil then FEvents.VisibleChange;
end;


procedure ComNotifyRigType(RigNumber: integer);
var
  i: integer;
begin
  for i:=ObjList.Count-1 downto 0 do
    with TOmniRigX(ObjList[i]) do
      if FEvents <> nil then FEvents.RigTypeChange(RigNumber);

  //rig type changed, client must re-read rig status
  ComNotifyStatus(RigNumber);
end;


//send message to fire event later

procedure ComNotifyStatus(RigNumber: integer);
begin
  PostMessage(MainForm.Handle, WM_COMSTATUS, RigNumber, 0);
end;


procedure ComNotifyParams(RigNumber, Params: integer);
begin
  PostMessage(MainForm.Handle, WM_COMPARAMS, RigNumber, Params);
end;


procedure ComNotifyCustom(RigNumber: integer; Sender: Pointer);
begin
  PostMessage(MainForm.Handle, WM_COMCUSTOM, RigNumber, Integer(Sender));
end;


//respond to message by firing an event

procedure DoComNotifyStatus(RigNumber: integer);
var
  i: integer;
begin
  for i:=ObjList.Count-1 downto 0 do
    with TOmniRigX(ObjList[i]) do
      if FEvents <> nil then FEvents.StatusChange(RigNumber);
end;


procedure DoComNotifyParams(RigNumber, Params: integer);
var
  i: integer;
begin
  for i:=ObjList.Count-1 downto 0 do
    with TOmniRigX(ObjList[i]) do
      if FEvents <> nil then FEvents.ParamsChange(RigNumber, Params);
end;


procedure DoComNotifyCustom(RigNumber: integer; Sender: Pointer);
var
  Rig: TRig;
begin
  if ObjList.IndexOf(Sender) < 0 then Exit;

  with TOmniRigX(Sender) do
    begin
    if RigNumber = 1 then Rig := RigX1.FRig else Rig := RigX2.FRig;
    Rig.Lock;
    try
      if FEvents <> nil then FEvents.CustomReply(RigNumber,
        BytesToSafeArray(CustCommand), BytesToSafeArray(CustReply));
    finally Rig.Unlock; end;
    end;
end;
         



initialization
  //TAutoObjectFactory.Create(ComServer, TOmniRigX, Class_OmniRigX,
  TScriptableAutoObjectFactory.Create(ComServer, TOmniRigX, Class_OmniRigX,
    ciMultiInstance, tmApartment);

  ObjList := TList.Create;



finalization
  ObjList.Free;




end.

