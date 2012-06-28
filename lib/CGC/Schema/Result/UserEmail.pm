use utf8;
package CGC::Schema::Result::UserEmail;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::UserEmail

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

=head1 TABLE: C<user_email>

=cut

__PACKAGE__->table("user_email");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 email

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 validated

  data_type: 'tinyint'
  is_nullable: 1

=head2 primary_email

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "email",
  { data_type => "char", default_value => "", is_nullable => 0, size => 255 },
  "validated",
  { data_type => "tinyint", is_nullable => 1 },
  "primary_email",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</user_id>

=item * L</email>

=back

=cut

__PACKAGE__->set_primary_key("user_id", "email");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-28 17:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pzuUsHEGKcDXAK+CrflTTg

__PACKAGE__->belongs_to(user=>'CGC::Schema::Result::UserUser','user_id');

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
