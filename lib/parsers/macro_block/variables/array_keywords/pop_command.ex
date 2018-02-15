defmodule MacroCompiler.Parser.PopCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.PopCommand
  alias MacroCompiler.Parser.ArrayVariable

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
      fn [array_variable] -> %PopCommand{array_variable: array_variable} end
    )
  end
end
