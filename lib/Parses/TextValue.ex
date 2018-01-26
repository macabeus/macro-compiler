defmodule MacroCompiler.TextValue do
  use Combine
  use Combine.Helpers
  alias MacroCompiler.ArrayVariable
  alias MacroCompiler.HashVariable

  @enforce_keys [:values]
  defstruct [:values]

  defp get_char(limited) do
    if limited do
      satisfy(char(),
      fn "\n" -> false;
        "," -> false;
        "(" -> false;
        ")" -> false;
        "{" -> false;
        "}" -> false;
        "+" -> false;
        "-" -> false;

          _ -> true
        end)
    else
      satisfy(char(),
        fn "\n" -> false;

          _ -> true
        end)
    end
  end

  def parser(limited \\ true) do
    map(
      many(
        choice([
          map(string("\\,"), fn _ -> "," end),
          string("\\@"),
          string("\\%"),
          ArrayVariable.parser(),
          HashVariable.parser(),
          get_char(limited)
        ])
      ),
      fn values -> %MacroCompiler.TextValue{values: values} end
    )
  end
end
