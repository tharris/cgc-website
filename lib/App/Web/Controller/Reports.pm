package App::Web::Controller::Reports;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

App::Web::Controller::Reports - Catalyst Controller

=head1 DESCRIPTION

App::Web::Controller::Reports - Admin-level reporting.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched App::Web::Controller::Reports.');
}


sub registered_users :Path("registered_users") {
    my ($self,$c) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'admin/registered_users.tt2';
    my @array;    

    $c->assert_user_roles( qw/admin/ ); # only admins can see registered users.

#       my $iter=$c->model('CGC::AppUser') ;
#       while( my $user= $iter->next){
# 	  my $hash = { username   => $user->username,
# 		       email      => $user->valid_emails,
# 		       id         => $user->user_id,
# 	  };


    if ($c->check_user_roles('admin')) {
      $c->stash->{'template'} = 'admin/registered_users.tt2';
      my @users;
      if ($c->assert_user_roles( qw/admin/)) {
	  foreach my $user ($c->model('CGC::AppUser')->search()) {
	      map { $user->{$_->role} = 1; } $user->roles;
	      push @users, $user;
	  }
	  $c->stash->{users}= @users ? \@users : undef;
      }
    }
} 




sub system_status :Path("system_status") {
    my ( $self, $c ) = @_;
    $c->stash->{noboiler} = 1;
    $c->stash->{template} = 'admin/system_status.tt2';

    # Get the status of our server pool
    # This is entirely dependent on our installation.

    # Get a list of servers
    # For each server, check (possibly using capistrano)
    # - available disk space
    # - starman status
    # - cpu load
    # - memory usage

    # Would be nice to create RRD of each, too.

} 





=head1 AUTHOR

Todd Harris

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
