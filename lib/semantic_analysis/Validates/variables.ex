defmodule MacroCompiler.SemanticAnalysis.Validates.Variables do
  alias MacroCompiler.ShowErrors

  def validate_variables(file, symbol_table) do
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
        name: variable_name,
        occurrences: Enum.map(metadatas, &ShowErrors.calc_line_and_column(file, &1.line, &1.offset)) |> Enum.reverse
      } end)
      |> Enum.map(fn %{name: variable_name, occurrences: occurrences} ->
        %{
          type: :warning,
          message: IO.ANSI.format([:black, :normal,  "variable ", :red, variable_name, :black, " is read but has never been written. It's happened at #{Enum.map(occurrences, fn {line, column} -> "#{line}:#{column}" end) |> Enum.join(" and ")}"])
        }
      end)

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
        name: variable_name,
        occurrences: Enum.map(metadatas, &ShowErrors.calc_line_and_column(file, &1.line, &1.offset)) |> Enum.reverse
      } end)
      |> Enum.map(fn %{name: variable_name, occurrences: occurrences} ->
        %{
          type: :warning,
          message: IO.ANSI.format([:black, :normal,  "variable ", :red, variable_name, :black, " is write but has never read. It's happened at #{Enum.map(occurrences, fn {line, column} -> "#{line}:#{column}" end) |> Enum.join(" and ")}"])
        }
      end)

    [messages_variables_read, messages_variables_write]
  end

  defp find_variables_read(stage) do
    case stage do
      %{macro_write: %{block: block}} ->
        Enum.map(block, &find_variables_read/1)

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
