use utf8;
package CGC::Schema::Result::Strain;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Strain

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

=head1 TABLE: C<strain>

=cut

__PACKAGE__->table("strain");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 20

=head2 species_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 description

  data_type: 'mediumtext'
  is_nullable: 1

=head2 outcrossed

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 mutagen_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 genotype

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 received

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 made_by

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 laboratory_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 males

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 inbreeding_state_selfed

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 inbreeding_state_isofemale

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 inbreeding_state_multifemale

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 inbreeding_state_inbred

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 reference_strain

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
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 20 },
  "species_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "description",
  { data_type => "mediumtext", is_nullable => 1 },
  "outcrossed",
  { data_type => "char", is_nullable => 1, size => 2 },
  "mutagen_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "genotype",
  { data_type => "varchar", is_nullable => 1, size => 100 },
  "received",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "made_by",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "laboratory_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "males",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "inbreeding_state_selfed",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "inbreeding_state_isofemale",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "inbreeding_state_multifemale",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "inbreeding_state_inbred",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "reference_strain",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<strain_name_unique>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("strain_name_unique", ["name"]);

=head1 RELATIONS

=head2 app_order_contents

Type: has_many

Related object: L<CGC::Schema::Result::AppOrderContent>

=cut

__PACKAGE__->has_many(
  "app_order_contents",
  "CGC::Schema::Result::AppOrderContent",
  { "foreign.strain_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 atomized_genotypes

Type: has_many

Related object: L<CGC::Schema::Result::AtomizedGenotype>

=cut

__PACKAGE__->has_many(
  "atomized_genotypes",
  "CGC::Schema::Result::AtomizedGenotype",
  { "foreign.strain_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 freezer_samples

Type: has_many

Related object: L<CGC::Schema::Result::FreezerSample>

=cut

__PACKAGE__->has_many(
  "freezer_samples",
  "CGC::Schema::Result::FreezerSample",
  { "foreign.strain_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 laboratory

Type: belongs_to

Related object: L<CGC::Schema::Result::Laboratory>

=cut

__PACKAGE__->belongs_to(
  "laboratory",
  "CGC::Schema::Result::Laboratory",
  { id => "laboratory_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 mutagen

Type: belongs_to

Related object: L<CGC::Schema::Result::Mutagen>

=cut

__PACKAGE__->belongs_to(
  "mutagen",
  "CGC::Schema::Result::Mutagen",
  { id => "mutagen_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 species

Type: belongs_to

Related object: L<CGC::Schema::Result::Species>

=cut

__PACKAGE__->belongs_to(
  "species",
  "CGC::Schema::Result::Species",
  { id => "species_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 strain_events

Type: has_many

Related object: L<CGC::Schema::Result::StrainEvent>

=cut

__PACKAGE__->has_many(
  "strain_events",
  "CGC::Schema::Result::StrainEvent",
  { "foreign.strain_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-14 17:46:14
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DERog322+2K+16LS7TDpIw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
