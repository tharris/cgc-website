use utf8;
package CGC::Schema::Result::Page;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::Page

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

=head1 TABLE: C<pages>

=cut

__PACKAGE__->table("pages");

=head1 ACCESSORS

=head2 page_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 url

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 title

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 is_obj

  data_type: 'tinyint'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "page_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "url",
  { data_type => "char", is_nullable => 1, size => 255 },
  "title",
  { data_type => "char", is_nullable => 1, size => 255 },
  "is_obj",
  { data_type => "tinyint", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</page_id>

=back

=cut

__PACKAGE__->set_primary_key("page_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-29 16:29:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Woy9E4NKbrTYNB0V+fn0cg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
