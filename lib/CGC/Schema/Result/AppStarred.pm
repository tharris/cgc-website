use utf8;
package CGC::Schema::Result::AppStarred;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::AppStarred

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

=head1 TABLE: C<app_starred>

=cut

__PACKAGE__->table("app_starred");

=head1 ACCESSORS

=head2 session_id

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 72

=head2 page_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 save_to

  data_type: 'char'
  is_nullable: 1
  size: 50

=head2 timestamp

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "session_id",
  { data_type => "char", default_value => "", is_nullable => 0, size => 72 },
  "page_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "save_to",
  { data_type => "char", is_nullable => 1, size => 50 },
  "timestamp",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</session_id>

=item * L</page_id>

=back

=cut

__PACKAGE__->set_primary_key("session_id", "page_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-29 16:29:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Qv5Pceu4H9XIVKXIdtLc8g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
