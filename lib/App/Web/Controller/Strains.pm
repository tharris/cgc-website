package App::Web::Controller::Strains;

use strict;
use warnings;
use parent 'App::Web::Controller';

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in App.pm
__PACKAGE__->config->{namespace} = '';

=head1 NAME

App::Web::Controller::Downloads - Various download actions.

=head1 DESCRIPTION

Download actions for the App web application.

=head1 METHODS

=cut

=head2 INDEX

An index page of available downloads.

=cut

sub index : Path Args(0) {
    my ($self, $c) = @_;
#    $c->stash->{template} = 'index.tt2';  # This should be unecessary.  make sure it is.
#    my $page = $c->model('Schema::Page')->find({url=>"/"});
#    my @widgets = $page->static_widgets if $page;
#    $c->stash->{static_widgets} = \@widgets if (@widgets);
    $c->stash->{template} = 'index.tt2';
}

sub all_strains : Path('/all_strains') : Args(0) {
    my ($self, $c) = @_;
    $c->detach('all_species', ['all'])
        ;    # TH: what does all mean in this context?
}

sub recently_added : Path('/recently_added') : Args(0) {
    my ($self, $c) = @_;
    $c->detach('recently_added', ['all'])
        ;    # TH: what does all mean in this context?
}

sub wild_strains : Path('/wild_strains') : Args(0) {
    my ($self, $c) = @_;
    $c->detach('wild_strains', ['all'])
        ;    # TH: what does all mean in this context?
}

sub non_celegans_strains : Path('/non_celegans_strains') : Args(0) {
    my ($self, $c) = @_;
    $c->detach('non_celegans_strains', ['all'])
        ;    # TH: what does all mean in this context?
}

=head1 AUTHOR

Todd Harris (info@toddharris.net)

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
