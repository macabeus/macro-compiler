defmodule MacroCompiler.Test.E2e.PostfixIf do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      log well... if not print it, then something wrong happened if (1)
      call CallIt if (1)
      call ShouldNotCallIt if (0)
    }

    macro CallIt {
      log called
    }

    macro ShouldNotCallIt {
      log not call it
    }
  """

  test_output :string, "should print log", fn value ->
    value == "well... if not print it, then something wrong happened"
  end

  test_output :string, "should call macro CallIt", fn value ->
    value == "called"
  end

  test_output :string, "should not call macro ShouldNotCallIt", fn value ->
    value == ""
  end
end

