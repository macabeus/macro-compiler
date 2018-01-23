defmodule MacroCompiler.PauseExpression do
  use Combine
  use Combine.Helpers

  @enforce_keys [:seconds]
  defstruct [:seconds]

  def parser() do
    map(
      sequence([
        ignore(string("pause")),
        skip(spaces()),

        option(either(
          float(),
          integer()
        )),
        skip(char(?\n))
      ]),
      fn [seconds] -> %MacroCompiler.PauseExpression{seconds: seconds} end
    )
  end
end
