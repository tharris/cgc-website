package App::Web::Controller::Documentation;

use strict;
use warnings;
use parent 'App::Web::Controller';
use FindBin qw/$Bin/;

##############################################################
#
#   The App Documentation. Yay!
# 
##############################################################

sub index : Path('/documentation') Args {
    my ($self,$c,$topic) = @_;
    my $template = 'documentation/';
    $template   .= $topic ? "$topic.tt2" : "index.tt2";
    $c->stash->{template} = $template;
}

1;
