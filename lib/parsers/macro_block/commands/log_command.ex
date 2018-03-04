defmodule MacroCompiler.Parser.LogCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.LogCommand
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:text]
  defstruct [:text]

  parser_command do
    sequence([
      ignore(string("log")),
      ignore(spaces()),

      TextValue.parser(false),

      skip(char(?\n))
    ])
  end

  def map_command([text]) do
    %LogCommand{text: text}
  end
end
