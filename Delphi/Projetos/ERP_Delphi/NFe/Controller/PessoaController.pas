{ *******************************************************************************
  Title: T2Ti ERP
  Description: Controller do lado Cliente relacionado à tabela [PESSOA]

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

  @author Albert Eije (t2ti.com@gmail.com)
  @version 1.0
  ******************************************************************************* }
unit PessoaController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB,  Windows, Forms, Controller, Rtti, Atributos,
  PessoaVO, Generics.Collections;

type
  TPessoaController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class procedure Consulta(pFiltro: String; pPagina: Integer);
    class function Insere(pPessoa: TPessoaVO): Boolean;
    class function Altera(pPessoa, pPessoaOld: TPessoaVO): Boolean;
    class function Exclui(pId: Integer): Boolean;
    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
  end;

implementation

uses UDataModule, T2TiORM,
     PessoaFisicaVO, PessoaJuridicaVO, ContatoVO, EnderecoVO;

class procedure TPessoaController.Consulta(pFiltro: String; pPagina: Integer);
var
  Retorno: TObjectList<TPessoaVO>;
  i: Integer;
begin
  try
    try
      if Pos('ID=', pFiltro) > 0 then
        Retorno := TT2TiORM.Consultar<TPessoaVO>(pFiltro, True, pPagina)
      else
        Retorno := TT2TiORM.Consultar<TPessoaVO>(pFiltro, False, pPagina);
      if Assigned(Retorno) then
        PopulaGrid<TPessoaVO>(Retorno);
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TPessoaController.Insere(pPessoa: TPessoaVO): Boolean;
var
  UltimoID:Integer;
  Contato: TContatoVO;
  Endereco: TEnderecoVO;
  ContatosEnumerator: TEnumerator<TContatoVO>;
  EnderecosEnumerator: TEnumerator<TEnderecoVO>;
  TipoPessoa: string;
begin
  Result := False;
  try
    try
      TipoPessoa := pPessoa.Tipo;
      UltimoID := TT2TiORM.Inserir(pPessoa);

      // Tipo de Pessoa
      if (TipoPessoa = 'F') and (Assigned(pPessoa.PessoaFisicaVO)) then
      begin
        pPessoa.PessoaFisicaVO.IdPessoa := UltimoID;
        TT2TiORM.Inserir(pPessoa.PessoaFisicaVO);
      end
      else if (TipoPessoa = 'J') and (Assigned(pPessoa.PessoaJuridicaVO)) then
      begin
        pPessoa.PessoaJuridicaVO.IdPessoa := UltimoID;
        TT2TiORM.Inserir(pPessoa.PessoaJuridicaVO);
      end;

      // Contatos
      ContatosEnumerator := pPessoa.ListaContatoVO.GetEnumerator;
      try
        with ContatosEnumerator do
        begin
          while MoveNext do
          begin
            Contato := Current;
            Contato.IdPessoa := UltimoID;
            TT2TiORM.Inserir(Contato);
          end;
        end;
      finally
        ContatosEnumerator.Free;
      end;

      // Endereços
      EnderecosEnumerator := pPessoa.ListaEnderecoVO.GetEnumerator;
      try
        with EnderecosEnumerator do
        begin
          while MoveNext do
          begin
            Endereco := Current;
            Endereco.IdPessoa := UltimoID;
            TT2TiORM.Inserir(Endereco);
          end;
        end;
      finally
        EnderecosEnumerator.Free;
      end;

      Consulta('ID = ' + IntToStr(UltimoID), 0);
      Result := True;
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro na inclusão do registro. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TPessoaController.Altera(pPessoa, pPessoaOld: TPessoaVO): Boolean;
var
  ContatosEnumerator: TEnumerator<TContatoVO>;
  EnderecosEnumerator: TEnumerator<TEnderecoVO>;
  TipoPessoa: String;
begin
  try
    try
      Result := TT2TiORM.Alterar(pPessoa, pPessoaOld);

      TipoPessoa := pPessoa.Tipo;

      // Tipo de Pessoa
      try
        if (TipoPessoa = 'F') and (Assigned(pPessoa.PessoaFisicaVO)) then
        begin
          if pPessoa.PessoaFisicaVO.Id > 0 then
            Result := TT2TiORM.Alterar(pPessoa.PessoaFisicaVO, pPessoaOld.PessoaFisicaVO)
          else
            Result := TT2TiORM.Inserir(pPessoa.PessoaFisicaVO) > 0;
        end
        else if (TipoPessoa = 'J') and (Assigned(pPessoa.PessoaJuridicaVO)) then
        begin
          if pPessoa.PessoaJuridicaVO.Id > 0 then
            Result := TT2TiORM.Alterar(pPessoa.PessoaJuridicaVO, pPessoaOld.PessoaJuridicaVO)
          else
            Result := TT2TiORM.Inserir(pPessoa.PessoaJuridicaVO) > 0;
        end;
      finally
      end;

      // Contatos
      try
        ContatosEnumerator := pPessoa.ListaContatoVO.GetEnumerator;
        with ContatosEnumerator do
        begin
          while MoveNext do
          begin
            if Current.Id > 0 then
              Result := TT2TiORM.Alterar(Current)
            else
              Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      finally
      end;

      // Endereços
      try
        EnderecosEnumerator := pPessoa.ListaEnderecoVO.GetEnumerator;
        with EnderecosEnumerator do
        begin
          while MoveNext do
          begin
            if Current.Id > 0 then
              Result := TT2TiORM.Alterar(Current)
            else
              Result := TT2TiORM.Inserir(Current) > 0;
          end;
        end;
      finally
      end;

    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro na inclusão do registro. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TPessoaController.Exclui(pId: Integer): Boolean;
var
  pPessoa: TPessoaVO;
begin
  pPessoa := TPessoaVO.Create;
  try
    pPessoa.Id := pId;
    Result := TT2TiORM.Excluir(pPessoa);
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro na exclusão do registro. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TPessoaController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TPessoaController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

end.
