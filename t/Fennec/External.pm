package TEST::Fennec::External;
use strict;
use warnings;
use Fennec;

tests load => sub {
    require_ok( 'Fennec::External' );
    can_ok( 'Fennec::External', 'export' );
};

1;
