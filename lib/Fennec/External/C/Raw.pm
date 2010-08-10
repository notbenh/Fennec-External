package Fennec::External::C::Raw;
use strict;
use warnings;
use base 'Fennec::External::C';
use Fennec::External 'testc_raw';

sub template { shift->code }

1;
