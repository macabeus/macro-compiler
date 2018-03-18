defmodule MacroCompiler.Parser.BlankSpaces do
  use Combine
  use Combine.Helpers

  def parser() do
    take_while(
      fn ?\s -> true;
         ?\n -> true;
         ?\t -> true;

         _ -> false
       end
    )
  end
end
