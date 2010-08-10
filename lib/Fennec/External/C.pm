package Fennec::External::C;
use strict;
use warnings;
use Fennec::External 'testc';
use File::Temp qw/ tempfile /;
use Fennec::Runner qw/ add_config /;
use Fennec::Util::Accessors;
use Carp;

add_config $_ for qw/ c_compiler c_compiler_args c_compiler_out_flag /;
Accessors qw/ c_compiler c_compiler_args c_compiler_out_flag /;

sub execute {
    my $self = shift;
    my ( $testobj ) = @_;
    my ($fh, $filename) = tempfile( "XXXXXX", SUFFIX => '.c' );
    print $fh $self->template;
    close( $fh );

    my $outfile = "$filename.compiled";

    my $cmd = join( " ",
        $self->c_compiler
            || Fennec::Runner->c_compiler
            || croak( "No compiler specified, use c_compiler config option" ),
        $self->c_compiler_args
            || Fennec::Runner->c_compiler_args
            || "",
        $filename,
        $self->c_compiler_out_flag || Fennec::Runner->c_compiler_out_flag,
        $outfile,
    );

    system( $cmd ) && die ( "$!" );

    die "Could not find compiled file $outfile!"
        unless -e $outfile;

    my $TAP = `./$outfile`;
    unlink( $filename );
    unlink( $outfile );

    $self->merge_tap( $TAP );
    my $out = !$?;
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
}
TEMPLATE
}

1;
