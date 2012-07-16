use utf8;
package CGC::Schema::Result::Event;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Event

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<event>

=cut

__PACKAGE__->table("event");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 event

  data_type: 'varchar'
  is_nullable: 1
  size: 255

a description of the event, eg initial freeze

=head2 event_date

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

the user who ENTERED the event

=head2 remark

  data_type: 'varchar'
  is_nullable: 1
  size: 255

a brief comment describing the results of the event

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "event",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "event_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "remark",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 admin_events

Type: has_many

Related object: L<CGC::Schema::Result::AdminEvent>

=cut

__PACKAGE__->has_many(
  "admin_events",
  "CGC::Schema::Result::AdminEvent",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 freezer_events

Type: has_many

Related object: L<CGC::Schema::Result::FreezerEvent>

=cut

__PACKAGE__->has_many(
  "freezer_events",
  "CGC::Schema::Result::FreezerEvent",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 freezer_sample_events

Type: has_many

Related object: L<CGC::Schema::Result::FreezerSampleEvent>

=cut

__PACKAGE__->has_many(
  "freezer_sample_events",
  "CGC::Schema::Result::FreezerSampleEvent",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 laboratory_events

Type: has_many

Related object: L<CGC::Schema::Result::LaboratoryEvent>

=cut

__PACKAGE__->has_many(
  "laboratory_events",
  "CGC::Schema::Result::LaboratoryEvent",
  { "foreign.event_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 strain_events

Type: has_many

Related object: L<CGC::Schema::Result::StrainEvent>

=cut

__PACKAGE__->has_many(
  "strain_events",
  "CGC::Schema::Result::StrainEvent",
  { "foreign.event_id" => "self.id" },
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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-14 20:05:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pm5RrXcANgkuuKcOoGLJaQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
