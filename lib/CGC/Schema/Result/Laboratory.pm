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
  default_value: (empty string)
  is_nullable: 0
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
);
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


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-11-09 21:54:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gt36nGp54yNT8x9oXlhmYA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
