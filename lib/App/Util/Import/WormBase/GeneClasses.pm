package App::Util::Import::WormBase::GeneClasses;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading gene_classes and associated features from WormBase'
    );

# hehe.  Has class.
has 'class' => (
    is => 'ro',
    default => 'gene_class',
    );


sub run {
    my $self  = shift;
    my $class = $self->class;
    $self->run_with_offset($class);
#    $self->run_with_iterator($class);
}


sub process_object {
    my ($self,$obj) = @_;
   
    my $rs  = $self->get_rs('GeneClass');
    my $row = $rs->update_or_create(
	{   name          => $obj->name        || undef,
	    description   => $obj->Description || undef,
	    laboratory_id => $self->lab_finder($obj->Designating_laboratory || 'not specified')->id,
	},
	{ key => 'gene_class_name_unique' }
        );
}

1;

