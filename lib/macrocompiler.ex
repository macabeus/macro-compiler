defmodule MacroCompiler do
  use Combine

  alias MacroCompiler.Parser.TopLevelBlock
  alias MacroCompiler.Parser.SyntaxError

  alias MacroCompiler.SemanticAnalysis

  alias MacroCompiler.CodeGeneration
  alias MacroCompiler.CodeGenerationHeader

  def start_parser(macro_file) do
    file = File.read!(macro_file)

    try do
      [ast] = Combine.parse(file, TopLevelBlock.parser())

      symbols_table = SemanticAnalysis.build_symbols_table(ast)
      SemanticAnalysis.run_validates(symbols_table)

      CodeGenerationHeader.generate(ast, ast, symbols_table)
      CodeGeneration.start_generate(ast, ast, symbols_table)

    rescue
      e in SyntaxError ->
        MacroCompiler.ShowErrors.show(file, e)
    end
  end
end


case System.argv do
  [] -> MacroCompiler.start_parser("macro.txt")
  [macro_file] -> MacroCompiler.start_parser(macro_file)
end
