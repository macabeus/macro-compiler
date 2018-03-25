defmodule MacroCompiler.Parser.RandomCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.RandomCommand
  alias MacroCompiler.Parser.ScalarValue

  @enforce_keys [:values]
  defstruct [:values]

  parser_command do
    sequence([
      ignore(string("&random(")),

      sep_by(
        ScalarValue.parser(),

        sequence([
          char(?,),
          skip(spaces())
        ])
      ),

      ignore(char(?)))
    ])
  end

  def map_command([values]) do
    %RandomCommand{values: values}
  end
end
