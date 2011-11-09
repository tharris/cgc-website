#!/usr/local/bin/perl

use strict;
use warnings;

use Getopt::Long;
use Readonly;
use Pod::Usage;
use IO::Dir;
use IO::Handle;
use Config::Tiny;
use Data::Dumper;

MAIN: {
    my (%options);
    GetOptions(\%options, 'conf|c=s', 'dir|d=s', 'type|t=s', 'help|h|?',
        'man');
    if ($options{help}) { pod2usage(-verbose => 1); }
    if ($options{man})  { pod2usage(-verbose => 2); }

    $options{conf} ||= './import.conf';
    my $conf = load_import_configuration($options{conf});
    $options{dir} ||= '.';

    print Data::Dumper::Dumper($conf);
    exit 0;

    my $io = IO::Dir->new();
    $io->fdopen($options{input}, 'r')
        or die "Cannot open input file $options{input} for reading:$!\n";
    $io->close();

    exit 0;
}

=head2 load_import_configuration

    Loads the configuration describing the data within the import directory.

=cut
sub load_import_configuration {
    my ($filename) = @_;
    return Config::Tiny->read($filename);
}


=head1 NAME

    import - Description

=head1 SYNOPSIS

    perl import [options]

    Options:
        -h --help

=head1 OPTIONS

B<-h,--help>
        Print a brief help message and exits.

=head1 DESCRIPTION

B<This program>
    [Description]

=head1 AUTHOR

    Shiran Pasternak (shiran@cshl.edu)

=head1 COPYRIGHT

    Copyright (c) 2011 Cold Spring Harbor Laboratory.

=cut
