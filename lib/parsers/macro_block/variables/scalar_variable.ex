defmodule MacroCompiler.Parser.ScalarVariable do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.Identifier
  alias MacroCompiler.Parser.ScalarValue

  @enforce_keys [:name, :array_position, :hash_position]
  defstruct [:name, :array_position, :hash_position]

  parser_command do
    sequence([
      ignore(string("$")),
      Identifier.parser(),

      option(
        between(
          char("["),
          ScalarValue.parser(),
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
    ])
  end

  def map_command([name, array_position, hash_position]) do
    %ScalarVariable{name: name, array_position: array_position, hash_position: hash_position}
  end
end
