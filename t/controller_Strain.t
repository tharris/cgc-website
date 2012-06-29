use strict;
use warnings;
use Test::More;


unless (eval q{use Test::WWW::Mechanize::Catalyst 'Strain'; 1}) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst required';
    exit 0;
}

ok( my $mech = Test::WWW::Mechanize::Catalyst->new, 'Created mech object' );

$mech->get_ok( 'http://localhost/strain' );
done_testing();
