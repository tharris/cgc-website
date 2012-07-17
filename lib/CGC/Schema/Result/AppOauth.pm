package CGC::Schema::Result::AppOauth;

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

CGC::Schema::Result::AppOauth

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
__PACKAGE__->set_primary_key("oauth_id");


# Created by DBIx::Class::Schema::Loader v0.07010 @ 2012-07-16 20:47:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Bb61Z7eRZbLIIzSJx6FYkw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
