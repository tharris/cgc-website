# Tests App::Util modules

use strict;
use warnings;

use lib qw(t/lib lib);

use Test::Unit::HarnessUnit;
my $runner = Test::Unit::HarnessUnit->new();
$runner->start('App::Util::MonkeyPatcherTest');

