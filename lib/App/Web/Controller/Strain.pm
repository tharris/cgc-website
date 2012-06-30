package App::Web::Controller::Strain;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

__PACKAGE__->config(
	default => 'application/json',
	map => {
		'text/html' => [ qw/View TT/ ],
		'application/json' => 'JSON',
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
	
	$c->stash->{template} = 'strain/index.tt2';
	$self->status_ok(
		$c,
		entity => {
			foo => $stash_key
		}
	);
}

sub list : Local : ActionClass('REST') { }

sub list_GET {
	my ($self, $c) = @_;

	my $strains = [ $c->model('CGC::Strain')->get_column('name')->all() ];
	$self->status_ok(
		$c,
		entity => $strains
	);	
}

# sub strain : Path('/strain') : Args(2) : ActionClass('REST') {}
# sub strain_GET { my ($self,$c,@args) = @_; if $args[0] eq 'list' {}....

=head1 AUTHOR

Shiran Pasternak

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
