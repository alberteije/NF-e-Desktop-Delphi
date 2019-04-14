object Form1: TForm1
  Left = 470
  Top = 336
  Width = 367
  Height = 279
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
  object Memo1: TMemo
    Left = 32
    Top = 56
    Width = 297
    Height = 161
    TabOrder = 0
  end
  object Edit1: TEdit
    Left = 32
    Top = 24
    Width = 121
    Height = 21
    TabOrder = 1
  end
  object CEP: TButton
    Left = 168
    Top = 24
    Width = 75
    Height = 25
    Caption = 'CEP'
    TabOrder = 2
    OnClick = CEPClick
  end
  object HTTPRIO1: THTTPRIO
    WSDLLocation = 'http://www.byjg.com.br/site/webservice.php/ws/cep?WSDL'
    Service = 'CEPService'
    Port = 'CEPServicePort'
    HTTPWebNode.Agent = 'Borland SOAP 1.2'
    HTTPWebNode.UseUTF8InHeader = False
    HTTPWebNode.InvokeOptions = [soIgnoreInvalidCerts, soAutoCheckAccessPointViaUDDI]
    Converter.Options = [soSendMultiRefObj, soTryAllSchema, soRootRefNodesToBody, soCacheMimeResponse, soUTF8EncodeXML]
    Left = 176
    Top = 88
  end
end
