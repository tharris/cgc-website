use utf8;
package CGC::Schema::Result::AppHistory;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::AppHistory

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<app_history>

=cut

__PACKAGE__->table("app_history");

=head1 ACCESSORS

=head2 session_id

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 72

=head2 page_id

  data_type: 'integer'
  default_value: 0
  extra: {unsigned => 1}
  is_nullable: 0

=head2 timestamp

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 visit_count

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "session_id",
  { data_type => "char", default_value => "", is_nullable => 0, size => 72 },
  "page_id",
  {
    data_type => "integer",
    default_value => 0,
    extra => { unsigned => 1 },
    is_nullable => 0,
  },
  "timestamp",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "visit_count",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</session_id>

=item * L</page_id>

=back

=cut

__PACKAGE__->set_primary_key("session_id", "page_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-10-31 13:06:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TmDDRpTZajB8sW7JZq7dZg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
