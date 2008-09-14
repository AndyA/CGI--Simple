use Test::More tests => 2;
use strict;
use warnings;
use Config;

use CGI::Simple;

# Makes forked test work OK
Test::More->builder->no_ending( 1 );

my ( $q, $sv );

$CGI::Simple::POST_MAX = -1;

SKIP: {
  skip "Fork not available on this platform", 2
   unless $Config{d_fork};

  $ENV{REQUEST_METHOD} = 'POST';
  $ENV{CONTENT_LENGTH} = 10_005;
  $ENV{CONTENT_TYPE}   = 'application/x-www-form-urlencoded';

  if ( open( CHILD, "|-" ) ) {    # cparent
    print CHILD 'SLOW=';
    for ( 1 .. 10 ) {
      print CHILD 'X' x 1000;
      sleep 1;
    }
    close CHILD;
    exit 0;
  }

  # at this point, we're in a new (child) process
  $q  = new CGI::Simple;
  $sv = $q->param( 'SLOW' );

## Please see file perltidy.ERR
  is( length $sv, 10_000,      'length ok' );
  is( $sv,        'X' x10_000, 'value ok' );
}
