defmodule MacroCompiler.CheckVariablesUse do
  def validate_check_variables_use(validate_tree) do
    variables_read =
      validate_tree
      |> Enum.map(&find_variables_read/1)
      |> List.flatten
      |> MapSet.new
      |> MapSet.delete(nil)

    variables_write =
      validate_tree
      |> Enum.map(&find_variables_write/1)
      |> List.flatten
      |> MapSet.new
      |> MapSet.delete(nil)


    variables_read
    |> MapSet.difference(variables_write)
    |> MapSet.to_list
    |> Enum.map(&(
      IO.puts IO.ANSI.format([:yellow, :bright, "Warning: ", :black, :normal,  "variable ", :red, &1, :black, " is read but has never been write"], true)
    ))

    variables_write
    |> MapSet.difference(variables_read)
    |> MapSet.to_list
    |> Enum.map(&(
      IO.puts IO.ANSI.format([:yellow, :bright, "Warning: ", :black, :normal,  "variable ", :red, &1, :black, " is write but has never read"], true)
    ))
  end

  defp find_variables_read(stage) do
    case stage do
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
