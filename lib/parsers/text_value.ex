defmodule MacroCompiler.Parser.TextValue do
  use Combine
  use Combine.Helpers

  alias MacroCompiler.Parser.TextValue
  alias MacroCompiler.Parser.ScalarVariable
  alias MacroCompiler.Parser.ArrayVariable
  alias MacroCompiler.Parser.HashVariable

  @enforce_keys [:values]
  defstruct [:values]

  defp get_char(limited) do
    if limited do
      satisfy(
        char(),
        fn
          "\n" -> false;
          "#"  -> false;
          ","  -> false;
          "("  -> false;
          ")"  -> false;
          "]"  -> false;
          "{"  -> false;
          "}"  -> false;
          "+"  -> false;
          "-"  -> false;
          " "  -> false;

          _    -> true
        end
      )
    else
      satisfy(
        char(),
        fn
          "\n" -> false;
          "#"  -> false;

          _  -> true
        end
      )
    end
  end

  def if_is_not_postfix_if(block) do
    if_not(
      sequence([
        spaces(),
        string("if"),
        spaces(),
        char(?()
      ]),
      block
    )
  end

  def parser(limited \\ true) do
    map(
      many(
        choice([
          map(string("\\,"), fn _ -> "," end),
          string("\\$"),
          string("\\@"),
          string("\\%"),
          string("\\#"),
          ScalarVariable.parser(),
          ArrayVariable.parser(),
          HashVariable.parser(),
          if_is_not_postfix_if(
            get_char(limited)
          )
        ])
      ),
      fn values -> %TextValue{values: values} end
    )
  end
end
