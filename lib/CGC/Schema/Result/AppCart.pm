package CGC::Schema::Result::AppCart;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::AppCart

=cut

__PACKAGE__->table("app_cart");

=head1 ACCESSORS

=head2 cart_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "cart_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("cart_id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<CGC::Schema::Result::AppUser>

=cut

__PACKAGE__->belongs_to(
  "user",
  "CGC::Schema::Result::AppUser",
  { user_id => "user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 app_cart_content

Type: might_have

Related object: L<CGC::Schema::Result::AppCartContent>

=cut

__PACKAGE__->might_have(
  "app_cart_content",
  "CGC::Schema::Result::AppCartContent",
  { "foreign.cart_id" => "self.cart_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-18 21:11:51
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:04IJiW6hKTPN7ICSfV+rJw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
