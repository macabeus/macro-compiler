package Log;

use Exporter 'import';

our @EXPORT_OK = qw(message);

sub message {
  print @_;
}

1;

