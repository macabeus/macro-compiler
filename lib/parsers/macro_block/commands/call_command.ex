defmodule MacroCompiler.Parser.CallCommand do
  use Combine
  use Combine.Helpers

  import MacroCompiler.Parser

  alias MacroCompiler.Parser.CallCommand
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:macro, :params]
  defstruct [:macro, :params]

  parser_command do
    sequence([
      ignore(string("call")),
      ignore(spaces()),

      Identifier.parser(),

      either(
        ignore(char(?\n)),

        many(
          between(
            sequence([
              spaces(),
              char(?")
            ]),

            take_while(fn ?" -> false; _ -> true end),

            char(?")
          )
        )
      )
    ])
  end

  def map_command([macro]) do
    %CallCommand{macro: macro, params: []}
  end

  def map_command([macro, params]) do
    %CallCommand{macro: macro, params: params |> Enum.map(&List.to_string/1)}
  end
end
