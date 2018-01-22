defmodule MacroCompiler.UndefScalarVariable do
  use Combine
  use Combine.Helpers

  @enforce_keys [:name]
  defstruct [:name]

  def parser() do
    map(
      sequence([
        ignore(string("$")),
        word(),

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
