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
	if (!$cart) {
		$cart = $c->model('CGC::AppCart')->find_or_create({
			user_id => $user->id
		});
	}
	if ($post_data->{strains}) {
		my $strain_names = ref $post_data->{strains} eq 'ARRAY'
			? $post_data->{strains}
			: [ split(',', $post_data->{strains}) ];
			
		$errors = $self->add_strains($c, $cart, $strain_names);
		if (scalar @$errors) {
			$self->status_not_found($c, message => join(" ", @$errors));
		}
	}
	if (scalar @$errors == 0) {
		$self->status_ok($c,
			entity => $cart->flatten
		);
	}
}

sub add_strains :Private {
	my ($self, $c, $cart, $names) = @_;
	my @errors     = ();
	my @strain_ids = ();
	my $model = $c->model('CGC::Strain');
	for my $name (@$names) {
		my $strain = $model->single({ name => $name });
		if (!$strain) {
			push @errors, "Cannot find strain $name";
		} else {
			push @strain_ids, $strain->id;
		}
	}
	if (scalar @errors == 0) {
		# No errors, update model.
		for my $id (@strain_ids) {
			$c->log->debug("Adding strain $id");
			$cart->find_or_create_related('app_cart_contents', {
				strain_id => $id
			});
		}
	}
	return \@errors;
}


=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
