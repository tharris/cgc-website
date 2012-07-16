package App::Web::Controller::Freezer;

use Moose;

BEGIN { extends 'App::Web::Controller::REST'; }

##############################################################
#
# List all freezers
#
##############################################################

sub freezers :Path('/freezers') :Args(0)   {
    my ($self,$c) = @_;

    my @rows = $c->model('CGC::Freezer')->search();
    
    my $entity;
    foreach my $row (@rows) {
	my @samples = $row->freezer_samples;
	push @{$entity->{freezers}},{
	    name       => $row->name,
	    id         => $row->id,
	    type       => $row->type,
	    samples    => scalar @samples,
	};
    }

    $c->stash->{template} = 'freezer/all.tt2';
    $self->status_ok($c, entity => $entity);
}


##############################################################
#
# List all samples in a given freezer
#
##############################################################

sub freezer : Path('/freezer') : ActionClass('REST') { }

sub freezer_GET  :Path('/freezer') :Args(1) {
    my ($self,$c,$id) = @_;

    $c->stash->{template} = 'freezer/index.tt2';

    # Hack! Assume that name entries do not begin with a number.
    my $column;
    if ($id =~ /^\d/) {
	$column = 'id';
    } else {
	$column = 'name';
    }

    my $row = $c->model('CGC::Freezer')->single({ $column => $id });

    my $entity;
    if ($row) {
	$entity = {
	    name       => $row->name,
	    id         => $row->id,
	    type       => $row->type,
	};

	foreach my $sample ($row->freezer_samples) {

	    # Get the event history for this sample.
	    my $flattened_history = $self->get_history($c,'FreezerSampleEvent','freezer_sample_id',$sample->id);
	    	    
	    push @{$entity->{samples}},{ id => $sample->id,
					 genotype => $sample->strain->genotype,
					 strain   => $sample->strain->name,
					 location => $sample->freezer_location,
					 sample_count => $sample->vials,
					 history  => $flattened_history,
	    }
	}	
    }
    $self->status_ok($c, entity => $entity);
}


1;
