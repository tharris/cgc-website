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
    my $self  = shift;
    my $class = $self->class;
    $self->run_with_offset($class);
#    $self->run_with_iterator($class);
}



sub process_object {
    my ($self,$obj) = @_;

    my ($chromosome,$gmap) = $self->_get_gmap_position($obj);
    
    my $lab = $obj->Laboratory;
    unless ($lab) {
	$lab = eval { $obj->Person->Laboratory } ;
    }

    my @genes = $obj->Gene;
    my $transgene_rs = $self->get_rs('Transgene');
    my $transgene_row = $transgene_rs->update_or_create(
	{   name          => $obj->name || undef,
	    chromosome    => $chromosome             || undef,
	    gmap          => $gmap                   || undef,
	    description   => $obj->Summary           || undef,
	    reporter_type => $obj->Reporter_type     || undef,
	    reporter_product         => $obj->Reporter_product || undef,
	    reporter_product_gene_id => @genes ? $self->gene_finder($genes[0],'wormbase_id')->id : undef,
	    extrachromosomal         => $obj->Extrachromosomal || undef,
	    integrated               => $obj->Integrated        || undef,	    
	    laboratory_id            => $lab ? $self->lab_finder($lab)->id : undef,
	    species_id               => $obj->Species ? $self->species_finder($obj->Species)->id : undef,
	},
	{ key => 'transgene_name_unique' }
	);	
}

   
1;

