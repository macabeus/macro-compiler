defmodule MacroCompiler.Parser.ScalarVariable do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser
  import MacroCompiler.Parser.Lazy

  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.Identifier
  alias MacroCompiler.Parser.RandCommand

  alias Combine.ParserState

  @enforce_keys [:name, :array_position, :hash_position]
  defstruct [:name, :array_position, :hash_position]

  parser_command do
    sequence([
      ignore(string("$")),
      Identifier.parser(),

      option(
        between(
          char("["),
          choice([
            lazy(ScalarVariable.parser()),
            lazy(RandCommand.parser()),
            integer()
          ]),
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
