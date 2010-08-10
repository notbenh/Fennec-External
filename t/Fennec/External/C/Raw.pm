package TEST::Fennec::External::C::Raw;
use strict;
use warnings;
use Fennec;
use File::Which qw(which);

BEGIN {
    require_ok Fennec::External::C::Raw;
    Fennec::External::C::Raw->import;
    can_ok( __PACKAGE__, 'testc_raw' );
}

die "SKIP: This test requires GCC\n"
    unless Fennec::Runner->c_compiler( scalar( which( 'gcc' )));

Fennec::Runner->c_compiler_args( '$infile -o $outfile' );

testc_raw its_ok => <<C_CODE;
#include <stdio.h>
void ok( int result, char* name ) {
    if ( result ) {
        printf("ok - %s\\n", name);
    }
    else {
        printf("not ok - %s\\n", name);
    }
}

int main(void) {
    ok( 1, "Should pass" );
    ok( 1, "Another");
    return 0;
}
C_CODE

1;
