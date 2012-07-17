package CGC::Schema::Result::Freezer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::Freezer

=cut

__PACKAGE__->table("freezer");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 freezer_events

Type: has_many

Related object: L<CGC::Schema::Result::FreezerEvent>

=cut

__PACKAGE__->has_many(
  "freezer_events",
  "CGC::Schema::Result::FreezerEvent",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 freezer_samples

Type: has_many

Related object: L<CGC::Schema::Result::FreezerSample>

=cut

__PACKAGE__->has_many(
  "freezer_samples",
  "CGC::Schema::Result::FreezerSample",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 legacy_frzlocs

Type: has_many

Related object: L<CGC::Schema::Result::LegacyFrzloc>

=cut

__PACKAGE__->has_many(
  "legacy_frzlocs",
  "CGC::Schema::Result::LegacyFrzloc",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 21:09:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JrqZCZfCpoSgWdOtegh04g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
