use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'CGI::Simple',
    sign                => 1,
    license             => 'perl',
    dist_author         => 'Andy Armstrong <andy@hexten.net>',
    dist_version_from   => 'lib/CGI/Simple.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'CGI-Simple-*' ],
);

$builder->create_build_script();
