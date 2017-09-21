object MainFm: TMainFm
  Left = 0
  Top = 0
  Caption = #1052#1072#1088#1082#1086#1074#1080#1094
  ClientHeight = 547
  ClientWidth = 908
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  DesignSize = (
    908
    547)
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 280
    Top = 16
    Width = 128
    Height = 16
    Caption = #1055#1077#1088#1080#1086#1076' '#1090#1077#1089#1090#1080#1088#1086#1074#1072#1085#1080#1103
  end
  object Label2: TLabel
    Left = 721
    Top = 18
    Width = 109
    Height = 16
    Caption = #1055#1077#1088#1080#1086#1076' '#1088#1077#1073#1072#1083#1072#1085#1089#1072
  end
  object lblResult: TLabel
    Left = 280
    Top = 176
    Width = 5
    Height = 19
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label4: TLabel
    Left = 575
    Top = 18
    Width = 111
    Height = 16
    Caption = #1053#1072#1095#1072#1083#1100#1085#1099#1081' '#1073#1072#1083#1072#1085#1089
  end
  object lblInstrums: TLabel
    Left = 16
    Top = 16
    Width = 77
    Height = 16
    Caption = #1048#1085#1089#1090#1088#1091#1084#1077#1085#1090#1099
  end
  object lblRealPeriod: TLabel
    Left = 280
    Top = 201
    Width = 4
    Height = 16
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblInstrumNames: TLabel
    Left = 280
    Top = 151
    Width = 5
    Height = 19
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 280
    Top = 248
    Width = 231
    Height = 16
    Caption = #1055#1086#1080#1089#1082' '#1083#1091#1095#1096#1080#1093' '#1089#1086#1095#1077#1090#1072#1085#1080#1081' '#1080#1085#1089#1090#1088#1091#1084#1077#1085#1090#1086#1074
  end
  object Label5: TLabel
    Left = 281
    Top = 80
    Width = 141
    Height = 16
    Caption = #1056#1072#1079#1085#1080#1094#1072' '#1074' '#1087#1086#1088#1090#1092#1077#1083#1077', %'
  end
  object Label6: TLabel
    Left = 428
    Top = 80
    Width = 108
    Height = 16
    Caption = #1056#1086#1089#1090' '#1087#1086#1088#1090#1092#1077#1083#1103', %'
  end
  object Label7: TLabel
    Left = 552
    Top = 80
    Width = 110
    Height = 16
    Caption = #1056#1086#1089#1090' '#1082#1086#1090#1080#1088#1086#1074#1082#1080', %'
  end
  object dtpStart: TDateTimePicker
    Left = 280
    Top = 40
    Width = 109
    Height = 24
    Date = 42894.723395069440000000
    Time = 42894.723395069440000000
    TabOrder = 0
  end
  object dtpEnd: TDateTimePicker
    Left = 416
    Top = 40
    Width = 129
    Height = 24
    Date = 42894.723569375000000000
    Time = 42894.723569375000000000
    TabOrder = 1
  end
  object TreeView1: TTreeView
    Left = 8
    Top = 40
    Width = 252
    Height = 499
    Anchors = [akLeft, akTop, akBottom]
    Indent = 19
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    SortType = stText
    TabOrder = 2
  end
  object btnStart: TButton
    Left = 768
    Top = 102
    Width = 123
    Height = 25
    Caption = #1055#1086#1089#1095#1080#1090#1072#1090#1100
    TabOrder = 3
    OnClick = btnStartClick
  end
  object cbxRebalance: TComboBox
    Left = 720
    Top = 40
    Width = 145
    Height = 24
    Style = csDropDownList
    TabOrder = 4
  end
  object edBalance: TEdit
    Left = 575
    Top = 40
    Width = 121
    Height = 24
    TabOrder = 5
    Text = '200000'
  end
  object lvBestResults: TListView
    Left = 280
    Top = 288
    Width = 620
    Height = 251
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Width = 500
      end>
    ReadOnly = True
    RowSelect = True
    SortType = stData
    TabOrder = 6
    ViewStyle = vsReport
    OnCompare = lvBestResultsCompare
  end
  object SpinEdit1: TSpinEdit
    Left = 561
    Top = 245
    Width = 48
    Height = 26
    MaxValue = 10
    MinValue = 2
    TabOrder = 7
    Value = 2
  end
  object btnSearch: TButton
    Left = 632
    Top = 245
    Width = 97
    Height = 25
    Caption = #1048#1089#1082#1072#1090#1100
    TabOrder = 8
    OnClick = btnSearchClick
  end
  object ProgressBar1: TProgressBar
    Left = 281
    Top = 274
    Width = 619
    Height = 10
    Anchors = [akLeft, akTop, akRight]
    Step = 1
    TabOrder = 9
    Visible = False
  end
  object btnStop: TButton
    Left = 735
    Top = 245
    Width = 75
    Height = 25
    Caption = #1057#1090#1086#1087
    TabOrder = 10
    Visible = False
    OnClick = btnStopClick
  end
  object btnSave: TButton
    Left = 816
    Top = 245
    Width = 75
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 11
    Visible = False
    OnClick = btnSaveClick
  end
  object seDiffAmount: TSpinEdit
    Left = 281
    Top = 102
    Width = 57
    Height = 26
    MaxValue = 99999
    MinValue = 0
    TabOrder = 12
    Value = 0
  end
  object sePortfolioGrow: TSpinEdit
    Left = 428
    Top = 102
    Width = 57
    Height = 26
    MaxValue = 99999
    MinValue = 0
    TabOrder = 13
    Value = 0
  end
  object seQuoteGrow: TSpinEdit
    Left = 552
    Top = 102
    Width = 57
    Height = 26
    MaxValue = 99999
    MinValue = 0
    TabOrder = 14
    Value = 0
  end
  object FileSaveDialog1: TFileSaveDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 800
    Top = 184
  end
end
