defmodule MacroCompiler.Test.E2e.Log do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      log foo
      log 123
    }
  """

  test_output :string, "should be foo", fn value ->
    value == "foo"
  end

  test_output :integer, "should be 123", fn value ->
    value == 123
  end
end

