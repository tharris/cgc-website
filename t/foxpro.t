# Tests FoxPro import functionality

use strict;
use warnings;

use Test::More qw/no_plan/;

use FoxPro::Parser;
use FoxPro::Record;

my $dump1  = 't/data/foxpro_dump1.txt';
my $parser = FoxPro::Parser->new();
ok($parser, "Should obtain a valid parser object");

$parser->filename($dump1);
is($dump1, $parser->filename, "Should have set filename");

while (my $record = $parser->next_record()) {
    ok($record, "Should have an initial record");
    is($record->num_columns, 9, "Incorrect column count");
}
is($parser->records_processed, 29, "Wrong number of records");
