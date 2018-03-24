defmodule MacroCompiler.Parser.RandCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.RandCommand
  alias MacroCompiler.Parser.TextValue
  alias MacroCompiler.Parser.ScalarVariable

  @enforce_keys [:min, :max]
  defstruct [:min, :max]

  parser_command do
    sequence([
      ignore(string("&rand(")),

      choice([
        ScalarVariable.parser(),
        TextValue.parser()
      ]),

      ignore(char(",")),
      skip(spaces()),

      choice([
        ScalarVariable.parser(),
        TextValue.parser()
      ]),

      ignore(char(")"))
    ])
  end

  def map_command([min, max]) do
    %RandCommand{min: min, max: max}
  end
end
