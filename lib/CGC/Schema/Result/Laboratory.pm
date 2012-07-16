package CGC::Schema::Result::Laboratory;

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

CGC::Schema::Result::Laboratory

=cut

__PACKAGE__->table("laboratory");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 25

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

=head2 allele_designation

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

=head2 contact_email

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date_assigned

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 date_updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
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
  "name",
  { data_type => "varchar", is_nullable => 1, size => 25 },
  "head",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lab_head_first_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lab_head_middle_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "lab_head_last_name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "allele_designation",
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
  "contact_email",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_assigned",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "date_updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("name_unique", ["name"]);

=head1 RELATIONS

=head2 app_orders

Type: has_many

Related object: L<CGC::Schema::Result::AppOrder>

=cut

__PACKAGE__->has_many(
  "app_orders",
  "CGC::Schema::Result::AppOrder",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 gene_classes

Type: has_many

Related object: L<CGC::Schema::Result::GeneClass>

=cut

__PACKAGE__->has_many(
  "gene_classes",
  "CGC::Schema::Result::GeneClass",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 laboratory_events

Type: has_many

Related object: L<CGC::Schema::Result::LaboratoryEvent>

=cut

__PACKAGE__->has_many(
  "laboratory_events",
  "CGC::Schema::Result::LaboratoryEvent",
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

=head2 rearrangements

Type: has_many

Related object: L<CGC::Schema::Result::Rearrangement>

=cut

__PACKAGE__->has_many(
  "rearrangements",
  "CGC::Schema::Result::Rearrangement",
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

=head2 transgenes

Type: has_many

Related object: L<CGC::Schema::Result::Transgene>

=cut

__PACKAGE__->has_many(
  "transgenes",
  "CGC::Schema::Result::Transgene",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 variations

Type: has_many

Related object: L<CGC::Schema::Result::Variation>

=cut

__PACKAGE__->has_many(
  "variations",
  "CGC::Schema::Result::Variation",
  { "foreign.laboratory_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 16:52:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:O9C1GntDI7W1DVhybJVucQ
# These lines were loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/Laboratory.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

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
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-28 17:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a1cEYDw+xE16PWYhIsL6Ww


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/Laboratory.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
