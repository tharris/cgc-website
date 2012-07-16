package CGC::Schema::Result::AppUsersToRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::AppUsersToRole

=cut

__PACKAGE__->table("app_users_to_roles");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 role_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "role_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("user_id", "role_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 16:52:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JUf/qFd9UkoeaskJOPMSog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->belongs_to(user=>'CGC::Schema::Result::AppUser','user_id');
__PACKAGE__->belongs_to(role=>'CGC::Schema::Result::AppRole','role_id');
__PACKAGE__->meta->make_immutable;
1;
