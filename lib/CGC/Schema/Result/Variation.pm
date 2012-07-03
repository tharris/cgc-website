use utf8;
package CGC::Schema::Result::Variation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Variation

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

=head1 TABLE: C<variation>

=cut

__PACKAGE__->table("variation");

=head1 ACCESSORS

=head2 variation_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 wormbase_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 public_name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 chromosome

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 gmap

  data_type: 'float'
  is_nullable: 1
  size: [7,5]

=head2 pmap

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 species_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 strain_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 is_reference_allele

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "variation_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "wormbase_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "public_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "chromosome",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "gmap",
  { data_type => "float", is_nullable => 1, size => [7, 5] },
  "pmap",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "species_id",
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
  "is_reference_allele",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</variation_id>

=back

=cut

__PACKAGE__->set_primary_key("variation_id");

=head1 UNIQUE CONSTRAINTS

=head2 C<variation_public_name>

=over 4

=item * L</public_name>

=back

=cut

__PACKAGE__->add_unique_constraint("variation_public_name", ["public_name"]);

=head1 RELATIONS

=head2 atomized_genotypes

Type: has_many

Related object: L<CGC::Schema::Result::AtomizedGenotype>

=cut

__PACKAGE__->has_many(
  "atomized_genotypes",
  "CGC::Schema::Result::AtomizedGenotype",
  { "foreign.variation_id" => "self.variation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
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

=head2 variation2genes

Type: has_many

Related object: L<CGC::Schema::Result::Variation2gene>

=cut

__PACKAGE__->has_many(
  "variation2genes",
  "CGC::Schema::Result::Variation2gene",
  { "foreign.variation_id" => "self.variation_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 genes

Type: many_to_many

Composing rels: L</variation2genes> -> gene

=cut

__PACKAGE__->many_to_many("genes", "variation2genes", "gene");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-03 02:46:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XJne0DloWmwPaUBsoqq2TQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
