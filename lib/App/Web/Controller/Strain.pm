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
	
	$c->log->debug("[SP] index page");
	return "index";
}

sub strain_GET {
	my ($self, $c, $key) = @_;
	
	if (!$key) {
		$c->log->debug("[SP] Detaching to index\n");
		$c->detach('index');
	}
	my $strain
		= $c->model('CGC::Strain')->single({ name => $key });
	$c->stash->{template} = 'strain/index.tt2';
	my $entity;
	if (defined($strain)) {
		$c->log->debug("[SP] Found strain $strain\n");
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
			history    => [] # TODO: Track history
		};
		$self->status_ok($c, entity => $entity);
	} else {
		$self->status_not_found($c, message => "Cannot find strain '$key'");
	}
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
