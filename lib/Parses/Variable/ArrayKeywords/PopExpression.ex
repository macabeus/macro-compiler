defmodule MacroCompiler.PopExpression do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable

  @enforce_keys [:array_variable]
  defstruct [:array_variable]

  def parser() do
    map(
      sequence([
        ignore(string("&pop(")),

        ArrayVariable.parser(),

        ignore(string(")")),

        skip(newline())
      ]),
      fn [array_variable] -> %MacroCompiler.PopExpression{array_variable: array_variable} end
    )
  end
end
