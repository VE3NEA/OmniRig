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

unit AutoPort;

interface

uses
  Windows, ComObj, ActiveX, OmniRig_TLB, StdVcl, AlComPrt;

type
  TPortBits = class(TAutoObject, IPortBits)
  protected
    function Get_Cts: WordBool; safecall;
    function Get_Dsr: WordBool; safecall;
    function Get_Dtr: WordBool; safecall;
    function Get_Rts: WordBool; safecall;
    function Lock: WordBool; safecall;
    procedure Set_Dtr(Value: WordBool); safecall;
    procedure Set_Rts(Value: WordBool); safecall;
    procedure Unlock; safecall;
  public
    FPort: TAlCommPort;
  end;

implementation

uses ComServ, Main;

function TPortBits.Lock: WordBool;
begin

end;

procedure TPortBits.Unlock;
begin

end;


function TPortBits.Get_Cts: WordBool;
begin
  Result := FPort.CtsBit;
end;

function TPortBits.Get_Dsr: WordBool;
begin
  Result := FPort.DsrBit;
end;

function TPortBits.Get_Dtr: WordBool;
begin
  Result := FPort.DtrBit;
end;

function TPortBits.Get_Rts: WordBool;
begin
  Result := FPort.RtsBit;
end;


procedure TPortBits.Set_Dtr(Value: WordBool);
begin
  FPort.DtrBit := Value;
end;

procedure TPortBits.Set_Rts(Value: WordBool);
begin
  FPort.RtsBit := Value;
end;



initialization
  TAutoObjectFactory.Create(ComServer, TPortBits, Class_PortBits,
    ciInternal, tmApartment);
end.

