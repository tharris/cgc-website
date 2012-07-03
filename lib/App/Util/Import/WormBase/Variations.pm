package App::Util::Import::WormBase::Variations;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading variations and associated features from WormBase'
    );


sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    my $log  = join('/',$self->import_log_dir,'variations.log');
    my %previous = $self->_parse_previous_import_log($log);

    # Open cache log for writing.
    open OUT,">>$log";

    my $iterator = $ace->fetch_many(Strain => '*');
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

    # Variations can remove more than one gene.
    my $variation_rs = $self->get_rs('Variation');
    my $var_row = $variation_rs->update_or_create(
	{   wormbase_id   => $obj->name,
	    name          => $obj->Public_name || undef,
	    chromosome    => $chromosome             || undef,
	    gmap          => $gmap                   || undef,
	    species       => $self->species_finder($obj->Species || 'not specified; probably C. elegans'),
	    gene_class    => $self->gene_class_finder($obj->Gene_class || 'not specified'),
	},
	{ key => 'variation_name_unique' }
	);	

    my $gene_rs = $schema->resultset('Gene');
    my @genes   = $obj->Gene;
    foreach my $gene (@genes) {
	my $gene_row = $gene_rs->update_or_create(
	    {   wormbase_id   => $gene->name,
		name          => $gene->Public_name   || undef,
		locus_name    => $gene->CGC_name      || undef,
		sequence_name => $gene->Sequence_name || undef,
		chromosome    => $chromosome          || undef,
		gmap          => $gmap                || undef,
		species       => $self->species_finder($obj->Species || 'not specified; probably C. elegans'),
	    },
	    { key => 'gene_wormbase_id' }
	    );

	my $v2gene_rs = $schema->resultset('Variation2gene');
	my $gene_row = $finder->($_->name,'Gene','wormbase_id');
	$v2gene_rs->update_or_create(
	    { variation_id => $obj_row->id,
	      gene_id      => $gene_row->id,
	    });
    }	
}

   
1;

