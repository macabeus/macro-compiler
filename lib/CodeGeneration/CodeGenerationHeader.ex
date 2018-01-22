defmodule MacroCompiler.CodeGenerationHeader do
  alias MacroCompiler.Macro
  alias MacroCompiler.DoExpression
  alias MacroCompiler.LogExpression

  def generate(node, ast, symbolsTable) do
    IO.puts "package macroCompiled;"

    find_modules(node, ast, symbolsTable)
    |> List.flatten
    |> MapSet.new
    |> MapSet.delete(nil)
    |> Enum.map(&(
      IO.puts "use #{&1};"
    ))

    IO.puts """
    Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', \&on_unload);
    sub on_unload { }
    """
  end


  defp find_modules(block, ast, symbolsTable) when is_list(block) do
    Enum.map(block, &(find_modules(&1, ast, symbolsTable)))
  end

  defp find_modules(%Macro{name: _name, block: block}, ast, symbolsTable) do
    find_modules(block, ast, symbolsTable)
  end

  defp find_modules(%DoExpression{action: _action}, _ast, _symbolsTable) do
    "Commands"
  end

  defp find_modules(%LogExpression{message: _message}, _ast, _symbolsTable) do
    "Log qw(message)"
  end

  defp find_modules(_undefinedNode, _ast, _symbolsTable) do

  end
end
