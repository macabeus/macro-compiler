<h1 align="center"> MacroCompiler </h1> <br>
<p align="center">
  <a href="">
    <img alt="Logo" src="https://i.imgur.com/QeSM2Ca.png" width="108">
  </a>
</p>

>Best way to create macro.

MacroCompiler is a compiler from the awesome [EventMacro](http://openkore.com/index.php/EventMacro) to [OpenKore](https://github.com/OpenKore/openkore/) plugin (that is, Perl).

This project aim to offer a faster, more secure and more flexible alternative to run macros on OpenKore.

**Faster** because the OpenKore doesn't need interprete a Macro code to then run Perl code. Now it run Perl code directly.
**More secure** because the compiler show errors, then you can fix it before run the bot.
**More flexible** because is more easy add new feature in a compiler than a regex-based interpreter.

>Hey! Warning: This project is under in construction, then it's incomplete and only have a tiny subset of EventMacro commands.

# Example

The macro

```
macro save {
  $map = prontera
  do move $map 151 29
  do talknpc 151 29 c r0
  call sayHello
}

macro sayHello {
  do c hello to everyone!
}
```

will compile to

```
package macroCompiled;
use Commands;
my $map;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_save {
$map = "prontera";
Commands::run("move $map 151 29");
Commands::run("talknpc 151 29 c r0");
&macro_sayHello();
}
sub macro_sayHello {
Commands::run("c hello to everyone!");
}
```

Then you will can use this plugin.

# How to run

You must have Elixir in your computer. [Read here how to install it](https://elixir-lang.org/install.html).

To compiler your macro, run this command:

```
mix run lib/macrocompiler.ex path/of/eventMacro.txt > macro.pl
```
