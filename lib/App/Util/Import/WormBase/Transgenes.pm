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

