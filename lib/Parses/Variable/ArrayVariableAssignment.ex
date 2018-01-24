defmodule MacroCompiler.ArrayVariableAssignment do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable

  @enforce_keys [:array_variable, :values]
  defstruct [:array_variable, :values]

  def parser() do
    map(
      sequence([
        ArrayVariable.parser(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        ignore(char("(")),

        sep_by(
          word(),
          sequence([
            char(","),
            skip(spaces())
          ])
        ),

        ignore(char(")")),

        skip(char(?\n))
      ]),
      fn [scalar_variable, values] -> %MacroCompiler.ArrayVariableAssignment{array_variable: scalar_variable, values: values} end
    )
  end
end
