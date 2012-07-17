package CGC::Schema::Result::AppOpenid;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

CGC::Schema::Result::AppOpenid

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
__PACKAGE__->set_primary_key("auth_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 21:09:15
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9KUUWsJiUK86k3uIZNE8yA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
