defmodule MacroCompiler.Parser.ScalarAssignmentCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.ScalarAssignmentCommand
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:scalar_variable, :text]
  defstruct [:scalar_variable, :text]

  def parser() do
    map(
      sequence([
        ScalarVariable.parser(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        TextValue.parser()
      ]),
      fn [scalar_variable, text] -> %ScalarAssignmentCommand{scalar_variable: scalar_variable, text: text} end
    )
  end
end
