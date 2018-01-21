defmodule MacroCompiler do
  use Combine
  alias MacroCompiler.TopLevelBlock
  alias MacroCompiler.SymbolsTable
  alias MacroCompiler.SemanticAnalysis

  def start_parser() do
    [ast] = Combine.parse_file("macro.txt", TopLevelBlock.parser())

    table = SymbolsTable.build(ast)

    SemanticAnalysis.validate(ast, ast, table)

    ast
  end
end

IO.inspect MacroCompiler.start_parser()
