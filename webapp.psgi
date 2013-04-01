use strict;
use warnings;

use webapp;

my $app = webapp->apply_default_middlewares(webapp->psgi_app);
$app;

