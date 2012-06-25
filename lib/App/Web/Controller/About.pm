package App::Web::Controller::About;

use strict;
use warnings;
use parent 'App::Web::Controller';
#use FindBin qw/$Bin/;

#__PACKAGE__->config->{libroot} = "$Bin/../../lib/App/API";

##############################################################
#
#   Simple about pages.
# 
##############################################################

sub about :Path('/about') :Args(0) {
    my ($self,$c) = @_;
    $c->stash->{section}  = 'about';
    $c->stash->{template} = 'about/index.tt2';  # necessary?
#    $c->stash->{section} = 'resources';
#    $c->stash->{template} = 'about/report.tt2';
#    my $page = $c->model('Schema::Page')->find({url=>"/about"});
#    my @widgets = $page->static_widgets if $page;
#    $c->stash->{static_widgets} = \@widgets if (@widgets);

}

sub citing_cgc :Path('/citing_the_cgc') :Args(0) {
    my ($self,$c) = @_;
    $c->stash->{section}  = 'about';
    $c->stash->{template} = 'about/acknowleging_the_cgc.tt2';  # necessary?
}

1;
