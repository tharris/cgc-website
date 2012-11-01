use utf8;
package CGC::Schema::Result::AppCart;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::AppCart

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<app_cart>

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

=head2 remark

  data_type: 'mediumtext'
  is_nullable: 1

Order requests supplied by user

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
  "remark",
  { data_type => "mediumtext", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</cart_id>

=back

=cut

__PACKAGE__->set_primary_key("cart_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<user_id>

=over 4

=item * L</user_id>

=back

=cut

__PACKAGE__->add_unique_constraint("user_id", ["user_id"]);

=head1 RELATIONS

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

=head2 strains

Type: many_to_many

Composing rels: L</app_cart_contents> -> strain

=cut

__PACKAGE__->many_to_many("strains", "app_cart_contents", "strain");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-10-31 13:06:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:sieKtl8u+YIYbVCxkeyo2w

sub flatten {
	my ($self) = @_;
	return +{
		remark => $self->remark,
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
