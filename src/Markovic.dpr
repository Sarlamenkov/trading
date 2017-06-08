program Markovic;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {MainFm},
  uModel in 'uModel.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainFm, MainFm);
  Application.Run;
end.
