package App::Web::Controller::Strain;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
	default => 'application/json',
	map => {
		'text/html' => [ qw/View TT/ ],
	}
);

=head1 NAME

App::Web::Controller::Strain - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub strain : Path('/strain') : ActionClass('REST') { }

sub index : Private {
	my ($self, $c) = @_;	
	return "index";
}

sub strain_GET {
	my ($self, $c, $key) = @_;
	
	if (!$key) {
		$c->detach('index');
	}
	my $strain = $c->model('CGC::Strain')->single({ name => $key });
	$c->stash->{template} = 'strain/index.tt2';
	my $entity;
	if (defined($strain)) {


	    
	    # Get the event history for this sample.
	    my $strain_history = $self->get_history($c,'StrainEvent','strain_id',$strain->id);
	    
	    
            # Pull out some admin level fields, mainly samples and their history.
	    my $freezer_samples;

	    # All freezer samples, and history for those samples.
	    my @sample_rows = $c->model('CGC::FreezerSample')->search(
		{ strain_id => $strain->id }
		);
	    
	    foreach my $sample (@sample_rows) {
		my $freezer_history = $self->get_history($c,'FreezerSampleEvent','freezer_sample_id',$sample->id);
		my $freezer = $sample->freezer;

		# Kind of dumb. We reset this meta information each time around.
		$freezer_samples->{$freezer->name}->{id} = $freezer->id;
		$freezer_samples->{$freezer->name}->{type} = $freezer->type;
		
		push @{$freezer_samples->{$sample->freezer->name}->{samples}},
		{ sample_id   => $sample->id,		  
		  freezer_location => $sample->freezer_location,
		  vials       => $sample->vials,
		  history     => $freezer_history,
		}
	    }   

	    $entity = {
			name       => $strain->name,
			species    => $strain->species
				? $strain->species->name : 'No species',
			outcrossed => $strain->outcrossed,
			mutagen    => $strain->mutagen
				? $strain->mutagen->name : 'No mutagen',
			genotype   => $strain->genotype,
			received   => $strain->received,
			# lab_order  => $strain->lab_order,
			made_by    => $strain->made_by,
			laboratory => $strain->laboratory ? $strain->laboratory->name : 'laboratory of origin unknown',
			samples    => $freezer_samples,
		};
		$self->status_ok($c, entity => $entity);
	} else {
		$self->status_not_found($c, message => "Cannot find strain '$key'");
	}
}





# Generically get the history for sample/freezer/whatever.
# Kind of bizarre that this is in REST controller, but subclasses
# inherit from us.
sub get_history {
    my ($self,$c,$model,$column,$id) = @_;
    
    my @history_rows = $c->model("CGC::" . $model)->search(
	{ $column => $id },
	{ join => [qw/event/] });
    
    my @flattened_history;
    foreach my $history (@history_rows) {
	my $event = $history->event;
	push @flattened_history,{
	    event  => $event->event,
	    date   => $event->event_date,
	    remark => $event->remark,
	};
    }
    return \@flattened_history;
}
    



=cut


=head1 AUTHORS

Shiran Pasternak and Todd Harris

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
