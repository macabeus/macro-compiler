defmodule MacroCompiler.Parser.ShiftCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.ShiftCommand
  alias MacroCompiler.Parser.ArrayVariable

  @enforce_keys [:array_variable]
  defstruct [:array_variable]

  def parser() do
    map(
      sequence([
        ignore(string("&shift(")),

        ArrayVariable.parser(),

        ignore(string(")")),

        skip(newline())
      ]),
      fn [array_variable] -> %ShiftCommand{array_variable: array_variable} end
    )
  end
end
