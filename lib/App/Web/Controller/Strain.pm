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

sub strain_GET {
	my ($self, $c, $stash_key) = @_;
	
	my $strain
		= $c->model('CGC::Strain')->single({ name => $stash_key });
	$c->stash->{template} = 'strain/index.tt2';
	my $entity;
	if (defined($strain)) {
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
			history    => [] # TODO: Track history
		}
	}
	$self->status_ok($c, entity => $entity);
}

sub list : Local : ActionClass('REST') { }

sub list_GET {
	my ($self, $c) = @_;

	my $columns = $c->request->param('columns')
		? [ split(',', $c->request->param('columns')) ]
		: [ qw/name/ ];
	my $transformer = sub {
		my $row = shift;
		return [ map { $row->get_column($_) } @$columns ];
	};
	my $select = exists $c->request->parameters->{distinct}
		? { select => { distinct => $columns }, as => $columns }
		: { columns => $columns };
	my $strains = [ map { $transformer->($_) }
		$c->model('CGC::Strain')->search(undef, $select) ];
	$c->stash->{cachecontrol}{list} =  1800; # 30 minutes
	$self->status_ok(
		$c,
		entity => $strains
	);
}

=head1 AUTHOR

Shiran Pasternak

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
