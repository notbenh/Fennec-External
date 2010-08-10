package Fennec::External;
use strict;
use warnings;

use Fennec::Util::Accessors;
use Carp;
use TAP::Parser;

use Fennec::Util::Alias qw/
    Fennec::Output::Result
    Fennec::Output::Diag
/;

Accessors qw/code/;

use base 'Fennec::TestSet';

our $VERSION = "0.001";

sub execute { croak "must override execute()"         }
sub method  { confess "method() should not be called" }

sub run_on {
    my $self = shift;
    $self->observed(1);
    my $ok = $self->execute( @_ ) || 0;
    Result->new(
        pass => $ok,
        name => "Return ok: " . $self->name
    )->write;
}

sub import {
    my $class = shift;
    my ( $keyword ) = @_;
    my $exporter = caller;
    {
        no strict 'refs';
        push @{ "$exporter\::ISA" } => $class;
        *{ "$exporter\::import" } = \&_import;
    }
    $exporter->export(
        $keyword || croak ("You must provide a keyword"),
        sub {
            my $name = shift;
            my %proto = @_ > 1 ? @_ : (code => shift( @_ ));
            my ( $caller, $file, $line ) = caller;
            $caller->fennec_meta->workflow->add_item(
                $exporter->new( $name,
                    file => $file,
                    line => $line,
                    created_in => $$,
                    %proto
                )
            );
        }
    );
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

sub merge_tap {
    my $self = shift;
    my ( $tap ) = @_;
    my $parser = TAP::Parser->new( { source => $tap } );
    while ( my $result = $parser->next ) {
        $self->_merge_result( $result )
            if $result->is_test;
        $self->_merge_comment( $result )
            if $result->is_comment;
    }
}

sub _merge_result {
    my $self = shift;
    my ( $result ) = @_;
    Result->new(
        pass => $result->is_actual_ok || 0,
        name => ("C Result " . $result->description) || "unnamed test",
        $result->has_skip
            ? ( skip => $result->explanation )
            : (),
        $result->has_todo
            ? ( todo => $result->explanation )
            : (),
    )->write;
}

sub _merge_comment {
    my $self = shift;
    my ( $result ) = @_;
    my $msg = $result->as_string;
    $msg =~ s/^#//;
    Diag->new( stderr => $msg )->write;
}

1;
