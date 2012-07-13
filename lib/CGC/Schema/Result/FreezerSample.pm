use utf8;
package CGC::Schema::Result::FreezerSample;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::FreezerSample

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

=head1 TABLE: C<freezer_sample>

=cut

__PACKAGE__->table("freezer_sample");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 freezer_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 strain_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 sample_count

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 freezer_location

  data_type: 'char'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "freezer_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "strain_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "sample_count",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "freezer_location",
  { data_type => "char", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 events

Type: has_many

Related object: L<CGC::Schema::Result::Event>

=cut

__PACKAGE__->has_many(
  "events",
  "CGC::Schema::Result::Event",
  { "foreign.sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 strain

Type: belongs_to

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->belongs_to(
  "strain",
  "CGC::Schema::Result::Strain",
  { id => "strain_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-13 14:04:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ET7Depw7dbA06ZXjSkXCGg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
