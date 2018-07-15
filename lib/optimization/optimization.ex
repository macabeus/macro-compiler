defmodule MacroCompiler.Optimization do
  alias MacroCompiler.Optimization.DeadCodeStrip
  alias MacroCompiler.Optimization.ConstantFolding
  alias MacroCompiler.SemanticAnalysis

  def build_ast_optimized(ast, optimization) do
    symbols_table = SemanticAnalysis.build_symbols_table(ast)
    new_ast = optimization.optimize(ast, symbols_table)

    if new_ast == ast do
      new_ast
    else
      build_ast_optimized(new_ast, optimization)
    end
  end

  def build_ast_optimized(ast) do
    symbols_table = SemanticAnalysis.build_symbols_table(ast)
    new_ast =
      ast
      |> DeadCodeStrip.optimize(symbols_table)
      |> ConstantFolding.optimize(symbols_table)

    if new_ast == ast do
      new_ast
    else
      build_ast_optimized(new_ast)
    end
  end
end
