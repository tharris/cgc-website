package CGC::Schema::Result::Species;

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

CGC::Schema::Result::Species

=cut

__PACKAGE__->table("species");

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
  size: 255

=head2 ncbi_taxonomy_id

  data_type: 'integer'
  extra: {unsigned => 1}
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
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "ncbi_taxonomy_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("species_name_unique", ["name"]);

=head1 RELATIONS

=head2 genes

Type: has_many

Related object: L<CGC::Schema::Result::Gene>

=cut

__PACKAGE__->has_many(
  "genes",
  "CGC::Schema::Result::Gene",
  { "foreign.species_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 rearrangements

Type: has_many

Related object: L<CGC::Schema::Result::Rearrangement>

=cut

__PACKAGE__->has_many(
  "rearrangements",
  "CGC::Schema::Result::Rearrangement",
  { "foreign.species_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 strains

Type: has_many

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->has_many(
  "strains",
  "CGC::Schema::Result::Strain",
  { "foreign.species_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 transgenes

Type: has_many

Related object: L<CGC::Schema::Result::Transgene>

=cut

__PACKAGE__->has_many(
  "transgenes",
  "CGC::Schema::Result::Transgene",
  { "foreign.species_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 variations

Type: has_many

Related object: L<CGC::Schema::Result::Variation>

=cut

__PACKAGE__->has_many(
  "variations",
  "CGC::Schema::Result::Variation",
  { "foreign.species_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 16:52:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XKIlIz8r1M9JUjoV1FBNOA
# These lines were loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/Species.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package CGC::Schema::Result::Species;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Species

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

=head1 TABLE: C<species>

=cut

__PACKAGE__->table("species");

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
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 50 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 strains

Type: has_many

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->has_many(
  "strains",
  "CGC::Schema::Result::Strain",
  { "foreign.species_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-28 17:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:dhBEUItuWWw9aKt698dxPQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/Species.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
