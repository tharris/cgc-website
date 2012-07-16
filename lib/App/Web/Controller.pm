package App::Web::Controller;

use strict;
use warnings;
use parent 'Catalyst::Controller';

#########################################
# Accessors for configuration variables #
#########################################
sub error_custom{
     my ( $self, $c, $status,$message ) = @_;
	$c->res->status($status);
	$c->error($message) ;
	$c->detach();
     
}






1;
