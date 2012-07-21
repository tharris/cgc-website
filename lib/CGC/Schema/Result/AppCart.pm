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
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

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
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("cart_id");
__PACKAGE__->add_unique_constraint("user_id", ["user_id"]);

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

=head2 app_cart_contents

Type: has_many

Related object: L<CGC::Schema::Result::AppCartContent>

=cut

__PACKAGE__->has_many(
  "app_cart_contents",
  "CGC::Schema::Result::AppCartContent",
  { "foreign.cart_id" => "self.cart_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-20 21:49:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ivlOu+N411qP5ZXE8+jaHw

sub flatten {
	my ($self) = @_;
	return +{
		strains =>
			$self->app_cart_contents ?
			[ map { $_->strain->name } $self->app_cart_contents ] : []
	};
}

sub items {
	my ($self) = @_;
	return $self->app_cart_contents
		? scalar $self->app_cart_contents
		: 0;
}

1;
