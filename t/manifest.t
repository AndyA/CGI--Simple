#!perl

use strict;
use warnings;

use ExtUtils::Manifest qw( fullcheck );
use Test::More tests => 2;

my ( $missing, $extra ) = fullcheck;

is_deeply $missing, [], 'missing files';
is_deeply $extra,   [], 'extra files';

# vim:ts=2:sw=2:et:ft=perl

