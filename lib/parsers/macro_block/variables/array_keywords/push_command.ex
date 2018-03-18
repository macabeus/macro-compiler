defmodule MacroCompiler.Parser.PushCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.PushCommand
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:array_variable, :text]
  defstruct [:array_variable, :text]

  parser_command do
    sequence([
      ignore(string("&push(")),

      ArrayVariable.parser(),

      skip(spaces()),
      ignore(string(",")),
      skip(spaces()),

      TextValue.parser(),

      ignore(string(")"))
    ])
  end

  def map_command([array_variable, text]) do
    %PushCommand{array_variable: array_variable, text: text}
  end
end
