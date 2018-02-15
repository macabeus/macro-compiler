defmodule MacroCompiler.Parser.HashAssignmentCommand do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.HashAssignmentCommand
  alias MacroCompiler.Parser.HashVariable
  alias MacroCompiler.Parser.Identifier
  alias MacroCompiler.Parser.TextValue

  @enforce_keys [:hash_variable, :keystexts]
  defstruct [:hash_variable, :keystexts]

  def parser() do
    map(
      sequence([
        HashVariable.parser(),

        skip(spaces()),
        ignore(string("=")),
        skip(spaces()),

        ignore(char("(")),

        sep_by(
          sequence([
            Identifier.parser(),
            ignore(spaces()),
            ignore(string("=>")),
            ignore(spaces()),
            TextValue.parser()
          ]),

          sequence([
            char(","),
            skip(spaces())
          ])
        ),

        ignore(char(")")),

        skip(char(?\n))
      ]),
      fn [hash_variable, keystexts] -> %HashAssignmentCommand{hash_variable: hash_variable, keystexts: keystexts} end
    )
  end
end
