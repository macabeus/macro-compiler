defmodule MacroCompiler.Test.Helper.SemanticAnalysis do
  alias MacroCompiler.Parser.TopLevelBlock
  alias MacroCompiler.SemanticAnalysis

  alias MacroCompiler.Error
  alias MacroCompiler.SemanticAnalysis.FatalError, as: FatalSemanticError

  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: true
      import MacroCompiler.Test.Helper.SemanticAnalysis
    end
  end

  def get_validates_result(code) do
    [ast] = Combine.parse(code, TopLevelBlock.parser())

    symbols_table = SemanticAnalysis.build_symbols_table(ast)
    SemanticAnalysis.run_validates(symbols_table)
  end

  defmacro test_should_works(description, code) do
    quote do
      test unquote(description) do
        validates_result = get_validates_result(unquote(code))

        assert length(validates_result) == 0
        Error.raise_fatal_error(validates_result)
      end
    end
  end

  defmacro test_semantic_warning(description, code, compare_list) do
    quote do
      test unquote(description) do
        validates_result = get_validates_result(unquote(code))

        List.zip([validates_result, unquote(compare_list)])
        |> Enum.each(fn {validate_result, [message: message, metadatas: metadatas]} ->
          assert validate_result.message == message
          assert validate_result.metadatas == metadatas
          assert validate_result.type == :warning
       end)
      end
    end
  end

  defmacro test_semantic_error(description, code, compare_list) do
    quote do
      test unquote(description) do
        validates_result = get_validates_result(unquote(code))

        List.zip([validates_result, unquote(compare_list)])
        |> Enum.each(fn {validate_result, [message: message, metadatas: metadatas]} ->
          assert validate_result.message == message
          assert validate_result.metadatas == metadatas
          assert validate_result.type == :error
        end)

        assert_raise FatalSemanticError, fn ->
          Error.raise_fatal_error(validates_result)
        end
      end
    end
  end
end

