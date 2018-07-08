defmodule MacroCompiler do
  use Combine

  alias MacroCompiler.Parser.TopLevelBlock
  alias MacroCompiler.Parser.SyntaxError

  alias MacroCompiler.SemanticAnalysis
  alias MacroCompiler.SemanticAnalysis.FatalError, as: FatalSemanticError

  alias MacroCompiler.Error

  alias MacroCompiler.Optimization

  alias MacroCompiler.CodeGeneration
  alias MacroCompiler.CodeGenerationHeader

  def compiler(macro_file) do
    file = File.read!(macro_file)

    try do
      [ast] = Combine.parse(file, TopLevelBlock.parser())

      symbols_table = SemanticAnalysis.build_symbols_table(ast)
      validates_result = SemanticAnalysis.run_validates(symbols_table)
      Error.show(file, validates_result)
      Error.raise_fatal_error(validates_result)

      optimized_ast = Optimization.build_ast_otimatized(ast)

      []
      |> Enum.concat(CodeGenerationHeader.generate(optimized_ast, symbols_table))
      |> Enum.concat(CodeGeneration.start_generate(optimized_ast, symbols_table))

    rescue
      e in SyntaxError ->
        Error.show(file, e)

      e in FatalSemanticError ->
        IO.puts e.message
    end
  end

  def print_result(generated_code) do
    generated_code
    |> Enum.each(&IO.puts/1)
  end
end


case System.argv do
  [] -> MacroCompiler.compiler("macro.txt") |> MacroCompiler.print_result
  [macro_file] -> MacroCompiler.compiler(macro_file) |> MacroCompiler.print_result
end
