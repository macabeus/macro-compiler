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

  def generate(node, ast, symbolsTable) do
    IO.puts "package macroCompiled;"

    find_requirements(node, ast, symbolsTable)
    |> List.flatten
    |> MapSet.new
    |> MapSet.delete(nil)
    |> Enum.map(&(
      case &1 do
        %{module: module_name} -> IO.puts "use #{module_name};"
        %{variable: variable_name} -> IO.puts "my #{variable_name};"
      end
    ))

    IO.puts """
    Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', \&on_unload);
    sub on_unload { }
    """
  end

  defp find_requirements({node, _metadata}, ast, symbolsTable) do
    find_requirements(node, ast, symbolsTable)
  end

  defp find_requirements(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(find_requirements(&1, ast, symbolsTable)))
  end

  defp find_requirements(%Macro{name: _name, block: block}, ast, symbolsTable) do
    find_requirements(block, ast, symbolsTable)
  end

  defp find_requirements(%DoCommand{text: _text}, _ast, _symbolsTable) do
    %{module: "Commands"}
  end

  defp find_requirements(%LogCommand{text: _text}, _ast, _symbolsTable) do
    %{module: "Log qw(message)"}
  end

  defp find_requirements(%ScalarAssignmentCommand{scalar_variable: scalar_variable, text: _text}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%ArrayAssignmentCommand{array_variable: array_variable, texts: _texts}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%HashAssignmentCommand{hash_variable: hash_variable, keystexts: _keystexts}, ast, symbolsTable) do
    find_requirements(hash_variable, ast, symbolsTable)
  end

  defp find_requirements(%UndefCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%IncrementCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%DecrementCommand{scalar_variable: scalar_variable}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%PushCommand{array_variable: array_variable, text: _text}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%PopCommand{array_variable: array_variable}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%ShiftCommand{array_variable: array_variable}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%UnshiftCommand{array_variable: array_variable, text: _text}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%ScalarVariable{name: name, array_position: nil, hash_position: nil}, _ast, _symbolsTable) do
    %{variable: "$#{name}"}
  end

  defp find_requirements(%ArrayVariable{name: name}, _ast, _symbolsTable) do
    %{variable: "@#{name}"}
  end

  defp find_requirements(%HashVariable{name: name}, _ast, _symbolsTable) do
    %{variable: "%#{name}"}
  end

  defp find_requirements(_undefinedNode, _ast, _symbolsTable) do

  end
end
