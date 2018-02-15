defmodule MacroCompiler.Parser.PauseCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.PauseCommand

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
      fn [seconds] -> %PauseCommand{seconds: seconds} end
    )
  end
end
