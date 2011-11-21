package CGC::Schema::Result::LabOrder;

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

CGC::Schema::Result::LabOrder

=cut

__PACKAGE__->table("lab_order");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_foreign_key: 1
  is_nullable: 0

=head2 laboratory_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 strain_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 order_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "laboratory_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "strain_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "order_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 id

Type: belongs_to

Related object: L<CGC::Schema::Result::Laboratory>

=cut

__PACKAGE__->belongs_to(
  "id",
  "CGC::Schema::Result::Laboratory",
  { id => "id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 id

Type: belongs_to

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->belongs_to(
  "id",
  "CGC::Schema::Result::Strain",
  { id => "id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-11-09 21:54:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qcvuGWy5KgRfIq3GbVcMqg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
