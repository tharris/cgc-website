use utf8;
package CGC::Schema::Result::AppOpenid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::AppOpenid

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

=head1 TABLE: C<app_openid>

=cut

__PACKAGE__->table("app_openid");

=head1 ACCESSORS

=head2 auth_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 openid_url

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 user_id

  data_type: 'integer'
  is_nullable: 1

=head2 provider

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 oauth_access_token

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 oauth_access_token_secret

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 screen_name

  data_type: 'char'
  is_nullable: 1
  size: 255

=head2 auth_type

  data_type: 'char'
  is_nullable: 1
  size: 20

=cut

__PACKAGE__->add_columns(
  "auth_id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "openid_url",
  { data_type => "char", is_nullable => 1, size => 255 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "provider",
  { data_type => "char", is_nullable => 1, size => 255 },
  "oauth_access_token",
  { data_type => "char", is_nullable => 1, size => 255 },
  "oauth_access_token_secret",
  { data_type => "char", is_nullable => 1, size => 255 },
  "screen_name",
  { data_type => "char", is_nullable => 1, size => 255 },
  "auth_type",
  { data_type => "char", is_nullable => 1, size => 20 },
);

=head1 PRIMARY KEY

=over 4

=item * L</auth_id>

=back

=cut

__PACKAGE__->set_primary_key("auth_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-06-29 16:29:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zkTq9UxrM0ZxuShOy5HGjg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
