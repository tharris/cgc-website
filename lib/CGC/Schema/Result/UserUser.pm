use utf8;
package CGC::Schema::Result::UserUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::UserUser

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<user_users>

=cut

__PACKAGE__->table("user_users");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
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

=head2 gtalk_key

  data_type: 'text'
  is_nullable: 1

=head2 active

  data_type: 'integer'
  is_nullable: 1

=head2 wbid

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 wb_link_confirm

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "username",
  { data_type => "char", is_nullable => 1, size => 255 },
  "password",
  { data_type => "char", is_nullable => 1, size => 255 },
  "gtalk_key",
  { data_type => "text", is_nullable => 1 },
  "active",
  { data_type => "integer", is_nullable => 1 },
  "wbid",
  { data_type => "char", is_nullable => 1, size => 255 },
  "wb_link_confirm",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-28 17:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WdcaxW1zvQ1lMvfZZlEQPQ

__PACKAGE__->has_many(users_to_roles=>'CGC::Schema::Result::UserUsersToRole', 'user_id');
#__PACKAGE__->has_many(open_ids=>'CGC::Schema::Result::UserOpenID', 'user_id');
__PACKAGE__->has_one(primary_email=>'CGC::Schema::Result::UserEmail', 'user_id', ,{ where => { validated => 1, primary_email => 1 } });
__PACKAGE__->has_many(valid_emails=>'CGC::Schema::Result::UserEmail', 'user_id', ,{ where => { validated => 1 } });
__PACKAGE__->has_many(email_address=>'CGC::Schema::Result::UserEmail', 'user_id');
__PACKAGE__->many_to_many(roles => 'user_users_to_roles', 'user_role');

#__PACKAGE__->has_many(issues_reported=>'CGC::Schema::Result::Issue', 'reporter_id');
#__PACKAGE__->has_many(issues_responsible=>'CGC::Schema::Result::Issue', 'responsible_id');
__PACKAGE__->has_many(comments=>'CGC::Schema::Result::Comment', 'user_id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
