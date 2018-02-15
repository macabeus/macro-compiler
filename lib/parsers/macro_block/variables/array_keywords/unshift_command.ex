defmodule MacroCompiler.Parser.UnshiftCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.UnshiftCommand
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.TextValue

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
      fn [array_variable, text] -> %UnshiftCommand{array_variable: array_variable, text: text} end
    )
  end
end
