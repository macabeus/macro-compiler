defmodule MacroCompiler.Test.E2e.Rand do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      $value = &rand(0, 5)
      log $value
    }
  """

  test_output :integer, "should be between 0 and 5", fn value ->
    Enum.member?(0..5, value)
  end
end

