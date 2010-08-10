package Fennec::External::C;
use strict;
use warnings;
use Fennec::External 'testc';
use File::Temp qw/ tempfile /;
use Fennec::Runner qw/ add_config /;
use Fennec::Util::Accessors;
use Carp;

add_config $_ for qw/ c_compiler c_compiler_args /;
Accessors qw/ c_compiler c_compiler_args no_tap_merge /;

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
    return <<TEMPLATE;
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
    $code
    return 0;
}
TEMPLATE
}

1;
