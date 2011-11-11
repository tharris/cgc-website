#!/usr/local/bin/perl

use strict;
use warnings;

use feature 'switch';

use Getopt::Long;
use Readonly;
use Pod::Usage;
use IO::Handle;
use Config::Tiny;
use Config::General qw/ParseConfig/;
use File::Spec;
use IO::File;
use Log::Log4perl qw(:easy);
use FindBin;
use lib "$FindBin::Bin/../../lib";

use CGC::Schema;
use App::Util::Import::Parser;

use Data::Dumper;

Readonly my %IMPORTS => (
    lablist => {
        fields => [
            qw(
                updated    flag       code       allele     name
                country    location   namelocat  annfeepd   commercial)
        ],
        primary => 'name',
        type    => 'tsv',
    },
    cgcmail => {
        fields => [
            qw(
                transnum   strain     code       lab_member date
                fee        invoice    invsent    comment
                )
        ],
        primary => 'transnum',
        type    => 'tsv',
    },
    frzloc => {
        fields => [
            qw(
                strain     bigliqloc  liqloc     liqvials   revloc
                revvials   bigliqfrz  liqfrz     revfrz
                )
        ],
        primary => 'strain',
        type    => 'tsv',
    },
    transrec => {
        fields => [
            qw(
                transnum   orderdate  lab_member code       invoice
                ponumber   amountbill annfeeincl invsent    paid
                amountpaid form       comment
                )
        ],
        primary => 'transnum',
        type    => 'tsv',
    },

    # strain => {
    #     fields => [
    #         qw(
    #             strain     species    genotype   description mutagen
    #             outcrossed reference  made_by    received
    #         )
    #     ],
    #     primary => 'name',
    #     type => 'vertical',
    #     extension => 'ego',
    # },
);

MAIN: {
    my (%options);
    GetOptions(\%options, 'conf|c=s', 'dir|d=s', 'help|h|?', 'man',
        'verbose|v:1', 'db=s');
    if ($options{help}) { pod2usage(-verbose => 1); }
    if ($options{man})  { pod2usage(-verbose => 2); }

    $options{conf} ||= './import.ini';
    init_log($options{verbose});
    INFO('Loading import configuration');
    my $conf = load_import_configuration($options{conf});
    $options{dir} ||= '.';
    die "Import directory $options{dir} was not found.\n"
        unless (-e $options{dir});
    die "Import directory $options{dir} is not, in fact, a directory.\n"
        unless (-d $options{dir});

    $options{db} ||= './dbic.conf';
    my $dbconf = load_database_configuration($options{db});

    my (%import);
    for my $key (keys %$conf) {
        $import{$key} = [
            load_import_file(
                dir  => $options{dir},
                key  => $key,
                conf => $conf->{$key}
            )
        ];
    }
    INFO('Loaded all import data.');

    populate_schema(\%import, $dbconf);
    exit 0;
}

=head2 init_log

    Initializes logging based on indicated verbosity

=cut

sub init_log {
    my ($verbose) = @_;
    Readonly my @LEVELS => ($WARN, $INFO, $DEBUG);
    $verbose ||= 0;    # Default to lowest loglevel if not specified
    $verbose = $#LEVELS if $verbose > $#LEVELS;
    my $loglevel = $LEVELS[$verbose];
    Log::Log4perl->easy_init($loglevel);
}

=head2 check_readable_file

    Checks that a given file exists and can be read. Else, die.

=cut

sub check_readable_file {
    my ($filename, $description) = @_;
    $description ||= 'File';
    die "$description $filename was not found.\n"
        unless (-e $filename);
    die "$description $filename cannot be read.\n"
        unless (-r $filename);
}

=head2 load_import_configuration

    Loads the configuration describing the data within the import directory.

=cut

sub load_import_configuration {
    my ($filename) = @_;
    check_readable_file($filename, 'Import configuration');
    my $conf = Config::Tiny->read($filename);
    for my $key (keys %IMPORTS) {
        if (exists $conf->{$key}) {
            my %subhash = %{ $IMPORTS{$key} };
            for my $subkey (keys %subhash) {
                if (!exists $conf->{$key}->{$subkey}) {
                    $conf->{$key}->{$subkey} = $subhash{$subkey};
                }
            }
        } else {
            $conf->{$key} = $IMPORTS{$key};
        }
    }
    return $conf;
}

=head2 load_database_configuration

    Loads database configuration...

=cut

sub load_database_configuration {
    my ($filename) = @_;
    check_readable_file($filename, 'Database configuration');
    return +{ ParseConfig($filename) };
}

=head2 load_import_file

    Loads data in the data file

=cut

sub load_import_file {
    my %params    = ref $_[0] eq 'HASH' ? %{ $_[0] } : @_;
    my $conf      = $params{conf};
    my $extension = $conf->{extension} || $conf->{type};
    my $filename  = File::Spec->catfile($params{dir},
        join('.', $params{key}, $extension));
    check_readable_file($filename, 'Data file');
    INFO("Reading data from $filename");
    my $io = IO::File->new($filename, 'r');
    my (@input, %index);
    my ($primary_idx)
        = grep { $conf->{fields}->[$_] eq $conf->{primary} }
        (0 .. $#{ $conf->{fields} });
    DEBUG("Primary ($conf->{primary}) at index $primary_idx");

    my $process_currier;
    my $process_line;
    given ($conf->{type}) {
        when ('tsv') {
            $process_currier
                = \&App::Util::Import::Parser::curry_tsv_processor;
        }
        when ('vertical') {
            $process_currier
                = \&App::Util::Import::Parser::curry_ego_processor;
        }
    }
    $process_line = $process_currier->(\@input, \%index, $primary_idx);

    while (my $line = <$io>) {
        chomp $line;
        my $fields = $process_line->($line);
    }
    $io->close();
    INFO(
        "Read ",
        scalar @input,
        " lines, indexed to ",
        scalar keys %index,
        " items."
    );
    return (\@input, \%index);
}

=head2 populate_schema

    Populates schema objects with imported data

=cut

sub populate_schema {
    my ($import, $dbconf) = @_;
    my @connect_info = map { $dbconf->{'Model::Schema'}->{connect_info} }
        qw/dsn user password/;
    DEBUG('Connecting to database');
    my $schema = CGC::Schema->connect(@connect_info);
    load_strains($schema, $import->{strain});

    # my $freezer = $schema->resultset('Freezer')->new({ name => 'Shiran' });
    # $freezer->insert();
}

=head1 NAME

    import - Description

=head1 SYNOPSIS

    perl import [options]

    Options:
        -h --help -?
        -c --conf
        -d --dir
        -m --man
        -v --verbose

=head1 OPTIONS

B<-h,--help, -?>
        Print a brief help message and exits.

B<-c --conf>
        Does something cool.
        
B<-d --dir>
        Does something cool.
        
B<-m --man>
        Does something cool.
        
B<-v --verbose>
        Does something cool.
        

=head1 DESCRIPTION

B<This program>
    [Description]

=head1 AUTHOR

    Shiran Pasternak (shiran@cshl.edu)

=head1 COPYRIGHT

    Copyright (c) 2011 Cold Spring Harbor Laboratory.

=cut
