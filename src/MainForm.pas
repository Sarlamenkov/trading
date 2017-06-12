unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

  uModel, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Samples.Spin;

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
    lblInstrums: TLabel;
    lblRealPeriod: TLabel;
    lvBestResults: TListView;
    lblInstrumNames: TLabel;
    Label3: TLabel;
    SpinEdit1: TSpinEdit;
    btnSearch: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure lvBestResultsCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
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

procedure TMainFm.btnSearchClick(Sender: TObject);
var
  vInstrList: TList;
  i, j, k: Integer;
  vInstrNames: string;
  vRebalance: THistoryType;
  vPrevCursor: TCursor;
begin
  lvBestResults.Clear;
  lvBestResults.Items.BeginUpdate;
  vInstrList := TList.Create;
  vPrevCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    for vRebalance := Low(THistoryType) to High(THistoryType) do
    begin
      for i := 0 to FInstrums.Count - SpinEdit1.Value do
      begin
        for j := i + 1 to FInstrums.Count - SpinEdit1.Value + 1 do
        begin
          vInstrList.Clear;
          vInstrList.Add(FInstrums[i]);
          vInstrNames := FInstrums[i].Name;
          for k := 0 to SpinEdit1.Value - 2 do
          begin
            vInstrList.Add(FInstrums[j + k]);
            vInstrNames := vInstrNames + '/' + FInstrums[j + k].Name
          end;

          FMarkovic.StartBalance := StrToIntDef(edBalance.Text, 200000);
          FMarkovic.RebalancePeriod := vRebalance;
          FMarkovic.Calc(dtpStart.Date, dtpEnd.Date, vInstrList);

          lvBestResults.AddItem(FormatFloat('0.00', FMarkovic.Percent) +
            '% ' + vInstrNames + ' ' + THistory.ToText(vRebalance) +
            ' (' + DateToStr(FMarkovic.RealStart) + ' - ' + DateToStr(FMarkovic.RealEnd) + ')',
            TObject(Trunc(FMarkovic.Percent * 1000000)) );
        end;
      end;
    end;
  finally
    vInstrList.Free;
    lvBestResults.Items.EndUpdate;
    Screen.Cursor := vPrevCursor;
  end;
  lvBestResults.AlphaSort;
end;

procedure TMainFm.btnStartClick(Sender: TObject);
var
  vInstrList: TList;
  i: Integer;
begin
  vInstrList := TList.Create;
  lblInstrumNames.Caption := '';
  for i := 0 to TreeView1.SelectionCount - 1 do
    if TObject(TreeView1.Selections[i].Data) is TInstrument then
    begin
      vInstrList.Add(TreeView1.Selections[i].Data);
      if i > 0 then
        lblInstrumNames.Caption := lblInstrumNames.Caption + ', ';
      lblInstrumNames.Caption := lblInstrumNames.Caption + TInstrument(TreeView1.Selections[i].Data).Name;
    end;

  if vInstrList.Count > 1 then
  begin
    FMarkovic.StartBalance := StrToIntDef(edBalance.Text, 200000);
    FMarkovic.RebalancePeriod := THistoryType(cbxRebalance.Items.Objects[cbxRebalance.ItemIndex]);
    FMarkovic.Calc(dtpStart.Date, dtpEnd.Date, vInstrList);
    lblResult.Caption := 'Баланс с применением алогитма: ' + IntToStr(FMarkovic.EndBalance) +
      ' (' + FormatFloat('0.000', FMarkovic.Percent) + '%), без него: ' +
      IntToStr(FMarkovic.EndBalanceWithoutAlgorithm) + ' (' + FormatFloat('0.000', FMarkovic.PercentWithoutAlgorithm) + '%)';
    lblRealPeriod.Caption := 'Реальный период тестирования с ' + DateToStr(FMarkovic.RealStart) +
      ' по ' + DateToStr(FMarkovic.RealEnd);
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
  TreeView1.AlphaSort;
  lblInstrums.Caption := 'Инструменты (' + IntToStr(FInstrums.Count) + ')' ;
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

procedure TMainFm.lvBestResultsCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
begin
  Compare := Integer(Item2.Data) - Integer(Item1.Data);
end;

end.
