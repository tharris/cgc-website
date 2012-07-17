package CGC::Schema::Result::FreezerSample;

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

CGC::Schema::Result::FreezerSample

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

=head2 freezer_location

  data_type: 'char'
  is_nullable: 1
  size: 10

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
  "freezer_location",
  { data_type => "char", is_nullable => 1, size => 10 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 freezer

Type: belongs_to

Related object: L<CGC::Schema::Result::Freezer>

=cut

__PACKAGE__->belongs_to(
  "freezer",
  "CGC::Schema::Result::Freezer",
  { id => "freezer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 strain

Type: belongs_to

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->belongs_to(
  "strain",
  "CGC::Schema::Result::Strain",
  { id => "strain_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 freezer_sample_events

Type: has_many

Related object: L<CGC::Schema::Result::FreezerSampleEvent>

=cut

__PACKAGE__->has_many(
  "freezer_sample_events",
  "CGC::Schema::Result::FreezerSampleEvent",
  { "foreign.freezer_sample_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 16:52:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1xMT3PlvqIGD6232SAGNmg
# These lines were loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/FreezerSample.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package CGC::Schema::Result::FreezerSample;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::FreezerSample

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

=head1 TABLE: C<freezer_sample>

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

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 freezer

Type: belongs_to

Related object: L<CGC::Schema::Result::Freezer>

=cut

__PACKAGE__->belongs_to(
  "freezer",
  "CGC::Schema::Result::Freezer",
  { id => "freezer_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);

=head2 strain

Type: belongs_to

Related object: L<CGC::Schema::Result::Strain>

=cut

__PACKAGE__->belongs_to(
  "strain",
  "CGC::Schema::Result::Strain",
  { id => "strain_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "CASCADE",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-28 17:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:I1oWXcx9cTIt3tR6efncNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/FreezerSample.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
