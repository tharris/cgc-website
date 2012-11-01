use utf8;
package CGC::Schema::Result::AppRole;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

CGC::Schema::Result::AppRole

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

=head1 TABLE: C<app_roles>

=cut

__PACKAGE__->table("app_roles");

=head1 ACCESSORS

=head2 role_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 0

=head2 role

  data_type: 'char'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "role_id",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 0 },
  "role",
  { data_type => "char", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</role_id>

=back

=cut

__PACKAGE__->set_primary_key("role_id");


# Created by DBIx::Class::Schema::Loader v0.07024 @ 2012-10-31 13:06:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:KaIt9YJYhOkWC0nomt/Xgw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
