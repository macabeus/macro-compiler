defmodule MacroCompiler.ScalarVariableAssignment do
  use Combine
  use Combine.Helpers

  @enforce_keys [:name, :value]
  defstruct [:name, :value]

  def parser() do
    map(
      sequence([
        ignore(string("$")),
        word(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        take_while(fn ?\n -> false; _ -> true end)
      ]),
      fn [name, value] -> %MacroCompiler.ScalarVariableAssignment{name: name, value: value |> List.to_string} end
    )
  end
end
