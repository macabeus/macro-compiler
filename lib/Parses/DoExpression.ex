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

        option(word())
      ]),
      fn [action] -> %MacroCompiler.DoExpression{action: action} end
    )
  end
end
