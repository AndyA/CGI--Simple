use strict;
use Module::Build;

use lib 'inc';

use MyBuilder;

my $builder = MyBuilder->new(
  module_name       => 'CGI::Simple',
  sign              => 1,
  license           => 'perl',
  dist_author       => 'Andy Armstrong <andy@hexten.net>',
  dist_version_from => 'lib/CGI/Simple.pm',
  requires          => { 'Test::More' => 0, },
  add_to_cleanup    => ['CGI-Simple-*'],
);

$builder->create_build_script();
