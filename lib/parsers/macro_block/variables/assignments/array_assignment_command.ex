defmodule MacroCompiler.Parser.ArrayAssignmentCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.ArrayAssignmentCommand
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:array_variable, :texts]
  defstruct [:array_variable, :texts]

  parser_command do
    sequence([
      ArrayVariable.parser(),

      skip(spaces()),
      ignore(string("=")),
      skip(spaces()),

      ignore(char("(")),

      sep_by(
        TextValue.parser(),
        sequence([
          char(","),
          skip(spaces())
        ])
      ),

      ignore(char(")"))
    ])
  end

  def map_command([scalar_variable, texts]) do
    %ArrayAssignmentCommand{array_variable: scalar_variable, texts: texts}
  end
end
