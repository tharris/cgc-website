package CGC::Schema::Result::AppHistory;

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

CGC::Schema::Result::AppHistory

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
  is_nullable: 0

=head2 timestamp

  data_type: 'integer'
  is_nullable: 1

=head2 visit_count

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "session_id",
  { data_type => "char", default_value => "", is_nullable => 0, size => 72 },
  "page_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "timestamp",
  { data_type => "integer", is_nullable => 1 },
  "visit_count",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("session_id", "page_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 16:52:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ty7ga5p9qy9xk8+2b7jRow


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
