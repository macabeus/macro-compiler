defmodule MacroCompiler.ArrayVariableAssignment do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.TextValue

  @enforce_keys [:array_variable, :texts]
  defstruct [:array_variable, :texts]

  def parser() do
    map(
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

        ignore(char(")")),

        skip(char(?\n))
      ]),
      fn [scalar_variable, texts] -> %MacroCompiler.ArrayVariableAssignment{array_variable: scalar_variable, texts: texts} end
    )
  end
end
