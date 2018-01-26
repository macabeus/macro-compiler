defmodule MacroCompiler.ScalarVariableAssignment do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ScalarVariable
  alias MacroCompiler.TextValue

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
      fn [scalar_variable, text] -> %MacroCompiler.ScalarVariableAssignment{scalar_variable: scalar_variable, text: text} end
    )
  end
end
