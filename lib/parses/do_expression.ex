defmodule MacroCompiler.DoExpression do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.TextValue

  @enforce_keys [:text]
  defstruct [:text]

  def parser() do
    map(
      sequence([
        ignore(string("do")),
        skip(space()),

        TextValue.parser(false)
      ]),
      fn [text] -> %MacroCompiler.DoExpression{text: text} end
    )
  end
end
