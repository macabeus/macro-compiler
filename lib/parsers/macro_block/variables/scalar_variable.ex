defmodule MacroCompiler.Parser.ScalarVariable do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:name, :array_position, :hash_position]
  defstruct [:name, :array_position, :hash_position]

  def parser() do
    map(
      sequence([
        ignore(string("$")),
        Identifier.parser(),

        option(
          between(
            char("["),
            Identifier.parser(),
            char("]")
          )
        ),
        option(
          between(
            char("{"),
            Identifier.parser(),
            char("}")
          )
        )
      ]),
      fn [name, array_position, hash_position] -> %ScalarVariable{name: name, array_position: array_position, hash_position: hash_position} end
    )
  end
end
