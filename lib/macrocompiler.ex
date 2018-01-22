defmodule MacroCompiler do
  use Combine
  alias MacroCompiler.TopLevelBlock
  alias MacroCompiler.SymbolsTable
  alias MacroCompiler.SemanticAnalysis
  alias MacroCompiler.CodeGeneration
  alias MacroCompiler.CodeGenerationHeader

  def start_parser() do
    [ast] = Combine.parse_file("macro.txt", TopLevelBlock.parser())

    table = SymbolsTable.build(ast)

    SemanticAnalysis.validate(ast, ast, table)

    CodeGenerationHeader.generate(ast, ast, table)
    CodeGeneration.generate(ast, ast, table)
  end
end

MacroCompiler.start_parser()
