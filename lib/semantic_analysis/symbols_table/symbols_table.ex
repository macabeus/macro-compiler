defmodule MacroCompiler.SymbolsTable do
  alias MacroCompiler.Parser.Macro
  alias MacroCompiler.MacroSymbolsTable

  def build(ast) do
    Enum.map(ast, fn i ->
      case i do
        %Macro{name: _, block: _} -> MacroSymbolsTable.build(i)
        _ -> raise("Can't build symbol table on #{i}")
      end
    end)
  end
end
