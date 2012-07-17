package CGC::Schema::Result::AppRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::AppRole

=cut

__PACKAGE__->table("app_roles");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  is_nullable: 0

=head2 role

  data_type: 'char'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "role_id",
  { data_type => "integer", is_nullable => 0 },
  "role",
  { data_type => "char", is_nullable => 1, size => 255 },
);
__PACKAGE__->set_primary_key("role_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 21:09:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:3+CEwnmmAlEF459/Sk9qcA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
