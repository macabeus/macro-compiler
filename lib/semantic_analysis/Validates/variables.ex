defmodule MacroCompiler.SemanticAnalysis.Validates.Variables do
  def validate_variables(symbol_table) do
    variables_read =
      symbol_table
      |> Enum.map(&find_variables_read/1)
      |> List.flatten
      |> MapSet.new
      |> MapSet.delete(nil)

    variables_write =
      symbol_table
      |> Enum.map(&find_variables_write/1)
      |> List.flatten
      |> MapSet.new
      |> MapSet.delete(nil)


    messages_variables_read =
      variables_read
      |> MapSet.difference(variables_write)
      |> MapSet.to_list
      |> Enum.map(&(
        %{
          type: :warning,
          message: IO.ANSI.format([:black, :normal,  "variable ", :red, &1, :black, " is read but has never been written"])
        }
      ))

    messages_variables_write =
      variables_write
      |> MapSet.difference(variables_read)
      |> MapSet.to_list
      |> Enum.map(&(
        %{
          type: :warning,
          message: IO.ANSI.format([:black, :normal,  "variable ", :red, &1, :black, " is write but has never read"])
        }
      ))

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

      %{variable_name: x} ->
        x

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

      %{variable_name: x} ->
        x

      _ ->
        nil
    end
  end
end
