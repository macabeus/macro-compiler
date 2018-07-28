defmodule MacroCompiler.SemanticAnalysis.SymbolsTable do
  def list_written_macros(symbols_table) do
    symbols_table
    |> get_in([Access.all(), Access.key(:macro_write), Access.key(:name)])
  end

  def list_read_macros(symbols_table) do
    macros_block = get_macros_block(symbols_table)

    listMacro(:macro_read, macros_block)
    |> filter_nil
  end

  def list_written_variables(symbols_table) do
    macros_block = get_macros_block(symbols_table)

    list(:variable_write, macros_block)
    |> filter_nil
  end

  def list_read_variables(symbols_table) do
    macros_block = get_macros_block(symbols_table)

    list(:variable_read, macros_block)
    |> filter_nil
  end

  def list_special_variables(symbols_table) do
    read_variables = list_read_variables(symbols_table)

    read_variables
    |> Enum.map(fn {name, _metadata} -> name end)
    |> Enum.filter(&is_special_variable/1)
    |> MapSet.new
  end

  # Private functions

  defp get_macros_block(symbols_table) do
    symbols_table
    |> get_in([Access.all(), Access.key(:macro_write), Access.key(:block)])
    |> filter_nil
  end

  # TODO: This function needs to be refactored
  defp listMacro(operation, symbols_table, acc \\ []) do
    m =
      symbols_table
      |> get_in([Access.all(), Access.key(operation)])
      |> filter_nil

    a =
      symbols_table
      |> get_in([Access.all(), Access.key(:variable_read)])
      |> filter_nil

    if (length(a) > 0) do
      acc = [acc | m]
      [acc | listMacro(operation, a, acc)]
    else
      [acc | m]
    end
  end

  # TODO: This function needs to be refactored
  defp list(operation, symbols_table, acc \\ []) do
    occurrences =
      symbols_table
      |> get_in([Access.all(), Access.key(operation)])
      |> filter_nil

    a =
      occurrences
      |> get_in([Access.all(), Access.key(:variable_name)])

    if (length(a) > 0) do
      acc = [acc | a]
      list(operation, occurrences, acc)
    else
      acc
    end
  end

  defp is_special_variable(variable_name) do
    String.slice(variable_name, 1..1) == "."
  end

  def filter_special_variable(variable_list) do
    variable_list
    |> Enum.filter(fn {name, _metadata} -> is_special_variable(name) end)
  end

  def reject_special_variable(variable_list) do
    variable_list
    |> Enum.reject(fn {name, _metadata} -> is_special_variable(name) end)
  end

  defp filter_nil(list) do
    list
    |> List.flatten
    |> Enum.reject(&is_nil/1)
  end
end

