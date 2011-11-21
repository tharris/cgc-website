package CGC::Schema::Result::Freezer;

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
  default_value: (empty string)
  is_nullable: 1
  size: 50

=head2 location

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
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 50 },
  "location",
  { data_type => "char", is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-11-17 18:48:26
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qjiwHvuTAQazlaT6TsYddA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
