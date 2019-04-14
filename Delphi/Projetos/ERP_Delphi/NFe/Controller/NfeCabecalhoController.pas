{*******************************************************************************
Title: T2Ti ERP                                                                 
Description: Controller do lado Cliente relacionado à tabela [NFE_CABECALHO] 
                                                                                
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
           t2ti.com@gmail.com                                                   
                                                                                
@author Albert Eije (t2ti.com@gmail.com)                    
@version 1.0                                                                    
*******************************************************************************}
unit NfeCabecalhoController;

interface

uses
  Classes, Dialogs, SysUtils, DBClient, DB,  Windows, Forms, Controller, Rtti,
  Atributos, NfeCabecalhoVO, Generics.Collections;


type
  TNfeCabecalhoController = class(TController)
  private
    class var FDataSet: TClientDataSet;
  public
    class procedure Consulta(pFiltro: String; pPagina: Integer); overload;
    class function Consulta(pFiltro: String): TNfeCabecalhoVO; overload;
    class function Insere(pNfeCabecalho: TNfeCabecalhoVO): Boolean;
    class function Altera(pNfeCabecalho, pNfeCabecalhoOld: TNfeCabecalhoVO): Boolean;
    class function Exclui(pId: Integer; pExcluirQuem: String; pIdProduto: Integer = 0; pQuantidade: Integer = 0): Boolean;
    class function GetDataSet: TClientDataSet; override;
    class procedure SetDataSet(pDataSet: TClientDataSet); override;
  end;

implementation

uses UDataModule, Conversor, T2TiORM,
    //
    NfeReferenciadaVO, NfeEmitenteVO, NfeLocalEntregaVO, NfeLocalRetiradaVO,
    NfeTransporteVO, NfeFaturaVO, NfeDuplicataVO, NfeDetalheVO, ProdutoLoteVO,
    NfeCupomFiscalReferenciadoVO, NfeDetalheImpostoCofinsVO, NfeDetalheImpostoIcmsVO,
    NfeDetalheImpostoPisVO, NfeDetalheImpostoIiVO, NfeDetalheImpostoIssqnVO,
    NfeDetalheImpostoIpiVO, NfeDeclaracaoImportacaoVO, NfeImportacaoDetalheVO,
    NfeDetEspecificoVeiculoVO, NfeDetEspecificoCombustivelVO, NfeDetEspecificoMedicamentoVO,
    NfeDetEspecificoArmamentoVO, NfeNfReferenciadaVO, NfeCteReferenciadoVO,
    NfeProdRuralReferenciadaVO, NfeTransporteReboqueVO, NfeTransporteVolumeVO,
    TributOperacaoFiscalVO,
    //
    ControleEstoqueController;

class function TNfeCabecalhoController.Consulta(pFiltro: String): TNfeCabecalhoVO;
begin
  try
    try
      Result := TT2TiORM.ConsultarUmObjeto<TNfeCabecalhoVO>(pFiltro, True);
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class procedure TNfeCabecalhoController.Consulta(pFiltro: String; pPagina: Integer);
var
  Retorno: TObjectList<TNfeCabecalhoVO>;
  i: Integer;
begin
  try
    try
      if Pos('ID=', pFiltro) > 0 then
        Retorno := TT2TiORM.Consultar<TNfeCabecalhoVO>(pFiltro, True, pPagina)
      else
        Retorno := TT2TiORM.Consultar<TNfeCabecalhoVO>(pFiltro, False, pPagina);

      // Campos Transientes
      for i := 0 to Retorno.Count - 1 do
      begin
        // Operação Fiscal
        if TNfeCabecalhoVO(Retorno.Items[i]).IdOperacaoFiscal > 0 then
        begin
          TNfeCabecalhoVO(Retorno.Items[i]).TributOperacaoFiscalVO := TT2TiORM.ConsultarUmObjeto<TTributOperacaoFiscalVO>('ID=' + IntToStr(TNfeCabecalhoVO(Retorno.Items[i]).IdOperacaoFiscal), False);
          if Assigned(TNfeCabecalhoVO(Retorno.Items[i]).TributOperacaoFiscalVO) then
            TNfeCabecalhoVO(Retorno.Items[i]).TributOperacaoFiscalDescricao := TNfeCabecalhoVO(Retorno.Items[i]).TributOperacaoFiscalVO.Descricao;
        end;
      end;

      if Assigned(Retorno) then
        PopulaGrid<TNfeCabecalhoVO>(Retorno);
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TNfeCabecalhoController.Insere(pNfeCabecalho: TNfeCabecalhoVO): Boolean;
var
  UltimoID: Integer;
  //
  ProdutoLote: TProdutoLoteVO;
  //
  NfeReferenciada: TNfeReferenciadaVO;
  NfeNfReferenciada: TNfeNfReferenciadaVO;
  NfeCteReferenciado: TNfeCteReferenciadoVO;
  NfeCupomFiscalReferenciado: TNfeCupomFiscalReferenciadoVO;
  NfeRuralReferenciada: TNfeProdRuralReferenciadaVO;
  NfeTransporteReboque: TNfeTransporteReboqueVO;
  NfeTransporteVolume: TNfeTransporteVolumeVO;
  NfeDuplicata: TNfeDuplicataVO;
  //
  NfeDetalhe: TNfeDetalheVO;
  NfeDeclaracaoImportacao: TNfeDeclaracaoImportacaoVO;
  NfeImportacaoDetalhe: TNfeImportacaoDetalheVO;
  NfeDetalheEspecificoMedicamento: TNfeDetEspecificoMedicamentoVO;
  NfeDetalheEspecificoArmamento: TNfeDetEspecificoArmamentoVO;
  //
  NfeReferenciadaEnumerator: TEnumerator<TNfeReferenciadaVO>;
  NfReferenciadaEnumerator: TEnumerator<TNfeNfReferenciadaVO>;
  NfeRuralReferenciadaEnumerator: TEnumerator<TNfeProdRuralReferenciadaVO>;
  NfeCteReferenciadoEnumerator: TEnumerator<TNfeCteReferenciadoVO>;
  NfeCupomFiscalReferenciadoEnumerator: TEnumerator<TNfeCupomFiscalReferenciadoVO>;
  NfeTransporteReboqueEnumerator: TEnumerator<TNfeTransporteReboqueVO>;
  NfeTransporteVolumeEnumerator: TEnumerator<TNfeTransporteVolumeVO>;
  NfeDuplicataEnumerator: TEnumerator<TNfeDuplicataVO>;
  //
  NfeDetalheEnumerator: TEnumerator<TNfeDetalheVO>;
  NfeDeclaracaoImportacaoEnumerator: TEnumerator<TNfeDeclaracaoImportacaoVO>;
  NfeDetalheEspecificoMedicamentoEnumerator: TEnumerator<TNfeDetEspecificoMedicamentoVO>;
  NfeDetalheEspecificoArmamentoEnumerator: TEnumerator<TNfeDetEspecificoArmamentoVO>;
  NfeImportacaoDetalheEnumerator: TEnumerator<TNfeImportacaoDetalheVO>;
begin
  Result := False;
  try
    try
      UltimoID := TT2TiORM.Inserir(pNfeCabecalho);

      { Destinatario }
      if Assigned(pNfeCabecalho.NfeDestinatarioVO) then
      begin
        pNfeCabecalho.NfeDestinatarioVO.IdNfeCabecalho := UltimoID;
        TT2TiORM.Inserir(pNfeCabecalho.NfeDestinatarioVO);
      end;

      { Emitente }
      if Assigned(pNfeCabecalho.NfeEmitenteVO) then
      begin
        pNfeCabecalho.NfeEmitenteVO.IdNfeCabecalho := UltimoID;
        TT2TiORM.Inserir(pNfeCabecalho.NfeEmitenteVO);
      end;

      (* Grupo de informação dos documentos referenciados *)
      {NF-e Referenciada}
      if Assigned(pNfeCabecalho.ListaNfeReferenciadaVO) then
      begin
        NfeReferenciadaEnumerator := pNfeCabecalho.ListaNfeReferenciadaVO.GetEnumerator;
        try
          with NfeReferenciadaEnumerator do
          begin
            while MoveNext do
            begin
              NfeReferenciada := Current;
              NfeReferenciada.IdNfeCabecalho := UltimoID;
              TT2TiORM.Inserir(NfeReferenciada);
            end;
          end;
        finally
          NfeReferenciadaEnumerator.Free;
        end;
      end;

      {NF Referenciada}
      if Assigned(pNfeCabecalho.ListaNfeNfReferenciadaVO) then
      begin
        NfReferenciadaEnumerator := pNfeCabecalho.ListaNfeNfReferenciadaVO.GetEnumerator;
        try
          with NfReferenciadaEnumerator do
          begin
            while MoveNext do
            begin
              NfeNfReferenciada := Current;
              NfeNfReferenciada.IdNfeCabecalho := UltimoID;
              TT2TiORM.Inserir(NfeNfReferenciada);
            end;
          end;
        finally
          NfReferenciadaEnumerator.Free;
        end;
      end;

      {NF Rural Referenciada}
      if Assigned(pNfeCabecalho.ListaNfeProdRuralReferenciadaVO) then
      begin
        NfeRuralReferenciadaEnumerator := pNfeCabecalho.ListaNfeProdRuralReferenciadaVO.GetEnumerator;
        try
          with NfeRuralReferenciadaEnumerator do
          begin
            while MoveNext do
            begin
              NfeRuralReferenciada := Current;
              NfeRuralReferenciada.IdNfeCabecalho := UltimoID;
              TT2TiORM.Inserir(NfeRuralReferenciada);
            end;
          end;
        finally
          NfeRuralReferenciadaEnumerator.Free;
        end;
      end;

      {CT-e Referenciado}
      if Assigned(pNfeCabecalho.ListaNfeCteReferenciadoVO) then
      begin
        NfeCteReferenciadoEnumerator := pNfeCabecalho.ListaNfeCteReferenciadoVO.GetEnumerator;
        try
          with NfeCteReferenciadoEnumerator do
          begin
            while MoveNext do
            begin
              NfeCteReferenciado := Current;
              NfeCteReferenciado.IdNfeCabecalho := UltimoID;
              TT2TiORM.Inserir(NfeCteReferenciado);
            end;
          end;
        finally
          NfeCteReferenciadoEnumerator.Free;
        end;
      end;

      {Cupom Fiscal Referenciado}
      if Assigned(pNfeCabecalho.ListaNfeCupomFiscalReferenciadoVO) then
      begin
        NfeCupomFiscalReferenciadoEnumerator := pNfeCabecalho.ListaNfeCupomFiscalReferenciadoVO.GetEnumerator;
        try
          with NfeCupomFiscalReferenciadoEnumerator do
          begin
            while MoveNext do
            begin
              NfeCupomFiscalReferenciado := Current;
              NfeCupomFiscalReferenciado.IdNfeCabecalho := UltimoID;
              TT2TiORM.Inserir(NfeCupomFiscalReferenciado);
            end;
          end;
        finally
          NfeCupomFiscalReferenciadoEnumerator.Free;
        end;
      end;
      (* Fim Grupo de informação dos documentos referenciados *)

      { Local Entrega }
      if Assigned(pNfeCabecalho.NfeLocalEntregaVO) then
      begin
        if pNfeCabecalho.NfeLocalEntregaVO.Id > 0 then
        begin
          pNfeCabecalho.NfeLocalEntregaVO.IdNfeCabecalho := UltimoID;
          TT2TiORM.Inserir(pNfeCabecalho.NfeLocalEntregaVO);
        end;
      end;

      { Local Retirada }
      if Assigned(pNfeCabecalho.NfeLocalRetiradaVO) then
      begin
        if pNfeCabecalho.NfeLocalRetiradaVO.Id > 0 then
        begin
          pNfeCabecalho.NfeLocalRetiradaVO.IdNfeCabecalho := UltimoID;
          TT2TiORM.Inserir(pNfeCabecalho.NfeLocalRetiradaVO);
        end;
      end;


      (* Grupo de Transporte *)
      { Transporte }
      if Assigned(pNfeCabecalho.NfeTransporteVO) then
      begin
        pNfeCabecalho.NfeTransporteVO.IdNfeCabecalho := UltimoID;
        pNfeCabecalho.NfeTransporteVO.Id := TT2TiORM.Inserir(pNfeCabecalho.NfeTransporteVO);

        { Transporte - Reboque }
        if Assigned(pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteReboqueVO) then
        begin
          NfeTransporteReboqueEnumerator := pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteReboqueVO.GetEnumerator;
          try
            with NfeTransporteReboqueEnumerator do
            begin
              while MoveNext do
              begin
                NfeTransporteReboque := Current;
                NfeTransporteReboque.IdNfeTransporte := pNfeCabecalho.NfeTransporteVO.Id;
                TT2TiORM.Inserir(NfeTransporteReboque);
              end;
            end;
          finally
            NfeTransporteReboqueEnumerator.Free;
          end;
        end;

        { Transporte - Volumes }
        if Assigned(pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteVolumeVO) then
        begin
          NfeTransporteVolumeEnumerator := pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteVolumeVO.GetEnumerator;
          try
            with NfeTransporteVolumeEnumerator do
            begin
              while MoveNext do
              begin
                NfeTransporteVolume := Current;
                NfeTransporteVolume.IdNfeTransporte := pNfeCabecalho.NfeTransporteVO.Id;
                TT2TiORM.Inserir(NfeTransporteVolume);
              end;
            end;
          finally
            NfeTransporteVolumeEnumerator.Free;
          end;
        end;
      end;
      (* Fim Grupo de Transporte *)


      (* Grupo de Cobrança *)
      { Fatura }
      if Assigned(pNfeCabecalho.NfeFaturaVO) then
      begin
        if pNfeCabecalho.NfeFaturaVO.Id > 0 then
        begin
          pNfeCabecalho.NfeFaturaVO.IdNfeCabecalho := UltimoID;
          TT2TiORM.Inserir(pNfeCabecalho.NfeFaturaVO);
        end;
      end;

      { Duplicatas }
      if Assigned(pNfeCabecalho.ListaNfeDuplicataVO) then
      begin
        NfeDuplicataEnumerator := pNfeCabecalho.ListaNfeDuplicataVO.GetEnumerator;
        try
          with NfeDuplicataEnumerator do
          begin
            while MoveNext do
            begin
              NfeDuplicata := Current;
              NfeDuplicata.IdNfeCabecalho := UltimoID;
              TT2TiORM.Inserir(NfeDuplicata);
            end;
          end;
        finally
          NfeDuplicataEnumerator.Free;
        end;
      end;
      (* Fim Grupo de Cobrança *)


      (* Grupo de Detalhes *)
      { NFeDetalhe }
      if Assigned(pNfeCabecalho.ListaNfeDetalheVO) then
      begin
        NFeDetalheEnumerator := pNfeCabecalho.ListaNfeDetalheVO.GetEnumerator;
        try
          with NFeDetalheEnumerator do
          begin
            while MoveNext do
            begin
              NFeDetalhe := Current;
              NFeDetalhe.IdNfeCabecalho := UltimoID;
              NFeDetalhe.Id := TT2TiORM.Inserir(NFeDetalhe);

              // Atualiza estoque
              TControleEstoqueController.Create().AtualizarEstoque(NFeDetalhe.QuantidadeComercial, NFeDetalhe.IdProduto);

              { Detalhe - Imposto - ICMS }
              if Assigned(NFeDetalhe.NfeDetalheImpostoIcmsVO) then
              begin
                NFeDetalhe.NfeDetalheImpostoIcmsVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetalheImpostoIcmsVO);
              end;

              { Detalhe - Imposto - IPI }
              if Assigned(NFeDetalhe.NfeDetalheImpostoIpiVO) then
              begin
                NFeDetalhe.NfeDetalheImpostoIpiVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetalheImpostoIpiVO);
              end;

              { Detalhe - Imposto - II }
              if Assigned(NFeDetalhe.NfeDetalheImpostoIiVO) then
              begin
                NFeDetalhe.NfeDetalheImpostoIiVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetalheImpostoIiVO);
              end;

              { Detalhe - Imposto - PIS }
              if Assigned(NFeDetalhe.NfeDetalheImpostoPisVO) then
              begin
                NFeDetalhe.NfeDetalheImpostoPisVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetalheImpostoPisVO);
              end;

              { Detalhe - Imposto - COFINS }
              if Assigned(NFeDetalhe.NfeDetalheImpostoCofinsVO) then
              begin
                NFeDetalhe.NfeDetalheImpostoCofinsVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetalheImpostoCofinsVO);
              end;

              { Detalhe - Imposto - ISSQN }
              if Assigned(NFeDetalhe.NfeDetalheImpostoIssqnVO) then
              begin
                NFeDetalhe.NfeDetalheImpostoIssqnVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetalheImpostoIssqnVO);
              end;

              { Detalhe - Específico - Veículo }
              if Assigned(NFeDetalhe.NfeDetEspecificoVeiculoVO) then
              begin
                NFeDetalhe.NfeDetEspecificoVeiculoVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetEspecificoVeiculoVO);
              end;

              { Detalhe - Específico - Combustível }
              if Assigned(NFeDetalhe.NfeDetEspecificoCombustivelVO) then
              begin
                NFeDetalhe.NfeDetEspecificoCombustivelVO.IdNfeDetalhe := NFeDetalhe.Id;
                TT2TiORM.Inserir(NFeDetalhe.NfeDetEspecificoCombustivelVO);
              end;

              { Detalhe - Específico - Medicamento }
              if Assigned(NFeDetalhe.ListaNfeDetEspecificoMedicamentoVO) then
              begin
                NfeDetalheEspecificoMedicamentoEnumerator := NFeDetalhe.ListaNfeDetEspecificoMedicamentoVO.GetEnumerator;
                try
                  with NfeDetalheEspecificoMedicamentoEnumerator do
                  begin
                    while MoveNext do
                    begin
                      NfeDetalheEspecificoMedicamento := Current;
                      NfeDetalheEspecificoMedicamento.IdNfeDetalhe := NFeDetalhe.Id;
                      TT2TiORM.Inserir(NfeDetalheEspecificoMedicamento);

                      // Produto - Lote
                      ProdutoLote := TProdutoLoteVO.Create;
                      ProdutoLote.IdProduto := NFeDetalhe.IdProduto;
                      ProdutoLote.Codigo := NfeDetalheEspecificoMedicamento.NumeroLote;
                      ProdutoLote.DataCadastro := now;
                      ProdutoLote.DataCompra := pNfeCabecalho.DataEmissao;
                      ProdutoLote.DataFabricacao := NfeDetalheEspecificoMedicamento.DataFabricacao;
                      ProdutoLote.DataValidade := NfeDetalheEspecificoMedicamento.DataValidade;
                      ProdutoLote.Quantidade := NfeDetalheEspecificoMedicamento.QuantidadeLote;
                      ProdutoLote.PrecoMaximoConsumidor := NfeDetalheEspecificoMedicamento.PrecoMaximoConsumidor;
                      TT2TiORM.Inserir(ProdutoLote);
                    end;
                  end;
                finally
                  NfeDetalheEspecificoMedicamentoEnumerator.Free;
                end;
              end;

              { Detalhe - Específico - Armamento }
              if Assigned(NFeDetalhe.ListaNfeDetEspecificoArmamentoVO) then
              begin
                NfeDetalheEspecificoArmamentoEnumerator := NFeDetalhe.ListaNfeDetEspecificoArmamentoVO.GetEnumerator;
                try
                  with NfeDetalheEspecificoArmamentoEnumerator do
                  begin
                    while MoveNext do
                    begin
                      NfeDetalheEspecificoArmamento := Current;
                      NfeDetalheEspecificoArmamento.IdNfeDetalhe := NFeDetalhe.Id;
                      TT2TiORM.Inserir(NfeDetalheEspecificoArmamento);
                    end;
                  end;
                finally
                  NfeDetalheEspecificoArmamentoEnumerator.Free;
                end;
              end;

              { Detalhe - Declaração de Importação }
              if Assigned(NFeDetalhe.ListaNfeDeclaracaoImportacaoVO) then
              begin
                NfeDeclaracaoImportacaoEnumerator := NFeDetalhe.ListaNfeDeclaracaoImportacaoVO.GetEnumerator;
                try
                  with NfeDeclaracaoImportacaoEnumerator do
                  begin
                    while MoveNext do
                    begin
                      NfeDeclaracaoImportacao := Current;
                      NfeDeclaracaoImportacao.IdNfeDetalhe := NFeDetalhe.Id;
                      NfeDeclaracaoImportacao.Id := TT2TiORM.Inserir(NfeDeclaracaoImportacao);

                      { Detalhe - Declaração de Importação - Adições }
                      if Assigned(NfeDeclaracaoImportacao.ListaNfeImportacaoDetalheVO) then
                      begin
                        NfeImportacaoDetalheEnumerator := NfeDeclaracaoImportacao.ListaNfeImportacaoDetalheVO.GetEnumerator;
                        try
                          with NfeImportacaoDetalheEnumerator do
                          begin
                            while MoveNext do
                            begin
                              NfeImportacaoDetalhe := Current;
                              NfeImportacaoDetalhe.IdNfeDeclaracaoImportacao := NfeDeclaracaoImportacao.Id;
                              NfeImportacaoDetalhe.Id := TT2TiORM.Inserir(NfeImportacaoDetalhe);
                            end;
                          end;
                        finally
                          NfeImportacaoDetalheEnumerator.Free;
                        end;
                      end;
                    end;
                  end;
                finally
                  NfeDeclaracaoImportacaoEnumerator.Free;
                end;
              end;

            end;
          end;
        finally
          NFeDetalheEnumerator.Free;
        end;
      end;
      (* Fim Grupo de Detalhes *)

      Consulta('ID = ' + IntToStr(UltimoID), 0);
      Result := True;
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro na inclusão do registro. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TNfeCabecalhoController.Altera(pNfeCabecalho, pNfeCabecalhoOld: TNfeCabecalhoVO): Boolean;
var
  NfeReferenciadaEnumerator: TEnumerator<TNfeReferenciadaVO>;
  NfReferenciadaEnumerator: TEnumerator<TNfeNfReferenciadaVO>;
  NfeRuralReferenciadaEnumerator: TEnumerator<TNfeProdRuralReferenciadaVO>;
  NfeCteReferenciadoEnumerator: TEnumerator<TNfeCteReferenciadoVO>;
  NfeCupomFiscalReferenciadoEnumerator: TEnumerator<TNfeCupomFiscalReferenciadoVO>;
  NfeTransporteReboqueEnumerator: TEnumerator<TNfeTransporteReboqueVO>;
  NfeTransporteVolumeEnumerator: TEnumerator<TNfeTransporteVolumeVO>;
  NfeDuplicataEnumerator: TEnumerator<TNfeDuplicataVO>;
  //
  NfeDetalheEnumerator: TEnumerator<TNfeDetalheVO>;
  NfeDetalheEnumeratorOld: TEnumerator<TNfeDetalheVO>;
  NfeDeclaracaoImportacaoEnumerator: TEnumerator<TNfeDeclaracaoImportacaoVO>;
  NfeDetalheEspecificoMedicamentoEnumerator: TEnumerator<TNfeDetEspecificoMedicamentoVO>;
  NfeDetalheEspecificoArmamentoEnumerator: TEnumerator<TNfeDetEspecificoArmamentoVO>;
  NfeImportacaoDetalheEnumerator: TEnumerator<TNfeImportacaoDetalheVO>;
begin
  try
    try
      Result := TT2TiORM.Alterar(pNfeCabecalho);

      { Destinatario }
      if Assigned(pNfeCabecalho.NfeDestinatarioVO) then
      begin
        if pNfeCabecalho.NfeDestinatarioVO.Id > 0 then
          Result := TT2TiORM.Alterar(pNfeCabecalho.NfeDestinatarioVO)
        else
          Result := TT2TiORM.Inserir(pNfeCabecalho.NfeDestinatarioVO) > 0;
      end;

      { Emitente }
      if Assigned(pNfeCabecalho.NfeEmitenteVO) then
      begin
        if pNfeCabecalho.NfeEmitenteVO.Id > 0 then
          Result := TT2TiORM.Alterar(pNfeCabecalho.NfeEmitenteVO)
        else
          Result := TT2TiORM.Inserir(pNfeCabecalho.NfeEmitenteVO) > 0;
      end;

      (* Grupo de informação dos documentos referenciados *)
      {NF-e Referenciada}
      if Assigned(pNfeCabecalho.ListaNfeReferenciadaVO) then
      begin
        NfeReferenciadaEnumerator := pNfeCabecalho.ListaNfeReferenciadaVO.GetEnumerator;
        try
          with NfeReferenciadaEnumerator do
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
          NfeReferenciadaEnumerator.Free;
        end;
      end;

      {NF Referenciada}
      if Assigned(pNfeCabecalho.ListaNfeNfReferenciadaVO) then
      begin
        NfReferenciadaEnumerator := pNfeCabecalho.ListaNfeNfReferenciadaVO.GetEnumerator;
        try
          with NfReferenciadaEnumerator do
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
          NfReferenciadaEnumerator.Free;
        end;
      end;

      {NF Rural Referenciada}
      if Assigned(pNfeCabecalho.ListaNfeProdRuralReferenciadaVO) then
      begin
        NfeRuralReferenciadaEnumerator := pNfeCabecalho.ListaNfeProdRuralReferenciadaVO.GetEnumerator;
        try
          with NfeRuralReferenciadaEnumerator do
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
          NfeRuralReferenciadaEnumerator.Free;
        end;
      end;

      {CT-e Referenciado}
      if Assigned(pNfeCabecalho.ListaNfeCteReferenciadoVO) then
      begin
        NfeCteReferenciadoEnumerator := pNfeCabecalho.ListaNfeCteReferenciadoVO.GetEnumerator;
        try
          with NfeCteReferenciadoEnumerator do
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
          NfeCteReferenciadoEnumerator.Free;
        end;
      end;

      {Cupom Fiscal Referenciado}
      if Assigned(pNfeCabecalho.ListaNfeCupomFiscalReferenciadoVO) then
      begin
        NfeCupomFiscalReferenciadoEnumerator := pNfeCabecalho.ListaNfeCupomFiscalReferenciadoVO.GetEnumerator;
        try
          with NfeCupomFiscalReferenciadoEnumerator do
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
          NfeCupomFiscalReferenciadoEnumerator.Free;
        end;
      end;
      (* Fim Grupo de informação dos documentos referenciados *)

      { Local Entrega }
      if Assigned(pNfeCabecalho.NfeLocalEntregaVO) then
      begin
        if pNfeCabecalho.NfeLocalEntregaVO.Id > 0 then
          Result := TT2TiORM.Alterar(pNfeCabecalho.NfeLocalEntregaVO)
        else
        begin
          pNfeCabecalho.NfeLocalEntregaVO.IdNfeCabecalho := pNfeCabecalho.Id;
          Result := TT2TiORM.Inserir(pNfeCabecalho.NfeLocalEntregaVO) > 0;
        end;
      end;

      { Local Retirada }
      if Assigned(pNfeCabecalho.NfeLocalRetiradaVO) then
      begin
        if pNfeCabecalho.NfeLocalRetiradaVO.Id > 0 then
          Result := TT2TiORM.Alterar(pNfeCabecalho.NfeLocalRetiradaVO)
        else
        begin
          pNfeCabecalho.NfeLocalRetiradaVO.IdNfeCabecalho := pNfeCabecalho.Id;
          Result := TT2TiORM.Inserir(pNfeCabecalho.NfeLocalRetiradaVO) > 0;
        end;
      end;


      (* Grupo de Transporte *)
      { Transporte }
      if Assigned(pNfeCabecalho.NfeTransporteVO) then
      begin
        Result := TT2TiORM.Alterar(pNfeCabecalho.NfeTransporteVO);

        { Transporte - Reboque }
        if Assigned(pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteReboqueVO) then
        begin
          NfeTransporteReboqueEnumerator := pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteReboqueVO.GetEnumerator;
          try
            with NfeTransporteReboqueEnumerator do
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
            NfeTransporteReboqueEnumerator.Free;
          end;
        end;

        { Transporte - Volumes }
        if Assigned(pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteVolumeVO) then
        begin
          NfeTransporteVolumeEnumerator := pNfeCabecalho.NfeTransporteVO.ListaNfeTransporteVolumeVO.GetEnumerator;
          try
            with NfeTransporteVolumeEnumerator do
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
            NfeTransporteVolumeEnumerator.Free;
          end;
        end;
      end;
      (* Fim Grupo de Transporte *)


      (* Grupo de Cobrança *)
      { Fatura }
      if Assigned(pNfeCabecalho.NfeFaturaVO) then
      begin
        if pNfeCabecalho.NfeFaturaVO.Id > 0 then
          Result := TT2TiORM.Alterar(pNfeCabecalho.NfeFaturaVO)
        else
        begin
          pNfeCabecalho.NfeFaturaVO.IdNfeCabecalho := pNfeCabecalho.Id;
          Result := TT2TiORM.Inserir(pNfeCabecalho.NfeFaturaVO) > 0;
        end;
      end;

      { Duplicatas }
      if Assigned(pNfeCabecalho.ListaNfeDuplicataVO) then
      begin
        NfeDuplicataEnumerator := pNfeCabecalho.ListaNfeDuplicataVO.GetEnumerator;
        try
          with NfeDuplicataEnumerator do
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
          NfeDuplicataEnumerator.Free;
        end;
      end;
      (* Fim Grupo de Cobrança *)


      (* Grupo de Detalhes *)
      { NFeDetalhe }
      if Assigned(pNfeCabecalho.ListaNfeDetalheVO) then
      begin
        NFeDetalheEnumerator := pNfeCabecalho.ListaNfeDetalheVO.GetEnumerator;
        try
          with NFeDetalheEnumerator do
          begin
            while MoveNext do
            begin

              if Current.Id > 0 then
              begin
                Result := TT2TiORM.Alterar(Current);
              end
              else
                Current.Id := TT2TiORM.Inserir(Current);

              // Atualiza estoque
              TControleEstoqueController.Create().AtualizarEstoque(Current.QuantidadeComercial, Current.IdProduto);

              { Detalhe - Imposto - ICMS }
              if Assigned(Current.NfeDetalheImpostoIcmsVO) then
              begin
                Current.NfeDetalheImpostoIcmsVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetalheImpostoIcmsVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetalheImpostoIcmsVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetalheImpostoIcmsVO) > 0;
              end;

              { Detalhe - Imposto - IPI }
              if Assigned(Current.NfeDetalheImpostoIpiVO) then
              begin
                Current.NfeDetalheImpostoIpiVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetalheImpostoIpiVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetalheImpostoIpiVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetalheImpostoIpiVO) > 0;
              end;

              { Detalhe - Imposto - II }
              if Assigned(Current.NfeDetalheImpostoIiVO) then
              begin
                Current.NfeDetalheImpostoIiVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetalheImpostoIiVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetalheImpostoIiVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetalheImpostoIiVO) > 0;
              end;

              { Detalhe - Imposto - PIS }
              if Assigned(Current.NfeDetalheImpostoPisVO) then
              begin
                Current.NfeDetalheImpostoPisVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetalheImpostoPisVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetalheImpostoPisVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetalheImpostoPisVO) > 0;
              end;

              { Detalhe - Imposto - COFINS }
              if Assigned(Current.NfeDetalheImpostoCofinsVO) then
              begin
                Current.NfeDetalheImpostoCofinsVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetalheImpostoCofinsVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetalheImpostoCofinsVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetalheImpostoCofinsVO) > 0;
              end;

              { Detalhe - Imposto - ISSQN }
              if Assigned(Current.NfeDetalheImpostoIssqnVO) then
              begin
                Current.NfeDetalheImpostoIssqnVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetalheImpostoIssqnVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetalheImpostoIssqnVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetalheImpostoIssqnVO) > 0;
              end;

              { Detalhe - Específico - Veículo }
              if Assigned(Current.NfeDetEspecificoVeiculoVO) then
              begin
                Current.NfeDetEspecificoVeiculoVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetEspecificoVeiculoVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetEspecificoVeiculoVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetEspecificoVeiculoVO) > 0;
              end;

              { Detalhe - Específico - Combustível }
              if Assigned(Current.NfeDetEspecificoCombustivelVO) then
              begin
                Current.NfeDetEspecificoVeiculoVO.IdNfeDetalhe := Current.Id;
                if Current.NfeDetEspecificoCombustivelVO.Id > 0 then
                  Result := TT2TiORM.Alterar(Current.NfeDetEspecificoCombustivelVO)
                else
                  Result := TT2TiORM.Inserir(Current.NfeDetEspecificoCombustivelVO) > 0;
              end;

              { Detalhe - Específico - Medicamento }
              if Assigned(Current.ListaNfeDetEspecificoMedicamentoVO) then
              begin
                NfeDetalheEspecificoMedicamentoEnumerator := Current.ListaNfeDetEspecificoMedicamentoVO.GetEnumerator;
                try
                  with NfeDetalheEspecificoMedicamentoEnumerator do
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
                  NfeDetalheEspecificoMedicamentoEnumerator.Free;
                end;
              end;

              { Detalhe - Específico - Armamento }
              if Assigned(Current.ListaNfeDetEspecificoArmamentoVO) then
              begin
                NfeDetalheEspecificoArmamentoEnumerator := Current.ListaNfeDetEspecificoArmamentoVO.GetEnumerator;
                try
                  with NfeDetalheEspecificoArmamentoEnumerator do
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
                  NfeDetalheEspecificoArmamentoEnumerator.Free;
                end;
              end;

              { Detalhe - Declaração de Importação }
              if Assigned(Current.ListaNfeDeclaracaoImportacaoVO) then
              begin
                NfeDeclaracaoImportacaoEnumerator := Current.ListaNfeDeclaracaoImportacaoVO.GetEnumerator;
                try
                  with NfeDeclaracaoImportacaoEnumerator do
                  begin
                    while MoveNext do
                    begin
                      if Current.Id > 0 then
                        Result := TT2TiORM.Alterar(Current)
                      else
                        Result := TT2TiORM.Inserir(Current) > 0;

                      { Detalhe - Declaração de Importação - Adições }
                      if Assigned(Current.ListaNfeImportacaoDetalheVO) then
                      begin
                        NfeImportacaoDetalheEnumerator := Current.ListaNfeImportacaoDetalheVO.GetEnumerator;
                        try
                          with NfeImportacaoDetalheEnumerator do
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
                          NfeImportacaoDetalheEnumerator.Free;
                        end;
                      end;
                    end;
                  end;
                finally
                  NfeDeclaracaoImportacaoEnumerator.Free;
                end;
              end;

            end;
          end;
        finally
          NFeDetalheEnumerator.Free;
        end;
      end;
      (* Fim Grupo de Detalhes *)

    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro na alteração do registro. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TNfeCabecalhoController.Exclui(pId: Integer; pExcluirQuem: String; pIdProduto: Integer = 0; pQuantidade: Integer = 0): Boolean;
var
  pNfeCabecalho: TNfeCabecalhoVO;
  IdRetornado: Integer;
begin
  pNfeCabecalho := TNfeCabecalhoVO.Create;
  try
    try
      if pExcluirQuem = 'CABECALHO' then
      begin
        Result := False;
      end
      else if pExcluirQuem = 'DETALHE' then
      begin
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_COFINS where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_PIS where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_ICMS where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_II where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_IPI where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE_IMPOSTO_ISSQN where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_COMBUSTIVEL where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_VEICULO where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_ARMAMENTO where ID_NFE_DETALHE = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DET_ESPECIFICO_MEDICAMENTO where ID_NFE_DETALHE = ' + IntToStr(pId));

        IdRetornado := TT2TiORM.SelectMax('NFE_DECLARACAO_IMPORTACAO', 'ID_NFE_DETALHE= ' + IntToStr(pId));
        if IdRetornado <> -1 then
        begin
          Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_IMPORTACAO_DETALHE where ID_NFE_DECLARACAO_IMPORTACAO = ' + IntToStr(IdRetornado));
          Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DECLARACAO_IMPORTACAO where ID_NFE_DETALHE = ' + IntToStr(pId));
        end;

        // Atualiza estoque
        TControleEstoqueController.Create().AtualizarEstoque(pQuantidade * -1, pIdProduto);

        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DETALHE where ID = ' + IntToStr(pId));
      end
      else if pExcluirQuem = 'REFERENCIADO' then
      begin
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_REFERENCIADA where ID_NFE_CABECALHO = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_NF_REFERENCIADA where ID_NFE_CABECALHO = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_CTE_REFERENCIADO where ID_NFE_CABECALHO = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_PROD_RURAL_REFERENCIADA where ID_NFE_CABECALHO = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_CUPOM_FISCAL_REFERENCIADO where ID_NFE_CABECALHO = ' + IntToStr(pId));
      end
      else if pExcluirQuem = 'ENTREGA_RETIRADA' then
      begin
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_LOCAL_ENTREGA where ID_NFE_CABECALHO = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_LOCAL_RETIRADA where ID_NFE_CABECALHO = ' + IntToStr(pId));
      end
      else if pExcluirQuem = 'TRANSPORTE' then
      begin
        IdRetornado := TT2TiORM.SelectMax('NFE_TRANSPORTE', 'ID_NFE_CABECALHO= ' + IntToStr(pId));
        if IdRetornado <> -1 then
        begin
          Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_TRANSPORTE_REBOQUE where ID_NFE_TRANSPORTE = ' + IntToStr(IdRetornado));

          IdRetornado := TT2TiORM.SelectMax('NFE_TRANSPORTE_VOLUME', 'ID_NFE_TRANSPORTE= ' + IntToStr(IdRetornado));
          if IdRetornado <> -1 then
          begin
            Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_TRANSPORTE_VOLUME_LACRE where ID_NFE_TRANSPORTE_VOLUME = ' + IntToStr(IdRetornado));
            Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_TRANSPORTE_VOLUME where ID = ' + IntToStr(IdRetornado));
          end;
          Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_TRANSPORTE where ID_NFE_CABECALHO = ' + IntToStr(pId));
        end;
      end
      else if pExcluirQuem = 'COBRANCA' then
      begin
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_FATURA where ID_NFE_CABECALHO = ' + IntToStr(pId));
        Result := TT2TiORM.ComandoSQL('DELETE FROM NFE_DUPLICATA where ID_NFE_CABECALHO = ' + IntToStr(pId));
      end;
    except
      on E: Exception do
      begin
        Result := False;
      end;
    end;
  finally
    pNfeCabecalho.Free;
  end;
end;

class function TNfeCabecalhoController.GetDataSet: TClientDataSet;
begin
  Result := FDataSet;
end;

class procedure TNfeCabecalhoController.SetDataSet(pDataSet: TClientDataSet);
begin
  FDataSet := pDataSet;
end;

end.
