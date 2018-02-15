defmodule MacroCompiler.Parser.Identifier do
  use Combine
  use Combine.Helpers

  def parser() do
    map(
      take_while(
        fn 0x20 -> false;
           ?\n -> false;
           ?, -> false;
           ?( -> false;
           ?) -> false;
           ?[ -> false;
           ?] -> false;
           ?{ -> false;
           ?} -> false;
           ?+ -> false;
           ?- -> false;

           _ -> true
         end
      ),
      fn name -> List.to_string(name) end
    )
  end
end
