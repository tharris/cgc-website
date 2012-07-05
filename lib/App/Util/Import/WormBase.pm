package App::Util::Import::WormBase;

use Moose;
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


sub mutagen_finder {
    my ($self,$name,$column) = @_;
    $column ||= 'name';
    my $schema = $self->schema;
    my $resultset = $schema->resultset('Mutagen');    
    my $row = $resultset->update_or_create({ $column => $name });
    return $row;
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





1;
