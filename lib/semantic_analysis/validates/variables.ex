defmodule MacroCompiler.SemanticAnalysis.Validates.Variables do
  alias MacroCompiler.SemanticAnalysis.SymbolsTable

  def validate_variables(%{macros: symbols_table_macros}) do
    variables_read =
      symbols_table_macros
      |> SymbolsTable.list_read_variables
      |> SymbolsTable.reject_special_variable

    variables_read_names =
      variables_read
      |> Enum.map(fn {name, _} -> name end)


    variables_write =
      symbols_table_macros
      |> SymbolsTable.list_written_variables
      |> SymbolsTable.reject_special_variable

    variables_write_names =
      variables_write
      |> Enum.map(fn {name, _} -> name end)


    messages_variables_read =
      variables_read
      |> Enum.reject(fn {name, _} -> Enum.member?(variables_write_names, name) end)
      |> Enum.reduce(%{}, fn({name, metadata}, acc) ->
        case Map.fetch(acc, name) do
          {:ok, metadatas} ->
            %{acc | name => [metadata | metadatas]}

          :error ->
            Map.put(acc, name, [metadata])
        end
      end)
      |> Enum.map(fn({variable_name, metadatas}) -> %{
        type: :error,
        metadatas: metadatas,
        message: ["variable ", :red, variable_name, :default_color, " is read but it has never been written."]
      } end)

    messages_variables_write =
      variables_write
      |> Enum.reject(fn {name, _} -> Enum.member?(variables_read_names, name) end)
      |> Enum.reduce(%{}, fn({name, metadata}, acc) ->
        case Map.fetch(acc, name) do
          {:ok, metadatas} ->
            %{acc | name => [metadata | metadatas]}

          :error ->
            Map.put(acc, name, [metadata])
        end
      end)
      |> Enum.map(fn({variable_name, metadatas}) -> %{
        type: :warning,
        metadatas: metadatas,
        message: ["variable ", :red, variable_name, :default_color, " is write but it has never read."]
      } end)

    [messages_variables_read, messages_variables_write]
  end
end
