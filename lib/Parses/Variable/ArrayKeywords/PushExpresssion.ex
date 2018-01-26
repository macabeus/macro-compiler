defmodule MacroCompiler.PushExpression do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.Identifier

  @enforce_keys [:array_variable, :value]
  defstruct [:array_variable, :value]

  def parser() do
    map(
      sequence([
        ignore(string("&push(")),

        ArrayVariable.parser(),

        skip(spaces()),
        ignore(string(",")),
        skip(spaces()),

        Identifier.parser(),

        ignore(string(")")),

        skip(newline())
      ]),
      fn [array_variable, value] -> %MacroCompiler.PushExpression{array_variable: array_variable, value: value} end
    )
  end
end
