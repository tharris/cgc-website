#!/usr/bin/perl
#   !/usr/local/bin/perl

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
#use App::Util::Import;
use App::Util::Import::Parser;


use App::Util::ImportNew; # Should be merged to Import;
use Data::Dumper;

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
        Displays a brief help message and exits.

B<-c --conf>
        Optional configuration file for overriding import types and column definitions.
        
B<-d --dir>
        [REQUIRED] Directory containing the data to import (Default: .).
        
B<-m --man>
        Display more verbose help.
        
B<-v --verbose>
        Prints progress, can use an integer value to indicate level (off/0: WARN, on/1: INFO, 2: DEBUG).
        

=head1 DESCRIPTION

B<This program>
    [Description]

=head1 AUTHOR

    Shiran Pasternak (shiranpasternak@gmail.com)

=head1 COPYRIGHT

    Copyright (c) 2011 Shiran Pasternak.

=cut

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
                strain     
                big_liquid_location  liquid_location liquid_vials
                rev_loc rev_vials
                big_liquid_freezer_date  liquid_freezer_date     rev_freezer_data
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
    strain => {
        fields => [
            qw(
                strain     species    genotype   description mutagen
                outcrossed reference  made_by    received
                )
        ],
        primary   => 'strain',
        type      => 'vertical',
        extension => 'ego',
    },
);

MAIN: {
    my (%options);
    GetOptions(\%options, 'conf|c=s', 'dir|d=s', 'help|h|?', 'man',
        'verbose|v:1', 'db=s');
    if ($options{help}) { pod2usage(-verbose => 1); }
    if ($options{man})  { pod2usage(-verbose => 2); }

    init_log($options{verbose});
    INFO('Loading import configuration');
    my $conf = load_import_configuration($options{conf});
    $options{dir} ||= '.';
    pod2usage("Import directory $options{dir} was not found.\n")
        unless (-e $options{dir});
    pod2usage(
        "Import directory $options{dir} is not, in fact, a directory.\n")
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

=head1 METHODS

=cut

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
    pod2usage("$description $filename was not found.\n")
        unless (-e $filename);
    pod2usage("$description $filename cannot be read.\n")
        unless (-r $filename);
}

=head2 load_import_configuration

    Loads the configuration describing the data within the import directory.

=cut

sub load_import_configuration {
    my ($filename) = @_;
    my $conf = {};
    if (defined $filename) {
        check_readable_file($filename, 'Import configuration');
        $conf = Config::Tiny->read($filename);
    }
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
    die "Primary index could not be determined for "
        . " $conf->{type}:$conf->{primary}. Aborting\n"
        unless (defined $primary_idx);
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
    $process_line
        = $process_currier->(\@input, \%index, $primary_idx, $conf->{fields});

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
    my @connect_info = map { $dbconf->{'CGC::Schema'}->{connect_info} }
        qw/dsn user password/;
    DEBUG('Connecting to database');
    my $schema = CGC::Schema->connect(@connect_info);
#    populate_strains($schema, $import->{strain});
#    populate_laboratories($schema, $import->{lablist});
    populate_freezers($schema, $import->{frzloc});
#    populate_transactions($schema, $import->{transrec});
}

=head2 populate_strains

    Populate strain data in the database

=cut

sub populate_strains {
    my ($schema, $strains) = @_;

#    my $importer = App::Util::ImportNew->new();

    # Open cache log for writing.
#    my $log  = join('/',$importer->import_log_dir,"strains-cgc-merge.log");
    # Hard-coded for now.  Need to merge Import/ImportNew and import.pl functionality
    my $log  = join('/','/usr/local/wormbase/todd/cgc-website/logs/import_logs',"strains-cgc-merge.log");
    open OUT,">>$log";

    my $finder = sub {
        my ($input, $table, $column) = @_;
        my $value;
        eval "\$value = \$input->$column";
        return update_or_create($schema, $table, { name => $value });
    };

    my $resultset = $schema->resultset('Strain');
    for my $input (@{ $strains->[0] }) {
	my $row = $resultset->find( { name    => $input->strain },
				    { primary => 'strain_name_unique' } );
	if ($row) {
	    print OUT "CGC strain " . $input->strain . " found in database already: updating...\n";	    
	    foreach my $field (@{ $IMPORTS{strain}->{fields} }) {		

		next if $field eq 'reference';  # not using this field.
		my $db_col = ($field eq 'strain') ? 'name' : $field;  # hack: field name different than db col name.
		my $input_val = $input->$field;

		my $db_val;
		if ($field eq 'species' || $field eq 'mutagen') {
		    $db_val    = $row->$db_col->name;
		} else {
		    $db_val    = $row->$db_col;
		}

		# Clean up the genotype
#		if ($field eq 'genotype') {
#		    $input_val =~ s/\.$//;
#		}		

		if ($input_val ne $db_val) { print OUT "\t$db_col changed from " 
						 . "\n\t\t" . $db_val 
						 . "\n\t\t" . $input_val . "\n" }
	    }
	} else {
	    print OUT "------> FOUND A STRAIN NOT PRESENT IN WORMBASE: " . $input->strain . "\n";
	}
	next;
	my $strain = $resultset->update_or_create(
	    {   name        => $input->strain,
#		description => $input->description,
#                received    => $input->received,
                made_by     => $input->made_by,
                outcrossed  => $input->outcrossed,
                mutagen     => $finder->($input, 'Mutagen', 'mutagen'),
                genotype    => $finder->($input, 'Genotype', 'genotype'),
                species     => $finder->($input, 'Species', 'species'),
            },
            { primary => 'strain_name_unique' }
	    );
    }
}

sub populate_laboratories {
    my ($schema, $labs) = @_;
    my $resultset = $schema->resultset('Laboratory');
    my $legacy_rs = $schema->resultset('LegacyLablist');
    for my $input (@{ $labs->[0] }) {
        my $labdata = App::Util::Import::Parser::parse_lab_name($input);
        my $is_commercial
            = (    defined $input->commercial
                && $input->commercial ne 'N'
                && $input->commercial ne '');
        my $laboratory = $resultset->update_or_create(
            {   name         => $labdata->{name},
		head         => $labdata->{head},
                institution  => $labdata->{institution},
                city         => $labdata->{city},
                state        => $labdata->{state},
                commercial   => $is_commercial,
                country      => $input->country,
		date_updated => $input->updated,
            },
	    { primary => 'name_unique' }
        );

        # Add legacy data and associate with laboratory.
        my $rawdata = join("\t",
            map { $input->{$_} || q{} } @{ $IMPORTS{lablist}->{fields} });
        $legacy_rs->find_or_create(
            {   laboratory => $laboratory,
                entry      => $rawdata,
            }
        );
    }
}

=head2 populate_freezers

    Populates freezer-related tables

=cut

sub populate_freezers {
    my ($schema, $freezers) = @_;
    my $freezer_rs = $schema->resultset('Freezer');
    my $sample_rs  = $schema->resultset('FreezerSample');
    my $legacy_rs  = $schema->resultset('LegacyFrzloc');

    my $finder = sub {
        my ($input, $table, $column) = @_;
        my $value;
        eval "\$value = \$input->$column";
        return update_or_create($schema, $table, { name => $value });
    };

    # Enter symbolic names of the freezers.
    my $big_liquid_row = $freezer_rs->update_or_create(
	{   name     => "big liquid nitrogen",
	},
	{ primary => 'freezer_name_unique' }
	);
    
    for my $input (@{ $freezers->[0] }) {
	my $row = $sample_rs->update_or_create(
	    {   freezer_id => $freezer_row->id,
		strain     => $finder->($input, 'Strain', 'strain'),		
	    },
	    { primary => 'freezer_name_unique' }
	    );
    }
}

=head2 populate_transactions

    Populate the lab orders in the database.

=cut

sub populate_transactions {
    my ($schema, $transactions) = @_;
    my $orders = $schema->resultset('LabOrder');
    for my $input (@{ $transactions->[0] }) {

    }
}

=head2 find_or_create

    Find a schema object based on params. If doesn't exist, create.

=cut

sub find_or_create {
    my ($schema, $name, $params) = @_;
    my $resultset = $schema->resultset($name);
    my $object    = $resultset->find($params);
    if (!$object) {
        $object = $resultset->new($params);
        $object->insert();
    }
    return $object;
}
