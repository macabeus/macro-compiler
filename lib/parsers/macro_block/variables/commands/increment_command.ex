defmodule MacroCompiler.Parser.IncrementCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.IncrementCommand
  alias MacroCompiler.Parser.ScalarVariable

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  def parser() do
    map(
      sequence([
        ScalarVariable.parser(),

        ignore(string("++")),

        skip(newline())
      ]),
      fn [scalar_variable] -> %IncrementCommand{scalar_variable: scalar_variable} end
    )
  end
end
