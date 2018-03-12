defmodule MacroCompiler.Parser.DeleteCommand do
  use Combine

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.DeleteCommand

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  parser_command do
    sequence([
      ignore(string("&delete(")),

      ScalarVariable.parser(),

      ignore(string(")")),

      skip(newline())
    ])
  end

  def map_command([scalar_variable]) do
    %DeleteCommand{scalar_variable: scalar_variable}
  end
end
