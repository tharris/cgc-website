use utf8;
package CGC::Schema::Result::Laboratory2variation;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Laboratory2variation

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

=head1 TABLE: C<laboratory2variation>

=cut

__PACKAGE__->table("laboratory2variation");

=head1 ACCESSORS

=head2 laboratory_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 variation_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "laboratory_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "variation_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</laboratory_id>

=item * L</variation_id>

=back

=cut

__PACKAGE__->set_primary_key("laboratory_id", "variation_id");

=head1 RELATIONS

=head2 laboratory

Type: belongs_to

Related object: L<CGC::Schema::Result::Laboratory>

=cut

__PACKAGE__->belongs_to(
  "laboratory",
  "CGC::Schema::Result::Laboratory",
  { id => "laboratory_id" },
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


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-07-03 21:38:25
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7YnhNq2IUbLels/hrsCKMg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
