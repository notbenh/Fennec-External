package TEST::Fennec::External::C;
use strict;
use warnings;
use Fennec;

BEGIN {
    require_ok Fennec::External::C;
    Fennec::External::C->import;
    can_ok( __PACKAGE__, 'testc' );
}

exit 0 if system( 'gcc --help > /dev/null' );

Fennec::Runner->c_compiler( 'gcc' );
Fennec::Runner->c_compiler_out_flag( '-o' );

testc its_ok => <<C_CODE;
    ok( 1, "Should pass" );
C_CODE

testc its_not_ok => (
    todo => 'Not really todo, testing a fail in the C',
    code => <<'    C_CODE',
        ok( 0, "Should fail todo" );
    C_CODE
);
1;
