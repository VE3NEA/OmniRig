unit OmniRig_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : $Revision:   1.88.1.0.1.0  $
// File generated on 2/8/2017 2:55:47 PM from Type Library described below.

// ************************************************************************ //
// Type Lib: C:\DMdocs\DelphiDev\OmniRig\OmniRig.tlb (1)
// IID\LCID: {4FE359C5-A58F-459D-BE95-CA559FB4F270}\0
// Helpfile: 
// DepndLst: 
//   (1) v2.0 stdole, (C:\WINDOWS\system32\stdole2.tlb)
//   (2) v4.0 StdVCL, (C:\WINDOWS\system32\STDVCL40.DLL)
// ************************************************************************ //
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, OleCtrls, StdVCL;

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  OmniRigMajorVersion = 1;
  OmniRigMinorVersion = 0;

  LIBID_OmniRig: TGUID = '{4FE359C5-A58F-459D-BE95-CA559FB4F270}';

  IID_IOmniRigX: TGUID = '{501A2858-3331-467A-837A-989FDEDACC7D}';
  DIID_IOmniRigXEvents: TGUID = '{2219175F-E561-47E7-AD17-73C4D8891AA1}';
  CLASS_OmniRigX: TGUID = '{0839E8C6-ED30-4950-8087-966F970F0CAE}';
  IID_IRigX: TGUID = '{D30A7E51-5862-45B7-BFFA-6415917DA0CF}';
  CLASS_RigX: TGUID = '{78AECFA2-3F52-4E39-98D3-1646C00A6234}';
  IID_IPortBits: TGUID = '{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}';
  CLASS_PortBits: TGUID = '{B786DE29-3B3D-4C66-B7C4-547F9A77A21D}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum RigParamX
type
  RigParamX = TOleEnum;
const
  PM_UNKNOWN = $00000001;
  PM_FREQ = $00000002;
  PM_FREQA = $00000004;
  PM_FREQB = $00000008;
  PM_PITCH = $00000010;
  PM_RITOFFSET = $00000020;
  PM_RIT0 = $00000040;
  PM_VFOAA = $00000080;
  PM_VFOAB = $00000100;
  PM_VFOBA = $00000200;
  PM_VFOBB = $00000400;
  PM_VFOA = $00000800;
  PM_VFOB = $00001000;
  PM_VFOEQUAL = $00002000;
  PM_VFOSWAP = $00004000;
  PM_SPLITON = $00008000;
  PM_SPLITOFF = $00010000;
  PM_RITON = $00020000;
  PM_RITOFF = $00040000;
  PM_XITON = $00080000;
  PM_XITOFF = $00100000;
  PM_RX = $00200000;
  PM_TX = $00400000;
  PM_CW_U = $00800000;
  PM_CW_L = $01000000;
  PM_SSB_U = $02000000;
  PM_SSB_L = $04000000;
  PM_AM = $20000000;
  PM_FM = $40000000;
  PM_RTTY_U = $40000001;
  PM_RTTY_L = $40000002;
  PM_PSK_U = $40000003;
  PM_PSK_L = $40000004;

// Constants for enum RigStatusX
type
  RigStatusX = TOleEnum;
const
  ST_NOTCONFIGURED = $00000000;
  ST_DISABLED = $00000001;
  ST_PORTBUSY = $00000002;
  ST_NOTRESPONDING = $00000003;
  ST_ONLINE = $00000004;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IOmniRigX = interface;
  IOmniRigXDisp = dispinterface;
  IOmniRigXEvents = dispinterface;
  IRigX = interface;
  IRigXDisp = dispinterface;
  IPortBits = interface;
  IPortBitsDisp = dispinterface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  OmniRigX = IOmniRigX;
  RigX = IRigX;
  PortBits = IPortBits;


// *********************************************************************//
// Interface: IOmniRigX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {501A2858-3331-467A-837A-989FDEDACC7D}
// *********************************************************************//
  IOmniRigX = interface(IDispatch)
    ['{501A2858-3331-467A-837A-989FDEDACC7D}']
    function  Get_InterfaceVersion: Integer; safecall;
    function  Get_SoftwareVersion: Integer; safecall;
    function  Get_Rig1: IRigX; safecall;
    function  Get_Rig2: IRigX; safecall;
    function  Get_DialogVisible: WordBool; safecall;
    procedure Set_DialogVisible(Value: WordBool); safecall;
    property InterfaceVersion: Integer read Get_InterfaceVersion;
    property SoftwareVersion: Integer read Get_SoftwareVersion;
    property Rig1: IRigX read Get_Rig1;
    property Rig2: IRigX read Get_Rig2;
    property DialogVisible: WordBool read Get_DialogVisible write Set_DialogVisible;
  end;

// *********************************************************************//
// DispIntf:  IOmniRigXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {501A2858-3331-467A-837A-989FDEDACC7D}
// *********************************************************************//
  IOmniRigXDisp = dispinterface
    ['{501A2858-3331-467A-837A-989FDEDACC7D}']
    property InterfaceVersion: Integer readonly dispid 1;
    property SoftwareVersion: Integer readonly dispid 2;
    property Rig1: IRigX readonly dispid 3;
    property Rig2: IRigX readonly dispid 4;
    property DialogVisible: WordBool dispid 5;
  end;

// *********************************************************************//
// DispIntf:  IOmniRigXEvents
// Flags:     (4096) Dispatchable
// GUID:      {2219175F-E561-47E7-AD17-73C4D8891AA1}
// *********************************************************************//
  IOmniRigXEvents = dispinterface
    ['{2219175F-E561-47E7-AD17-73C4D8891AA1}']
    procedure VisibleChange; dispid 1;
    procedure RigTypeChange(RigNumber: Integer); dispid 2;
    procedure StatusChange(RigNumber: Integer); dispid 3;
    procedure ParamsChange(RigNumber: Integer; Params: Integer); dispid 4;
    procedure CustomReply(RigNumber: Integer; Command: OleVariant; Reply: OleVariant); dispid 5;
  end;

// *********************************************************************//
// Interface: IRigX
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D30A7E51-5862-45B7-BFFA-6415917DA0CF}
// *********************************************************************//
  IRigX = interface(IDispatch)
    ['{D30A7E51-5862-45B7-BFFA-6415917DA0CF}']
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
    procedure SetSimplexMode(Freq: Integer); safecall;
    procedure SetSplitMode(RxFreq: Integer; TxFreq: Integer); safecall;
    function  FrequencyOfTone(Tone: Integer): Integer; safecall;
    procedure SendCustomCommand(Command: OleVariant; ReplyLength: Integer; ReplyEnd: OleVariant); safecall;
    function  GetRxFrequency: Integer; safecall;
    function  GetTxFrequency: Integer; safecall;
    function  Get_PortBits: IPortBits; safecall;
    property RigType: WideString read Get_RigType;
    property ReadableParams: Integer read Get_ReadableParams;
    property WriteableParams: Integer read Get_WriteableParams;
    property Status: RigStatusX read Get_Status;
    property StatusStr: WideString read Get_StatusStr;
    property Freq: Integer read Get_Freq write Set_Freq;
    property FreqA: Integer read Get_FreqA write Set_FreqA;
    property FreqB: Integer read Get_FreqB write Set_FreqB;
    property RitOffset: Integer read Get_RitOffset write Set_RitOffset;
    property Pitch: Integer read Get_Pitch write Set_Pitch;
    property Vfo: RigParamX read Get_Vfo write Set_Vfo;
    property Split: RigParamX read Get_Split write Set_Split;
    property Rit: RigParamX read Get_Rit write Set_Rit;
    property Xit: RigParamX read Get_Xit write Set_Xit;
    property Tx: RigParamX read Get_Tx write Set_Tx;
    property Mode: RigParamX read Get_Mode write Set_Mode;
    property PortBits: IPortBits read Get_PortBits;
  end;

// *********************************************************************//
// DispIntf:  IRigXDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {D30A7E51-5862-45B7-BFFA-6415917DA0CF}
// *********************************************************************//
  IRigXDisp = dispinterface
    ['{D30A7E51-5862-45B7-BFFA-6415917DA0CF}']
    property RigType: WideString readonly dispid 1;
    property ReadableParams: Integer readonly dispid 2;
    property WriteableParams: Integer readonly dispid 3;
    function  IsParamReadable(Param: RigParamX): WordBool; dispid 4;
    function  IsParamWriteable(Param: RigParamX): WordBool; dispid 5;
    property Status: RigStatusX readonly dispid 6;
    property StatusStr: WideString readonly dispid 7;
    property Freq: Integer dispid 8;
    property FreqA: Integer dispid 9;
    property FreqB: Integer dispid 10;
    property RitOffset: Integer dispid 11;
    property Pitch: Integer dispid 12;
    property Vfo: RigParamX dispid 13;
    property Split: RigParamX dispid 14;
    property Rit: RigParamX dispid 15;
    property Xit: RigParamX dispid 16;
    property Tx: RigParamX dispid 17;
    property Mode: RigParamX dispid 18;
    procedure ClearRit; dispid 19;
    procedure SetSimplexMode(Freq: Integer); dispid 20;
    procedure SetSplitMode(RxFreq: Integer; TxFreq: Integer); dispid 21;
    function  FrequencyOfTone(Tone: Integer): Integer; dispid 22;
    procedure SendCustomCommand(Command: OleVariant; ReplyLength: Integer; ReplyEnd: OleVariant); dispid 23;
    function  GetRxFrequency: Integer; dispid 24;
    function  GetTxFrequency: Integer; dispid 25;
    property PortBits: IPortBits readonly dispid 26;
  end;

// *********************************************************************//
// Interface: IPortBits
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}
// *********************************************************************//
  IPortBits = interface(IDispatch)
    ['{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}']
    function  Lock: WordBool; safecall;
    function  Get_Rts: WordBool; safecall;
    procedure Set_Rts(Value: WordBool); safecall;
    function  Get_Dtr: WordBool; safecall;
    procedure Set_Dtr(Value: WordBool); safecall;
    function  Get_Cts: WordBool; safecall;
    function  Get_Dsr: WordBool; safecall;
    procedure Unlock; safecall;
    property Rts: WordBool read Get_Rts write Set_Rts;
    property Dtr: WordBool read Get_Dtr write Set_Dtr;
    property Cts: WordBool read Get_Cts;
    property Dsr: WordBool read Get_Dsr;
  end;

// *********************************************************************//
// DispIntf:  IPortBitsDisp
// Flags:     (4416) Dual OleAutomation Dispatchable
// GUID:      {3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}
// *********************************************************************//
  IPortBitsDisp = dispinterface
    ['{3DEE2CC8-1EA3-46E7-B8B4-3E7321F2446A}']
    function  Lock: WordBool; dispid 1;
    property Rts: WordBool dispid 2;
    property Dtr: WordBool dispid 3;
    property Cts: WordBool readonly dispid 4;
    property Dsr: WordBool readonly dispid 5;
    procedure Unlock; dispid 6;
  end;

// *********************************************************************//
// The Class CoOmniRigX provides a Create and CreateRemote method to          
// create instances of the default interface IOmniRigX exposed by              
// the CoClass OmniRigX. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoOmniRigX = class
    class function Create: IOmniRigX;
    class function CreateRemote(const MachineName: string): IOmniRigX;
  end;

// *********************************************************************//
// The Class CoRigX provides a Create and CreateRemote method to          
// create instances of the default interface IRigX exposed by              
// the CoClass RigX. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoRigX = class
    class function Create: IRigX;
    class function CreateRemote(const MachineName: string): IRigX;
  end;

// *********************************************************************//
// The Class CoPortBits provides a Create and CreateRemote method to          
// create instances of the default interface IPortBits exposed by              
// the CoClass PortBits. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoPortBits = class
    class function Create: IPortBits;
    class function CreateRemote(const MachineName: string): IPortBits;
  end;

implementation

uses ComObj;

class function CoOmniRigX.Create: IOmniRigX;
begin
  Result := CreateComObject(CLASS_OmniRigX) as IOmniRigX;
end;

class function CoOmniRigX.CreateRemote(const MachineName: string): IOmniRigX;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_OmniRigX) as IOmniRigX;
end;

class function CoRigX.Create: IRigX;
begin
  Result := CreateComObject(CLASS_RigX) as IRigX;
end;

class function CoRigX.CreateRemote(const MachineName: string): IRigX;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_RigX) as IRigX;
end;

class function CoPortBits.Create: IPortBits;
begin
  Result := CreateComObject(CLASS_PortBits) as IPortBits;
end;

class function CoPortBits.CreateRemote(const MachineName: string): IPortBits;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_PortBits) as IPortBits;
end;

end.
