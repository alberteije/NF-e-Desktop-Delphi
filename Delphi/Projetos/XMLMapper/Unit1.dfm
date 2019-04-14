object Form1: TForm1
  Left = 576
  Top = 249
  Width = 561
  Height = 377
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
  object DBGrid1: TDBGrid
    Left = 96
    Top = 24
    Width = 441
    Height = 225
    DataSource = DataSource1
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object Button1: TButton
    Left = 240
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 1
    OnClick = Button1Click
  end
  object ClientDataSet1: TClientDataSet
    Active = True
    Aggregates = <>
    Params = <>
    ProviderName = 'XMLTransformProvider1'
    Left = 32
    Top = 40
  end
  object DataSource1: TDataSource
    DataSet = ClientDataSet1
    Left = 32
    Top = 96
  end
  object XMLTransformProvider1: TXMLTransformProvider
    TransformRead.TransformationFile = 'E:\Backup Geral\Projetos\Livros\NFe\delphi\ToDp.xtr'
    TransformWrite.TransformationFile = 'E:\Backup Geral\Projetos\Livros\NFe\delphi\ToXml.xtr'
    XMLDataFile = 'E:\Backup Geral\Projetos\Livros\NFe\delphi\NFe.xml'
    Left = 64
    Top = 272
  end
end
