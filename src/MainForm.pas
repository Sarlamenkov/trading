unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, StdCtrls, ComCtrls, Spin,

  uModel, Vcl.Dialogs;

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
    lblInstrumNames: TLabel;
    Label3: TLabel;
    SpinEdit1: TSpinEdit;
    btnSearch: TButton;
    ProgressBar1: TProgressBar;
    btnStop: TButton;
    btnSave: TButton;
    FileSaveDialog1: TFileSaveDialog;
    Label5: TLabel;
    seDiffAmount: TSpinEdit;
    Label6: TLabel;
    sePortfolioGrow: TSpinEdit;
    Label7: TLabel;
    seQuoteGrow: TSpinEdit;
    lvBestResults: TMemo;
    procedure FormShow(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
  private
    FInstrums: TInstruments;
    FMarkovic: TMarkovic;
    FInProcess: Boolean;
    FResults: TStringList;
    procedure FillInstrums;
    procedure UpdateUIState;
  public
    { Public declarations }
  end;

var
  MainFm: TMainFm;

implementation

uses
  StrUtils;

{$R *.dfm}

procedure TMainFm.btnSaveClick(Sender: TObject);
begin
  if FileSaveDialog1.Execute then
  begin
    FResults.SaveToFile(FileSaveDialog1.FileName);

  end;
end;

function MySort(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Integer(List.Objects[Index2]) - Integer(List.Objects[Index1]);
end;

procedure TMainFm.btnSearchClick(Sender: TObject);
var
  vInstrList: TList;
  i, j, k: Integer;
  vInstrNames: string;
  vRebalance: THistoryType;
  vPrevCursor: TCursor;
begin
  if FInProcess then Exit;

  FInProcess := True;
 // lvBestResults.Clear;

  vInstrList := TList.Create;
  vPrevCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  ProgressBar1.Position := 0;
  UpdateUIState;

  FResults.BeginUpdate;
  FResults.Clear;

  Application.ProcessMessages;
  try
    for i := 0 to FInstrums.Count - SpinEdit1.Value do
    begin
      for vRebalance := htDay to High(THistoryType) do
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
          FMarkovic.PortfolioDifferenceAmount := seDiffAmount.Value;
          FMarkovic.PortfolioGrowAmount := sePortfolioGrow.Value;
          FMarkovic.MaxQuiteGrowAmount := seQuoteGrow.Value;
          FMarkovic.Calc(dtpStart.Date, dtpEnd.Date, vInstrList);

          FResults.AddObject(
            FormatFloat('0.00', FMarkovic.Percent - FMarkovic.PercentWithoutAlgorithm) + #9 +
            vInstrNames + #9 + THistory.ToText(vRebalance) + #9 +
            FormatFloat('0.00', FMarkovic.Percent) + #9 +
            FormatFloat('0.00', FMarkovic.PercentWithoutAlgorithm) + #9 +
            IntToStr(FMarkovic.RebalanceCount) + #9 +
            DateToStr(FMarkovic.RealStart) + #9 + DateToStr(FMarkovic.RealEnd) + #9 +
            IntToStr(Trunc(FMarkovic.RealEnd - FMarkovic.RealStart)) + #9 +
            FormatFloat('0.00', FInstrums[i].History[htDay].GetRate(dtpStart.Date).Close) + '/' +
            FormatFloat('0.00', FInstrums[i].History[htDay].GetRate(dtpEnd.Date).Close),
            TObject(Trunc((FMarkovic.Percent - FMarkovic.PercentWithoutAlgorithm) * 100000)) );
        end;
      end;
      ProgressBar1.Position := Trunc((i + 1) / FInstrums.Count * 100);
      if FInProcess then
        Application.ProcessMessages
      else
        Exit;
    end;
    FResults.CustomSort(MySort);
    FResults.Insert(0, '%'#9'Instrum'#9'Intv'#9'%w alg'#9'%w/o alg'#9'Rebal'#9'Start'#9'End'#9'Days'#9'Start/End Quote');
    lvBestResults.Lines.Assign(FResults);
  finally
    vInstrList.Free;
    FResults.EndUpdate;
    Screen.Cursor := vPrevCursor;
    FInProcess := False;
    UpdateUIState;
  end;
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
    FMarkovic.PortfolioDifferenceAmount := seDiffAmount.Value;
    FMarkovic.PortfolioGrowAmount := sePortfolioGrow.Value;
    FMarkovic.MaxQuiteGrowAmount := seQuoteGrow.Value;
    FMarkovic.Calc(dtpStart.Date, dtpEnd.Date, vInstrList);
    lblResult.Caption := '������ � ����������� ���������: ' + IntToStr(FMarkovic.EndBalance) +
      ' (' + FormatFloat('0.000', FMarkovic.Percent) + '%), ��� ����: ' +
      IntToStr(FMarkovic.EndBalanceWithoutAlgorithm) + ' (' + FormatFloat('0.000', FMarkovic.PercentWithoutAlgorithm) + '%)';
    lblRealPeriod.Caption := '�������� ������ ������������ � ' + DateToStr(FMarkovic.RealStart) +
      ' �� ' + DateToStr(FMarkovic.RealEnd) + ', ��������: ' + FormatFloat('0.00 ', FMarkovic.TotalComission)
      + ', ����������: ' + IntToStr(FMarkovic.RebalanceCount);
  end;

  vInstrList.Free;
end;

procedure TMainFm.btnStopClick(Sender: TObject);
begin
  FInProcess := False;
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
  lblInstrums.Caption := '����������� (' + IntToStr(FInstrums.Count) + ')' ;
end;

procedure TMainFm.FormShow(Sender: TObject);
var
  i: THistoryType;
begin
  FInstrums := TInstruments.Create;
  FMarkovic := TMarkovic.Create;
  FResults := TStringList.Create;
  FResults.Sorted := False;
  FInstrums.LoadFromFolder(ExtractFilePath(Application.ExeName) + 'data');
  FillInstrums;
  cbxRebalance.Clear;
  for i := Low(THistoryType) to High(THistoryType) do
    cbxRebalance.Items.AddObject(THistory.ToText(i), TObject(i));
  cbxRebalance.ItemIndex := 0;
end;

procedure TMainFm.UpdateUIState;
begin
  ProgressBar1.Visible := FInProcess;
  btnSearch.Enabled := not FInProcess;
  btnStop.Visible := FInProcess;
  btnSave.Visible := not FInProcess;
end;

end.
