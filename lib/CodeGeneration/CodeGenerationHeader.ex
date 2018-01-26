defmodule MacroCompiler.CodeGenerationHeader do
  alias MacroCompiler.Macro
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.UndefScalarVariable
  alias MacroCompiler.ScalarVariableAssignment
  alias MacroCompiler.ArrayVariableAssignment
  alias MacroCompiler.HashVariableAssignment
  alias MacroCompiler.ScalarVariable
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.HashVariable
  alias MacroCompiler.IncrementExpression
  alias MacroCompiler.DecrementExpression
  alias MacroCompiler.PushExpression
  alias MacroCompiler.PopExpression

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


  defp find_requirements(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(find_requirements(&1, ast, symbolsTable)))
  end

  defp find_requirements(%Macro{name: _name, block: block}, ast, symbolsTable) do
    find_requirements(block, ast, symbolsTable)
  end

  defp find_requirements(%DoExpression{text: _text}, _ast, _symbolsTable) do
    %{module: "Commands"}
  end

  defp find_requirements(%LogExpression{text: _text}, _ast, _symbolsTable) do
    %{module: "Log qw(message)"}
  end

  defp find_requirements(%ScalarVariableAssignment{scalar_variable: scalar_variable, text: _text}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%ArrayVariableAssignment{array_variable: array_variable, texts: _texts}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%HashVariableAssignment{hash_variable: hash_variable, keystexts: _keystexts}, ast, symbolsTable) do
    find_requirements(hash_variable, ast, symbolsTable)
  end

  defp find_requirements(%UndefScalarVariable{scalar_variable: scalar_variable}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%IncrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%DecrementExpression{scalar_variable: scalar_variable}, ast, symbolsTable) do
    find_requirements(scalar_variable, ast, symbolsTable)
  end

  defp find_requirements(%PushExpression{array_variable: array_variable, text: _text}, ast, symbolsTable) do
    find_requirements(array_variable, ast, symbolsTable)
  end

  defp find_requirements(%PopExpression{array_variable: array_variable}, ast, symbolsTable) do
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
