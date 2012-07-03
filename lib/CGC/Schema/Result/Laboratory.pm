use utf8;
package CGC::Schema::Result::Laboratory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Laboratory

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

=head1 TABLE: C<laboratory>

=cut

__PACKAGE__->table("laboratory");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 head

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 lab_head_first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 lab_head_middle_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 lab_head_last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 laboratory_designation

  data_type: 'varchar'
  is_nullable: 1
  size: 25

=head2 strain_designation

  data_type: 'varchar'
  is_nullable: 1
  size: 5

=head2 street_address

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 address1

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 address2

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 state

  data_type: 'char'
  is_nullable: 1
  size: 2

=head2 zip

  data_type: 'decimal'
  extra: {unsigned => 1}
  is_nullable: 1
  size: [5,0]

=head2 country

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 commercial

  data_type: 'tinyint'
  is_nullable: 1

=head2 institution

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 city

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 website

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date_assigned

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "head",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lab_head_first_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lab_head_middle_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lab_head_last_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "laboratory_designation",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "strain_designation",
  { data_type => "varchar", is_nullable => 1, size => 5 },
  "street_address",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "address1",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "address2",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "state",
  { data_type => "char", is_nullable => 1, size => 2 },
  "zip",
  {
    data_type => "decimal",
    extra => { unsigned => 1 },
    is_nullable => 1,
    size => [5, 0],
  },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "commercial",
  { data_type => "tinyint", is_nullable => 1 },
  "institution",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "city",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "website",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_assigned",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<laboratory_designation_unique>

=over 4

=item * L</laboratory_designation>

=back

=cut

__PACKAGE__->add_unique_constraint("laboratory_designation_unique", ["laboratory_designation"]);

=head1 RELATIONS

=head2 gene_classes_2s

Type: has_many

Related object: L<CGC::Schema::Result::GeneClass>

=cut

__PACKAGE__->has_many(
  "gene_classes_2s",
  "CGC::Schema::Result::GeneClass",
  { "foreign.designating_laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 lab_order

Type: might_have

Related object: L<CGC::Schema::Result::LabOrder>

=cut

__PACKAGE__->might_have(
  "lab_order",
  "CGC::Schema::Result::LabOrder",
  { "foreign.id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 laboratory2gene_classes

Type: has_many

Related object: L<CGC::Schema::Result::Laboratory2geneClass>

=cut

__PACKAGE__->has_many(
  "laboratory2gene_classes",
  "CGC::Schema::Result::Laboratory2geneClass",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 laboratory2variations

Type: has_many

Related object: L<CGC::Schema::Result::Laboratory2variation>

=cut

__PACKAGE__->has_many(
  "laboratory2variations",
  "CGC::Schema::Result::Laboratory2variation",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 legacy_lablists

Type: has_many

Related object: L<CGC::Schema::Result::LegacyLablist>

=cut

__PACKAGE__->has_many(
  "legacy_lablists",
  "CGC::Schema::Result::LegacyLablist",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 strains

Type: has_many

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->has_many(
  "strains",
  "CGC::Schema::Result::Strain",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_classes

Type: many_to_many

Composing rels: L</laboratory2gene_classes> -> gene_class

=cut

__PACKAGE__->many_to_many("gene_classes", "laboratory2gene_classes", "gene_class");

=head2 variations

Type: many_to_many

Composing rels: L</laboratory2variations> -> variation

=cut

__PACKAGE__->many_to_many("variations", "laboratory2variations", "variation");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-03 22:16:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RblRY1Kv7HtkgitWHSLoeQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
