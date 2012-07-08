package App::Util::Import::WormBase::Transgenes;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading transgenes associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'transgene',
    );

sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;
    $|++;


    my $class = $self->class;
    my $log  = join('/',$self->import_log_dir,"$class.log");
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log";

    my $iterator = $ace->fetch_many(ucfirst($class) => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	if ($previous{$obj}) {
	    print STDERR "Already seen $obj. Skipping...";
	    print STDERR -t STDOUT && !$ENV{EMACS} ? "\r" : "\n"; 
	    next;
	}
	last if ($test && $test == ++$c);
	$self->log->info("Processing ($obj)...");
	$self->process_object($obj);
	print OUT "$obj\n";
    }
    close OUT;
}



sub process_object {
    my ($self,$obj) = @_;

    my ($chromosome,$gmap) = $self->_get_gmap_position($obj);
    
    my $lab = $obj->Laboratory;
    unless ($lab) {
	$lab = eval { $obj->Person->Laboratory } ;
    }


    my $transgene_rs = $self->get_rs('Transgene');
    my $transgene_ row = $transgene_rs->update_or_create(
	{   name          => $obj->name || undef,
	    chromosome    => $chromosome             || undef,
	    gmap          => $gmap                   || undef,
	    description   => $obj->Summary           || undef,
	    reporter_type => $obj->Reporter_type     || undef,
	    reporter_product => $obj->Reporter_product || undef,
	    reporter_gene => $obj->Gene ? $self->gene_finder($obj->Gene,'wormbase_id') : undef,
	    extrachomosomal => $obj->Extrachromosomal || undef,
	    integrated    => $obj->Integrated        || undef,	    
	    laboratory_id => $self->lab_finder($lab ? $lab : 'not specified')->id,
	    species       => $self->species_finder($obj->Species || 'not specified; probably C. elegans'),	    
	},
	{ key => 'transgene_name_unique' }
	);	
    }	
}

   
1;

