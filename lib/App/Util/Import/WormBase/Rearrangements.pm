package App::Util::Import::WormBase::Rearrangements;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading rearrangements and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'rearrangement',
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
    my $schema = $self->schema;

    my $lab = $obj->Location;
    unless ($lab) {
	$lab = eval { $obj->Person->Laboratory } ;
    }

    my @ref_strain = $obj->Reference_strain;

    # Variations can remove more than one gene.
    my $rearr_rs = $self->get_rs('Rearrangement');
    my $rearr_row = $rearr_rs->update_or_create(
	{  
	    name          => $obj || undef,
	    description   => $obj->Remark ? join("\n",$obj->Remark) : undef,
	    type          => $obj->Type        || undef,
	    mutagen_id     => $self->mutagen_finder($obj->Mutagen ? $obj->Mutagen : 'not specified')->id,
	    chromosome    => $chromosome             || undef,
	    gmap          => $gmap                   || undef,
	    reference_strain_id => @ref_strain ? $self->strain_finder($ref_strain[0]) : undef,
	    laboratory_id => $self->lab_finder($lab ? $lab : 'not specified')->id,
	    species       => $self->species_finder($obj->Species       || 'not specified; probably C. elegans'),
	},
	{ key => 'rearrangement_name_unique' }
	);	
}

   
1;

