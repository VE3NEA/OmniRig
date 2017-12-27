object MainForm: TMainForm
  Left = 237
  Top = 116
  BorderStyle = bsDialog
  Caption = 'Omni-Rig 64 Settings'
  ClientHeight = 719
  ClientWidth = 438
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
  object Label20: TLabel
    Left = 40
    Top = 320
    Width = 49
    Height = 13
    Caption = 'LO Values'
  end
  object Panel1: TPanel
    Left = 0
    Top = 686
    Width = 438
    Height = 33
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      438
      33)
    object OkBtn: TButton
      Left = 276
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
      Left = 356
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
    Width = 530
    Height = 686
    Align = alLeft
    Anchors = [akLeft, akTop, akRight, akBottom]
    DockSite = True
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
      Height = 658
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
      object Label19: TLabel
        Left = 14
        Top = 329
        Width = 37
        Height = 13
        Caption = '50 MHz'
        FocusControl = RigComboBox
      end
      object Label21: TLabel
        Left = 46
        Top = 303
        Width = 123
        Height = 20
        Caption = 'LO Values (Hz)'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label22: TLabel
        Left = 14
        Top = 356
        Width = 43
        Height = 13
        Caption = '144 MHz'
        FocusControl = RigComboBox
      end
      object Label23: TLabel
        Left = 14
        Top = 385
        Width = 43
        Height = 13
        Caption = '222 MHz'
        FocusControl = RigComboBox
      end
      object Label24: TLabel
        Left = 14
        Top = 417
        Width = 43
        Height = 13
        Caption = '432 MHz'
        FocusControl = RigComboBox
      end
      object Label25: TLabel
        Left = 14
        Top = 449
        Width = 43
        Height = 13
        Caption = '903 MHz'
        FocusControl = RigComboBox
      end
      object Label26: TLabel
        Left = 14
        Top = 481
        Width = 49
        Height = 13
        Caption = '1296 MHz'
        FocusControl = RigComboBox
      end
      object Label27: TLabel
        Left = 14
        Top = 513
        Width = 30
        Height = 13
        Caption = '2 GHz'
        FocusControl = RigComboBox
      end
      object Label28: TLabel
        Left = 14
        Top = 545
        Width = 30
        Height = 13
        Caption = '3 GHz'
        FocusControl = RigComboBox
      end
      object Label29: TLabel
        Left = 14
        Top = 573
        Width = 30
        Height = 13
        Caption = '5 GHz'
        FocusControl = RigComboBox
      end
      object Label30: TLabel
        Left = 14
        Top = 601
        Width = 36
        Height = 13
        Caption = '10 GHz'
        FocusControl = RigComboBox
      end
      object Label31: TLabel
        Left = 14
        Top = 633
        Width = 36
        Height = 13
        Caption = '24 GHz'
        FocusControl = RigComboBox
      end
      object PortComboBox: TComboBox
        Left = 82
        Top = 39
        Width = 103
        Height = 21
        Style = csDropDownList
        DropDownCount = 16
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
        TabOrder = 1
      end
      object DataBitsComboBox: TComboBox
        Left = 82
        Top = 95
        Width = 103
        Height = 21
        Style = csDropDownList
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
        TabOrder = 9
        Items.Strings = (
          'Low'
          'High')
      end
      object Box144: TEdit
        Left = 79
        Top = 353
        Width = 106
        Height = 21
        TabOrder = 10
      end
      object Box222: TEdit
        Left = 79
        Top = 380
        Width = 106
        Height = 21
        TabOrder = 11
      end
      object Box432: TEdit
        Left = 79
        Top = 414
        Width = 106
        Height = 21
        TabOrder = 12
      end
      object Box903: TEdit
        Left = 79
        Top = 446
        Width = 106
        Height = 21
        TabOrder = 13
      end
      object Box1296: TEdit
        Left = 79
        Top = 478
        Width = 106
        Height = 21
        TabOrder = 14
      end
      object Box2G: TEdit
        Left = 79
        Top = 510
        Width = 106
        Height = 21
        TabOrder = 15
      end
      object Box3G: TEdit
        Left = 79
        Top = 542
        Width = 106
        Height = 21
        TabOrder = 16
      end
      object Box5G: TEdit
        Left = 79
        Top = 570
        Width = 106
        Height = 21
        TabOrder = 17
      end
      object Box10G: TEdit
        Left = 79
        Top = 598
        Width = 106
        Height = 21
        TabOrder = 18
      end
      object Box24G: TEdit
        Left = 79
        Top = 625
        Width = 106
        Height = 21
        TabOrder = 19
      end
      object Box50: TEdit
        Left = 79
        Top = 326
        Width = 106
        Height = 21
        TabOrder = 20
      end
    end
    object Panel3: TPanel
      Left = 210
      Top = 24
      Width = 316
      Height = 658
      Align = alClient
      BevelOuter = bvLowered
      UseDockManager = False
      DockSite = True
      TabOrder = 1
      Visible = False
      DesignSize = (
        316
        658)
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
        Width = 83
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
        Top = 636
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
        ExplicitTop = 272
      end
      object Label16: TLabel
        Left = 41
        Top = 156
        Width = 110
        Height = 13
        Caption = 'Copyright '#169' 2003-2014'
      end
      object Label17: TLabel
        Left = 26
        Top = 573
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
        ExplicitTop = 209
      end
      object Label18: TLabel
        Left = 32
        Top = 172
        Width = 132
        Height = 13
        Caption = 'Alex Shovkoplyas, VE3NEA'
      end
      object Label32: TLabel
        Left = 30
        Top = 210
        Width = 146
        Height = 13
        Caption = 'LO offsets and 64 bit by W3SZ'
        FocusControl = RigComboBox
      end
      object Label33: TLabel
        Left = 63
        Top = 229
        Width = 68
        Height = 20
        Caption = 'RF to IF'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label35: TLabel
        Left = 6
        Top = 282
        Width = 24
        Height = 20
        Caption = 'LO'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label36: TLabel
        Left = 6
        Top = 308
        Width = 18
        Height = 20
        Caption = 'IF'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label37: TLabel
        Left = 56
        Top = 351
        Width = 68
        Height = 20
        Caption = 'IF to RF'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label38: TLabel
        Left = 6
        Top = 378
        Width = 25
        Height = 20
        Caption = 'RF'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label39: TLabel
        Left = 6
        Top = 404
        Width = 24
        Height = 20
        Caption = 'LO'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label40: TLabel
        Left = 6
        Top = 430
        Width = 18
        Height = 20
        Caption = 'IF'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object Label41: TLabel
        Left = 6
        Top = 256
        Width = 25
        Height = 20
        Caption = 'RF'
        FocusControl = RigComboBox
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object RF2IF_LO: TEdit
        Left = 36
        Top = 282
        Width = 121
        Height = 21
        TabOrder = 0
      end
      object RF2IF_IF: TEdit
        Left = 36
        Top = 309
        Width = 121
        Height = 21
        TabOrder = 1
      end
      object IF2RF_RF: TEdit
        Left = 37
        Top = 377
        Width = 121
        Height = 21
        TabOrder = 2
      end
      object IF2RF_LO: TEdit
        Left = 37
        Top = 404
        Width = 121
        Height = 21
        TabOrder = 3
      end
      object IF2RF_IF: TEdit
        Left = 36
        Top = 431
        Width = 121
        Height = 21
        TabOrder = 4
      end
      object RF2IF_RF: TEdit
        Left = 37
        Top = 255
        Width = 121
        Height = 21
        TabOrder = 5
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
