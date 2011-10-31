#!/usr/bin/env perl

use strict;
use warnings;

use FoxPro::Parser;

MAIN: {
	my $parser = FoxPro::Parser->new();
	$parser->filename($ARGV[0]);
	while (my $record = $parser->next_record()) {
	    print $record->as_tsv(), "\n";
	}
}

1;

=head1 NAME

foxpro_parser.pl - Parses FoxPro dumps

=head1 SYNOPSIS



=head1 DESCRIPTION



=head1 AUTHOR

Shiran Pasternak, C<shiranpasternak@gmail.com>

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
