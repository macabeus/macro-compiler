defmodule MacroCompiler.Test.E2e.Call do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      log start
      call Called
      log end
    }

    macro Called {
      log called
    }
  """

  test_output :string, "should startly print 'start'", fn value ->
    value == "start"
  end

  test_output :string, "should print 'called'", fn value ->
    value == "called"
  end

  test_output :string, "should print at end 'end'", fn value ->
    value == "end"
  end
end

