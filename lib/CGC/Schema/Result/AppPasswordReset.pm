package CGC::Schema::Result::AppPasswordReset;

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

CGC::Schema::Result::AppPasswordReset

=cut

__PACKAGE__->table("app_password_reset");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 token

  data_type: 'char'
  is_nullable: 1
  size: 50

=head2 expires

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "token",
  { data_type => "char", is_nullable => 1, size => 50 },
  "expires",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("user_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 20:47:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jOQAZ8F8pH9Ni89PyooxVw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
