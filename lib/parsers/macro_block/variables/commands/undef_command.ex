defmodule MacroCompiler.Parser.UndefCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.UndefCommand
  alias MacroCompiler.Parser.ScalarVariable

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  def parser() do
    map(
      sequence([
        ScalarVariable.parser(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        ignore(choice([
          string("undef"),
          string("unset")
        ])),

        ignore(char(?\n))
      ]),
      fn [scalar_variable] -> %UndefCommand{scalar_variable: scalar_variable} end
    )
  end
end
