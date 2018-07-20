defmodule MacroCompiler.Test.E2e.BlankMacro do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      # nothing
    }
  """

  test_output :string, "should return nothing", fn value ->
    value == ""
  end
end

