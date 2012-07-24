use strict;
use warnings;
use Test::More;


use Catalyst::Test 'App::Web';
use App::Web::Controller::Event;

ok( request('/event')->is_success, 'Request should succeed' );
done_testing();
