object Form1: TForm1
  Left = 392
  Top = 367
  Width = 654
  Height = 378
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 16
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Gravar'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 104
    Top = 304
    Width = 75
    Height = 25
    Caption = 'Ler'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 16
    Top = 16
    Width = 625
    Height = 273
    TabOrder = 2
  end
  object XMLDocument1: TXMLDocument
    Left = 248
    Top = 296
    DOMVendorDesc = 'MSXML'
  end
end
