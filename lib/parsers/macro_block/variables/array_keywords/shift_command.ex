defmodule MacroCompiler.Parser.ShiftCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ShiftCommand
  alias MacroCompiler.Parser.ArrayVariable

  @enforce_keys [:array_variable]
  defstruct [:array_variable]

  parser_command do
    sequence([
      ignore(string("&shift(")),

      ArrayVariable.parser(),

      ignore(string(")")),

      skip(newline())
    ])
  end

  def map_command([array_variable]) do
    %ShiftCommand{array_variable: array_variable}
  end
end
