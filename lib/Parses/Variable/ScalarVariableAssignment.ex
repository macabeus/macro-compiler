defmodule MacroCompiler.ScalarVariableAssignment do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ScalarVariable

  @enforce_keys [:scalar_variable, :value]
  defstruct [:scalar_variable, :value]

  def parser() do
    map(
      sequence([
        ScalarVariable.parser(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        take_while(fn ?\n -> false; _ -> true end)
      ]),
      fn [scalar_variable, value] -> %MacroCompiler.ScalarVariableAssignment{scalar_variable: scalar_variable, value: value |> List.to_string} end
    )
  end
end
