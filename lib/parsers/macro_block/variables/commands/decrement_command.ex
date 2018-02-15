defmodule MacroCompiler.Parser.DecrementCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.DecrementCommand
  alias MacroCompiler.Parser.ScalarVariable

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  def parser() do
    map(
      sequence([
        ScalarVariable.parser(),

        ignore(string("--")),

        skip(newline())
      ]),
      fn [scalar_variable] -> %DecrementCommand{scalar_variable: scalar_variable} end
    )
  end
end
