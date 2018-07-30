defmodule MacroCompiler.Test.E2e.IfBlock do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      if (0) {
        log should not print it
      }

      if (1) {
        log should print it!
      }

      $value = 1
      if ($value) {
        log should can use a variable
      }

      if ($value == 1) {
        log should can compare a variable
      }
    }
  """

  test_output :string, "should print log at 'if' block", fn value ->
    value == "should print it!"
  end

  test_output :string, "should can use a variable", fn value ->
    value == "should can use a variable"
  end

  test_output :string, "should can compare a variable", fn value ->
    value == "should can compare a variable"
  end
end

