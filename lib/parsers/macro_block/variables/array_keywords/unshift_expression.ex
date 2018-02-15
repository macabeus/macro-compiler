defmodule MacroCompiler.UnshiftExpression do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.TextValue

  @enforce_keys [:array_variable, :text]
  defstruct [:array_variable, :text]

  def parser() do
    map(
      sequence([
        ignore(string("&unshift(")),

        ArrayVariable.parser(),

        skip(spaces()),
        ignore(string(",")),
        skip(spaces()),

        TextValue.parser(),

        ignore(string(")")),

        skip(newline())
      ]),
      fn [array_variable, text] -> %MacroCompiler.UnshiftExpression{array_variable: array_variable, text: text} end
    )
  end
end
