package CGC::Schema::Result::OrderEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::OrderEvent

=cut

__PACKAGE__->table("order_event");

=head1 ACCESSORS

=head2 event_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 order_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "event_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "order_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("event_id");

=head1 RELATIONS

=head2 event

Type: belongs_to

Related object: L<CGC::Schema::Result::Event>

=cut

__PACKAGE__->belongs_to(
  "event",
  "CGC::Schema::Result::Event",
  { id => "event_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-24 12:17:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PMMm80RpSIrD3xb+acbWnw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
