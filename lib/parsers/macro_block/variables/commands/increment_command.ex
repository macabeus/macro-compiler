defmodule MacroCompiler.Parser.IncrementCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.IncrementCommand
  alias MacroCompiler.Parser.ScalarVariable

  @enforce_keys [:scalar_variable]
  defstruct [:scalar_variable]

  parser_command do
    sequence([
      ScalarVariable.parser(),

      ignore(string("++"))
    ])
  end

  def map_command([scalar_variable]) do
    %IncrementCommand{scalar_variable: scalar_variable}
  end
end
