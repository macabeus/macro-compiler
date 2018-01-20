defmodule MacroCompiler.LogExpression do
  use Combine
  use Combine.Helpers

  @enforce_keys [:message]
  defstruct [:message]

  def parser() do
    map(
      sequence([
        ignore(string("log")),
        ignore(spaces()),

        take_while(fn ?\n -> false; _ -> true end)
      ]),
      fn [message] -> %MacroCompiler.LogExpression{message: message |> List.to_string} end
    )
  end
end
