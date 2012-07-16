package CGC::Schema::Result::Variation2gene;

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

CGC::Schema::Result::Variation2gene

=cut

__PACKAGE__->table("variation2gene");

=head1 ACCESSORS

=head2 variation_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 gene_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "variation_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "gene_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key("variation_id", "gene_id");

=head1 RELATIONS

=head2 gene

Type: belongs_to

Related object: L<CGC::Schema::Result::Gene>

=cut

__PACKAGE__->belongs_to(
  "gene",
  "CGC::Schema::Result::Gene",
  { id => "gene_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 variation

Type: belongs_to

Related object: L<CGC::Schema::Result::Variation>

=cut

__PACKAGE__->belongs_to(
  "variation",
  "CGC::Schema::Result::Variation",
  { id => "variation_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 16:52:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:w58yht0TW4STIjWZmZn5/Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
