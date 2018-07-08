defmodule MacroCompiler.CodeGenerationHeader do
  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.Parser.DoCommand
  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.UndefCommand
  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ArrayAssignmentCommand
  alias MacroCompiler.Parser.HashAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.IncrementCommand
  alias MacroCompiler.Parser.DecrementCommand
  alias MacroCompiler.Parser.PushCommand
  alias MacroCompiler.Parser.PopCommand
  alias MacroCompiler.Parser.ShiftCommand
  alias MacroCompiler.Parser.UnshiftCommand
  alias MacroCompiler.Parser.DeleteCommand
  alias MacroCompiler.Parser.KeysCommand
  alias MacroCompiler.Parser.ValuesCommand

  def generate(node, symbolsTable) do
    []
    |> Enum.concat(["package macroCompiled;"])
    |> Enum.concat(start_find_requirements(node, symbolsTable))
    |> Enum.concat([
      """
      Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', \&on_unload);
      sub on_unload { }
      """
    ])
  end

  defp start_find_requirements(node, symbolsTable) do
    find_requirements(node, symbolsTable)
    |> List.flatten
    |> MapSet.new
    |> MapSet.delete(nil)
    |> Enum.map(&(
      case &1 do
        %{module: module_name} -> "use #{module_name};"
        %{variable: variable_name} -> "my #{variable_name};"
      end
    ))
  end

  defp find_requirements({_node, %{ignore: true}}, symbolsTable) do

  end

  defp find_requirements({node, _metadata}, symbolsTable) do
    find_requirements(node, symbolsTable)
  end

  defp find_requirements(block, symbolsTable) when is_list(block) do
    Enum.map(block, &(find_requirements(&1, symbolsTable)))
  end

  defp find_requirements(%Macro{name: _name, block: block}, symbolsTable) do
    find_requirements(block, symbolsTable)
  end

  defp find_requirements(%DoCommand{text: _text}, _symbolsTable) do
    %{module: "Commands"}
  end

  defp find_requirements(%LogCommand{text: _text}, _symbolsTable) do
    %{module: "Log qw(message)"}
  end

  defp find_requirements(%ScalarAssignmentCommand{scalar_variable: scalar_variable, scalar_value: _scalar_value}, symbolsTable) do
    find_requirements(scalar_variable, symbolsTable)
  end

  defp find_requirements(%ArrayAssignmentCommand{array_variable: array_variable, texts: _texts}, symbolsTable) do
    find_requirements(array_variable, symbolsTable)
  end

  defp find_requirements(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: _keystexts}, symbolsTable) do
    find_requirements(hash_variable, symbolsTable)
  end

  defp find_requirements(%DeleteCommand{scalar_variable: scalar_variable}, symbolsTable) do
    find_requirements(scalar_variable, symbolsTable)
  end

  defp find_requirements(%KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, symbolsTable) do
    [
      find_requirements(array_variable, symbolsTable),
      find_requirements(param_hash_variable, symbolsTable)
    ]
  end

  defp find_requirements(%ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}, symbolsTable) do
    [
      find_requirements(array_variable, symbolsTable),
      find_requirements(param_hash_variable, symbolsTable)
    ]
  end

  defp find_requirements(%UndefCommand{scalar_variable: scalar_variable}, symbolsTable) do
    find_requirements(scalar_variable, symbolsTable)
  end

  defp find_requirements(%IncrementCommand{scalar_variable: scalar_variable}, symbolsTable) do
    find_requirements(scalar_variable, symbolsTable)
  end

  defp find_requirements(%DecrementCommand{scalar_variable: scalar_variable}, symbolsTable) do
    find_requirements(scalar_variable, symbolsTable)
  end

  defp find_requirements(%PushCommand{array_variable: array_variable, text: _text}, symbolsTable) do
    find_requirements(array_variable, symbolsTable)
  end

  defp find_requirements(%PopCommand{array_variable: array_variable}, symbolsTable) do
    find_requirements(array_variable, symbolsTable)
  end

  defp find_requirements(%ShiftCommand{array_variable: array_variable}, symbolsTable) do
    find_requirements(array_variable, symbolsTable)
  end

  defp find_requirements(%UnshiftCommand{array_variable: array_variable, text: _text}, symbolsTable) do
    find_requirements(array_variable, symbolsTable)
  end

  defp find_requirements(%ScalarVariable{name: name, array_position: nil, hash_position: hash_position}, _symbolsTable) do
    case {name, hash_position} do
      {name, nil} ->
        %{variable: "$#{name}"}

      {name, hash_position} ->
        %{variable: "%#{name}"}
    end
  end

  defp find_requirements(%ArrayVariable{name: name}, _symbolsTable) do
    %{variable: "@#{name}"}
  end

  defp find_requirements(%HashVariable{name: name}, _symbolsTable) do
    %{variable: "%#{name}"}
  end

  defp find_requirements(_undefinedNode, _symbolsTable) do

  end
end
