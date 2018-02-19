defmodule MacroCompiler.CheckMacros do
  def validate_check_macros(validate_tree) do
    macros_read =
      validate_tree
      |> Enum.map(&find_macros_read/1)
      |> List.flatten
      |> Enum.reject(&is_nil/1)

    macros_write =
      validate_tree
      |> Enum.map(&find_macros_write/1)
      |> Enum.reject(&is_nil/1)

    macros_read
    |> Enum.reject(&Enum.member?(macros_write, &1))
    |> Enum.map(&(
      IO.puts IO.ANSI.format([:yellow, :bright, "Warning: ", :black, :normal,  "macro ", :red, &1, :black, " is called but never been written"], true)
    ))
  end

  defp find_macros_read(stage) do
    case stage do
      x when is_list(x) ->
        Enum.map(x, &find_macros_read/1)

      %{macro_write: %{block: block}} ->
        find_macros_read(block)

      %{macro_read: %{name: macro, params: params}} ->
        macro

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
