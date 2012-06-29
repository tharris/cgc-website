use utf8;
package CGC::Schema::Result::AppOauth;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::AppOauth

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

=head1 TABLE: C<app_oauth>

=cut

__PACKAGE__->table("app_oauth");

=head1 ACCESSORS

=head2 oauth_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=head2 provider

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 access_token

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 access_token_secret

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 username

  data_type: 'char'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "oauth_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "provider",
  { data_type => "char", is_nullable => 1, size => 255 },
  "access_token",
  { data_type => "char", is_nullable => 1, size => 255 },
  "access_token_secret",
  { data_type => "char", is_nullable => 1, size => 255 },
  "username",
  { data_type => "char", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</oauth_id>

=back

=cut

__PACKAGE__->set_primary_key("oauth_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-29 16:29:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:quXsMw6PLahgY1q8HXD9OA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
