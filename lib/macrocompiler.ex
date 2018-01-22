defmodule MacroCompiler do
  use Combine
  alias MacroCompiler.TopLevelBlock
  alias MacroCompiler.SymbolsTable
  alias MacroCompiler.SemanticAnalysis
  alias MacroCompiler.CodeGeneration
  alias MacroCompiler.CodeGenerationHeader

  def start_parser(macro_file) do
    [ast] = Combine.parse_file(macro_file, TopLevelBlock.parser())

    table = SymbolsTable.build(ast)

    SemanticAnalysis.validate(ast, ast, table)

    CodeGenerationHeader.generate(ast, ast, table)
    CodeGeneration.generate(ast, ast, table)
  end
end


case System.argv do
  [] -> MacroCompiler.start_parser("macro.txt")
  [macro_file] -> MacroCompiler.start_parser(macro_file)
end
