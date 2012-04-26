use strict;
use warnings;
use Test::More;


use Catalyst::Test 'webapp';
use webapp::Controller::admin;

ok( request('/admin')->is_success, 'Request should succeed' );
done_testing();
