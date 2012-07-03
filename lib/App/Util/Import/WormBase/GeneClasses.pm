package App::Util::Import::WormBase::GeneClasses;

use Moose;
extends 'App::Util::Import::WormBase';

has 'step' => (
    is => 'ro',
    default => 'loading gene_classes and associated features from WormBase'
    );

sub run {
    my $self = shift; 
    my $ace  = $self->ace_handle;

    my $iterator = $ace->fetch_many(Gene_class => '*');
    my $c = 1;
    my $test = $self->test;
    while (my $obj = $iterator->next) {
	last if ($test && $test == ++$c);
	$self->log->warn("Processing ($obj)...");
	$self->process_object($obj);
    }
}


sub process_object {
    my ($self,$obj) = @_;
   
    my $rs  = $self->get_rs('GeneClass');
    my $row = $lab_rs->update_or_create(
	{   name          => $obj->name   || undef,
	    description   => $obj->Description || undef,
	    designating_laboratory   => $self->laboratory_finder($obj->Designating_laboratory || 'not specified'),
	}
	{ key => 'gene_class_name_unique' }
        );
}

1;

