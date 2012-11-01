use utf8;
package CGC::Schema::Result::Comment;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Comment

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

=head1 TABLE: C<comments>

=cut

__PACKAGE__->table("comments");

=head1 ACCESSORS

=head2 comment_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 page_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 timestamp

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 parent_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "comment_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "page_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "timestamp",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "parent_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</comment_id>

=back

=cut

__PACKAGE__->set_primary_key("comment_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-10-31 13:06:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:owRjC9UCFyYHnfjFsBCsHQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
