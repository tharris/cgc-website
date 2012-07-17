package App::Web::Controller::User;

use strict;
use warnings;
use base 'App::Web::Controller';
 
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in App.pm
__PACKAGE__->config->{namespace} = '';

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
    my $user = $c->model('CGC::AppUser')->search({user_id => $user_id});
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

=head2 /user/*/cart

The user's cart.

=cut

sub cart :Chained('user') :PathPart('cart') :Args(0) {
    my ($self, $c) = @_;
    $c->stash->{template} = 'user/cart.tt2';
}



=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
