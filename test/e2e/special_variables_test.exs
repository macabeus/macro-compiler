defmodule MacroCompiler.Test.E2e.SpecialVariables do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      log I have $.zeny zeny!
    }
  """

  test_output :string, "should print the amount of zeny", fn value ->
    value == "I have 1000 zeny!"
  end
end

