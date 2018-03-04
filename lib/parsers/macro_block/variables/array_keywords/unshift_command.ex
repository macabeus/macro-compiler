defmodule MacroCompiler.Parser.UnshiftCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.UnshiftCommand
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:array_variable, :text]
  defstruct [:array_variable, :text]

  parser_command do
    sequence([
      ignore(string("&unshift(")),

      ArrayVariable.parser(),

      skip(spaces()),
      ignore(string(",")),
      skip(spaces()),

      TextValue.parser(),

      ignore(string(")")),

      skip(newline())
    ])
  end

  def map_command([array_variable, text]) do
    %UnshiftCommand{array_variable: array_variable, text: text}
  end
end
