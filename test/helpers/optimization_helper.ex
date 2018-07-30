defmodule MacroCompiler.Test.Helper.Optimization do
  alias MacroCompiler.Parser.TopLevelBlock
  alias MacroCompiler.Optimization

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import MacroCompiler.Test.Helper.Optimization
    end
  end

  def build_optimized_ast(code, optimization) do
    [ast] = Combine.parse(code, TopLevelBlock.parser())

    Optimization.build_ast_optimized(ast, optimization)
  end

  defmacro test_equivalents_ast(description, code_a, code_b) do
    quote do
      test unquote(description) do
        Process.put(:no_metadata, true)
        Process.put(:no_keep_ignored_node, true)

        ast_a = build_optimized_ast(unquote(code_a), @optimization)
        ast_b = build_optimized_ast(unquote(code_b), @optimization)

        Process.put(:no_metadata, nil)
        Process.put(:no_keep_ignored_node, nil)

        assert ast_a == ast_b
      end
    end
  end

  defmacro test_different_ast(description, code_a, code_b) do
    quote do
      test unquote(description) do
        Process.put(:no_metadata, true)
        Process.put(:no_keep_ignored_node, true)

        ast_a = build_optimized_ast(unquote(code_a), @optimization)
        ast_b = build_optimized_ast(unquote(code_b), @optimization)

        Process.put(:no_metadata, nil)
        Process.put(:no_keep_ignored_node, nil)

        assert ast_a != ast_b
      end
    end
  end
end

