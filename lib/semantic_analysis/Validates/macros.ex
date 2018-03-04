defmodule MacroCompiler.SemanticAnalysis.Validates.Macros do
  alias MacroCompiler.ShowErrors

  def validate_macros(file, symbol_table) do
    macros_read =
      symbol_table
      |> Enum.map(&find_macros_read/1)
      |> List.flatten
      |> Enum.reject(&is_nil/1)

    macros_write =
      symbol_table
      |> Enum.map(&find_macros_write/1)
      |> Enum.reject(&is_nil/1)

    macros_read
    |> Enum.reject(&Enum.member?(macros_write, &1.name))
    |> Enum.reduce(%{}, fn(macro, acc) ->
      case Map.fetch(acc, macro.name) do
        {:ok, metadatas} ->
          %{acc | macro.name => [macro.metadata | metadatas]}

        :error ->
          Map.put(acc, macro.name, [macro.metadata])
      end
    end)
    |> Enum.map(fn({macro_name, metadatas}) -> %{
      name: macro_name,
      occurrences: Enum.map(metadatas, &ShowErrors.calc_line_and_column(file, &1.line, &1.offset)) |> Enum.reverse
    } end)
    |> Enum.map(fn %{name: macro_name, occurrences: occurrences} ->
      %{
        type: :warning,
        message: IO.ANSI.format([:black, :normal,  "macro ", :red, macro_name, :black, " is called but never been written. It's happened at #{Enum.map(occurrences, fn {line, column} -> "#{line}:#{column}" end) |> Enum.join(" and ")}"])
      }
    end)
  end

  defp find_macros_read(stage) do
    case stage do
      x when is_list(x) ->
        Enum.map(x, &find_macros_read/1)

      %{macro_write: %{block: block}} ->
        find_macros_read(block)

      %{macro_read: {%{name: name, params: _params}, metadata}} ->
        %{name: name, metadata: metadata}

      _ ->
        nil
    end
  end

  defp find_macros_write(stage) do
    case stage do
      %{macro_write: %{name: name}} ->
        name

      _ ->
        nil
    end
  end
end
