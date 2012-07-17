package CGC::Schema::Result::Comment;

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

CGC::Schema::Result::Comment

=cut

__PACKAGE__->table("comments");

=head1 ACCESSORS

=head2 comment_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=head2 page_id

  data_type: 'integer'
  is_nullable: 1

=head2 timestamp

  data_type: 'integer'
  is_nullable: 1

=head2 parent_id

  data_type: 'integer'
  is_nullable: 1

=head2 content

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "comment_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "page_id",
  { data_type => "integer", is_nullable => 1 },
  "timestamp",
  { data_type => "integer", is_nullable => 1 },
  "parent_id",
  { data_type => "integer", is_nullable => 1 },
  "content",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("comment_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 20:47:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0GNAzJfc3H6zRi2Xk3WDNQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
