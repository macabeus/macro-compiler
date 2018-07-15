defmodule MacroCompiler.Test.E2e.Random do
  use MacroCompiler.Test.Helper.E2e

  def code, do: """
    macro Test {
      $city = &random(prontera, payon, geffen, marroc)
      log $city
    }
  """

  test_output :string, "should be a random city", fn value ->
    cities = ["prontera", "payon", "geffen", "marroc"]
    Enum.member?(cities, value)
  end
end

