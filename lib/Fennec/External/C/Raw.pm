package Fennec::External::C::Raw;
use strict;
use warnings;
use base 'Fennec::External::C';
use Fennec::External 'testc_raw';

sub template { shift->code }

1;

__END__

=head1 NAME

Fennec::External::C::Raw - Test RAW C code with Fennec

=head1 SYNOPSIS

    package TEST::MyC;
    use strict;
    use warnings;
    use Fennec;
    use Fennec::External::C::Raw;

    Fennec::Runner->c_compiler( 'gcc' );
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

=head1 DESCRIPTION

Provides testc( $code ). This will compile your C code AS-IS and run it. See
L<Fennec::External::C> for a templated wrapper.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
