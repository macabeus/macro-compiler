defmodule MacroCompiler.SemanticAnalysis.Validates.SpecialVariables do
  alias MacroCompiler.SemanticAnalysis.SymbolsTable

  def validate_special_variables(%{macros: symbols_table_macros}) do
    special_variables_written =
      symbols_table_macros
      |> SymbolsTable.list_written_variables
      |> SymbolsTable.filter_special_variable

    special_variables_written
    |> Enum.reduce(%{}, fn ({name, metadata}, acc) ->
      case Map.fetch(acc, name) do
        {:ok, metadatas} ->
          %{acc | name => [metadata | metadatas]}

        :error ->
          Map.put(acc, name, [metadata])
      end
    end)
    |> Enum.map(fn ({variable_name, metadatas}) ->
      %{
        type: :error,
        metadatas: metadatas,
        message: [:red, variable_name, :default_color, " is a special variable, reassigning is not allowed"]
      }
    end)
  end
end

