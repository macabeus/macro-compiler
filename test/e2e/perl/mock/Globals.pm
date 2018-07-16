###
package Char;

sub new {
  my $class = shift;
  my $self = {
    zeny => shift
  };
}

###
package Globals;

use Exporter 'import';

our @EXPORT_OK = qw($char) ;

our $char = new Char(1000);

1;

