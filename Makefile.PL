use strict;
use ExtUtils::MakeMaker;

my %conf = (
  #( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
  NAME          => 'CGI::Simple',
  AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
  VERSION_FROM  => 'lib/CGI/Simple.pm',
  ABSTRACT_FROM => 'lib/CGI/Simple.pm',
  PL_FILES      => {},
  PREREQ_PM     => {
    'Test::More' => 0,
    'Test::NoWarnings' => 0,
    'IO::Scalar' => 0
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'CGI-Simple-*' },
);

if (eval { ExtUtils::MakeMaker->VERSION(6.3002) }) {
	$conf{LICENSE} = 'perl';
}

if (eval { ExtUtils::MakeMaker->VERSION(6.46) }) {
	$conf{META_MERGE} = {
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type       => 'git',
				url        => 'http://github.com/szabgab/CGI--Simple.git',
				web        => 'http://github.com/szabgab/CGI--Simple',
				license    => 'http://dev.perl.org/licenses/',
			},
		},
	};
}

WriteMakefile(%conf);

