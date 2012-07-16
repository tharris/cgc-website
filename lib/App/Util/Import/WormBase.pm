package App::Util::Import::WormBase;

use Moose;
use Bio::DB::GFF;
use Date::Parse;
use Ace;

extends 'App::Util::ImportNew';

has 'ace_host' => (
    is => 'rw',
    default => 'localhost'
    );

has 'ace_port' => (
    is => 'rw',
    default => '2005'
    );

has 'ace_handle' => (
    is => 'ro',
    lazy_build => 1,
    );

sub _build_ace_handle {
    my $self = shift;
    my $db   = Ace->connect(-host => $self->ace_host,
			    -port => $self->ace_port) or die;
}

has 'test' => (
    is => 'rw',
    );


has 'gff_handle' => (
    is         => 'rw',
    lazy_build => 1,
    );



sub _build_gff_handle {
    my $self = shift;
    
    my $db = Bio::DB::GFF->new( -user => 'root',# $self->user,
				-pass => '3l3g@nz', # $self->pass,
				-dsn =>"dbi:mysql:database=c_elegans;host=localhost",  # "dbi:mysql:database=c_elegans".$self->source.";host=" . $self->host,
				-adaptor     => "dbi::mysql",
				-aggregators => [
				     "processed_transcript{coding_exon,5_UTR,3_UTR/CDS}",
				     "full_transcript{coding_exon,five_prime_UTR,three_prime_UTR/Transcript}",
				     
				     "transposon{coding_exon,five_prime_UTR,three_prime_UTR}"
				]);
return $db;
}





sub _get_gmap_position {    
    my ($self,$object) = @_;
    my $class  = $object->class;
    
    my ($chromosome,$position,$error,$method);
    
    # CDSs and Sequence are only interpolated                                                                   
    # AD: no... only Sequence... (that's what the models suggests)                                              
    #  if ($class eq 'CDS' || $class eq 'Sequence') {                                                           
    if ($class eq 'Sequence' || $class eq 'Variation') {
        my $imp = eval {$object->Interpolated_map_position};
        if ($imp) {
            ($chromosome,$position,$error) = eval { $object->Interpolated_map_position(1)->row };
            $method = 'interpolated';
	    
            # Fetch the interpolated map position if it exists...                                               
            # if (my $m = $object->get('Interpolated_map_position')) {                                          
            if (my $m = eval {$object->get('Interpolated_map_position') }) {
                #my ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;                
                my ($chromosome,$position) = $m->right->row;
                return ($chromosome,$position) if $chromosome;
            }
            elsif (my $l = $object->Gene) {
#		return $self->_get_interpolated_position($l);
            }
        }
        elsif ($object->class eq 'Sequence') {
            #my ($chromosome,$position,$error) = $obj->Interpolated_map_position(1)->row;                       
            my $chromosome = $object->get(Interpolated_map_position=>1);
            my $position   = $object->get(Interpolated_map_position=>2);
            return ($chromosome,$position) if $chromosome;
	} else {
            # Try fetching from the gene                                                                        
            if (my $gene    = $object->Gene) {
                $chromosome = $gene->get(Map=>1);
                $position   = $gene->get(Map=>3);
                $method     = 'interpolated';
            }
	}
    } else {
        ($chromosome,undef,$position,undef,$error) = eval{$object->Map(1)->row};
        # TH: Can't conclude that this is experimentally determined. Model used inconsistently.                 
        #  $method = 'experimentally determined' if $chromosome;                                                
        $method = '';
    }
    
    # Nothing yet? Trying fetching interpolated position.                                                       
    unless ($chromosome) {
        #      if ($object->Interpolated_map_position) {                                                        
        if ($class eq 'Sequence' && $object->Interpolated_map_position) {
            ($chromosome,$position,$error) = $object->Interpolated_map_position(1)->row;
            $method = 'interpolated';
        }
    }
    
    my $label;
    if ($position) {
#        $label= sprintf("$chromosome:%2.2f +/- %2.3f cM",$position,$error || 0);
    }
    else {
        $label = $chromosome;
    }
    
    return ($chromosome,$position);
    
#    return {
#        description => "the genetic position of the $class:$object",
#        data        => {
#	    chromosome => $chromosome && "$chromosome",
#            position   => $position   && "$position",
#            error      => $error      && "$error",
#            formatted  => $label      && "$label",
#            method     => $method     && "$method",
#        }
#    };
}


sub get_rs {
    my ($self,$class) = @_;
    my $schema = $self->schema;
    my $rs = $schema->resultset($class) or die "$!";
#    print $class . '_' . $rs;
    return $rs;
}


# Custom finders for foreign keys
sub species_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Species');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}


sub variation_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Variation');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}


sub gene_class_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('GeneClass');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}


# By default, find using the lab designation.
sub lab_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Laboratory');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}


sub gene_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Gene');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}    

sub strain_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Strain');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}    


sub transgene_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Transgene');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}    


sub rearrangement_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Rearrangement');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}    

sub mutagen_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Mutagen');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
}    


# Instead of lengthy reitrations of objects already parsed,
# Just get an offset.
sub _get_ace_offset {
    my ($self,$log_file) = @_;
    $self->log->info("  ---> getting offset from $log_file");	
    if (-e "$log_file") {
	
	# Instead just get the offset
	my $wc = `wc -l $log_file`;
	chomp $wc;
	$wc =~ /(\d*)\s.*/;
	my $offset = $1;
	if ($offset) {
	    $offset = $offset <= 30 ? $offset = 0 : ($offset - 30);
	} else {
	    $offset = 0;
	}
	return $offset;
    }
}

sub _parse_previous_import_log {
    my ($self,$log_file) = @_;
    $self->log->info("  ---> parsing log of previous imports at $log_file");
    my %previous;
    if (-e "$log_file") {

#	# First off, just tail the file to see if we're finished.
#	my $complete_flag = `tail -1 $cache_log`;
#	chomp $complete_flag;
#	if ($complete_flag =~ /COMPLETE/) {
#	    $previous{COMPLETE}++;
#	    $self->log->info("  ---> all widgets already cached.");
#	    return %previous;
#	}

	open IN,"$log_file" or $self->log->warn("$!");

	while (<IN>) {

#	    if (/COMPLETE/) {
#		$previous{COMPLETE}++;
#		next;
#	    }
	    chomp;
	    $previous{$_}++;
	    print STDERR "   Recording $_ as seen...";
	    print STDERR -t STDOUT && !$ENV{EMACS} ? "\r" : "\n";
	}
#	print STDERR "\n";
	close IN;
    }
    return %previous;
}




sub run_with_offset {
    my ($self,$class) = @_;
    my $ace  = $self->ace_handle;
    $|++;
#    my $class = $self->class;
    my $log  = join('/',$self->import_log_dir,"$class.log");

    # Open cache log for writing.
    open OUT,">>$log";
    my $offset = $self->_get_ace_offset($log);
    my @objects = $ace->fetch(-class => ucfirst($class),
			      -name  => '*',
			      -offset => ($offset));
    my $c = 1;
    my $test = $self->test;
    foreach my $obj (@objects) {
	$ace->reopen();
	last if ($test && $test == ++$c);
	$self->log->info("Processing ($obj)...");
	$self->process_object($obj);
	print OUT "$obj\n";
    }
    close OUT;
}



sub run_with_iterator {
    my ($self,$class) = @_;
    my $ace  = $self->ace_handle;

    $|++;
#    my $class = $self->class;
    my $log  = join('/',$self->import_log_dir,"$class.log");
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log";

    my $iterator = $ace->fetch_many(ucfirst($class) => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	$ace->reopen();
	last if ($test && $test == ++$c);
	$self->log->info("Processing ($obj)...");
	$self->process_object($obj);
	print OUT "$obj\n";
    }
    close OUT;
}




sub genomic_position {
    my ($self,$segment) = @_;
    my ($ref, $start, $stop) = map { $segment->$_ } qw(abs_ref abs_start abs_stop);
    my $strand = ($stop < $start) ? '-' : '+';
    return ($ref,$start,$stop,$strand);
}


sub reformat_date {
    my ($self,$date) = @_;
    $date =~ m|(\d\d)\s(\w\w\w)\s(\d\d\d\d)\s(.*)|;
 
    my %month2number = ( Jan => '01',
			 Feb => '02',
			 Mar => '03',
			 Apr => '04',
			 May => '05',
			 Jun => '06',
			 Jul => '07',
			 Aug => '08',
			 Sep => '09',
			 Oct => '10',
			 Nov => '11',
			 Dec => '12' );
			 
    my $month = $month2number{$2};
    
    my $reformatted =  "$3-$month-$1 $4\n";
    return $reformatted;
}





1;
