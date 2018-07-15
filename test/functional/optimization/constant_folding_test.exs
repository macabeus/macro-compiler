defmodule MacroCompiler.Test.Functional.ConstantFolding do
  use MacroCompiler.Test.Helper.Optimization

  @optimization MacroCompiler.Optimization.ConstantFolding

  test_equivalents_ast(
    "Should propagate constant scalar value",
    """
      macro Test {
        $foo = 1
        log $foo
      }
    """,
    """
      macro Test {
        $foo = 1
        log 1
      }
    """
  )

  test_equivalents_ast(
    "Should propagate constant scalar value set in macro called",
    """
      macro Test {
        call SetVars
        log $foo $bar $baz
      }

      macro SetVars {
        $foo = 1
        $bar = 2
        $baz = 3
      }
    """,
    """
      macro Test {
        call SetVars
        log 1 2 3
      }

      macro SetVars {
        $foo = 1
        $bar = 2
        $baz = 3
        }
    """
  )
end

