package Fennec::External::C;
use strict;
use warnings;
use Fennec::External 'testc';
use File::Temp qw/ tempfile /;
use Fennec::Runner qw/ add_config /;
use Fennec::Util::Accessors;
use Carp;

add_config $_ for qw/ c_compiler c_compiler_args c_includes /;
Accessors qw/ c_compiler c_compiler_args no_tap_merge c_includes /;

sub execute {
    my $self = shift;
    my ( $testobj ) = @_;
    my ($fh, $infile) = tempfile( "XXXXXX", SUFFIX => '.c' );
    print $fh $self->template;
    close( $fh );

    my $outfile = "$infile.compiled";

    my $args = $self->c_compiler_args
            || Fennec::Runner->c_compiler_args
            || "";

    if ( $args ) {
        $args = eval "qq{$args}";
        die( $@ ) unless $args;
    }

    my $cmd = join( " ",
        $self->c_compiler
            || Fennec::Runner->c_compiler
            || croak( "No compiler specified, use c_compiler config option" ),
        $args,
    );

    if ( system( $cmd )) {
        unlink $infile;
        die ( "$!" );
    }

    die "Could not find compiled file $outfile!"
        unless -e $outfile;

    my $TAP = `./$outfile`;
    my $out = !$?;

    unlink( $infile );
    unlink( $outfile );

    $self->merge_tap( $TAP )
        unless $self->no_tap_merge;

    return $out;
}

sub template {
    my $self = shift;
    my $code = $self->code;
    my $include = join "\n", map { "#include \"$_\"" }
        @{ $self->c_includes || Fennec::Runner->c_includes || [] };

    return <<TEMPLATE;
#include <stdio.h>
$include
void ok( int result, char* name ) {
    if ( result ) {
        printf("ok - %s\\n", name);
    }
    else {
        printf("not ok - %s\\n", name);
    }
}

int main(void) {
    $code
    return 0;
}
TEMPLATE
}

1;

__END__

=head1 NAME

Fennec::External::C - Test C code with Fennec

=head1 SYNOPSIS

    package TEST::MyC;
    use strict;
    use warnings;
    use Fennec;
    use Fennec::External::C;

    Fennec::Runner->c_compiler( 'gcc' );
    Fennec::Runner->c_compiler_args( '$infile -o $outfile' );
    Fennec::Runner->c_includes([ './MyHeader.h' ]);

    testc its_ok => <<C_CODE;
        // ok() is provided to your c code.
        ok( 1, "Should pass" );
        ok( 1, "Another");
        // prove it is C not perl
        int *x;
        int y = 1;
        x = &y;
        ok( *x, "Proof this is C" );
    C_CODE

    testc its_not_ok => (
        // The failure well not be registered by Fennec
        // when no_tap_merge is set.
        no_tap_merge => 1,
        c_includes => [ './MyHeader2.h' ];
        code => <<'    C_CODE',
            ok( 0, "Should fail" );
        C_CODE
    );

    1;

=head1 DESCRIPTION

Provides testc( $code ). This will insert your code into the main() function in
a C template file that also defines the ok( int pass, char* name ) C function.
If you do not wish to use the template see L<Fennec::External::C::Raw>.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2010 Chad Granum

Fennec is free software; Standard perl licence.

Fennec is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.  See the license for more details.
