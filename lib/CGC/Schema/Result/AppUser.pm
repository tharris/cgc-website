package CGC::Schema::Result::AppUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::AppUser

=cut

__PACKAGE__->table("app_user");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 username

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 password

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 laboratory_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 first_name

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 middle_name

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 last_name

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 email

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 validated

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "username",
  { data_type => "char", is_nullable => 1, size => 255 },
  "password",
  { data_type => "char", is_nullable => 1, size => 255 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "laboratory_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "first_name",
  { data_type => "char", is_nullable => 1, size => 255 },
  "middle_name",
  { data_type => "char", is_nullable => 1, size => 255 },
  "last_name",
  { data_type => "char", is_nullable => 1, size => 255 },
  "email",
  { data_type => "char", default_value => "", is_nullable => 0, size => 255 },
  "validated",
  { data_type => "tinyint", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("user_id");

=head1 RELATIONS

=head2 app_orders

Type: has_many

Related object: L<CGC::Schema::Result::AppOrder>

=cut

__PACKAGE__->has_many(
  "app_orders",
  "CGC::Schema::Result::AppOrder",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 events

Type: has_many

Related object: L<CGC::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "CGC::Schema::Result::Event",
  { "foreign.user_id" => "self.user_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 21:09:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:24FyHWIFA97r/zpOL+6W3A


__PACKAGE__->has_many(users_to_roles=>'CGC::Schema::Result::AppUsersToRole', 'user_id');
__PACKAGE__->many_to_many(roles => 'users_to_roles', 'role');
#__PACKAGE__->has_many(open_ids=>'CGC::Schema::Result::OpenID', 'user_id');


#__PACKAGE__->has_many(issues_reported=>'CGC::Schema::Result::Issue', 'reporter_id');
#__PACKAGE__->has_many(issues_responsible=>'CGC::Schema::Result::Issue', 'responsible_id');
#__PACKAGE__->has_many(comments=>'CGC::Schema::Result::Comment', 'user_id');
1;
