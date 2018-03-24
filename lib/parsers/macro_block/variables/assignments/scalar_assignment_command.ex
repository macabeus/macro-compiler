defmodule MacroCompiler.Parser.ScalarAssignmentCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:scalar_variable, :scalar_value]
  defstruct [:scalar_variable, :scalar_value]

  parser_command do
    sequence([
      ScalarVariable.parser(),

      skip(spaces()),
      ignore(string("=")),
      skip(spaces()),

      choice([
        ScalarVariable.parser(),
        TextValue.parser()
      ])
    ])
  end

  def map_command([scalar_variable, scalar_value]) do
    %ScalarAssignmentCommand{scalar_variable: scalar_variable, scalar_value: scalar_value}
  end
end
