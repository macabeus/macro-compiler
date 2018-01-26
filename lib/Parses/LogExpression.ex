defmodule MacroCompiler.LogExpression do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.TextValue

  @enforce_keys [:text]
  defstruct [:text]

  def parser() do
    map(
      sequence([
        ignore(string("log")),
        ignore(spaces()),

        TextValue.parser(false),

        skip(char(?\n))
      ]),
      fn [text] -> %MacroCompiler.LogExpression{text: text} end
    )
  end
end
