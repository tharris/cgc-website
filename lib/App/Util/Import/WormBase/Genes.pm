package App::Util::Import::WormBase::Genes;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading genes and associated features from WormBase'
    );


sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    my $iterator = $ace->fetch_many(Gene => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	last if ($test && $test == ++$c);
	$self->log->info("Processing ($obj)...");
	$self->process_object($obj);
    }
}





sub process_object {
    my ($self,$gene) = @_;

    my $schema = $self->schema;
    my ($chromosome,$gmap) = $self->_get_gmap_position($gene);

    my $gene_resultset = $self->get_rs('Gene');

#    print join("\n","PROCESSING: $gene",
#	       $gene->name,
#	       $gene->Public_name,
#	       $gene->CGC_name,
#	       $gene->Sequence_name,
#	       $chromosome,
#	       $gmap,
#             $gene->Species);


    my $gene_row = $gene_resultset->update_or_create(
	{   wormbase_id   => $gene->name,
	    name          => $gene->Public_name   || undef,
	    locus_name    => $gene->CGC_name      || undef,
	    sequence_name => $gene->Sequence_name || undef,
	    chromosome    => $chromosome          || undef,
	    gmap          => $gmap                || undef,
	    gene_class    => $self->gene_class_finder($gene->Gene_class || 'not assigned'),
	    species       => $self->species_finder($gene->Species || 'not specified; probably C. elegans'),
	},
	{ key => 'gene_wormbase_id_unique' }
        );
    return;
   
    # Variations can remove more than one gene.
    my $variation_resultset = $schema->resultset('Variation');
    foreach my $variation ($gene->Allele) {
	my ($chromosome,$gmap) = _get_chromosome($variation);
	my $var_row = $variation_resultset->update_or_create(
	    {   wormbase_id   => $variation->name,
		name          => $variation->Public_name || undef,
		chromosome    => $chromosome             || undef,
		gmap          => $gmap                   || undef,
		is_reference_allele => ($gene->Reference_allele && $gene->Reference_allele eq $variation) ? 1 : undef,		
     	        species       => $self->species_finder($variation->Species || $gene->Species || 'not specified; probably C. elegans'),		
	    },
	    { key => 'variation_name_unique' }
	    );	

#    print join("\n","     ->variation: $gene:$variation",
#	       $variation->name,
#	       $variation->Public_name,
#	       $gene->Reference_allele,
#	       $chromosome,
#	       $gmap,
#	       $variation->Species);

	my @genes     = $variation->Gene;
	my $v2gene_rs = $schema->resultset('Variation2gene');
	foreach (@genes) {
	    my $gene_row = $self->gene_finder($_->name,'wormbase_id');
	    $v2gene_rs->update_or_create(
		{ variation_id => $var_row->id,
		  gene_id      => $gene_row->id,
		});
	}	
    }
}






1;
