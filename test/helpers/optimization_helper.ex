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

  def remove_ignored_nodes(ast) do
    filter_ignore_nodes = Access.filter(fn {_node, metadata} -> metadata.ignore == true end)

    ast
    |> update_in([Access.all(), Access.elem(0), Access.key(:block), filter_ignore_nodes], fn _ -> nil end)
    |> update_in([Access.all(), Access.elem(0), Access.key(:block)], fn nodes -> Enum.reject(nodes, &is_nil/1) end)
  end

  def remove_metadata(ast) do
    update_in(ast, [Access.all(), Access.elem(0), Access.key(:block), Access.all()], fn {node, _metadata} -> node end)
  end

  defmacro test_equivalents_ast(description, code_a, code_b) do
    quote do
      test unquote(description) do
        ast_a = build_optimized_ast(unquote(code_a), @optimization)
        ast_b = build_optimized_ast(unquote(code_b), @optimization)

        ast_filtered_a =
          ast_a
          |> remove_ignored_nodes
          |> remove_metadata

        ast_filtered_b =
          ast_b
          |> remove_metadata

        assert ast_filtered_a == ast_filtered_b
      end
    end
  end
end

