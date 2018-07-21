defmodule MacroCompiler.Test.E2e.PostfixIf do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      log well... if not print it, then something wrong happened if (1)

      $value = 1000 if (1)
      call CallIt if ($.zeny > 0)

      call ShouldNotCallIt if (1000 != 1000)
    }

    macro CallIt {
      log value is $value
    }

    macro ShouldNotCallIt {
      log not call it
    }
  """

  test_output :string, "should print log", fn value ->
    value == "well... if not print it, then something wrong happened"
  end

  test_output :string, "should call macro CallIt", fn value ->
    value == "value is 1000"
  end

  test_output :string, "should not call macro ShouldNotCallIt", fn value ->
    value == ""
  end
end

