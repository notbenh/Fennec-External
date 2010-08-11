package TEST::Fennec::External::C;
use strict;
use warnings;
use Fennec;
use File::Which qw(which);

BEGIN {
    require_ok Fennec::External::C;
    Fennec::External::C->import;
    can_ok( __PACKAGE__, 'testc' );
}

die "SKIP: This test requires GCC\n"
    unless Fennec::Runner->c_compiler( scalar( which( 'gcc' )));

Fennec::Runner->c_compiler_args( '$infile -o $outfile' );

testc its_ok => <<C_CODE;
    ok( 1, "Should pass" );
    ok( 1, "Another");
    // prove it is C not perl
    int *x;
    int y = 1;
    x = &y;
    ok( *x, "Proof this is C" );
C_CODE

testc its_not_ok => (
    no_tap_merge => 1,
    code => <<'    C_CODE',
        ok( 0, "Should fail" );
    C_CODE
);

tests template {
    my $template = Fennec::External::C->new(
        'name',
        observed => 1,
        code => "XXX",
        c_includes => [ 'a', 'b' ],
    )->template;

    is(
        $template,
        <<'        EOT',
#include <stdio.h>
#include "a"
#include "b"
void ok( int result, char* name ) {
    if ( result ) {
        printf("ok - %s\n", name);
    }
    else {
        printf("not ok - %s\n", name);
    }
}

int main(void) {
    XXX
    return 0;
}
        EOT
        "Template with includes"
    );
};

1;
