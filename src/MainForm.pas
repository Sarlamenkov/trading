unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  uModel, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TMainFm = class(TForm)
    Label1: TLabel;
    dtpStart: TDateTimePicker;
    dtpEnd: TDateTimePicker;
    TreeView1: TTreeView;
    btnStart: TButton;
    Label2: TLabel;
    cbxRebalance: TComboBox;
    lblResult: TLabel;
    edBalance: TEdit;
    Label4: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    FInstrums: TInstruments;
    FMarkovic: TMarkovic;
    procedure FillInstrums;
  public
    { Public declarations }
  end;

var
  MainFm: TMainFm;

implementation

{$R *.dfm}

procedure TMainFm.btnStartClick(Sender: TObject);
var
  vInstrList: TList;
  i: Integer;
begin
  vInstrList := TList.Create;

  for i := 0 to TreeView1.SelectionCount - 1 do
    if TObject(TreeView1.Selections[i].Data) is TInstrument then
    begin
      vInstrList.Add(TreeView1.Selections[i].Data);
    end;

  if vInstrList.Count > 1 then
  begin
    FMarkovic.StartBalance := StrToIntDef(edBalance.Text, 200000);
    FMarkovic.RebalancePeriod := THistoryType(cbxRebalance.Items.Objects[cbxRebalance.ItemIndex]);
    FMarkovic.Calc(dtpStart.Date, dtpEnd.Date, vInstrList);
    lblResult.Caption := 'Баланс с применением алогитма: ' + IntToStr(FMarkovic.EndBalance) +
      ', без него: ' + IntToStr(FMarkovic.EndBalanceWithoutAlgorithm);
  end;

  vInstrList.Free;
end;

procedure TMainFm.FillInstrums;
var
  i: Integer;
  h: THistoryType;
  vRootNode: TTreeNode;
  vInstrum: TInstrument;
  vHist: THistory;
  vHistText: string;
begin
  dtpStart.Date := 0;
  dtpEnd.Date := Now;
  TreeView1.Items.Clear;
  for i := 0 to FInstrums.Count - 1 do
  begin
    vInstrum := FInstrums[i];
    vRootNode := TreeView1.Items.AddChildObject(nil, vInstrum.Name, vInstrum);
    for h := Low(THistoryType) to High(THistoryType) do
    begin
      vHist := vInstrum.History[h];
      if vHist.Count > 0 then
      begin
        vHistText := vHist.HistoryTypeText +
          ' (' + vHist[0].DateAsText + ' - ' + vHist[vHist.Count-1].DateAsText + ')';
        TreeView1.Items.AddChildObject(vRootNode, vHistText, vHist);
        if vHist[0].VDate > dtpStart.Date then
          dtpStart.Date := vHist[0].VDate;
        if vHist[vHist.Count-1].VDate < dtpEnd.Date then
          dtpEnd.Date := vHist[vHist.Count-1].VDate;
      end;
    end;
  end;
  TreeView1.FullExpand;
end;

procedure TMainFm.FormShow(Sender: TObject);
var
  i: THistoryType;
begin
  FInstrums := TInstruments.Create;
  FMarkovic := TMarkovic.Create;
  FInstrums.LoadFromFolder(ExtractFilePath(Application.ExeName) + 'data');
  FillInstrums;
  cbxRebalance.Clear;
  for i := Low(THistoryType) to High(THistoryType) do
    cbxRebalance.Items.AddObject(THistory.ToText(i), TObject(i));
  cbxRebalance.ItemIndex := 0;
end;

end.
