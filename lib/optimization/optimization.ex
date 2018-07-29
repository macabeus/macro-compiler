defmodule MacroCompiler.Optimization do
  alias MacroCompiler.Optimization.DeadCodeStrip
  alias MacroCompiler.Optimization.ConstantFolding
  alias MacroCompiler.SemanticAnalysis

  # Run all optimizations
  def build_ast_optimized(ast) do
    build_ast_optimized(ast, [DeadCodeStrip, ConstantFolding])
  end

  # Run a couple of optimizations
  def build_ast_optimized(ast, opts) when is_list(opts) do
    symbols_table = SemanticAnalysis.build_symbols_table(ast)

    optimized_ast =
      Enum.reduce(opts, ast, fn (opt, current_ast) ->
        opt.optimize(current_ast, symbols_table)
      end)

    if optimized_ast == ast do
      optimized_ast
    else
      build_ast_optimized(optimized_ast, opts)
    end
  end

  # Run a single optimization
  def build_ast_optimized(ast, opt) when is_atom(opt) do
    symbols_table = SemanticAnalysis.build_symbols_table(ast)

    optimized_ast =
      opt.optimize(ast, symbols_table)

    if optimized_ast == ast do
      optimized_ast
    else
      build_ast_optimized(optimized_ast, opt)
    end
  end
end
