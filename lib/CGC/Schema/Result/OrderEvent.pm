use utf8;
package CGC::Schema::Result::OrderEvent;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::OrderEvent

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

=head1 TABLE: C<order_event>

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

=head1 PRIMARY KEY

=over 4

=item * L</event_id>

=back

=cut

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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-10-31 13:06:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:e/FPP0tBFx6RqkGPMbY3fw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
