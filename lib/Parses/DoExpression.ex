defmodule MacroCompiler.DoExpression do
  use Combine
  use Combine.Helpers

  @enforce_keys [:action]
  defstruct [:action]

  def parser() do
    map(
      sequence([
        ignore(string("do")),
        skip(space()),

        take_while(fn ?\n -> false; _ -> true end)
      ]),
      fn [action] -> %MacroCompiler.DoExpression{action: action |> List.to_string} end
    )
  end
end
