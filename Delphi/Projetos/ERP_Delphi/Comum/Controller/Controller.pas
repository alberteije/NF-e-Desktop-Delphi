{ *******************************************************************************
Title: T2Ti ERP
Description: Unit de controle Base - Cliente.

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
******************************************************************************* }
unit Controller;

interface

uses
  Classes, SessaoUsuario, SysUtils, Forms, Windows, DB, DBClient, SWSystem,
  VO, Rtti, Atributos, StrUtils, TypInfo, Generics.Collections, Biblioteca, T2TiORM;

type
  TController = class
  private
  public
    class function GetDataSet: TClientDataSet; virtual;
    class procedure SetDataSet(pDataSet: TClientDataSet); virtual;

    class function VO<O: class>(pId: Integer): O; overload;
    class function VO<O: class>(pCampo: String; pValor: String): O; overload;
    class function VO<O: class>(pFiltro: String): O; overload;

  protected
    class function Sessao: TSessaoUsuario;
    class procedure PopulaGrid<O: class>(pListaObjetos: TObjectList<O>); overload;
    class procedure PopulaGrid<O: class>(pListaObjetos: TObjectList<O>; pLimparDataSet: Boolean); overload;
  end;

  TClassController = class of TController;

implementation

uses Conversor;
{ TController }

class function TController.GetDataSet: TClientDataSet;
begin
  Result := nil;
  // Implementar nas classes filhas
end;

class function TController.Sessao: TSessaoUsuario;
begin
  Result := TSessaoUsuario.Instance;
end;

class procedure TController.SetDataSet(pDataSet: TClientDataSet);
begin
  //
end;

class procedure TController.PopulaGrid<O>(pListaObjetos: TObjectList<O>; pLimparDataSet: Boolean);
var
  I: Integer;
  ObjetoVO: O;
  Contexto: TRttiContext;
  Tipo: TRttiType;
  Propriedade: TRttiProperty;
  Atributo: TCustomAttribute;
  Metodo: TRttiMethod;
  Params: TArray<TRttiParameter>;
  DataSetField: TField;
  DataSet: TClientDataSet;
begin
  DataSet := GetDataSet;

  if not Assigned(DataSet) then
    Exit;

  try
    DataSet.DisableControls;
    if pLimparDataset then
      DataSet.EmptyDataSet;

    try
      Contexto := TRttiContext.Create;
      Tipo := Contexto.GetType(TClass(O));

      for I := 0 to pListaObjetos.Count - 1 do
      begin

        ObjetoVO := O(pListaObjetos[i]);
        try
          DataSet.Append;

          for Propriedade in Tipo.GetProperties do
          begin
            for Atributo in Propriedade.GetAttributes do
            begin
              if Atributo is TColumn then
              begin
                DataSetField := DataSet.FindField((Atributo as TColumn).Name);
                if Assigned(DataSetField) then
                begin
                  if Propriedade.PropertyType.TypeKind in [tkEnumeration] then
                    DataSetField.AsBoolean := Propriedade.GetValue(TObject(ObjetoVO)).AsBoolean
                  else
                    DataSetField.Value := Propriedade.GetValue(TObject(ObjetoVO)).AsVariant;

                  if DataSetField.DataType = ftDateTime then
                  begin
                    if DataSetField.AsDateTime = 0 then
                      DataSetField.Clear;
                  end;
                end;
              end
              else if Atributo is TId then
              begin
                DataSetField := DataSet.FindField((Atributo as TId).NameField);
                if Assigned(DataSetField) then
                begin
                  DataSetField.Value := Propriedade.GetValue(TObject(ObjetoVO)).AsVariant;
                end;
              end;
            end;
          end;
        finally
          TObject(ObjetoVO).Free;
        end;

        DataSet.Post;
      end;
    finally
      Contexto.Free;
    end;

    DataSet.Open;
    DataSet.First;
  finally
    DataSet.EnableControls;
  end;
end;

class procedure TController.PopulaGrid<O>(pListaObjetos: TObjectList<O>);
begin
  PopulaGrid<O>(pListaObjetos, True);
end;

class function TController.VO<O>(pId: Integer): O;
begin
  try
    try
      Result := TT2TiORM.ConsultarUmObjeto<O>('ID=' + IntToStr(pId), True)
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TController.VO<O>(pCampo: String; pValor: String): O;
begin
  try
    try
      Result := TT2TiORM.ConsultarUmObjeto<O>(pCampo + '=' + pValor, True)
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

class function TController.VO<O>(pFiltro: String): O;
begin
  try
    try
      Result := TT2TiORM.ConsultarUmObjeto<O>(pFiltro, True)
    finally
    end;
  except
    on E: Exception do
      Application.MessageBox(PChar('Ocorreu um erro durante a consulta. Informe a mensagem ao Administrador do sistema.' + #13 + #13 + E.Message), 'Erro do sistema', MB_OK + MB_ICONERROR);
  end;
end;

end.
