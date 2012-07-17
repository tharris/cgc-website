package CGC::Schema::Result::AppOrderContent;

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

CGC::Schema::Result::AppOrderContent

=cut

__PACKAGE__->table("app_order_contents");

=head1 ACCESSORS

=head2 order_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 strain_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 date_thawed

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 thaw_status

  data_type: 'enum'
  extra: {list => ["success","failed"]}
  is_nullable: 1

=head2 curator_remarks

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=cut

__PACKAGE__->add_columns(
  "order_id",
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
  "date_thawed",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "thaw_status",
  {
    data_type => "enum",
    extra => { list => ["success", "failed"] },
    is_nullable => 1,
  },
  "curator_remarks",
  { data_type => "varchar", is_nullable => 1, size => 5 },
);
__PACKAGE__->set_primary_key("order_id", "strain_id");

=head1 RELATIONS

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

=head2 order

Type: belongs_to

Related object: L<CGC::Schema::Result::AppOrder>

=cut

__PACKAGE__->belongs_to(
  "order",
  "CGC::Schema::Result::AppOrder",
  { id => "order_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 20:47:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:vvOZxq3AQEZUGyG2I+/6BQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
