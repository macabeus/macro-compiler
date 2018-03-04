defmodule MacroCompiler.Parser.PauseCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.PauseCommand

  @enforce_keys [:seconds]
  defstruct [:seconds]

  parser_command do
    sequence([
      ignore(string("pause")),
      skip(spaces()),

      option(either(
        float(),
        integer()
      )),
      skip(char(?\n))
    ])
  end

  def map_command([seconds]) do
    %PauseCommand{seconds: seconds}
  end
end
