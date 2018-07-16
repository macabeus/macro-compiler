defmodule MacroCompiler.SemanticAnalysis.ListSpecialVariables do
  def build(symbols_table) do
    x =
      symbols_table
      |> get_in([Access.all(), Access.key(:macro_write), Access.key(:block)])
      |> filter_nil

    y =
      rec([], x)
      |> List.flatten

    y
    |> filter_nil
    |> get_in([Access.all(), Access.elem(0)])
    |> Enum.filter(&is_special_variable/1)
    |> MapSet.new
  end

  def rec(acc, symbols_table_stage) do
    m =
      symbols_table_stage
      |> get_in([Access.all(), Access.key(:variable_read)])
      |> filter_nil
    a =
      m
      |> get_in([Access.all(), Access.key(:variable_name)])

    if (length(a) > 0) do
      acc = [acc | a]
      [acc | recursive(m)]
    else
      []
    end
  end

  def recursive(symbols_table_stage) do
    m =
      symbols_table_stage
      |> get_in([Access.all(), Access.key(:variable_read)])
      |> filter_nil
    a =
      m
      |> get_in([Access.all(), Access.key(:variable_name)])

    if (length(a) > 0) do
      [a | recursive(m)]
    else
      []
    end
  end

  defp is_special_variable(variable_name) do
    String.slice(variable_name, 1..1) == "."
  end

  defp filter_nil(list) do
    list
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end
end

