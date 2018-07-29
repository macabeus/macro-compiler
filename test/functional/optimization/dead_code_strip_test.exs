defmodule MacroCompiler.Test.Functional.DeadCodeStrip do
  use MacroCompiler.Test.Helper.Optimization

  @optimization MacroCompiler.Optimization.DeadCodeStrip

  test_equivalents_ast(
    "Should strip unnecessary variable declaration",
    """
      macro Test {
        $foo = 1
        @bar = (prontera, geffen, morroc)
        %baz = (1 => 2, 3 => 4)
      }
    """,
    """
      macro Test {
      }
    """
  )

  test_equivalents_ast(
    "Should not strip useful variable declaration",
    """
      macro Test {
        $useful = 1
        log $useful
      }
    """,
    """
      macro Test {
        $useful = 1
        log $useful
      }
    """
  )

  test_different_ast(
    "Should keep variable assignment if it is read in an 'if' block",
    """
      macro Test {
        $foo = 1

        if (1) {
          log $foo
        }
      }
    """,
    """
      macro Test {
        if (1) {
          log $foo
        }
      }
    """
  )
end

