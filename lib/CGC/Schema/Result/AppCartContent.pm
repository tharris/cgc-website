package CGC::Schema::Result::AppCartContent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::AppCartContent

=cut

__PACKAGE__->table("app_cart_contents");

=head1 ACCESSORS

=head2 cart_id

  data_type: 'integer'
  is_nullable: 0

=head2 strain_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cart_id",
  { data_type => "integer", is_nullable => 0 },
  "strain_id",
  { data_type => "integer", is_nullable => 0 },
);
__PACKAGE__->set_primary_key("cart_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 21:09:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bCxv0yDVFMdvENqA9w+bnA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
