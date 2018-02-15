defmodule MacroCompiler.Parser.DoCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.DoCommand
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:text]
  defstruct [:text]

  def parser() do
    map(
      sequence([
        ignore(string("do")),
        skip(space()),

        TextValue.parser(false)
      ]),
      fn [text] -> %DoCommand{text: text} end
    )
  end
end
