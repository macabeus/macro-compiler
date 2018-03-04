defmodule MacroCompiler.Parser.DoCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.DoCommand
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:text]
  defstruct [:text]

  parser_command do
    sequence([
      ignore(string("do")),
      skip(space()),

      TextValue.parser(false)
    ])
  end

  def map_command([text]) do
    %DoCommand{text: text}
  end
end
