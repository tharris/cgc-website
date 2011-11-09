package App::Schema::CGC::Result::FreezerSample;

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

App::Schema::CGC::Result::FreezerSample

=cut

__PACKAGE__->table("freezer_sample");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 freezer_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 strain_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 vials

  data_type: 'tinyint'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 freeze_date

  data_type: 'datetime'
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
  "freezer_id",
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
  "vials",
  { data_type => "tinyint", extra => { unsigned => 1 }, is_nullable => 1 },
  "freeze_date",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 strain

Type: belongs_to

Related object: L<App::Schema::CGC::Result::Strain>

=cut

__PACKAGE__->belongs_to(
  "strain",
  "App::Schema::CGC::Result::Strain",
  { id => "strain_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 freezer

Type: belongs_to

Related object: L<App::Schema::CGC::Result::Freezer>

=cut

__PACKAGE__->belongs_to(
  "freezer",
  "App::Schema::CGC::Result::Freezer",
  { id => "freezer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2011-10-31 16:23:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fAJeBf/nST1AniqbyWS+LQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
