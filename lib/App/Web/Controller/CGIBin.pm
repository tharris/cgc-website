package App::Web::Controller::CGIBin;

use strict;
use warnings;
use parent 'Catalyst::Controller::CGIBin';

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in App.pm
__PACKAGE__->config->{namespace} = '';

 

1;
