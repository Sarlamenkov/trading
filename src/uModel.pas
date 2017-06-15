unit uModel;

interface

uses
  Classes;

type
  THistoryData = class
  private
    FVDate: TDateTime;
    FLow: Double;
    FOpen: Double;
    FHigh: Double;
    FClose: Double;
  public
    constructor Create(const ADate: TDateTime; const AOpen, AHigh, ALow, AClose: Double);
    destructor Destroy; override;

    function DateAsText: string;

    property VDate: TDateTime read FVDate;
    property Open: Double read FOpen;
    property High: Double read FHigh;
    property Low: Double read FLow;
    property Close: Double read FClose;
  end;

  TInstrument = class;
  THistoryType = (htHour, htDay, htWeek, htMonth, htYear);

  THistory = class
  private
    FType: THistoryType;
    FOwner: TInstrument;
    FItems: TList;
    FEmpty: THistoryData;
    function GetData(const AIndex: Integer): THistoryData;
    function GetCount: Integer;
    function GetHTText: string;
  public
    class function HistoryTypeByText(const AText: string): THistoryType;
    class function ToText(const AType: THistoryType): string;
    class function Period(const AType: THistoryType): TDateTime;

    constructor Create(const AOwner: TInstrument; const AHistotyType: THistoryType);
    destructor Destroy; override;

    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStrings(const AStrings: TStrings);

    function GetRate(const ADate: TDateTime): THistoryData;
    function Min(const ABegin, AEnd: TDateTime): THistoryData;
    function Max(const ABegin, AEnd: TDateTime): THistoryData;

    property Items[const AIndex: Integer]: THistoryData read GetData; default;
    property Count: Integer read GetCount;
    property HistoryType: THistoryType read FType;
    property HistoryTypeText: string read GetHTText;
  end;

  TInstrument = class
  private
    FName: string;
    FHistories: TList;
    function GetHistory(const AType: THistoryType): THistory;
    procedure ClearHistory;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;

    function GetRate(const ADate: TDateTime; const AType: THistoryType): THistoryData;

    property Name: string read FName;
    property History[const AType: THistoryType]: THistory read GetHistory;
  end;

  TInstruments = class
  private
    FItems: TList;
    function GetInstrument(const AIndex: Integer): TInstrument;
    function GetInstrumentByName(const AName: string): TInstrument;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFolder(const AFolder: string);
    property Items[const AIndex: Integer]: TInstrument read GetInstrument; default;
    property Count: Integer read GetCount;
  end;

  TMarkovic = class
  private
    FStartBalance: Integer;
    FRebalancePeriod: THistoryType;
    FEndBalance: Integer;
    FCurTime: TDateTime;
    FCash: Double;
    FInstrumList: TList;
    FPortfolio: array of Integer;
    FInitialPortfolio: array of Integer;
    FEndBalanceWithoutAlgorithm: Integer;
    FRealStartPeriod, FRealEndPeriod: TDateTime;
    FPercent: Double;
    FPercentWithoutAlgorithm: Double;
    FRebalanceCount: Integer;
    FTotalComission: Double;
    FPortfolioDifferenceAmount: Double;
    procedure SetRebalancePeriod(const Value: THistoryType);
    procedure SetStartBalance(const Value: Integer);
    procedure Rebalance;
    function PortfolioValue(const ADate: TDateTime): Double;
    function PortfolioDifference(const ADate: TDateTime): Double;  // стоимость портфеля на дату
  public
    procedure Calc(const AStartPeriod, AEndPeriod: TDateTime; const AInstrumList: TList);

    property StartBalance: Integer read FStartBalance write SetStartBalance; // RUB
    property EndBalance: Integer read FEndBalance;
    property EndBalanceWithoutAlgorithm: Integer read FEndBalanceWithoutAlgorithm;
    property RebalancePeriod: THistoryType read FRebalancePeriod write SetRebalancePeriod;
    property PortfolioDifferenceAmount: Double read FPortfolioDifferenceAmount write FPortfolioDifferenceAmount; // макс разница в портфеле в % для ребаланса
    property RealStart: TDateTime read FRealStartPeriod;
    property RealEnd: TDateTime read FRealEndPeriod;
    property Percent: Double read FPercent;
    property PercentWithoutAlgorithm: Double read FPercentWithoutAlgorithm;
    property RebalanceCount: Integer read FRebalanceCount;
    property TotalComission: Double read FTotalComission;
  end;

implementation

uses
  SysUtils, StrUtils, DateUtils, Math;

{ TMarkovic }

procedure TMarkovic.Calc(const AStartPeriod, AEndPeriod: TDateTime; const AInstrumList: TList);
var
  i: Integer;
  vHist: THistory;
  vTestPeriodInYears: Double;
begin
  FRebalanceCount := 0;
  FTotalComission := 0;
  FCash := FStartBalance;
  FInstrumList := AInstrumList;
  FRealStartPeriod := AStartPeriod;
  FRealEndPeriod := AEndPeriod;
  SetLength(FPortfolio, FInstrumList.Count);
  SetLength(FInitialPortfolio, FInstrumList.Count);
  for i := 0 to FInstrumList.Count - 1 do
  begin
    FPortfolio[i] := 0;
    vHist := TInstrument(FInstrumList[i]).History[htDay];
    if FRealStartPeriod < vHist.Items[0].VDate then
      FRealStartPeriod := vHist.Items[0].VDate;
    if FRealEndPeriod > vHist.Items[vHist.Count - 1].VDate then
      FRealEndPeriod := vHist.Items[vHist.Count - 1].VDate;
  end;

  FCurTime := FRealStartPeriod;
  Rebalance;

  FEndBalanceWithoutAlgorithm := Trunc(PortfolioValue(AEndPeriod) + FCash);

  while FCurTime < FRealEndPeriod do
  begin
    if PortfolioDifferenceAmount > 0 then
    begin
      FCurTime := FCurTime + THistory.Period(htDay);
      if PortfolioDifference(FCurTime) > FPortfolioDifferenceAmount then
        Rebalance;
    end
    else
    begin
      FCurTime := FCurTime + THistory.Period(FRebalancePeriod);
      Rebalance;
    end;
  end;

  FEndBalance := Trunc(PortfolioValue(FRealEndPeriod) + FCash);

  vTestPeriodInYears := (FRealEndPeriod - FRealStartPeriod) / 365;
  FPercent := (Power(FEndBalance/FStartBalance, 1/vTestPeriodInYears) - 1) * 100;
  FPercentWithoutAlgorithm := (Power(FEndBalanceWithoutAlgorithm/FStartBalance, 1/vTestPeriodInYears) - 1) * 100;
end;

function TMarkovic.PortfolioValue(const ADate: TDateTime): Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FInstrumList.Count - 1 do
    Result := Result + FPortfolio[i] * TInstrument(FInstrumList[i]).GetRate(ADate, htDay).Close;
end;

function TMarkovic.PortfolioDifference(const ADate: TDateTime): Double;
var
  i: Integer;
  vRate2: Double;
begin
  Result := 0;
  vRate2 := (FPortfolio[1] * TInstrument(FInstrumList[1]).GetRate(ADate, htDay).Close);
  if vRate2 = 0 then Exit;

  Result := (FPortfolio[0] * TInstrument(FInstrumList[0]).GetRate(ADate, htDay).Close)/
    vRate2*100;
  if Result > 100 then
    Result := 1/Result;
end;

procedure TMarkovic.Rebalance;
var
  vBalance, vBalancePart, vRate, vBuySum, vComission: Double;
  i, vNeedCount, vBuyCount: Integer;
begin
  vBalance := PortfolioValue(FCurTime) + FCash;
  vBalancePart := vBalance / FInstrumList.Count; // делим портфель на равные части
  vComission := 0;
  for i := 0 to FInstrumList.Count - 1 do
  begin
    vRate := TInstrument(FInstrumList[i]).GetRate(FCurTime, htDay).Close;
    Assert(vRate > 0, 'Для инструмента: ' + TInstrument(FInstrumList[i]).Name +
      ' не найден курс на ' + FormatDateTime('dd.mm.yyyy', FCurTime));
    vNeedCount := Trunc(vBalancePart / vRate); // сколько нужно иметь этого инструмента
    vBuyCount := vNeedCount - FPortfolio[i]; // сколько нужно докупить (получится минус - значит сколько продать)
    vBuySum := vBuyCount * vRate;
    vComission := vComission + Abs(vBuySum*0.006);
    FCash := FCash - vBuySum;
    FPortfolio[i] := FPortfolio[i] + vBuyCount; // докупаем
  end;
  FCash := FCash - vComission;
  FTotalComission := FTotalComission + vComission;
  Inc(FRebalanceCount);
end;

procedure TMarkovic.SetRebalancePeriod(const Value: THistoryType);
begin
  FRebalancePeriod := Value;
end;

procedure TMarkovic.SetStartBalance(const Value: Integer);
begin
  FStartBalance := Value;
end;

{ TInstruments }

constructor TInstruments.Create;
begin
  FItems := TList.Create;
end;

destructor TInstruments.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TInstruments.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TInstruments.GetInstrument(const AIndex: Integer): TInstrument;
begin
  Result := TInstrument(FItems[AIndex]);
end;

function TInstruments.GetInstrumentByName(const AName: string): TInstrument;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FItems.Count - 1 do
    if SameText(AName, Items[i].Name) then
    begin
      Result := Items[i];
      Exit;
    end;

  if Result = nil then
  begin
    Result := TInstrument.Create(AName);
    FItems.Add(Result);
  end;
end;

function GetLexem(const AText: string; const ADelemiter: Char; const AIndex: Integer): string;
var
  vEndIndex, vStartIndex, c: Integer;
begin
  Result := '';
  c := -1; vStartIndex := 1;
  while c < AIndex do
  begin
    Inc(c);
    vEndIndex := PosEx(ADelemiter, AText, vStartIndex);
    Result := Copy(AText, vStartIndex, vEndIndex - vStartIndex);
    vStartIndex := vEndIndex + 1;
  end;
end;

procedure TInstruments.LoadFromFolder(const AFolder: string);
var
  vSearchRec: TSearchRec;
  vFolder: string;
  vFile: TStrings;
  vInstrum: TInstrument;
  vInstrumName, vTypeText: string;
  vHistType: THistoryType;
begin
  vFile := TStringList.Create;
  if SysUtils.FindFirst(AFolder + '\*.txt', faAnyFile, vSearchRec) = 0 then
    repeat
      vFolder := vSearchRec.Name;
      if not((vFolder = '.') or (vFolder = '..')) then
      begin
        vFile.LoadFromFile(AFolder + '\' + vFolder); // todo: overhead
        vInstrumName := GetLexem(vFile[0], ',', 0);
        vTypeText := GetLexem(vFile[0], ',', 1);
        vInstrum := GetInstrumentByName(vInstrumName);
        vHistType := THistory.HistoryTypeByText(vTypeText);
        vInstrum.History[vHistType].LoadFromStrings(vFile);
      end;
    until SysUtils.FindNext(vSearchRec) <> 0;

  SysUtils.FindClose(vSearchRec);
  vFile.Free;
end;

{ THistoryData }

constructor THistoryData.Create(const ADate: TDateTime; const AOpen, AHigh, ALow, AClose: Double);
begin
  FOpen := AOpen;
  FHigh := AHigh;
  FLow := ALow;
  FClose := AClose;
  FVDate := ADate;
end;

function THistoryData.DateAsText: string;
begin
  Result := FormatDateTime('dd.mm.yyyy', VDate);
end;

destructor THistoryData.Destroy;
begin

  inherited;
end;

{ TInstrument }

procedure TInstrument.ClearHistory;
var
  i: Integer;
begin
  for i := 0 to FHistories.Count - 1 do
    THistory(FHistories[i]).Free;
  FHistories.Clear;
end;

constructor TInstrument.Create(const AName: string);
begin
  FName := AName;
  FHistories := TList.Create;
end;

destructor TInstrument.Destroy;
begin
  ClearHistory;
  FreeAndNil(FHistories);
  inherited;
end;

function TInstrument.GetHistory(const AType: THistoryType): THistory;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FHistories.Count - 1 do
    if THistory(FHistories[i]).HistoryType = AType then
    begin
      Result := THistory(FHistories[i]);
      Exit;
    end;

  if Result = nil then
  begin
    Result := THistory.Create(Self, AType);
    FHistories.Add(Result);
  end;
end;

function TInstrument.GetRate(const ADate: TDateTime;
  const AType: THistoryType): THistoryData;
begin
  Result := History[AType].GetRate(ADate);
end;

{ THistory }

constructor THistory.Create(const AOwner: TInstrument; const AHistotyType: THistoryType);
begin
  FItems := TList.Create;
  FOwner := AOwner;
  FType := AHistotyType;
  FEmpty := THistoryData.Create(0, 0, 0, 0, 0);
end;

destructor THistory.Destroy;
begin
  FreeAndNil(FEmpty);
  FreeAndNil(FItems);
  inherited;
end;

function THistory.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function THistory.GetData(const AIndex: Integer): THistoryData;
begin
  Result := THistoryData(FItems[AIndex]);
end;

function THistory.GetHTText: string;
begin
  Result := ToText(FType);
end;

function THistory.GetRate(const ADate: TDateTime): THistoryData;
var
  L, H: Integer;
  mid, cmp: Integer;
  vFound: Boolean;
begin
  Result := FEmpty;
  vFound := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    mid := L + (H - L) shr 1;
//    cmp := Comparer.Compare(Values[mid], Item);
    cmp := CompareDate(Items[mid].VDate, ADate);
    if cmp < 0 then
      L := mid + 1
    else
    begin
      H := mid - 1;
      if cmp = 0 then
        vFound := True;
    end;
  end;
  if vFound then
    Result := Items[L]
  else if FItems.Count > 0 then
  begin
    if ADate < Items[0].VDate then
      Result := Items[0]
    else if ADate > Items[Count - 1].VDate then
      Result := Items[Count - 1]
    else if (L > 0) and (L < Count) then
      Result := Items[L-1];
  end;
end;

class function THistory.HistoryTypeByText(const AText: string): THistoryType;
begin
  Result := htHour;
  if SameText(AText, 'D') then
    Result := htDay
end;

procedure THistory.LoadFromFile(const AFileName: string);
begin

end;

procedure THistory.LoadFromStrings(const AStrings: TStrings);
var
  vSplit: TStrings;
  i: Integer;
  vHD: THistoryData;
  vDate: TDate;
  vOpen, vHigh, vLow, vClose: Double;
  vPrevDecSep: Char;
  function mStrToDate(const AStr: string): TDate;
  var
    vYear, vMon, vDay: Word;
  begin
    vYear := StrToInt(Copy(AStr, 0, 4));
    vMon := StrToInt(Copy(AStr, 5, 2));
    vDay := StrToInt(Copy(AStr, 7, 2));
    Result := EncodeDate(vYear, vMon, vDay);
  end;
begin
  vSplit := TStringList.Create;
  vSplit.Delimiter := ',';
  vPrevDecSep := FormatSettings.DecimalSeparator;
  FormatSettings.DecimalSeparator := '.';
  try
    for i := 0 to AStrings.Count - 1 do
    begin
      vSplit.DelimitedText := AStrings[i];
      if vSplit.Count = 0 then Continue;
      vDate := mStrToDate(vSplit[2]);
      vOpen := StrToFloat(vSplit[4]);
      vHigh := StrToFloat(vSplit[5]);
      vLow := StrToFloat(vSplit[6]);
      vClose := StrToFloat(vSplit[7]);
      vHD := THistoryData.Create(vDate, vOpen, vHigh, vLow, vClose);
      FItems.Add(vHD);
    end;
  finally
    FormatSettings.DecimalSeparator := vPrevDecSep;
    vSplit.Free;
  end;
end;

function THistory.Max(const ABegin, AEnd: TDateTime): THistoryData;
var
  i: Integer;
begin
  Result := FEmpty;
  for i := 0 to FItems.Count - 1 do
    if (Items[i].VDate >= ABegin) and (Items[i].VDate <= AEnd) and (Items[i].Close > Result.Close) then
      Result := Items[i];
end;

function THistory.Min(const ABegin, AEnd: TDateTime): THistoryData;
var
  i: Integer;
begin
  FEmpty.FClose := MaxInt;
  Result := FEmpty;
  for i := 0 to FItems.Count - 1 do
    if (Items[i].VDate >= ABegin) and (Items[i].VDate <= AEnd) and (Items[i].Close < Result.Close) then
      Result := Items[i];
  FEmpty.FClose := 0;
end;

class function THistory.Period(const AType: THistoryType): TDateTime;
begin
  Result := 0;
  case AType of
    htHour: Result := 1/24;
    htDay: Result := 1;
    htWeek: Result := 7;
    htMonth: Result := 30;
    htYear: Result := 365;
  end;
end;

const
  TextHistoryType: array[THistoryType] of string = ('Hour', 'Day', 'Week', 'Month', 'Year');

class function THistory.ToText(const AType: THistoryType): string;
begin
  Result := TextHistoryType[AType];
end;

end.
