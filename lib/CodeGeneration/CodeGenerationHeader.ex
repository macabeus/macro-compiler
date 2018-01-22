defmodule MacroCompiler.CodeGenerationHeader do
  alias MacroCompiler.Macro
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression
  alias MacroCompiler.ScalarVariableAssignment

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

  defp find_requirements(%DoExpression{action: _action}, _ast, _symbolsTable) do
    %{module: "Commands"}
  end

  defp find_requirements(%LogExpression{message: _message}, _ast, _symbolsTable) do
    %{module: "Log qw(message)"}
  end

  defp find_requirements(%ScalarVariableAssignment{name: name, value: _value}, _ast, _symbolsTable) do
    %{variable: "$#{name}"}
  end

  defp find_requirements(_undefinedNode, _ast, _symbolsTable) do

  end
end
