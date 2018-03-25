defmodule MacroCompiler.SemanticAnalysis.Validates.Variables do
  def validate_variables(symbol_table) do
    variables_read =
      symbol_table
      |> Enum.map(&find_variables_read/1)
      |> List.flatten
      |> Enum.reject(&is_nil/1)

    variables_read_names =
      variables_read
      |> Enum.map(&Map.get(&1, :name))


    variables_write =
      symbol_table
      |> Enum.map(&find_variables_write/1)
      |> List.flatten
      |> Enum.reject(&is_nil/1)

    variables_write_names =
      variables_write
      |> Enum.map(&Map.get(&1, :name))


    messages_variables_read =
      variables_read
      |> Enum.reject(&Enum.member?(variables_write_names, &1.name))
      |> Enum.reduce(%{}, fn(variable, acc) ->
        case Map.fetch(acc, variable.name) do
          {:ok, metadatas} ->
            %{acc | variable.name => [variable.metadata | metadatas]}

          :error ->
            Map.put(acc, variable.name, [variable.metadata])
        end
      end)
      |> Enum.map(fn({variable_name, metadatas}) -> %{
        type: :warning,
        metadatas: metadatas,
        message: [:black, :normal,  "variable ", :red, variable_name, :black, " is called but it has never been written."]
      } end)

    messages_variables_write =
      variables_write
      |> Enum.reject(&Enum.member?(variables_read_names, &1.name))
      |> Enum.reduce(%{}, fn(variable, acc) ->
        case Map.fetch(acc, variable.name) do
          {:ok, metadatas} ->
            %{acc | variable.name => [variable.metadata | metadatas]}

          :error ->
            Map.put(acc, variable.name, [variable.metadata])
        end
      end)
      |> Enum.map(fn({variable_name, metadatas}) -> %{
        type: :warning,
        metadatas: metadatas,
        message: [:black, :normal,  "variable ", :red, variable_name, :black, " is write but it has never read."]
      } end)

    [messages_variables_read, messages_variables_write]
  end

  defp find_variables_read(stage) do
    case stage do
      %{macro_write: %{block: block}} ->
        Enum.map(block, &find_variables_read/1)

      %{variable_read: x, variable_name: {name, metadata}} when is_list(x) ->
        [
          %{name: name, metadata: metadata},
          Enum.map(x, &find_variables_read/1)
        ]

      %{variable_read: x} when is_list(x) ->
        Enum.map(x, &find_variables_read/1)

      x when is_list(x) ->
        Enum.map(x, &find_variables_read/1)

      %{variable_read: x} when is_map(x) ->
        find_variables_read(x)

      %{variable_name: {name, metadata}} ->
        %{name: name, metadata: metadata}

      _ ->
        nil
    end
  end

  defp find_variables_write(stage) do
    case stage do
      %{macro_write: %{block: block}} ->
        Enum.map(block, &find_variables_write/1)

      %{variable_write: x} when is_list(x) ->
        Enum.map(x, &find_variables_write/1)

      x when is_list(x) ->
        Enum.map(x, &find_variables_write/1)

      %{variable_write: x} when is_map(x) ->
        find_variables_write(x)

      %{variable_name: {name, metadata}} ->
        %{name: name, metadata: metadata}

      _ ->
        nil
    end
  end
end
