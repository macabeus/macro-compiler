defmodule MacroCompiler.Parser.ScalarAssignmentCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:scalar_variable, :text]
  defstruct [:scalar_variable, :text]

  parser_command do
    sequence([
      ScalarVariable.parser(),

      skip(spaces()),
      ignore(string("=")),
      skip(spaces()),

      TextValue.parser()
    ])
  end

  def map_command([scalar_variable, text]) do
    %ScalarAssignmentCommand{scalar_variable: scalar_variable, text: text}
  end
end
