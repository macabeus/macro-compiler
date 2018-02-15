defmodule MacroCompiler.Parser.CallCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.CallCommand
  alias MacroCompiler.Parser.Identifier

  @enforce_keys [:macro, :params]
  defstruct [:macro, :params]

  def parser() do
    map(
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
        ),

        skip(char(?\n))
      ]),
      fn [macro] -> %CallCommand{macro: macro, params: []};
         [macro, params] -> %CallCommand{macro: macro, params: params |> Enum.map(&List.to_string/1)} end
    )
  end
end
