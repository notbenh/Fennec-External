#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Fennec::External',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires => {
        'Fennec'      => 0.027,
        'File::Which' => 0,
    },
    meta_merge => {
        resources => {
            repository  => 'http://github.com/exodist/Fennec-External',
            bugtracker  => 'http://github.com/exodist/Fennec-External/issues',
        },
    }
);

$build->create_build_script;
