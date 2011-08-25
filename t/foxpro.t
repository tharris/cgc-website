# Tests FoxPro import functionality

use strict;
use warnings;

use Test::More;

use FoxPro::Parser;

my $parser = FoxPro::Parser->new();
ok($parser, "Should obtain a valid parser object");