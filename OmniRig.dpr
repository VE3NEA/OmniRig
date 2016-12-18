program OmniRig;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  OmniRig_TLB in 'OmniRig_TLB.pas',
  AutoApp in 'AutoApp.pas' {OmniRig: CoClass},
  AutoRig in 'AutoRig.pas' {RigX: CoClass},
  RigSett in 'RigSett.pas',
  RigObj in 'RigObj.pas',
  RigCmds in 'RigCmds.pas',
  CustRig in 'CustRig.pas',
  CmdQue in 'CmdQue.pas',
  ByteFuns in 'ByteFuns.pas',
  AutoPort in 'AutoPort.pas' {PortBits: CoClass},
  AlComPrt in 'Lib\AlComPrt.pas',
  AlStrLst in 'Lib\AlStrLst.pas',
  ScrFctry in 'Lib\ScrFctry.pas';

{$R *.TLB}

{$R *.RES}

begin
  //MemChk;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Title := 'Omni-Rig';
  Application.Run;
end.

