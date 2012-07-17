package CGC::Schema::Result::Transgene;

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

CGC::Schema::Result::Transgene

=cut

__PACKAGE__->table("transgene");

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

=head2 description

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 reporter_type

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 reporter_product

  data_type: 'varchar'
  is_nullable: 1
  size: 40

=head2 extrachromosomal

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 integrated

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 reporter_product_gene_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

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

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 species_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 laboratory_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

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
  "description",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "reporter_type",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "reporter_product",
  { data_type => "varchar", is_nullable => 1, size => 40 },
  "extrachromosomal",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "integrated",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "reporter_product_gene_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
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
  "status",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "species_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "laboratory_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("transgene_name_unique", ["name"]);

=head1 RELATIONS

=head2 atomized_genotypes

Type: has_many

Related object: L<CGC::Schema::Result::AtomizedGenotype>

=cut

__PACKAGE__->has_many(
  "atomized_genotypes",
  "CGC::Schema::Result::AtomizedGenotype",
  { "foreign.transgene_id" => "self.id" },
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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 20:47:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:GbKZ5J1LD7MKdJ6pYd0Uhw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
