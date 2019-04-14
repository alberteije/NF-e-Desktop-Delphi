unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBClient, StdCtrls, XMLDoc, XMLIntf, xmldom, msxmldom;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Memo1: TMemo;
    XMLDocument1: TXMLDocument;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
	xmlDoc: TXMLDocument;
    NodeNivelA, NodeNivelB, NodeNivelC, NodeNivelD: IXMLNode;
    nItens : integer;
begin

  xmlDoc := TXMLDocument.Create(self);
  Try
  With xmlDoc do begin
       Active := True;
       Version := '1.0';
       Encoding := 'utf-8';
       AddChild('NFe','http://www.portalfiscal.inf.br/nfe');

		//A - Dados da Nota Fiscal eletrônica (infNFe)
       NodeNivelA := DocumentElement;

       //Adiciona a Tag
       NodeNivelA.AddChild('infNFe');
       //Adiciona atributo "Id" da Tag infNFe
       NodeNivelA.ChildNodes['infNFe'].Attributes['Id'] := 'NFe35080599999090910270550010000000015180051273';
       //Adiciona atributo "versao" da Tag infNFe
       NodeNivelA.ChildNodes['infNFe'].Attributes['versao'] := '1.10';

		 //B - Identificação da Nota Fiscal eletrônica (ide)
       NodeNivelB := NodeNivelA.ChildNodes['infNFe'];

       NodeNivelB.ChildNodes['ide'].AddChild('cUF').NodeValue := '35' ;
       NodeNivelB.ChildNodes['ide'].AddChild('cNF').NodeValue := '518005127';
       NodeNivelB.ChildNodes['ide'].AddChild('natOp').NodeValue := 'Venda a vista';
       NodeNivelB.ChildNodes['ide'].AddChild('mod').NodeValue := '55';
       NodeNivelB.ChildNodes['ide'].AddChild('serie').NodeValue := '1';
       NodeNivelB.ChildNodes['ide'].AddChild('dEmi').NodeValue := '2008-05-06';
       NodeNivelB.ChildNodes['ide'].AddChild('cMunFG').NodeValue := '3550308';

		 //C - Identificação do Emitente da Nota Fiscal eletrônica (emit)
       //insira os dados necessários

  		 //H - Detalhamento de Produtos e Serviços da NF-e

       For nItens := 1 to 2 do begin
         //Tag <det>
         NodeNivelC := NodeNivelB.AddChild('det');
         NodeNivelB.ChildNodes.Last.Attributes['nitem'] := IntToStr(nItens);

         //Tag <prod>
         NodeNivelD := NodeNivelC.ChildNodes['prod'];
         NodeNivelD.AddChild('cProd').Nodevalue := IntToStr(nItens)+'121231111';
         NodeNivelD.AddChild('cEan').Nodevalue := '1111111111111';
         NodeNivelD.AddChild('xProd').Nodevalue := 'PRODUTO DE TESTE';
         NodeNivelD.AddChild('CFOP').Nodevalue := '6102';
       end;

       xmlDoc.SaveToFile('c:\TesteNFe.xml');
  end;
  finally
     xmlDoc.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
xmlDoc: TXMLDocument;
    NodeInfNFe, NodeIde: IXMLNode;
    cUf,cNF,natOp,mode,serie,dEmi,cMunFG : WideString;
begin
  xmlDoc := TXMLDocument.Create(self);
  //abre o arquivo TesteNFe.xml para leitura
  xmlDoc.LoadFromFile('TesteNFe.xml');

  //os dados serão lidos e inseridos num Memo
  Memo1.lines.Add( '-------------------------------------------------');
  Memo1.lines.Add( xmlDoc.XML.Text +#13+#13 );

  //vamos pegar os dados da tag <ide>
  NodeInfNFe := xmlDoc.DocumentElement.ChildNodes.FindNode('infNFe');
  NodeIde := NodeInfNFe.ChildNodes.FindNode('ide');

  cUf := NodeIde.ChildNodes['cUF'].text;
  cNF := NodeIde.ChildNodes['cNF'].text;
  natOp := NodeIde.ChildNodes['natOp'].text;
  mode := NodeIde.ChildNodes['mod'].text;
  serie := NodeIde.ChildNodes['serie'].text;
  dEmi := NodeIde.ChildNodes['dEmi'].text;
  cMunFG := NodeIde.ChildNodes['cMunFG'].text;

  // adiciona os dados no Memo (apenas exemplo)
  Memo1.Lines.Add('-----------------------------------------------');
  Memo1.Lines.Add( 'Código da UF      = ' + cUf );
  Memo1.Lines.Add( 'Código da Chave   = ' + cNF );
  Memo1.Lines.Add( 'Natureza Operação = ' + natOp );
  Memo1.Lines.Add( 'Modelo Documento  = ' + mode );
  Memo1.Lines.Add( 'Série Documento   = ' + serie );
  Memo1.Lines.Add( 'Data de Emissão   = ' + dEmi );
  Memo1.Lines.Add( 'Código Municipio  = ' + cMunFG );
  Memo1.Lines.Add('-----------------------------------------------');

end;

end.
