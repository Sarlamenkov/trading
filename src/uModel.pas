unit uModel;

interface

uses
  Classes;

type
  THistoryData = class
  private
    FValue: Double;
    FVDate: TDateTime;
  public
    constructor Create(const ADate: TDateTime; const AValue: Double);
    destructor Destroy; override;

    property VDate: TDateTime read FVDate;
    property Value: Double read FValue;
  end;

  TInstrument = class;
  THistoryType = (htHour, htDay, htMonth);

  THistory = class
  private
    FType: THistoryType;
    FOwner: TInstrument;
    FItems: TList;
    function GetData(const AIndex: Integer): THistoryData;
    function GetCount: Integer;
  public
    class function HistoryTypeByText(const AText: string): THistoryType;

    constructor Create(const AOwner: TInstrument; const AHistotyType: THistoryType);
    destructor Destroy; override;

    procedure LoadFromFile(const AFileName: string);
    procedure LoadFromStrings(const AStrings: TStrings);

    property Items[const AIndex: Integer]: THistoryData read GetData; default;
    property Count: Integer read GetCount;
    property HistoryType: THistoryType read FType;
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
    FRebalancePeriod: Integer;
    FEndBalance: Integer;
    procedure SetRebalancePeriod(const Value: Integer);
    procedure SetStartBalance(const Value: Integer);
  public
    procedure Calc;

    property StartBalance: Integer read FStartBalance write SetStartBalance; // some currency
    property EndBalance: Integer read FEndBalance;
    property RebalancePeriod: Integer read FRebalancePeriod write SetRebalancePeriod; // in hours
  end;

implementation

uses
  SysUtils, StrUtils, DateUtils;

{ TMarkovic }

procedure TMarkovic.Calc;
begin

end;

procedure TMarkovic.SetRebalancePeriod(const Value: Integer);
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

constructor THistoryData.Create(const ADate: TDateTime; const AValue: Double);
begin
  FValue := AValue;
  FVDate := ADate;
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

{ THistory }

constructor THistory.Create(const AOwner: TInstrument; const AHistotyType: THistoryType);
begin
  FItems := TList.Create;
  FOwner := AOwner;
  FType := AHistotyType;
end;

destructor THistory.Destroy;
begin
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
  vRate: Double;
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
      vDate := mStrToDate(vSplit[2]);
      vRate := StrToFloat(vSplit[4]);
      vHD := THistoryData.Create(vDate, vRate);
      FItems.Add(vHD);
    end;
  finally
    FormatSettings.DecimalSeparator := vPrevDecSep;
    vSplit.Free;
  end;
end;

end.
