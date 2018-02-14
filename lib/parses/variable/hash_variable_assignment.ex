defmodule MacroCompiler.HashVariableAssignment do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.HashVariable
  alias MacroCompiler.Identifier
  alias MacroCompiler.TextValue

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
      fn [hash_variable, keystexts] -> %MacroCompiler.HashVariableAssignment{hash_variable: hash_variable, keystexts: keystexts} end
    )
  end
end
