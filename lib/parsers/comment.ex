defmodule MacroCompiler.Parser.Comment do
  use Combine
  use Combine.Helpers

  def parser() do
    sequence([
      ignore(char("#")),
      
      take_while(
        fn ?\n -> false;

           _ -> true
         end
      )
    ])
  end
end
