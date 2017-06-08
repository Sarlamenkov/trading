unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  uModel, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TMainFm = class(TForm)
    ListBox1: TListBox;
    Label1: TLabel;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    procedure FormShow(Sender: TObject);
  private
    FInstrums: TInstruments;
    procedure FillInstrums;
  public
    { Public declarations }
  end;

var
  MainFm: TMainFm;

implementation

{$R *.dfm}

procedure TMainFm.FillInstrums;
var
  i: Integer;
begin
  ListBox1.Clear;
  for i := 0 to FInstrums.Count - 1 do
    ListBox1.Items.Add(FInstrums[i].Name)
end;

procedure TMainFm.FormShow(Sender: TObject);
begin
  FInstrums := TInstruments.Create;
  FInstrums.LoadFromFolder(ExtractFilePath(Application.ExeName) + 'data');
  FillInstrums;
end;

end.
