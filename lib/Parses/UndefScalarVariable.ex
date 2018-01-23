defmodule MacroCompiler.UndefScalarVariable do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.Identifier

  @enforce_keys [:name]
  defstruct [:name]

  def parser() do
    map(
      sequence([
        ignore(string("$")),
        Identifier.parser(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        ignore(choice([
          string("undef"),
          string("unset")
        ])),

        ignore(char(?\n))
      ]),
      fn [name] -> %MacroCompiler.UndefScalarVariable{name: name} end
    )
  end
end
