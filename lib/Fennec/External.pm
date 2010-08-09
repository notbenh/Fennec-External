package Fennec::External;
use strict;
use warnings;

use Exporter::Declare;
use Fennec::Util::Accessors;
use Carp;

use Fennec::Util::Alias qw/
    Fennec::Output::Result
/;

Accessors qw/code/;

use base 'Fennec::TestSet';

our $VERSION = "0.001";

sub keyword { croak "must override keyword()"         }
sub execute { croak "must override execute()"         }
sub method  { confess "method() should not be called" }

sub run_on {
    my $self = shift;
    my $ok = $self->execute( @_ ) || 0;
    Result->new(
        pass => $ok,
        name => $self->name
    );
}

sub import {
    my $class = shift;
    my $exporter = caller;
    $class->export(
        $class->keyword,
        sub {
            my $name = shift;
            my %proto = @_ > 1 ? @_ : (code => shift( @_ ));
            my ( $caller, $file, $line ) = caller;
            $caller->fennec_meta->workflow->add_item(
                __PACKAGE__->new( $name,
                    file => $file,
                    line => $line,
                    %proto
                )
            );
        }
    );
    no strict 'refs';
    *{ "$exporter\::import" } = &_import;
}

sub _import {
    my $class = shift;
    my $caller = caller;
    my ( $imports, $specs ) = $class->_import_args( @_ );
    $class->export_to( $caller, $specs->{prefix} || undef, @$imports );
}

sub new {
    my $class = shift;
    my $name = shift;
    my %proto = @_;
    return bless( { %proto, name => $name }, $class );
}

1;
