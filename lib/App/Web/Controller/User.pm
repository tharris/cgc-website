package App::Web::Controller::User;

use strict;
use warnings;
use base 'App::Web::Controller::REST';

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in App.pm
__PACKAGE__->config(
	namespace => '',
	default   => 'text/html' # Most user are HTML? --Shiran
);

=head1 NAME

App::Web::Controller::User - User Controller for App

=head1 DESCRIPTION

User-specific controller actions for the App web application.

=head1 METHODS

=cut

=head2 user

A private action that simply fetches the user.

=cut

sub user : Chained('/') PathPart('user') CaptureArgs(1) {
    my ($self, $c, $user_id) = @_;
    my $user = $c->model('CGC::AppUser')->single({user_id => $user_id});
	$c->stash->{user} = $user;
}


=head2 /user/*/profile

The public user profile.

=cut


sub profile : Chained('user') PathPart('profile')  Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'user/profile.tt2';
}

=head2 /user/*/account

The public user profile.

=cut


sub account : Chained('user') PathPart('account')  Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'user/account.tt2';
}

sub cart :Chained('/user') :Args(0) :ActionClass('REST') {
	my ($self, $c) = @_;
	$c->stash->{template} = 'user/cart.tt2';
}
	
sub cart_GET {
	my ($self, $c) = @_;
	my $cart = $c->stash->{user}->app_cart ||
		 $c->model('CGC::AppCart')->new({});
	$self->status_ok($c, entity => $cart->flatten);
}

sub cart_POST {
	my ($self, $c) = @_;
	my $user = $c->stash->{user};
	my $cart = $user->app_cart;
	my $errors = [];
	my $post_data = $c->req->data || $c->req->body_parameters;
	my $get_post_strains = sub {
		my $key = shift;
		my $strain_data = $post_data->{$key};
		return $strain_data
			? ref $strain_data eq 'ARRAY'
				? $strain_data
				: [ split(',', $strain_data) ]
			: undef;
	};
	if (!$cart) {
		$cart = $c->model('CGC::AppCart')->find_or_create({
			user_id => $user->id
		});
	}
	my $add_strains = $get_post_strains->('add');
	if ($add_strains) {
		# Add these strains
		$errors = $self->add_strains_to_cart($c, $cart, $add_strains);
		if (scalar @$errors) {
			$self->status_bad_request(
				$c,
				message => "Cannot add strains [@{[join(' ', @$errors)]}]"
			);
		}
	}
	
	my $remove_strains = $get_post_strains->('rem');
	if ($remove_strains) {
		# Remove these strains
		$errors = $self->remove_strains_from_cart($c, $cart, $remove_strains);
		if (scalar @$errors) {
			$self->status_bad_request(
				$c,
				message => "Cannot remove strains [@{[join(' ', @$errors)]}]"
			);
		}
	}
	if (scalar @$errors == 0) {
		$self->status_ok($c,
			entity => $cart->flatten
		);
	}
}

sub update_cart_contents :Private {
	my ($self, $c, $cart, $names, $related_operation) = @_;
	my @errors     = ();
	my @strain_ids = ();
	my $model = $c->model('CGC::Strain');
	for my $name (@$names) {
		my $strain = $model->single({ name => $name });
		if (!$strain) {
			push @errors, $name;
		} else {
			push @strain_ids, $strain->id;
		}
	}
	if (scalar @errors == 0) {
		# No errors, update model.
		for my $id (@strain_ids) {
			$cart->$related_operation('app_cart_contents', {
				strain_id => $id
			});
		}
	}
	return \@errors;
}

sub add_strains_to_cart :Private {
	return update_cart_contents(@_, 'find_or_create_related');
}

sub remove_strains_from_cart :Private {
	return update_cart_contents(@_, 'delete_related');
}


=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
