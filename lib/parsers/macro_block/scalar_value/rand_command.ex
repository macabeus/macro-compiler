defmodule MacroCompiler.Parser.RandCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.ScalarValue

  @enforce_keys [:min, :max]
  defstruct [:min, :max]

  parser_command do
    sequence([
      ignore(string("&rand(")),

      ScalarValue.parser(),

      ignore(char(",")),
      skip(spaces()),

      ScalarValue.parser(),

      ignore(char(")"))
    ])
  end

  def map_command([min, max]) do
    %RandCommand{min: min, max: max}
  end
end
