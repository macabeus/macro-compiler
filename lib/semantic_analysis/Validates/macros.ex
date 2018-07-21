defmodule MacroCompiler.SemanticAnalysis.Validates.Macros do
  alias MacroCompiler.SemanticAnalysis.SymbolsTable

  def validate_macros(%{macros: symbols_table_macros}) do
    macros_read =
      symbols_table_macros
      |> SymbolsTable.list_read_macros

    macros_write =
      symbols_table_macros
      |> SymbolsTable.list_written_macros

    macros_read
    |> Enum.reject(fn {macro, _metadata} -> Enum.member?(macros_write, macro.name) end)
    |> Enum.reduce(%{}, fn({macro, metadata}, acc) ->
      case Map.fetch(acc, macro.name) do
        {:ok, metadatas} ->
          %{acc | macro.name => [metadata | metadatas]}

        :error ->
          Map.put(acc, macro.name, [metadata])
      end
    end)
    |> Enum.map(fn({macro_name, metadatas}) -> %{
      type: :error,
      metadatas: metadatas,
      message: ["macro ", :red, macro_name, :default_color, " is called but it has never been written."]
    } end)
  end
end
