use lib './mock';
use Commands;
use Plugins;
require "./codes/$ARGV[0].pl";

if ($ARGV[1] != "0") {
  macroCompiled::macro_Test();
}

if ($ARGV[2]) {
  &$Commands::commandHandle('macroCompiled', $ARGV[2]);
}
