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

=head2 event_class

  data_type: 'enum'
  extra: {list => ["freezer","strain manipulation","administration","laboratory"]}
  is_nullable: 1

=head2 event

  data_type: 'varchar'
  is_nullable: 1
  size: 255

a description of the event, eg initial freeze

=head2 sample_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

either/or sample_id or freezer_id

=head2 freezer_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

either/or sample_id or freezer_id

=head2 event_date

  data_type: 'date'
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
  "event_class",
  {
    data_type => "enum",
    extra => {
      list => [
        "freezer",
        "strain manipulation",
        "administration",
        "laboratory",
      ],
    },
    is_nullable => 1,
  },
  "event",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "sample_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "freezer_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "event_date",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 1 },
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

=head2 freezer

Type: belongs_to

Related object: L<CGC::Schema::Result::Freezer>

=cut

__PACKAGE__->belongs_to(
  "freezer",
  "CGC::Schema::Result::Freezer",
  { id => "freezer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 sample

Type: belongs_to

Related object: L<CGC::Schema::Result::FreezerSample>

=cut

__PACKAGE__->belongs_to(
  "sample",
  "CGC::Schema::Result::FreezerSample",
  { id => "sample_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-13 14:04:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:OP3UA76S4dts3iNs/kMjNA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
