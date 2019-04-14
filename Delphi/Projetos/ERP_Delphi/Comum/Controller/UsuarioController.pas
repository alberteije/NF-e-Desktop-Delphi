{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [USUARIO] 
                                                                                
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
                                                                                
fabio_thz@yahoo.com.br | t2ti.com@gmail.com | fernandololiver@gmail.com
@author @author Fábio Thomaz | Albert Eije (T2Ti.COM) | Fernando L Oliveira
@version 1.0                                                                    
*******************************************************************************}
unit UsuarioController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB, Biblioteca,
  Windows, Forms, Controller, Rtti, Atributos, UsuarioVO, Generics.Collections;

type
  TUsuarioController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class function Usuario(pLogin, pSenha: string): TUsuarioVO; overload;
    class procedure Consulta(pFiltro: String; pPagina: Integer);
    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
    class function CriptografarLoginSenha(pLogin, pSenha: string): string;
  end;

implementation

uses UDataModule, Conversor, T2TiORM;

class procedure TUsuarioController.Consulta(pFiltro: String; pPagina: Integer);
var
  Retorno: TObjectList<TUsuarioVO>;
begin
  try
    try
      if Pos('ID=', pFiltro) > 0 then
        Retorno := TT2TiORM.Consultar<TUsuarioVO>(pFiltro, True, pPagina)
      else
        Retorno := TT2TiORM.Consultar<TUsuarioVO>(pFiltro, False, pPagina);
      if Assigned(Retorno) then
        PopulaGrid<TUsuarioVO>(Retorno);
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TUsuarioController.Usuario(pLogin, pSenha: string): TUsuarioVO;
var
  Filtro: string;
begin
  Result := nil;
  try
    try
      Filtro := 'LOGIN = '+QuotedStr(pLogin)+' AND SENHA = '+QuotedStr(CriptografarLoginSenha(pLogin,pSenha));
      Result := TT2TiORM.ConsultarUmObjeto<TUsuarioVO>(Filtro, True)
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TUsuarioController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TUsuarioController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

class function TUsuarioController.CriptografarLoginSenha(pLogin, pSenha: string): string;
begin
  Result := MD5String(pLogin+pSenha);
end;

end.

