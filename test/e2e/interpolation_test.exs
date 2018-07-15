defmodule MacroCompiler.Test.E2e.Interpolation do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      $scalar = foo
      log scalar: $scalar

      @array = (1, 2)
      log array: @array

      %hash = (1 => foo, 2 => bar)
      log hash: %hash
    }
  """

  test_output :string, "should can interpolate a scalar", fn value ->
    value == "scalar: foo"
  end

  test_output :string, "should can interpolate an array", fn value ->
    value == "array: 2"
  end

  test_output :string, "should can interpolate a hash", fn value ->
    value == "hash: 2"
  end
end

