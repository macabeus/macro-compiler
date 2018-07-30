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

  test_equivalents_ast(
    "Should propagate the constant value still it was written outside of 'if' block",
    """
      macro Test {
        $foo = 1

        if ($.zeny > 500) {
          log $foo
        }
      }
    """,
    """
      macro Test {
        $foo = 1

        if ($.zeny > 500) {
          log 1
        }
      }
    """
  )

  test_different_ast(
    "Should keep variable reference if it was written in an 'if' block",
    """
      macro Test {
        $foo = 1
        $foo = 2 if ($.zeny > 500)
        log $foo
      }
    """,
    """
      macro Test {
        $foo = 1
        $foo = 2 if ($.zeny > 500)
        log 1
      }
    """
  )

  test_different_ast(
    "Should not propagate the constant value if the variable was written inside of 'if' block",
    """
      macro Test {
        $foo = 1

        if ($.zeny > 500) {
          $bar = 22
        }

        log $baz
      }
    """,
    """
      macro Test {
        $foo = 1

        if ($.zeny > 500) {
          $bar = 22
        }

        log 22
      }
    """
  )
end

