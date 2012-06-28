package App::Web::Model::CGC;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'CGC::Schema',
    
    connect_info => {
        dsn => 'dbi:mysql:cgc',
        user => 'root',
        password => 'root',
        quote_names => q{1},
    }
);

=head1 NAME

App::Web::Model::CGC - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<App::Web>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<CGC::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.5

=head1 AUTHOR

Shiran Pasternak

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;