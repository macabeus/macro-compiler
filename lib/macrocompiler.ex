defmodule MacroCompiler do
  use Combine

  alias MacroCompiler.Parser.TopLevelBlock
  alias MacroCompiler.Parser.SyntaxError

  alias MacroCompiler.SemanticAnalysis

  alias MacroCompiler.Error.ShowErrors

  alias MacroCompiler.Optimization

  alias MacroCompiler.CodeGeneration
  alias MacroCompiler.CodeGenerationHeader

  def start_parser(macro_file) do
    file = File.read!(macro_file)

    try do
      [ast] = Combine.parse(file, TopLevelBlock.parser())

      symbols_table = SemanticAnalysis.build_symbols_table(ast)
      validates_result = SemanticAnalysis.run_validates(symbols_table)
      ShowErrors.show(file, validates_result)

      optimized_ast = Optimization.build_ast_otimatized(ast)

      CodeGenerationHeader.generate(optimized_ast, symbols_table)
      CodeGeneration.start_generate(optimized_ast, symbols_table)

    rescue
      e in SyntaxError ->
        ShowErrors.show(file, e)
    end
  end
end


case System.argv do
  [] -> MacroCompiler.start_parser("macro.txt")
  [macro_file] -> MacroCompiler.start_parser(macro_file)
end
