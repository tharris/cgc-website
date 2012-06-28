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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-11-09 21:54:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lKED3vU9ooFDwbHx/Ky0Cg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;