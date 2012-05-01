use strict;
use warnings;
use Test::More;


use Catalyst::Test 'webapp';
use webapp::Controller::profile;

ok( request('/profile')->is_success, 'Request should succeed' );
done_testing();
