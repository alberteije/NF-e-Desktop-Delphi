object Form1: TForm1
  Left = 405
  Top = 262
  Width = 564
  Height = 397
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
  object Image1: TImage
    Left = 288
    Top = 16
    Width = 250
    Height = 250
    Stretch = True
  end
  object BotaoBaixarTexto: TButton
    Left = 16
    Top = 280
    Width = 100
    Height = 25
    Caption = 'Baixar Texto'
    TabOrder = 0
    OnClick = BotaoBaixarTextoClick
  end
  object BotaoBaixarImagem: TButton
    Left = 288
    Top = 280
    Width = 100
    Height = 25
    Caption = 'Baixar Imagem'
    TabOrder = 1
    OnClick = BotaoBaixarImagemClick
  end
  object BotaoBaixarArquivo: TButton
    Left = 16
    Top = 320
    Width = 100
    Height = 25
    Caption = 'Baixar Arquivo'
    TabOrder = 2
    OnClick = BotaoBaixarArquivoClick
  end
  object Memo1: TMemo
    Left = 16
    Top = 16
    Width = 250
    Height = 250
    TabOrder = 3
  end
end
