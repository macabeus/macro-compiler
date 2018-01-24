defmodule MacroCompiler.HashVariableAssignment do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.HashVariable
  alias MacroCompiler.Identifier

  @enforce_keys [:hash_variable, :keysvalues]
  defstruct [:hash_variable, :keysvalues]

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
            Identifier.parser()
          ]),
          
          sequence([
            char(","),
            skip(spaces())
          ])
        ),

        ignore(char(")")),

        skip(char(?\n))
      ]),
      fn [hash_variable, keysvalues] -> %MacroCompiler.HashVariableAssignment{hash_variable: hash_variable, keysvalues: keysvalues} end
    )
  end
end
