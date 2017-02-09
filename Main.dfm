object MainForm: TMainForm
  Left = 237
  Top = 116
  BorderStyle = bsDialog
  Caption = 'Omni-Rig Settings'
  ClientHeight = 355
  ClientWidth = 411
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000000000000000000000000000000000007777000000000000000000
    0000000777777777700000000000000000000077777777777700000000000000
    0000077777777777777000000000000000007777777777777777000000000000
    0000777777777777777700000000000000007777777777777777000000000000
    0007777777777777777770000000000000077777777777777777700000000000
    0007777777777777777770000000000000877777777777777777780000000000
    8878777777777799977777880000000877887777777777999777887780000887
    888877777777779997778888788008F8888887777777777777788888878008F8
    888888777777777777888888878008F88FAFAFA7777777777FAFAFA8878008F8
    8AFAFAFAFA7777FAFAFAFAF8878008F88FAFAFAFAFAFAFAFAFAFAFA8878008F8
    8AFAF8FAFAFA8AFAFA8AFAF8878008F88FAFA8AFAFAF8FAFAF8FAFA8878008F8
    8AFAF8FAFAFA8AFAFA8AFAF8878008F88FAFAFAFAFAFAFAFAFAFAFA8878008F8
    8AFAFAFAFAFAFAFAFAFAFAF8878008F8888888888888888888888888878008F8
    888888888888888888888888878008FFFFFFFFFFFFFFFFFFFFFFFFFFFF800888
    888888888888888888888888888000000000000000000000000000000000FFFF
    FFFFFFFFFFFFFFFFFFFFFFFC3FFFFFE007FFFFC003FFFF8001FFFF0000FFFF00
    00FFFF0000FFFE00007FFE00007FFE00007FFC00003FF000000FE00000078000
    0001800000018000000180000001800000018000000180000001800000018000
    0001800000018000000180000001800000018000000180000001FFFFFFFF}
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHide = FormHide
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 322
    Width = 411
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object OkBtn: TButton
      Left = 249
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      OnClick = OkBtnClick
    end
    object CancelBtn: TButton
      Left = 329
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = CancelBtnClick
    end
  end
  object TabControl1: TTabControl
    Left = 0
    Top = 0
    Width = 411
    Height = 322
    Align = alClient
    TabOrder = 1
    Tabs.Strings = (
      'RIG 1'
      'RIG 2'
      'About')
    TabIndex = 0
    OnChange = TabControl1Change
    OnChanging = TabControl1Changing
    object Panel2: TPanel
      Left = 4
      Top = 24
      Width = 206
      Height = 294
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object Label1: TLabel
        Left = 14
        Top = 43
        Width = 19
        Height = 13
        Caption = 'Port'
        FocusControl = PortComboBox
      end
      object Label2: TLabel
        Left = 14
        Top = 71
        Width = 46
        Height = 13
        Caption = 'Baud rate'
        FocusControl = BaudRateComboBox
      end
      object Label3: TLabel
        Left = 14
        Top = 99
        Width = 42
        Height = 13
        Caption = 'Data bits'
        FocusControl = DataBitsComboBox
      end
      object Label4: TLabel
        Left = 14
        Top = 127
        Width = 26
        Height = 13
        Caption = 'Parity'
        FocusControl = ParityComboBox
      end
      object Label5: TLabel
        Left = 14
        Top = 155
        Width = 41
        Height = 13
        Caption = 'Stop bits'
        FocusControl = StopBitsComboBox
      end
      object Label6: TLabel
        Left = 14
        Top = 182
        Width = 22
        Height = 13
        Caption = 'RTS'
        FocusControl = RtsComboBox
      end
      object Label10: TLabel
        Left = 14
        Top = 15
        Width = 39
        Height = 13
        Caption = 'Rig type'
        FocusControl = RigComboBox
      end
      object Label12: TLabel
        Left = 14
        Top = 238
        Width = 53
        Height = 13
        Caption = 'Poll int., ms'
      end
      object Label14: TLabel
        Left = 14
        Top = 267
        Width = 57
        Height = 13
        Caption = 'Timeout, ms'
      end
      object Label11: TLabel
        Left = 14
        Top = 210
        Width = 23
        Height = 13
        Caption = 'DTR'
        FocusControl = DtrComboBox
      end
      object PortComboBox: TComboBox
        Left = 82
        Top = 39
        Width = 103
        Height = 21
        Style = csDropDownList
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'COM 1'
          'COM 2'
          'COM 3'
          'COM 4'
          'COM 5'
          'COM 6'
          'COM 7'
          'COM 8'
          'COM 9'
          'COM 10'
          'COM 11'
          'COM 12'
          'COM 13'
          'COM 14'
          'COM 15'
          'COM 16'
          'COM 17'
          'COM 18'
          'COM 19'
          'COM 20'
          '')
      end
      object BaudRateComboBox: TComboBox
        Left = 82
        Top = 67
        Width = 103
        Height = 21
        Style = csDropDownList
        DropDownCount = 19
        ItemHeight = 13
        TabOrder = 1
      end
      object DataBitsComboBox: TComboBox
        Left = 82
        Top = 95
        Width = 103
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
        Items.Strings = (
          '5'
          '6'
          '7'
          '8')
      end
      object ParityComboBox: TComboBox
        Left = 82
        Top = 123
        Width = 103
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        Items.Strings = (
          'None'
          'Odd'
          'Even'
          'Mark'
          'Space')
      end
      object StopBitsComboBox: TComboBox
        Left = 82
        Top = 151
        Width = 103
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        Items.Strings = (
          '1'
          '1.5'
          '2')
      end
      object RtsComboBox: TComboBox
        Left = 82
        Top = 179
        Width = 103
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        Items.Strings = (
          'Low'
          'High'
          'Handshake')
      end
      object RigComboBox: TComboBox
        Left = 82
        Top = 11
        Width = 103
        Height = 21
        Style = csDropDownList
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 6
        Items.Strings = (
          'Yes'
          'No')
      end
      object PollSpinEdit: TSpinEdit
        Left = 82
        Top = 235
        Width = 103
        Height = 22
        MaxLength = 4
        MaxValue = 2000
        MinValue = 100
        TabOrder = 7
        Value = 100
      end
      object TimeoutSpinEdit: TSpinEdit
        Left = 82
        Top = 265
        Width = 103
        Height = 22
        MaxLength = 4
        MaxValue = 4000
        MinValue = 100
        TabOrder = 8
        Value = 100
      end
      object DtrComboBox: TComboBox
        Left = 82
        Top = 207
        Width = 103
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 9
        Items.Strings = (
          'Low'
          'High')
      end
    end
    object Panel3: TPanel
      Left = 210
      Top = 24
      Width = 197
      Height = 294
      Align = alClient
      BevelOuter = bvLowered
      TabOrder = 1
      Visible = False
      object Label8: TLabel
        Left = 69
        Top = 31
        Width = 109
        Height = 28
        Caption = 'Omni-Rig'
        Font.Charset = ANSI_CHARSET
        Font.Color = clAqua
        Font.Height = -25
        Font.Name = 'Arial'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        Transparent = True
      end
      object Image1: TImage
        Left = 21
        Top = 28
        Width = 32
        Height = 32
        AutoSize = True
        Picture.Data = {
          055449636F6E0000010001002020100000000000E80200001600000028000000
          2000000040000000010004000000000080020000000000000000000000000000
          0000000000000000000080000080000000808000800000008000800080800000
          80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
          FFFFFF0000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000007777000000
          0000000000000000000777777777700000000000000000000077777777777700
          0000000000000000077777777777777000000000000000007777777777777777
          0000000000000000777777777777777700000000000000007777777777777777
          0000000000000007777777777777777770000000000000077777777777777777
          7000000000000007777777777777777770000000000000877777777777777777
          7800000000008878777777777799977777880000000877887777777777999777
          887780000887888877777777779997778888788008F888888777777777777778
          8888878008F8888888777777777777888888878008F88FAFAFA7777777777FAF
          AFA8878008F88AFAFAFAFA7777FAFAFAFAF8878008F88FAFAFAFAFAFAFAFAFAF
          AFA8878008F88AFAF8FAFAFA8AFAFA8AFAF8878008F88FAFA8AFAFAF8FAFAF8F
          AFA8878008F88AFAF8FAFAFA8AFAFA8AFAF8878008F88FAFAFAFAFAFAFAFAFAF
          AFA8878008F88AFAFAFAFAFAFAFAFAFAFAF8878008F888888888888888888888
          8888878008F8888888888888888888888888878008FFFFFFFFFFFFFFFFFFFFFF
          FFFFFF8008888888888888888888888888888880000000000000000000000000
          00000000FFFFFFFFFFFFFFFFFFFFFFFFFFFC3FFFFFE007FFFFC003FFFF8001FF
          FF0000FFFF0000FFFF0000FFFE00007FFE00007FFE00007FFC00003FF000000F
          E000000780000001800000018000000180000001800000018000000180000001
          8000000180000001800000018000000180000001800000018000000180000001
          FFFFFFFF}
        Transparent = True
      end
      object Label7: TLabel
        Left = 67
        Top = 29
        Width = 109
        Height = 28
        Caption = 'Omni-Rig'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlue
        Font.Height = -25
        Font.Name = 'Arial'
        Font.Style = [fsBold, fsItalic]
        ParentFont = False
        Transparent = True
      end
      object Label9: TLabel
        Left = 72
        Top = 64
        Width = 59
        Height = 13
        Caption = 'Version 0.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label13: TLabel
        Left = 56
        Top = 124
        Width = 84
        Height = 16
        Caption = ' FREEWARE '
        Color = clGreen
        Font.Charset = ANSI_CHARSET
        Font.Color = clGreen
        Font.Height = -13
        Font.Name = 'Arial'
        Font.Style = [fsBold, fsItalic]
        ParentColor = False
        ParentFont = False
        Transparent = True
      end
      object Label15: TLabel
        Left = 8
        Top = 272
        Width = 184
        Height = 13
        Cursor = crHandPoint
        Anchors = [akLeft, akBottom]
        Caption = 'www.dxatlas.com/omnirig'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Courier'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = Label15Click
      end
      object Label16: TLabel
        Left = 41
        Top = 156
        Width = 110
        Height = 13
        Caption = 'Copyright © 2003-2014'
      end
      object Label17: TLabel
        Left = 26
        Top = 209
        Width = 144
        Height = 13
        Cursor = crHandPoint
        Anchors = [akLeft, akBottom]
        Caption = 've3nea@dxatlas.com'
        Font.Charset = ANSI_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Courier'
        Font.Style = [fsUnderline]
        ParentFont = False
        OnClick = Label17Click
      end
      object Label18: TLabel
        Left = 32
        Top = 172
        Width = 132
        Height = 13
        Caption = 'Alex Shovkoplyas, VE3NEA'
      end
    end
  end
  object ApplicationEvents1: TApplicationEvents
    OnMessage = ApplicationEvents1Message
    Left = 104
    Top = 4
  end
  object Timer1: TTimer
    Interval = 100
    OnTimer = Timer1Timer
    Left = 132
    Top = 4
  end
end
