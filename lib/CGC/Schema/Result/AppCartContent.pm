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
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 strain_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cart_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "strain_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("cart_id", "strain_id");

=head1 RELATIONS

=head2 cart

Type: belongs_to

Related object: L<CGC::Schema::Result::AppCart>

=cut

__PACKAGE__->belongs_to(
  "cart",
  "CGC::Schema::Result::AppCart",
  { cart_id => "cart_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 strain

Type: belongs_to

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->belongs_to(
  "strain",
  "CGC::Schema::Result::Strain",
  { id => "strain_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-20 12:19:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DE8WNTvyEJ3QSmXgmkYGQw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
