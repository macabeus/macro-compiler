defmodule MacroCompiler.UndefScalarVariable do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ScalarVariable

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
      fn [scalar_variable] -> %MacroCompiler.UndefScalarVariable{scalar_variable: scalar_variable} end
    )
  end
end
