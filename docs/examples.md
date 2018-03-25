# Examples

This is a page with examples of codes compiled from EventMacro to OpenKore plugin (Perl)

## Scalar variables

```
macro scalarVariables {
  # Scalar variables declaration
  $foo = 1
  $bar = bar
  $baz = The $foo and $bar

  # Logs
  log \$foo value: $foo
  log \$bar value: $bar
  log \$baz value: $baz
}
```

```
package macroCompiled;
use Log qw(message);
my $bar;
my $baz;
my $foo;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_scalarVariables {
  $foo = "1";
  $bar = "bar";
  $baz = "The $foo and $bar";

  message "\$foo value: $foo"."\n";
  message "\$bar value: $bar"."\n";
  message "\$baz value: $baz"."\n";
}
```

## Array variables

```
macro arrayVariables {
  # Array variable declaration
  @array = (prontera, 42, don't panic)

  # Array variable manipulation
  $firstElement = $array[0]
  log The first element is $firstElement
  
  log And the second element is $array[1]

  &push(@array, openkore)
  log \@array now has @array elements

  &shift(@array)
  log \@array now has @array elements
}
```

```
package macroCompiled;
use Log qw(message);
my $firstElement;
my @array;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_arrayVariables {
  @array = ("prontera","42","don't panic");
  
  $firstElement = $array["0"];
  message "The first element is $firstElement"."\n";
  
  message "And the second element is ".$array["1"].""."\n";
  
  push @array,"openkore";
  message "\@array now has ".scalar(@array)." elements"."\n";
  
  shift @array;
  message "\@array now has ".scalar(@array)." elements"."\n";
}
```

## Hash variable

```
macro hashVariables {
  # Hash variable declaration
  %hash = (city => prontera, goodNumber => 42, message => don't panic)

  # Hash variable manipulation
  $city = $hash{city}
  log The city element is $city

  log And the good number is $hash{goodNumber}

  &delete($hash{message})
  log \%hash now has %hash elements

  @keys = &keys(%hash)
  log The keys is $keys[0] and $keys[1]

  @values = &values(%hash)
  log And the values is $values[0] and $values[1]
}
```

```
package macroCompiled;
use Log qw(message);
my $city;
my %hash;
my @keys;
my @values;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_hashVariables {
  %hash = ("city" => "prontera","goodNumber" => "42","message" => "don't panic");

  $city = $hash{city};
  message "The city element is $city"."\n";

  message "And the good number is $hash{goodNumber}"."\n";

  delete $hash{message};
  message "\%hash now has ".scalar(keys %hash)." elements"."\n";

  @keys = keys %hash;
  message "The keys is ".$keys["0"]." and ".$keys["1"].""."\n";

  @values = values %hash;
  message "And the values is ".$values["0"]." and ".$values["1"].""."\n";
}
```

## Random

```
macro goToRandomCity {
  $min = 2
  $randomNumber = &rand($min, 10)
  log The random number is $randomNumber

  @cities = (prontera, payon, geffen, morroc)
  $randomCity = $cities[&rand(0, 3)]

  log I'll go to $randomCity !
  do move $randomCity
}
```

```
package macroCompiled;
use Commands;
use Log qw(message);
my $min;
my $randomCity;
my $randomNumber;
my @cities;
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_goToRandomCity {
  $min = "2";
  $randomNumber = ($min + int(rand(1 + "10" - $min)));
  message "The random number is $randomNumber"."\n";
  
  @cities = ("prontera","payon","geffen","morroc");
  $randomCity = $cities[("0" + int(rand(1 + "3" - "0")))];

  message "I'll go to $randomCity !"."\n";
  Commands::run("move $randomCity");
}
```

## Calling function

```
macro a {
  log I'll call another macro
  call b
}

macro b {
  log Macro b called!
}
```

```
package macroCompiled;
use Log qw(message);
Plugins::register('macroCompiled', 'Compiled version of eventMacro.txt', &on_unload);
sub on_unload { }

sub macro_a {
  message "I'll call another macro"."\n";
  &macro_b();
}
sub macro_b {
  message "Macro b called!"."\n";
}
```
