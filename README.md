<h1 align="center"> MacroCompiler </h1> <br>
<p align="center">
  <a href="">
    <img alt="Logo" src="https://i.imgur.com/QeSM2Ca.png" width="108">
  </a>
</p>

>The best way to create macros.

MacroCompiler compiles from the language [EventMacro](http://openkore.com/index.php/EventMacro) to [OpenKore](https://github.com/OpenKore/openkore/) plugin (that is, Perl). EventMacro is a language to automate the actions from OpenKore – the bot used in the Rangarok online game. It compiles to Perl since OpenKore itself is written in Perl.

Using the EventMacro you can configure the bot to complete quests or to buy itens, for example. Currently the only solution to run EventMacro on OpenKore is using a regex-based interpreter, but it's a bad solution. This project aims to offer a faster, more secure and more flexible alternative to run macros on OpenKore.

**Faster** because the OpenKore doesn't need to interpret a Macro code to then run Perl code. Now it runs Perl code directly. And the compiler can optimize the EventMacro.
**More secure** because the compiler shows errors, then you can fix them before running the bot.
**More flexible** because it's easier to add new features in a compiler than a regex-based interpreter.

>Hey! Warning: This project is under construction, then it's incomplete and it only has a tiny subset of EventMacro commands.

# Example

The macro

```
macro goToRandomCity {
  @cities = (prontera, payon, geffen, morroc)
  $randomCity = $cities[&rand(0, 3)]
 
  log I'll go to $randomCity !
  do move $randomCity
}
```

will compile to

```
package macroCompiled;
use Log qw(message);
my $randomCity;
my @cities;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_goToRandomCity {
  @cities = ("prontera","payon","geffen","morroc");
  $randomCity = $cities[("0" + int(rand(1 + "3" - "0")))];
  message "I'll go to $randomCity !"."\n";
  Commands::run("move $randomCity");
}

```

Then you could use this plugin.

# How to run

You must have Elixir in your computer. [You could read here how to install it](https://elixir-lang.org/install.html).

To compile your macro, you need to run this command:

```
mix run lib/macrocompiler.ex path/of/eventMacro.txt > macro.pl
````
