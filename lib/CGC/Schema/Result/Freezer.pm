package CGC::Schema::Result::Freezer;

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

CGC::Schema::Result::Freezer

=cut

__PACKAGE__->table("freezer");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 type

  data_type: 'varchar'
  is_nullable: 1
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
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "type",
  { data_type => "varchar", is_nullable => 1, size => 50 },
);
__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 freezer_events

Type: has_many

Related object: L<CGC::Schema::Result::FreezerEvent>

=cut

__PACKAGE__->has_many(
  "freezer_events",
  "CGC::Schema::Result::FreezerEvent",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 freezer_samples

Type: has_many

Related object: L<CGC::Schema::Result::FreezerSample>

=cut

__PACKAGE__->has_many(
  "freezer_samples",
  "CGC::Schema::Result::FreezerSample",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 legacy_frzlocs

Type: has_many

Related object: L<CGC::Schema::Result::LegacyFrzloc>

=cut

__PACKAGE__->has_many(
  "legacy_frzlocs",
  "CGC::Schema::Result::LegacyFrzloc",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 20:47:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8BBW+r6ikn0glJRF1NNOtA
# These lines were loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/Freezer.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package CGC::Schema::Result::Freezer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Freezer

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

=head1 TABLE: C<freezer>

=cut

__PACKAGE__->table("freezer");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 50

=head2 location

  data_type: 'char'
  is_nullable: 1
  size: 10

Not sure yet how to represent location

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
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 50 },
  "location",
  { data_type => "char", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 freezer_samples

Type: has_many

Related object: L<CGC::Schema::Result::FreezerSample>

=cut

__PACKAGE__->has_many(
  "freezer_samples",
  "CGC::Schema::Result::FreezerSample",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 legacy_frzlocs

Type: has_many

Related object: L<CGC::Schema::Result::LegacyFrzloc>

=cut

__PACKAGE__->has_many(
  "legacy_frzlocs",
  "CGC::Schema::Result::LegacyFrzloc",
  { "foreign.freezer_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-28 17:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7TWkgGIpXDt3qg/VNDdWWw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/usr/local/lib/perl5/site_perl/5.14.1/CGC/Schema/Result/Freezer.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
