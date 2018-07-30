defmodule MacroCompiler.CodeGeneration.Header do
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

  alias MacroCompiler.SemanticAnalysis.SymbolsTable

  def generate(node, %{macros: symbols_table, special_variables: special_variables}) do
    []
    |> Enum.concat(["package macroCompiled;"])
    |> Enum.concat(start_find_requirements(node))
    |> Enum.concat(import_special_variables(special_variables))
    |> Enum.concat([
      """
      Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', \&on_unload);
      sub on_unload { }
      """
    ])
    |> Enum.concat(commands_register(symbols_table))
  end

  defp import_special_variables(special_variables) do
    special_variables
    |> Enum.map(fn
      "$.zeny" -> "use Globals qw($char);"
    end)
  end

  defp commands_register(symbols_table) do
    macros_hash_value =
      symbols_table
      |> SymbolsTable.list_written_macros
      |> Enum.map(&"#{&1} => \\&macro_#{&1},")

    [
      "Commands::register(",
      "['macroCompiled', 'MacroCompiled plugin', \\&commandHandler]",
      ");",
      "my %macros = (",
      macros_hash_value,
      ");",
      "sub commandHandler {",
      "  my $macroFunc = $macros{$_[1]};",
      "  &$macroFunc;",
      "}"
    ]
  end

  defp start_find_requirements(node) do
    find_requirements(node)
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

  defp find_requirements({_node, %{ignore: true}}) do

  end

  defp find_requirements({node, _metadata}) do
    find_requirements(node)
  end

  defp find_requirements(block) when is_list(block) do
    Enum.map(block, &(find_requirements(&1)))
  end

  defp find_requirements(%{block: block}) do
    find_requirements(block)
  end

  defp find_requirements(%DoCommand{text: _text}) do
    %{module: "Commands"}
  end

  defp find_requirements(%LogCommand{text: _text}) do
    %{module: "Log qw(message)"}
  end

  defp find_requirements(%ScalarAssignmentCommand{scalar_variable: scalar_variable, scalar_value: _scalar_value}) do
    find_requirements(scalar_variable)
  end

  defp find_requirements(%ArrayAssignmentCommand{array_variable: array_variable, texts: _texts}) do
    find_requirements(array_variable)
  end

  defp find_requirements(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: _keystexts}) do
    find_requirements(hash_variable)
  end

  defp find_requirements(%DeleteCommand{scalar_variable: scalar_variable}) do
    find_requirements(scalar_variable)
  end

  defp find_requirements(%KeysCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}) do
    [
      find_requirements(array_variable),
      find_requirements(param_hash_variable)
    ]
  end

  defp find_requirements(%ValuesCommand{array_variable: array_variable, param_hash_variable: param_hash_variable}) do
    [
      find_requirements(array_variable),
      find_requirements(param_hash_variable)
    ]
  end

  defp find_requirements(%UndefCommand{scalar_variable: scalar_variable}) do
    find_requirements(scalar_variable)
  end

  defp find_requirements(%IncrementCommand{scalar_variable: scalar_variable}) do
    find_requirements(scalar_variable)
  end

  defp find_requirements(%DecrementCommand{scalar_variable: scalar_variable}) do
    find_requirements(scalar_variable)
  end

  defp find_requirements(%PushCommand{array_variable: array_variable, text: _text}) do
    find_requirements(array_variable)
  end

  defp find_requirements(%PopCommand{array_variable: array_variable}) do
    find_requirements(array_variable)
  end

  defp find_requirements(%ShiftCommand{array_variable: array_variable}) do
    find_requirements(array_variable)
  end

  defp find_requirements(%UnshiftCommand{array_variable: array_variable, text: _text}) do
    find_requirements(array_variable)
  end

  defp find_requirements(%ScalarVariable{name: name, array_position: nil, hash_position: hash_position}) do
    case {name, hash_position} do
      {name, nil} ->
        %{variable: "$#{name}"}

      {name, _hash_position} ->
        %{variable: "%#{name}"}
    end
  end

  defp find_requirements(%ArrayVariable{name: name}) do
    %{variable: "@#{name}"}
  end

  defp find_requirements(%HashVariable{name: name}) do
    %{variable: "%#{name}"}
  end

  defp find_requirements(_undefinedNode) do

  end
end
