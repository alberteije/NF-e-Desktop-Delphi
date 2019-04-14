{*******************************************************************************
Title: T2Ti ERP                                                                 
Description:  VO  relacionado à tabela [PESSOA] 
                                                                                
The MIT License                                                                 
                                                                                
Copyright: Copyright (C) 2010 T2Ti.COM                                          
                                                                                
Permission is hereby granted, free of charge, to any person                     
obtaining a copy of this software and associated documentation                  
files (the "Software"), to deal in the Software without                         
restriction, including without limitation the rights to use,                    
copy, modify, merge, publish, distribute, sublicense, and/or sell               
copies of the Software, and to permit persons to whom the                       
Software is furnished to do so, subject to the following                        
conditions:                                                                     
                                                                                
The above copyright notice and this permission notice shall be                  
included in all copies or substantial portions of the Software.                 
                                                                                
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,                 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES                 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND                        
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT                     
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,                    
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING                    
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR                   
OTHER DEALINGS IN THE SOFTWARE.                                                 
                                                                                
       The author may be contacted at:                                          
           t2ti.com@gmail.com</p>                                               
                                                                                
@author Fernando Lúcio Oliveira (fsystem.br@gmail.com)                    
@version 1.0                                                                    
*******************************************************************************}
unit PessoaVO;

interface

uses
  JsonVO, Atributos;

type
  [TEntity]
  [TTable('PESSOA')]
  TPessoaVO = class(TJsonVO)
  private
    FID: Integer;
    FNOME: String;
    FTIPO: String;
    FEMAIL: String;
    FSITE: String;
    FCLIENTE: String;
    FFORNECEDOR: String;
    FCOLABORADOR: String;
    FCONVENIO: String;
    FCONTADOR: String;
    FTRANSPORTADORA: String;

  public 
    [TId('ID')]
    [TGeneratedValue(sAuto)]
    property Id: Integer  read FID write FID;
    [TColumn('NOME','Nome',450,[ldGrid, ldLookup], False)]
    property Nome: String  read FNOME write FNOME;
    [TColumn('TIPO','Tipo',32,[ldGrid, ldLookup], False)]
    property Tipo: String  read FTIPO write FTIPO;
    [TColumn('EMAIL','Email',450,[ldGrid, ldLookup], False)]
    property Email: String  read FEMAIL write FEMAIL;
    [TColumn('SITE','Site',450,[ldGrid, ldLookup], False)]
    property Site: String  read FSITE write FSITE;
    [TColumn('CLIENTE','Cliente',32,[ldGrid, ldLookup], False)]
    property Cliente: String  read FCLIENTE write FCLIENTE;
    [TColumn('FORNECEDOR','Fornecedor',32,[ldGrid, ldLookup], False)]
    property Fornecedor: String  read FFORNECEDOR write FFORNECEDOR;
    [TColumn('COLABORADOR','Colaborador',32,[ldGrid, ldLookup], False)]
    property Colaborador: String  read FCOLABORADOR write FCOLABORADOR;
    [TColumn('CONVENIO','Convenio',32,[ldGrid, ldLookup], False)]
    property Convenio: String  read FCONVENIO write FCONVENIO;
    [TColumn('CONTADOR','Contador',32,[ldGrid, ldLookup], False)]
    property Contador: String  read FCONTADOR write FCONTADOR;
    [TColumn('TRANSPORTADORA','Transportadora',32,[ldGrid, ldLookup], False)]
    property Transportadora: String  read FTRANSPORTADORA write FTRANSPORTADORA;

  end;

implementation



end.
