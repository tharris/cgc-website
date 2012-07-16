#!/usr/bin/perl
#   !/usr/local/bin/perl

use strict;
#use warnings;

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
                moos_tower_location  mcb_tower_location liquid_vials
                minus80_location minus80_vials
                oldest_freeze_in_nitrogen  date_strain_was_refrozen     date_strain_was_frozen_for_minus80
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
#    populate_strains($schema, $import->{strain});      # DONE
#    populate_laboratories($schema, $import->{lablist});
    populate_freezers($schema, $import->{frzloc});     # DONE
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
    close OUT;
}

sub populate_laboratories {
    my ($schema, $labs) = @_;
    my $resultset = $schema->resultset('Laboratory');
    my $legacy_rs = $schema->resultset('LegacyLablist');

    my $log  = join('/','/usr/local/wormbase/todd/cgc-website/logs/import_logs',"laboratory-cgc-merge.log");
    open OUT,">>$log";

    for my $input (@{ $labs->[0] }) {
        my $labdata = App::Util::Import::Parser::parse_lab_name($input);

	my $is_commercial
	    = ( defined $input->commercial
                && $input->commercial ne 'N'
                && $input->commercial ne '') ? 1 : '';

	my $row = $resultset->find( { name    => $input->{code} },
				    { primary => 'laboratory_name_unique' } );
	if ($row) {
	    print OUT "CGC laboratory " . $input->{code} . " found in database already: updating...\n";
	    foreach my $field (@{ $IMPORTS{lablist}->{fields} }) {		

		my ($input_val,$db_col);
		if ($field eq 'updated') {
		    $input_val = $input->updated;    # is this the date assigned or updated?
		    $db_col    = 'date_assigned';
		} elsif ($field eq 'flag') {
		    next; # NOT USING.
		} elsif ($field eq 'code') {
		    my $code = $input->{code};
		    $code =~ s/\s*//g;
		    $input_val = $code;
		    $db_col    = 'name';
		} elsif ($field eq 'allele') {
		    $input_val = $input->allele;
		    $db_col    = 'allele_designation';
		} elsif ($field eq 'name') {
		    $input_val = $labdata->{name};
		    $db_col    = 'head';
		} elsif ($field eq 'country') {
		    $input_val = $input->country;
		    $db_col    = 'country';
		} elsif ($field eq 'state') {
		    $input_val = $labdata->{state};
		    $db_col    = 'state';
		} elsif ($field eq 'city') {
		    $input_val = $labdata->{city};
		    $db_col    = 'country';		    
		} elsif ($field eq 'location') {
		    $input_val = $input->{location};
		    $db_col    = 'institution';
		} elsif ($field eq 'namelocat') {
		    next; # NOT USING.  (Parsed via lab data)
		} elsif ($field eq 'annfeepd') {
		    next; # NOT USING. NEED TO ACCOMODATE
		} elsif ($field eq 'commercial') {
		    $input_val = $is_commercial;
		    $db_col    = 'commercial';
		} else { print "field is $field\n"; next;  }

		my $db_val = $row->$db_col;
		if ($input_val ne $db_val) { print OUT "\t$db_col changed from " 
						 . "\n\t\t" . $db_val 
						 . "\n\t\t" . $input_val . "\n" }
	    }
	} else {
	    print OUT "------> FOUND A LABORATORY NOT PRESENT IN WORMBASE: " . $labdata->{head} . ' - ' . $input->{code} . "\n";
	}


	# If the input code is numeric, this is an individual that DOES NOT have 
	# a laboratory designation.  They were arbitrarily assigned an integer
	# as a lab code.
	# We don't really want to insert them. Not sure how to track them at this moment. 
	if ($input->{code} =~ /^\d/) {
	    next;
	}
	
	next;

        my $laboratory = $resultset->update_or_create(
            {   name         => $input->{code},
		head         => $labdata->{head},
                institution  => $input->{location},
                city         => $labdata->{city},
                state        => $labdata->{state},
                commercial   => $is_commercial,
                country      => $input->country,
#		date_updated => $input->updated,
            },
	    { primary => 'name_unique' }
        );

	# Date a strain arrived comes via WormBase.

	# Insert the date assigned into the laboratory_event table.
	my $event_rs = $schema->resultset('Event');
	my $event_row  = $event_rs->create({
	    event => 'laboratory code assigned',      # Or is this simply the date it was updated?
	    event_date => $input->updated ? reformat_date($input->updated) : undef,
	    user_id    => 1,
					   });
    
	# Create entry in the join table. Necessary?
	# or my $author = $book->create_related('author', { name => 'Fred'});
	my $event_join_rs = $schema->resultset('LaboratoryEvent');
	my $event_join_row = $event_join_rs->create({
	    event_id  => $event_row->id,
	    laboratory_id => $laboratory->id,
						    });
	
	
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
    my $strain_rs  = $schema->resultset('Strain');
    my $event_rs   = $schema->resultset('Event');

    my $finder = sub {
        my ($input, $table, $column) = @_;
        my $value;
        eval "\$value = \$input->$column";
        return update_or_create($schema, $table, { name => $value });
    };

    my $log  = join('/','/usr/local/wormbase/todd/cgc-website/logs/import_logs',"freezer-cgc-merge.log");
    open OUT,">>$log";

    # Get out rows corresponding to various freezers.
    my $moos_tower_row = $freezer_rs->find_or_create(
	{   name     => "Moos Tower",
	},
	{ primary => 'freezer_name_unique' }
	);
    
    my $mcb_tower_row = $freezer_rs->find_or_create(
	{   name     => "MCB",
	},
	{ primary => 'freezer_name_unique' }
	);
    
    my $minus80_row = $freezer_rs->find_or_create(
	{   name     => "Minus 80",
	},
	{ primary => 'freezer_name_unique' }
	);


    # Let's skip some entries
    # Those that have no strain.

    
    # Insert entries into freezer samples.
    for my $input (@{ $freezers->[0] }) {
	
	my $strain_row = $strain_rs->find({ name => $input->strain });
	
	unless ($strain_row) {
	    print OUT "No strain has yet been entered for : " . $input->strain . "\n";
	    next;
	}

	# Do three inserts, one for each freezer type
	# MCB nitrogen
	my ($mcb_insert,$moos_insert,$minus80_insert);
	if (my $location = $input->mcb_tower_location) {
	    $location =~ s/^\s//;
	    $mcb_insert = $sample_rs->update_or_create(
		{   freezer_id       => $mcb_tower_row->id,
		    strain_id        => $strain_row->id,
		    vials            => $input->liquid_vials || 0,
		    freezer_location => $location,
		},	    
		);
	} else {
	    print OUT $input->strain . " has no MCB tower location specified\n"; 
	}	

	# Moos tower nitrogen
	if (my $location = $input->moos_tower_location) {
	    $location =~ s/^\s//;
	    $moos_insert = $sample_rs->update_or_create(
	    {   freezer_id       => $moos_tower_row->id,
		strain_id        => $strain_row->id,
		vials            => $input->liquid_vials || 0,
		freezer_location => $location,
	    },	    
	    );
	} else {
	    print OUT $input->strain . " has no Moos tower location specified\n"; 
	}

	# Moos tower nitrogen
	if (my $location = $input->minus80_location) {
	    $location =~ s/^\s//;
	    $minus80_insert = $sample_rs->update_or_create(
	    {   freezer_id       => $minus80_row->id,
		strain_id        => $strain_row->id,
		vials            => $input->minus80_vials || 0,
		freezer_location => $location,
	    },	    
	    );
	} else {
	    print OUT $input->strain . " has no minus 80 location specified\n"; 
	}	

	# Now, create events for all three of these

	# Insert the date assigned into the laboratory_event table.
	my $event_rs = $schema->resultset('Event');
    
	# Create entry in the join table. Necessary?
	# or my $author = $book->create_related('author', { name => 'Fred'});
	my $event_join_rs = $schema->resultset('FreezerSampleEvent');
	
	if ($input->oldest_freeze_in_nitrogen =~ m|\d\d/\d\d/\d\d\d\d|) {
	    my $date = reformat_date($input->oldest_freeze_in_nitrogen);

	    if ($moos_insert) {
		my $moos_event_row  = $event_rs->create({
		    event => 'strain frozen in liquid nitrogen',
		    event_date => $date,
		    remark      => 'originally: date strain was frozen in liquid nitrogen; date was not originally tracked for both MCB and Moos as it is here - date is simply duplicated.',
		    user_id    => 1});
		
		my $moos_event_join_row = $event_join_rs->create({
		    event_id  => $moos_event_row->id,
		    freezer_sample_id => $moos_insert->id,
								 });
	    }
	    
	    if ($mcb_insert) {
		# Duplicate for MCB (CGC doesn't currently track these separately)
		my $mcb_event_row  = $event_rs->create({
		    event => 'strain frozen in liquid nitrogen',
		    event_date => $date,
		    remark      => 'originally: date strain was frozen in liquid nitrogen; date was not originally tracked for both MCB and Moos as it is here - date is simply duplicated.',
		    user_id    => 1});
		
		my $mcb_event_join_row = $event_join_rs->create({
		    event_id  => $mcb_event_row->id,
		    freezer_sample_id => $mcb_insert->id,
								});	    
	    }
	} else {
	    print OUT $input->strain . " has no original freeze date set\n"; 
	}	
	
	if ($input->date_strain_was_refrozen =~ m|\d\d/\d\d/\d\d\d\d|) {
	    my $date = reformat_date($input->date_strain_was_refrozen);
	    
	    if ($moos_insert) {
		my $moos_event_row  = $event_rs->create({
		    event       => 'strain re-frozen in liquid nitrogen',
		    event_date => $date,
		    remark      => 'originally: date strain was refrozen in liquid nitrogen; date was not originally tracked for both MCB and Moos as it is here - date is simply duplicated.',
		    user_id    => 1});
	    my $moos_event_join_row = $event_join_rs->create({
		event_id  => $moos_event_row->id,
		freezer_sample_id => $moos_insert->id,
							     });
	    }
	    
	    if ($mcb_insert) {
		my $mcb_event_row  = $event_rs->create({
		    event       => 'strain re-frozen in liquid nitrogen',
		    event_date => $date,
		    remark      => 'originally: date strain was refrozen in liquid nitrogen; date was not originally tracked for both MCB and Moos as it is here - date is simply duplicated.',
		    user_id    => 1});
		
		my $mcb_event_join_row = $event_join_rs->create({
		    event_id  => $mcb_event_row->id,
		    freezer_sample_id => $mcb_insert->id,
								});
	    }
	    
	} else {
	    print OUT $input->strain . " has no refreeze date set\n"; 
	}	
	
	if ($minus80_insert) {
	    if ($input->date_strain_was_frozen_for_minus80 =~ m|\d\d/\d\d/\d\d\d\d|) {
		my $date = reformat_date($input->date_strain_was_frozen_for_minus80);
		
		my $event_row  = $event_rs->create({
		    event       => 'strain frozen in minus 80',
		    event_date => $date,		
		    user_id    => 1});
		
		my $event_join_row = $event_join_rs->create({
		    event_id  => $event_row->id,
		    freezer_sample_id => $minus80_insert->id,
							    });
	    } else {
		print OUT $input->strain . " has no minus 80 date set\n"; 
	    }	
	}
	    
    }
}

sub reformat_date {
    my $date = shift;
    $date =~ m|(\d\d)/(\d\d)/(\d\d\d\d)|;
    return "$3-$1-$2 00:00:00";
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
