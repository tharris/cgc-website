package WormBase::Schema::Result::OAuth;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

WormBase::Schema::Result::OpenID

=cut

__PACKAGE__->table("oauth");

__PACKAGE__->add_columns(
  "oauth_id",
  { data_type => "text", is_nullable => 0, is_auto_increment => 1},
  "provider",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_nullable => 1 },
  "access_token",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "access_token_secret",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "username",
  { data_type => "text", default_value => "", is_nullable => 0 },

);

__PACKAGE__->set_primary_key("oauth_id");


#__PACKAGE__->add_unique_constraint([ 'openid_url' ]);

__PACKAGE__->belongs_to(user=>'WormBase::Schema::Result::User','user_id');

