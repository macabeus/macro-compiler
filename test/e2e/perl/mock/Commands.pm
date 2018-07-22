package Commands;

use Exporter 'import';
use strict;

our $commandHandle;

our @EXPORT_OK = qw(register);

sub register {
  foreach my $command (@_) {
    my ($name, $desc, $func) = @$command;
    $commandHandle = $func;
  }
}

1;

