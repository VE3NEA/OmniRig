//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//             Classes that make the object safe for scripting
//              Copyright (c) 2003 Alex Shovkoplyas, VE3NEA
//                         ve3nea@dxatlas.com
//------------------------------------------------------------------------------

unit ScrFctry;

interface

uses
  Windows, SysUtils, ComObj, ActiveX;

type
  TScriptableAutoObjectFactory = class (TAutoObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;


  TScriptableAutoObject = class (TAutoObject, IObjectSafety)
  private
    FObjectSafetyFlags: DWORD;
    function GetInterfaceSafetyOptions(const IID: TIID; pdwSupportedOptions,
      pdwEnabledOptions: PDWORD): HResult; stdcall;
    function SetInterfaceSafetyOptions(const IID: TIID; dwOptionSetMask,
      dwEnabledOptions: DWORD): HResult; stdcall;
  end;


implementation

{ TScriptableAutoObjectFactory }

procedure TScriptableAutoObjectFactory.UpdateRegistry(Register: Boolean);
const
  CATID_SafeForScripting = '{7DD95801-9882-11CF-9FA9-00AA006C42C4}';
  CATID_SafeForInitializing = '{7DD95802-9882-11CF-9FA9-00AA006C42C4}';
begin
  inherited UpdateRegistry(Register);
  //CreateRegKey('Component Categories\' + CATID_SafeForScripting,'','');
  //CreateRegKey('Component Categories\' + CATID_SafeForInitializing,'','');

  CreateRegKey('CLSID\' + GUIDToString(ClassID) + '\Implemented  Categories\'
    + CATID_SafeForScripting, '', '');

  CreateRegKey('CLSID\' + GUIDToString(ClassID) + '\Implemented  Categories\'
    + CATID_SafeForInitializing, '', '');
end;





{ TObjectSafety }

function TScriptableAutoObject.GetInterfaceSafetyOptions(const IID: TIID;
  pdwSupportedOptions, pdwEnabledOptions: PDWORD): HResult;
var
  Unk: IUnknown;
begin
  if (pdwSupportedOptions = nil) or (pdwEnabledOptions = nil) then
  begin
    Result := E_POINTER;
    Exit;
  end;
  Result := QueryInterface(IID, Unk);
  if Result = S_OK then
  begin
    pdwSupportedOptions^ := INTERFACESAFE_FOR_UNTRUSTED_CALLER or
      INTERFACESAFE_FOR_UNTRUSTED_DATA;
    pdwEnabledOptions^ := FObjectSafetyFlags and
      (INTERFACESAFE_FOR_UNTRUSTED_CALLER or INTERFACESAFE_FOR_UNTRUSTED_DATA);
  end
  else begin
    pdwSupportedOptions^ := 0;
    pdwEnabledOptions^ := 0;
  end;
end;

function TScriptableAutoObject.SetInterfaceSafetyOptions(const IID: TIID;
  dwOptionSetMask, dwEnabledOptions: DWORD): HResult;
var
  Unk: IUnknown;
begin
  Result := QueryInterface(IID, Unk);
  if Result <> S_OK then Exit;
  FObjectSafetyFlags := dwEnabledOptions and dwOptionSetMask;
end;


end.
 
