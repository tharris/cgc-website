package CGC::Schema::Result::Gene;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::Gene

=cut

__PACKAGE__->table("gene");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 wormbase_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 locus_name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 sequence_name

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

=head2 pmap_start

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 pmap_stop

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 strand

  data_type: 'char'
  is_nullable: 1
  size: 1

=head2 species_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 gene_class_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 type

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 confirmed

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "wormbase_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "locus_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "sequence_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "chromosome",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "gmap",
  { data_type => "float", is_nullable => 1, size => [7, 5] },
  "pmap_start",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "pmap_stop",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "strand",
  { data_type => "char", is_nullable => 1, size => 1 },
  "species_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "gene_class_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "confirmed",
  { data_type => "varchar", is_nullable => 1, size => 20 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("gene_name_unique", ["name"]);
__PACKAGE__->add_unique_constraint("gene_wormbase_id_unique", ["wormbase_id"]);

=head1 RELATIONS

=head2 atomized_genotypes

Type: has_many

Related object: L<CGC::Schema::Result::AtomizedGenotype>

=cut

__PACKAGE__->has_many(
  "atomized_genotypes",
  "CGC::Schema::Result::AtomizedGenotype",
  { "foreign.gene_id" => "self.id" },
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

=head2 gene_class

Type: belongs_to

Related object: L<CGC::Schema::Result::GeneClass>

=cut

__PACKAGE__->belongs_to(
  "gene_class",
  "CGC::Schema::Result::GeneClass",
  { id => "gene_class_id" },
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
  { "foreign.gene_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 21:09:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E25w8MmuYRv3NMK1GAHcQA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
