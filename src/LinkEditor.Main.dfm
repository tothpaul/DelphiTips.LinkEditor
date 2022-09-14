object Main: TMain
  Left = 0
  Top = 0
  Caption = 'LinkEditor'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    ParentBackground = False
    ParentColor = True
    ShowCaption = False
    TabOrder = 0
    ExplicitLeft = 232
    ExplicitTop = 224
    ExplicitWidth = 185
    object btNewTable: TButton
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 75
      Height = 33
      Align = alLeft
      Caption = 'New Table'
      TabOrder = 0
      OnClick = btNewTableClick
      ExplicitLeft = 272
      ExplicitTop = 8
      ExplicitHeight = 25
    end
    object btNewField: TButton
      AlignWithMargins = True
      Left = 85
      Top = 4
      Width = 75
      Height = 33
      Align = alLeft
      Caption = 'New Field'
      Enabled = False
      TabOrder = 1
      OnClick = btNewFieldClick
      ExplicitLeft = 156
      ExplicitTop = 5
    end
  end
  inline Designer: TDesigner
    Left = 0
    Top = 41
    Width = 624
    Height = 400
    Align = alClient
    AutoScroll = True
    TabOrder = 1
    ExplicitLeft = -16
    ExplicitTop = -39
  end
end
