package App::Util::Import::WormBase::Species;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading species and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'species',
    );

sub run {
    my $self  = shift;
    my $class = $self->class;
    $self->run_with_offset($class);
#    $self->run_with_iterator($class);
}



sub process_object {
    my ($self,$obj) = @_;

    my $rs  = $self->get_rs('Species');
    my $name      = $obj->name;
    my $truncated = substr($name,0,200);
    return if length $name > 250;  # kludge for some seriously broken object names
    my $row = $rs->update_or_create(
	{   name             => $truncated,
	    ncbi_taxonomy_id => $obj->NCBITaxonomyID || undef,
	},
	{ key => 'species_name_unique' }
        );    
}






1;

