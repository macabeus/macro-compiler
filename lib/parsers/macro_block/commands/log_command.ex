defmodule MacroCompiler.Parser.LogCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.TextValue

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
      fn [text] -> %LogCommand{text: text} end
    )
  end
end
