use strict;
use warnings;
use Test::More;


use Catalyst::Test 'webapp';
use webapp::Controller::init;

ok( request('/init')->is_success, 'Request should succeed' );
done_testing();
