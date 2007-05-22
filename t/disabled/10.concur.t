use Test::More;

eval "use CGI";
plan skip_all => "CGI required for tests" if $@;
plan tests => 158;

use CGI::Simple;

my ($q, $s, $cgi, $simp, @cgi, @simp, %cgi, %simp, @vals, $debug);

$ENV{'AUTH_TYPE'}      = 'PGP MD5 DES rot13';
$ENV{'CONTENT_LENGTH'} = '42';
$ENV{'CONTENT_TYPE'}   = 'application/x-www-form-urlencoded';
$ENV{'COOKIE'} = 'foo=a%20phrase; bar=yes%2C%20a%20phrase&I%20say';
$ENV{'DOCUMENT_ROOT'}     = '/vs/www/foo';
$ENV{'GATEWAY_INTERFACE'} = 'bleeding edge';
$ENV{'HTTPS'}             = 'ON';
$ENV{'HTTPS_A'}           = 'A';
$ENV{'HTTPS_B'}           = 'B';
$ENV{'HTTP_ACCEPT'} =
    'text/html;q=1, text/plain;q=0.8, image/jpg, image/gif;q=0.42, */*;q=0.001';
$ENV{'HTTP_COOKIE'}     = '';
$ENV{'HTTP_FROM'}       = 'spammer@nowhere.com';
$ENV{'HTTP_HOST'}       = 'the.vatican.org:8080';
$ENV{'HTTP_REFERER'}    = 'xxx.sex.com';
$ENV{'HTTP_USER_AGENT'} = 'LWP';
$ENV{'PATH_INFO'}       = '/somewhere/else';
$ENV{'PATH_TRANSLATED'} = '/usr/local/somewhere/else';
$ENV{'QUERY_STRING'} = 'name=JaPh%2C&color=red&color=green&color=blue';
$ENV{'REDIRECT_QUERY_STRING'} = '';
$ENV{'REMOTE_ADDR'}           = '127.0.0.1';
$ENV{'REMOTE_HOST'}           = 'localhost';
$ENV{'REMOTE_IDENT'}          = 'None of your damn business';
$ENV{'REMOTE_USER'}           = 'Just another Perl hacker,';
$ENV{'REQUEST_METHOD'}        = 'GET';
$ENV{'SCRIPT_NAME'}           = '/cgi-bin/foo.cgi';
$ENV{'SERVER_NAME'}           = 'nowhere.com';
$ENV{'SERVER_PORT'}           = '8080';
$ENV{'SERVER_PROTOCOL'}       = 'HTTP/1.0';
$ENV{'SERVER_SOFTWARE'}       = 'Apache - accept no substitutes';

# set and test global defaults, initialise our objects
$CGI::Simple::USE_CGI_PM_DEFAULTS = 1;    # set CGI.pm compatibility

$q = new CGI;
$s = new CGI::Simple;

is($CGI::Simple::DISABLE_UPLOADS, $CGI::DISABLE_UPLOADS,
    'DISABLE_UPLOADS');
is($CGI::Simple::POST_MAX, $CGI::POST_MAX, 'POST_MAX');
is($CGI::Simple::NO_UNDEF_PARAMS,
    defined $CGI::NO_UNDEF_PARAMS ? $CGI::NO_UNDEF_PARAMS : 0,
    'NO_UNDEF_PARAMS');
is($CGI::Simple::USE_PARAM_SEMICOLONS,
    $CGI::USE_PARAM_SEMICOLONS, 'USE_PARAM_SEMICOLONS');
is($CGI::Simple::HEADERS_ONCE, $CGI::HEADERS_ONCE, 'HEADERS_ONCE');
is($CGI::Simple::NPH,          $CGI::NPH,          'NPH');
is($CGI::Simple::DEBUG, defined $CGI::DEBUG ? $CGI::DEBUG : 1, 'DEBUG');

# make sure we are using the same defaults so we don't fail for trivial
# reasons as the defaults have changed across the CGI.pm versions

$CGI::Simple::DISABLE_UPLOADS      = $CGI::DISABLE_UPLOADS;
$CGI::Simple::POST_MAX             = $CGI::POST_MAX;
$CGI::Simple::NO_UNDEF_PARAMS      = $CGI::NO_UNDEF_PARAMS;
$CGI::Simple::USE_PARAM_SEMICOLONS = $CGI::USE_PARAM_SEMICOLONS;
$CGI::Simple::HEADERS_ONCE         = $CGI::HEADERS_ONCE;
$CGI::Simple::NPH                  = $CGI::NPH;
$CGI::Simple::DEBUG                = $CGI::DEBUG;

################ The Guts ################

# new() - scalar context, void argument
warn "Testing: new() plain constructor\n" if $debug;
$q = new CGI();
$s = new CGI::Simple();
is($s =~ m/CGI::Simple=HASH/, $q =~ m/CGI=HASH/, 'type is HASH');
is($s->query_string, $q->query_string, 'query_string 1');

# new() - scalar context, object constructor
warn "Testing new() object constructor\n" if $debug;
my $q_new = new CGI($q);
my $s_new = new CGI::Simple($s);
is($s_new->query_string, $q_new->query_string, 'query_string 2');

# new() - scalar context, hash constructor
warn "Testing: new() hash constructor\n" if $debug;
$q = new CGI({'foo'         => '1', 'bar' => [2, 3, 4]});
$s = new CGI::Simple({'foo' => '1', 'bar' => [2, 3, 4]});
is($s->query_string, $q->query_string, 'query_string 3');

# new() - scalar context, query string constructor
warn "Testing: new() query string constructor\n" if $debug;
$q = new CGI('foo=5&bar=6&bar=7&bar=8');
$s = new CGI::Simple('foo=5&bar=6&bar=7&bar=8');
is($s->query_string, $q->query_string, 'query_string 4');

open FH, '>./test.tmp', or die "Can't create temp file\n";
$s->save(\*FH);
close FH;

# new() - scalar context, file constructor
warn "Testing new() file constructor\n" if $debug;
open FH, '<./test.tmp', or die "Can't open temp file\n";
$q = new CGI(\*FH);
seek FH, 0, 0;
$s = new CGI::Simple(\*FH);
is($s->query_string, $q->query_string, 'query_string 5');
close FH;
unlink './test.tmp';

# DESTROY() - scalar context, void argument
# Is this a good idea? It fails anyway.
# warn "Testing: DESTROY()\n" if $debug;
# $cgi  = $q->DESTROY();
# $simp = $s->DESTROY();
# is( $simp, $cgi , 'DESTROY');

# clean slate
$q = new CGI;
$s = new CGI::Simple;

# _reset_globals() - scalar and array context, void argument
warn "Testing: _reset_globals()\n" if $debug;
$cgi  = $q->_reset_globals();
$simp = $s->_reset_globals();
@cgi  = $q->_reset_globals();
@simp = $s->_reset_globals();
is($simp, $cgi, 'reset globals scalar');
is(join('', @simp), join('', @cgi), 'reset globals array');

################ The Core Methods ################

# param() - scalar and array context, void argument
warn "Testing: param() void argument\n" if $debug;
$cgi  = $q->param();
$simp = $s->param();
@cgi  = $q->param();
@simp = $s->param();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context, single argument (valid)
warn "Testing: param('color') single argument (valid)\n" if $debug;
$cgi  = $q->param('color');
$simp = $s->param('color');
@cgi  = $q->param('color');
@simp = $s->param('color');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context, single argument (invalid)
warn "Testing: param('invalid') single argument (invalid)\n" if $debug;
$cgi  = $q->param('invalid');
$simp = $s->param('invalid');
@cgi  = $q->param('invalid');
@simp = $s->param('invalid');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context, -name=>'param' (valid)
warn "Testing: param( -name=>'color' ) get values\n" if $debug;
$cgi  = $q->param(-name => 'color');
$simp = $s->param(-name => 'color');
@cgi  = $q->param(-name => 'color');
@simp = $s->param(-name => 'color');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context, -name=>'param' (invalid)
warn "Testing: param( -name=>'invalid' ) get values\n" if $debug;
$cgi  = $q->param(-name => 'invalid');
$simp = $s->param(-name => 'invalid');
@cgi  = $q->param(-name => 'invalid');
@simp = $s->param(-name => 'invalid');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context, set values
warn "Testing: param( 'foo', 'some', 'new', 'values' ) set values\n"
    if $debug;
$cgi  = $q->param('foo', 'some', 'new', 'values');
$simp = $s->param('foo', 'some', 'new', 'values');
@cgi  = $q->param('foo', 'some', 'new', 'values');
@simp = $s->param('foo', 'some', 'new', 'values');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context
warn "Testing: param( -name=>'foo', -value=>'bar' ) set values\n"
    if $debug;
$cgi  = $q->param(-name => 'foo', -value => 'bar');
$simp = $s->param(-name => 'foo', -value => 'bar');
@cgi  = $q->param(-name => 'foo', -value => 'bar');
@simp = $s->param(-name => 'foo', -value => 'bar');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param() - scalar and array context
warn "Testing: param(-name=>'foo',-value=>['bar','baz']) set values\n"
    if $debug;
$cgi  = $q->param(-name => 'foo', -value => ['bar', 'baz']);
$simp = $s->param(-name => 'foo', -value => ['bar', 'baz']);
@cgi  = $q->param(-name => 'foo', -value => ['bar', 'baz']);
@simp = $s->param(-name => 'foo', -value => ['bar', 'baz']);
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# param_fetch() - scalar context, single  argument (valid)
warn "Testing: param_fetch('foo')\n" if $debug;
$cgi  = $q->param_fetch('foo');
$simp = $s->param_fetch('foo');
is(ref $simp, ref $cgi, '');
is((join '', @$simp), (join '', @$cgi), '');

# param_fetch() - scalar context, single  argument (invalid)
warn "Testing: param_fetch('foo')\n" if $debug;
$cgi  = $q->param_fetch('no');
$simp = $s->param_fetch('no');
is(ref $simp, ref $cgi, '');
is((join '', @$simp), (join '', @$cgi), '');

# param_fetch() - scalar context, -name=>'foo' syntax
warn "Testing: param_fetch()\n" if $debug;
$cgi  = $q->param_fetch(-name => 'foo');
$simp = $s->param_fetch(-name => 'foo');
is(ref $simp, ref $cgi, '');
is((join '', @$simp), (join '', @$cgi), '');

# url_param() - scalar and array context, void argument
warn "Testing: url_param() void argument\n" if $debug;
$cgi  = $q->url_param();
$simp = $s->url_param();
@cgi  = $q->url_param();
@simp = $s->url_param();
is($simp, $cgi, '');
is(join('', sort @simp), join('', sort @cgi), '');

# url_param() - scalar and array context, single argument (valid)
warn "Testing: url_param('color') single argument (valid)\n" if $debug;
$cgi  = $q->url_param('color');
$simp = $s->url_param('color');
@cgi  = $q->url_param('color');
@simp = $s->url_param('color');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# url_param() - scalar and array context, single argument (invalid)
warn "Testing: url_param('invalid') single argument (invalid)\n"
    if $debug;
$cgi  = $q->url_param('invalid');
$simp = $s->url_param('invalid');
@cgi  = $q->url_param('invalid');
@simp = $s->url_param('invalid');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

### BUG IN CGI PM - FAILS TO PARSE KEYWORDS IN QUERY STRING
#$ENV{'QUERY_STRING'} = 'Just+another++Perl%20hacker%2C';
# clean slate
#$q = new CGI;
#$s = new CGI::Simple;
# keywords() - scalar and array context, void argument
#print "Testing: keywords()\n" if $debug;
#$cgi  = $q->keywords();
#$simp = $s->keywords();
#@cgi  = $q->keywords();
#@simp = $s->keywords();
#is( $simp, $cgi , '');
#is( (join'',@simp), (join'',@cgi) , '');

# parse_keywordlist() - scalar and array context
warn "Testing: parse_keywordlist()\n" if $debug;
$cgi  = $q->parse_keywordlist('Just+another++Perl%20hacker%2C');
$simp = $s->parse_keywordlist('Just+another++Perl%20hacker%2C');
@cgi  = $q->parse_keywordlist('Just+another++Perl%20hacker%2C');
@simp = $s->parse_keywordlist('Just+another++Perl%20hacker%2C');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# keywords() - scalar and array context, void argument
warn "Testing: keywords()\n" if $debug;
$cgi  = $q->keywords();
$simp = $s->keywords();
@cgi  = $q->keywords();
@simp = $s->keywords();
is($simp, $cgi, '');

# is( $simp =~ m//, $cgi =~ m// , '');
is((join '', @simp), (join '', @cgi), '');

# clean slate
$q = new CGI;
$s = new CGI::Simple;

# Vars() - scalar and hash context, void argument
warn "Testing: Vars()\n" if $debug;
eval { $cgi = $q->Vars() };
if ($@) {
    skip('Vars is missing from CGI.pm', 1);
    skip('Vars is missing from CGI.pm', 1);
} else {
    $simp = $s->Vars();
    %cgi  = $q->Vars();
    %simp = $s->Vars();
    is($simp->{'name'}, $cgi->{'name'}, '');
    is($simp{'color'}, $cgi{'color'}, '');
}

# append() - scalar and array context, void argument
warn "Testing: append()\n" if $debug;
$cgi  = $q->append();
$simp = $s->append();
@cgi  = $q->append();
@simp = $s->append();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# append() - scalar and array context, set values, valid param
warn "Testing: append( 'foo', 'some' ) set values\n" if $debug;
$cgi  = $q->append('foo', 'some');
$simp = $s->append('foo', 'some');
@cgi  = $q->append('foo', 'some');
@simp = $s->append('foo', 'some');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');
is((join '', $s->param('foo')), (join '', $q->param('foo')), '');

# append() - scalar and array context, set values, invalid param
warn "Testing: append( 'invaild', 'param' ) set values\n" if $debug;
$cgi  = $q->append('invaild', 'param');
$simp = $s->append('invaild', 'param');
@cgi  = $q->append('invaild', 'param');
@simp = $s->append('invaild', 'param');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');
is((join '', $s->param('foo')), (join '', $q->param('foo')), '');

# CGI.pm BROKEN ONLY ADDS 'some' AND LOSES OTHER VALUES
# append() - scalar and array context, set values
#print "Testing: append( 'foo', 'some', 'new', 'values' ) set values\n" if $debug;
#$cgi  = $q->append( 'foo', 'some', 'new', 'values' );
#$simp = $s->append( 'foo', 'some', 'new', 'values' );
#@cgi  = $q->append( 'foo', 'some', 'new', 'values' );
#@simp = $s->append( 'foo', 'some', 'new', 'values' );
#is( $simp, $cgi , '');
#is( (join'',@simp), (join'',@cgi) , '');
#is( (join'',$s->param('foo')), (join'',$q->param('foo')) , '');

# append() - scalar and array context
warn "Testing: append( -name=>'foo', -value=>'bar' ) set values\n"
    if $debug;
$cgi  = $q->append(-name => 'foo', -value => 'bar');
$simp = $s->append(-name => 'foo', -value => 'bar');
@cgi  = $q->append(-name => 'foo', -value => 'bar');
@simp = $s->append(-name => 'foo', -value => 'bar');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');
is((join '', $s->param('foo')), (join '', $q->param('foo')), '');

# append() - scalar and array context
warn "Testing: append(-name=>'foo',-value=>['bar','baz']) set values\n"
    if $debug;
$cgi  = $q->append(-name => 'foo', -value => ['bar', 'baz']);
$simp = $s->append(-name => 'foo', -value => ['bar', 'baz']);
@cgi  = $q->append(-name => 'foo', -value => ['bar', 'baz']);
@simp = $s->append(-name => 'foo', -value => ['bar', 'baz']);
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');
is((join '', $s->param('foo')), (join '', $q->param('foo')), '');

# delete()
warn "Testing: delete()\n" if $debug;

# $q->delete();  # generates warnings in CGI.pm
# $s->delete();
$q->delete('foo');
$s->delete('foo');
is($s->param, $q->param, '');

# delete_all()
warn "Testing: delete_all()\n" if $debug;
$q->delete_all();
$s->delete_all();
is(!$s->param, !$q->param, '');

# clean slate
$q = new CGI;
$s = new CGI::Simple;

# Delete()
warn "Testing: Delete()\n" if $debug;
$q->Delete('foo');
$s->Delete('foo');
is($s->param, $q->param, '');

# Delete_all()
warn "Testing: Delete_all()\n" if $debug;
$q->Delete_all();
$s->Delete_all();
is(!$s->param, !$q->param, '');

# clean slate
$q = new CGI;
$s = new CGI::Simple;

# query_string() - scalar context, void argument
warn "Testing: query_string()\n" if $debug;
$cgi  = $q->query_string();
$simp = $s->query_string();
is($simp, $cgi, '');

################ Save and Restore params from file ###############

# save()
warn "Testing: save()\n" if $debug;
open FH, ">./qconcur.tmp" or die "Can't write a test file: $!\n";
$q->save(\*FH);
close FH;
open FH, ">./sconcur.tmp" or die "Can't write a test file: $!\n";
$s->save(\*FH);
close FH;
open FH, "<./qconcur.tmp" or die "Can't read a test file: $!\n";
my $q_data = join '', <FH>;
close FH;
open FH, "<./sconcur.tmp" or die "Can't read a test file: $!\n";
my $s_data = join '', <FH>;
close FH;
unlink './sconcur.tmp', './qconcur.tmp';
is($s_data, $q_data, '');

# BROKEN IN CGI.pm, WILL NOT ACCEPT FILEHANDLE OBJECTS
# save_parameters() is supposed to be a simple alias for save()
#print "Testing: save()\n" if $debug;
#open FH, ">./qconcur.tmp" or die "Can't write a test file: $!\n";
#$q->save_parameters(\*FH);
#close FH;
#open FH, ">./sconcur.tmp" or die "Can't write a test file: $!\n";
#$s->save_parameters(\*FH);
#close FH;
#open FH, "<./qconcur.tmp" or die "Can't read a test file: $!\n";
#my $q_data = join'',<FH>;
#close FH;
#open FH, "<./sconcur.tmp" or die "Can't read a test file: $!\n";
#my $s_data = join'',<FH>;
#close FH;
#unlink './sconcur.tmp', './qconcur.tmp';
#is( $s_data, $q_data , '');

################ Miscelaneous Methods ################

my $string =
    'Just another `~!@#$%^&*()_-+={[}]|\\:;"<,>.?/ Perl hacker,';

# escapeHTML() - scalar and array context, void argument
warn "Testing: escapeHTML()\n" if $debug;
$cgi  = $q->escapeHTML();
$simp = $s->escapeHTML();
$cgi  = $q->escapeHTML($string);
$simp = $s->escapeHTML($string);
is($simp, $cgi, '');

$string = $q->escapeHTML($string);

# unescapeHTML() - scalar and array context, void argument
warn "Testing: unescapeHTML()\n" if $debug;
$cgi  = $q->unescapeHTML();
$simp = $s->unescapeHTML();
@cgi  = $q->unescapeHTML($string);
@simp = $s->unescapeHTML($string);
is($simp, $cgi, '');

# put()
warn "Testing: put()\n" if $debug;
is($s->put(''), $q->put(''), '');

# print()
warn "Testing: print()\n" if $debug;
is($s->print(''), $q->print(''), '');

################# Cookie Methods ################

# raw_cookie() - scalar and array context, void argument
warn "Testing: raw_cookie()\n" if $debug;
$cgi  = $q->raw_cookie();
$simp = $s->raw_cookie();
@cgi  = $q->raw_cookie();
@simp = $s->raw_cookie();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# raw_cookie() - scalar and array context, valid argument
warn "Testing: raw_cookie('foo')\n" if $debug;
$cgi  = $q->raw_cookie('foo');
$simp = $s->raw_cookie('foo');
@cgi  = $q->raw_cookie('foo');
@simp = $s->raw_cookie('foo');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# raw_cookie() - scalar and array context, invalid argument
warn "Testing: raw_cookie('invalid')\n" if $debug;
$cgi  = $q->raw_cookie('invalid');
$simp = $s->raw_cookie('invalid');
@cgi  = $q->raw_cookie('invalid');
@simp = $s->raw_cookie('invalid');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# cookie() - scalar and array context, void argument
warn "Testing: cookie()\n" if $debug;
$cgi  = $q->cookie();
$simp = $s->cookie();
@cgi  = $q->cookie();
@simp = $s->cookie();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# cookie() - scalar and array context, valid argument, single value
warn "Testing: cookie('foo')\n" if $debug;
$cgi  = $q->cookie('foo');
$simp = $s->cookie('foo');
@cgi  = $q->cookie('foo');
@simp = $s->cookie('foo');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# cookie() - scalar and array context, valid argument, multiple values
warn "Testing: cookie('foo')\n" if $debug;
$cgi  = $q->cookie('bar');
$simp = $s->cookie('bar');
@cgi  = $q->cookie('bar');
@simp = $s->cookie('bar');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# cookie() - scalar and array context, invalid argument
warn "Testing: cookie('invalid')\n" if $debug;
$cgi  = $q->cookie('invalid');
$simp = $s->cookie('invalid');
@cgi  = $q->cookie('invalid');
@simp = $s->cookie('invalid');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

@vals = (
    -name    => 'Password',
    -value   => ['superuser', 'god', 'open sesame', 'mydog woofie'],
    -expires => 'Mon, 11-Nov-2018 11:00:00 GMT',
    -domain  => '.nowhere.com',
    -path    => '/cgi-bin/database',
    -secure  => 1
);

# cookie() - scalar and array context, full argument set, correct order
warn "Testing: cookie(\@vals) correct order\n" if $debug;
$cgi  = $q->cookie(@vals);
$simp = $s->cookie(@vals);
@cgi  = $q->cookie(@vals);
@simp = $s->cookie(@vals);
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# cookie() - scalar and array context, full argument set, incorrect order
warn "Testing: cookie(\@vals) incorrect order\n" if $debug;
$cgi  = $q->cookie(@vals[0, 1, 10, 11, 8, 9, 2, 3, 4, 5, 6, 7]);
$simp = $s->cookie(@vals[0, 1, 10, 11, 8, 9, 2, 3, 4, 5, 6, 7]);
@cgi  = $q->cookie(@vals[0, 1, 10, 11, 8, 9, 2, 3, 4, 5, 6, 7]);
@simp = $s->cookie(@vals[0, 1, 10, 11, 8, 9, 2, 3, 4, 5, 6, 7]);
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# cookie() - scalar and array context, partial argument set
warn "Testing: cookie( -name=>'foo', -value=>'bar' )\n" if $debug;
$cgi  = $q->cookie(-name => 'foo', -value => 'bar');
$simp = $s->cookie(-name => 'foo', -value => 'bar');
@cgi  = $q->cookie(-name => 'foo', -value => 'bar');
@simp = $s->cookie(-name => 'foo', -value => 'bar');
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

################# Header Methods ################

# header() - scalar and array context, void argument
warn "Testing: header()\n" if $debug;
$cgi  = $q->header();
$simp = $s->header();
@cgi  = $q->header();
@simp = $s->header();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# header() - scalar context, single argument
warn "Testing: header('image/gif')\n" if $debug;
$cgi  = $q->header('image/gif');
$simp = $s->header('image/gif');
is($simp, $cgi, '');

my $cookie = $s->cookie(@vals);

@vals = (
    -type       => 'image/gif',
    -nph        => 1,
    -status     => '402 Payment required',
    -expires    => 'Mon, 11-Nov-2018 11:00:00 GMT',
    -cookie     => $cookie,
    -charset    => 'utf-7',
    -attachment => 'foo.gif',
    -Cost       => '$2.00'
);

# header() - scalar context, complex header
warn "Testing: header(\@vals) - complex header\n" if $debug;
$cgi  = $q->header(@vals);
$simp = $s->header(@vals);
$cgi =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # strip the time elements as this may be a single
$simp =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # second different causing a spurious failure
is($simp, $cgi, '')
    ; # note lc is a bugfix for CGI.pm v 2.75 that lc's extra attributes 'Cost => cost: ...'

# cache() - scalar and array context, void argument
warn "Testing: cache()\n" if $debug;
$cgi  = $q->cache();
$simp = $s->cache();
is($simp, $cgi, '');

# cache() - scalar and array context, true argument, sets no cache paragma
warn "Testing: cache(1)\n" if $debug;
$cgi  = $q->cache(1);
$simp = $s->cache(1);
is($simp == 1, $cgi == 1, '');
$cgi  = $q->header();
$simp = $s->header();
is($simp =~ /Pragma: no-cache/, $cgi =~ /Pragma: no-cache/, '');

# redirect() - scalar and array context, void argument
warn "Testing: redirect()\n" if $debug;
$cgi  = $q->redirect('http://a.galaxy.far.away.gov');
$simp = $s->redirect('http://a.galaxy.far.away.gov');
is(lc $simp, lc $cgi, '')
    ; # note lc is a bugfix for CGI.pm v 2.75 that lc's extra attributes  'Location' => 'location: http://...'
$cgi  = $q->redirect(-uri => 'http://a.galaxy.far.away.gov', -nph => 1);
$simp = $s->redirect(-uri => 'http://a.galaxy.far.away.gov', -nph => 1);
$cgi =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # strip the time elements as this may be a single
$simp =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # second different causing a spurious failure
is($simp, $cgi, '');

################# Server Push Methods #################

# multipart_init() - scalar context, void argument
warn "Testing: multipart_init()\n" if $debug;
$cgi  = $q->multipart_init();
$simp = $s->multipart_init();
$cgi =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # strip the time elements as this may be a single
$simp =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # second different causing a spurious failure
is($simp, $cgi, '');

# multipart_init() - scalar context, void argument
warn "Testing: multipart_init()\n" if $debug;
$cgi  = $q->multipart_init('foobar');
$simp = $s->multipart_init('foobar');
$cgi =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # strip the time elements as this may be a single
$simp =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # second different causing a spurious failure
is($simp, $cgi, '');

# multipart_init() - scalar context, void argument
warn "Testing: multipart_init()\n" if $debug;
$cgi  = $q->multipart_init(-boundary => 'foobar');
$simp = $s->multipart_init(-boundary => 'foobar');
$cgi =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # strip the time elements as this may be a single
$simp =~ s/\d\d:\d\d:\d\d GMT//g
    ;    # second different causing a spurious failure
is($simp, $cgi, '');

# multipart_start() - scalar and array context, void argument
warn "Testing: multipart_start()\n" if $debug;
$cgi  = $q->multipart_start();
$simp = $s->multipart_start();
is($simp, $cgi, '');

# multipart_end() - scalar and array context, void argument
warn "Testing: multipart_end()\n" if $debug;
$cgi  = $q->multipart_end();
$simp = $s->multipart_end();
is($simp, $cgi, '');

# multipart_final() - scalar and array context, void argument
warn "Testing: multipart_final()\n" if $debug;
eval { $cgi = $q->multipart_final() };
$simp = $s->multipart_final();
$@ ? skip('No multipart final in CGI.pm', 1) : is($simp, $cgi, '');

################# Debugging Methods ################

@ARGV = qw( name=JaPh%2C color=red color=green color=blue );

# _read_from_cmdline() - scalar and array context, void argument
warn "Testing: read_from_cmdline()\n" if $debug;
$cgi  = $q->read_from_cmdline();
$simp = $s->read_from_cmdline();
is($simp, $cgi, '');
@ARGV = ();

# CAN'T RATIONALLY TEST CGI USES A HAND ROLLED SOLUTION
# CGI::Simple USES Data::Dumper
# Dump() - scalar and array context, void argument
warn "# Skip - Testing: Dump()\n" if $debug;

#$cgi  = $q->Dump();
#$simp = $s->Dump();

# ALIAS FOR Dump();
# as_string() - scalar and array context, void argument
warn "# Skip - Testing: as_string()\n" if $debug;

#$cgi  = $q->as_string();
#$simp = $s->as_string();

#$ENV{'REQUEST_METHOD'}= 'POST';
#$CGI::POST_MAX = 20;
#$CGI::Simple::POST_MAX = 20;
#$q = new CGI;
#$s = new CGI::Simple;
# ANOTHER WEIRD BEHAVIOUR FROM CGI.pm UNCOMMENT THE HERE: TAG SO WE SKIP
# ALL THE OTHER TESTS AND IT WORKS AS EXPECTED. IF OTHER CGI OBJECTS HAVE
# BEEN INITIALISED IT IS BROKEN! ODD - CONENT LENGTH IS 42.
# cgi_error() - scalar and array context, void argument
warn "# Skip - Testing: cgi_error()\n" if $debug;

#$cgi  = $q->cgi_error();
#$simp = $s->cgi_error();
#is( $simp=~/413 Request entity too large/, $cgi=~/413 Request entity too large/ , '');

################# cgi-lib.pl Compatibility Methods #################

# ReadParse() - scalar and array context, void argument
warn "Testing: ReadParse()\n" if $debug;
CGI::ReadParse();
$cgi = $in{'color'};
undef %in;
CGI::Simple::ReadParse();
$simp = $in{'color'};
undef %in;
is($simp, $cgi, '');

$s->ReadParse()
    ;    # all the CGI::Simple methods can be called thusly as well
$simp = $in{'color'};
undef %in;
is($simp, $cgi, '');

# CGI.pm generates errors with a void argument here
# SplitParam() - scalar and array context, void argument
#print "Testing: SplitParam()\n" if $debug;
#$cgi  = CGI::SplitParam() };
#$simp = $s->SplitParam();
#@cgi  = CGI::SplitParam() };
#@simp = $s->SplitParam();
#is( $simp, $cgi , '');
#is( (join'|',@simp), (join'|',@cgi) , '');

# SplitParam() - scalar and array context, valid argument
warn 'Testing: SplitParam("red\0green\0blue")' . "\n" if $debug;
$cgi  = CGI::SplitParam("red\0green\0blue");
$simp = $s->SplitParam("red\0green\0blue");
@cgi  = CGI::SplitParam("red\0green\0blue");
@simp = $s->SplitParam("red\0green\0blue");
is($simp, $cgi, '');
is((join '|', @simp), (join '|', @cgi), '');

# MethGet() - scalar context, void argument
warn "Testing: MethGet()\n" if $debug;
$cgi  = $q->MethGet();
$simp = $s->MethGet();
is($simp, $cgi, '');

# MethPost() - scalar context, void argument
warn "Testing: MethPost()\n" if $debug;
$cgi  = $q->MethPost();
$simp = $s->MethPost();
is($simp, $cgi, '');

# PrintHeader() - scalar and array context, void argument
warn "Testing: PrintHeader()\n" if $debug;
$cgi  = $q->PrintHeader();
$simp = $s->PrintHeader();
is($simp, $cgi, '');

# WE GET DIFFERENT RESULTS HERE AS CGI.pm PRINTS AN EXTENDED TOP
# HtmlTop() - scalar context, 'title' argument
#print "Testing: HtmlTop()\n" if $debug;
#$cgi  = $q->HtmlTop('title');
#$simp = $s->HtmlTop('title');

# HtmlBot() - scalar context, void argument
warn "Testing: HtmlBot()\n" if $debug;
$cgi  = $q->HtmlBot();
$simp = $s->HtmlBot();
$simp =~ s/\n//g;
is(lc $simp, lc $cgi, '');

################ Accessor Methods ################

# version() - scalar and array context, void argument
warn "Testing: version()\n" if $debug;
$cgi  = $q->version();
$simp = $s->version();
is($simp =~ /[\d\.]+/, $cgi =~ /[\d\.]+/, '');

# nph() - scalar and array context, void argument
warn "Testing: nph()\n" if $debug;
$cgi  = $q->nph();
$simp = $s->nph();
is($simp, $cgi, '');

# all_parameters() - scalar and array context, void argument
warn "Testing: all_parameters()\n" if $debug;
$cgi  = $q->all_parameters();
$simp = $s->all_parameters();
@cgi  = $q->all_parameters();
@simp = $s->all_parameters();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# charset() - scalar context, void argument
warn "Testing: charset()\n" if $debug;
eval { $cgi = $q->charset() };
$simp = $s->charset();
$@ ? skip('No charset() method in CGI.pm', 1) : is($simp, $cgi, '');

# auth_type() - scalar context, void argument
warn "Testing: auth_type()\n" if $debug;
$cgi  = $q->auth_type();
$simp = $s->auth_type();
is($simp, $cgi, '');

# content_type() - scalar context, void argument
warn "Testing: content_type()\n" if $debug;
eval { $cgi = $q->content_type() };
$simp = $s->content_type();
$@
    ? skip('No content_type() method in CGI.pm', 1)
    : is($simp, $cgi, '');

# path_translated() - scalar context, void argument
warn "Testing: path_translated()\n" if $debug;
$cgi  = $q->path_translated();
$simp = $s->path_translated();
is($simp, $cgi, '');

# referer() - scalar and array context, void argument
warn "Testing: referer()\n" if $debug;
$cgi  = $q->referer();
$simp = $s->referer();
is($simp, $cgi, '');

# remote_addr() - scalar context, void argument
warn "Testing: remote_addr()\n" if $debug;
$cgi  = $q->remote_addr();
$simp = $s->remote_addr();
is($simp, $cgi, '');

# is( $simp =~ m//, $cgi =~ m// , '');
is((join '', @simp), (join '', @cgi), '');

# remote_host() - scalar context, void argument
warn "Testing: remote_host()\n" if $debug;
$cgi  = $q->remote_host();
$simp = $s->remote_host();
is($simp, $cgi, '');

# remote_ident() - scalar context, void argument
warn "Testing: remote_ident()\n" if $debug;
$cgi  = $q->remote_ident();
$simp = $s->remote_ident();
is($simp, $cgi, '');

# remote_user() - scalar context, void argument
warn "Testing: remote_user()\n" if $debug;
$cgi  = $q->remote_user();
$simp = $s->remote_user();
is($simp, $cgi, '');

# request_method() - scalar context, void argument
warn "Testing: request_method()\n" if $debug;
$cgi  = $q->request_method();
$simp = $s->request_method();
is($simp, $cgi, '');

# script_name() - scalar context, void argument
warn "Testing: script_name()\n" if $debug;
$cgi  = $q->script_name();
$simp = $s->script_name();
is($simp, $cgi, '');

# server_name() - scalar context, void argument
warn "Testing: server_name()\n" if $debug;
$cgi  = $q->server_name();
$simp = $s->server_name();
is($simp, $cgi, '');

# server_port() - scalar context, void argument
warn "Testing: server_port()\n" if $debug;
$cgi  = $q->server_port();
$simp = $s->server_port();
is($simp, $cgi, '');

# server_protocol() - scalar and array context, void argument
warn "Testing: server_protocol()\n" if $debug;
$cgi  = $q->server_protocol();
$simp = $s->server_protocol();
is($simp, $cgi, '');

# server_software() - scalar and array context, void argument
warn "Testing: server_software()\n" if $debug;
$cgi  = $q->server_software();
$simp = $s->server_software();
is($simp, $cgi, '');

# user_name() - scalar and array context, void argument
warn "Testing: user_name()\n" if $debug;
$cgi  = $q->user_name();
$simp = $s->user_name();
is($simp, $cgi, '');

# user_agent() - scalar and array context, void argument
warn "Testing: user_agent()\n" if $debug;
$cgi  = $q->user_agent();
$simp = $s->user_agent();
is($simp, $cgi, '');

# virtual_host() - scalar and array context, void argument
warn "Testing: virtual_host()\n" if $debug;
$cgi  = $q->virtual_host();
$simp = $s->virtual_host();
is($simp, $cgi, '');

# path_info() - scalar and array context, void argument
warn "Testing: path_info()\n" if $debug;
$cgi  = $q->path_info();
$simp = $s->path_info();
is($simp, $cgi, '');

# Accept() - scalar and array context, void argument
warn "Testing: Accept()\n" if $debug;
$cgi  = $q->Accept();
$simp = $s->Accept();
is($simp, $cgi, '');

# Accept() - scalar and array context, gif argument
warn "Testing: Accept()\n" if $debug;
$cgi  = $q->Accept('foo/bar');
$simp = $s->Accept('foo/bar');
is($simp == 0.001, $cgi == 0.001, '');

# http() - scalar and array context, void argument
warn "Testing: http()\n" if $debug;
do { local $^W = 0; $cgi = $q->http() }; # CGI.pm generates warnings here
$simp = $s->http();
do { local $^W = 0; @cgi = $q->http() }; # CGI.pm generates warnings here
@simp = $s->http();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# http() - scalar context, valid argument
warn "Testing: http('Accept')\n" if $debug;
$cgi  = $q->http('Accept');
$simp = $s->http('Accept');
is($simp, $cgi, '');

# http() - scalar context, invalid argument
warn "Testing: http('Rocks')\n" if $debug;
$cgi  = $q->http('Rocks');
$simp = $s->http('Rocks');
is($simp, $cgi, '');

# https() - scalar and array context, void argument
warn "Testing: https()\n" if $debug;
$cgi  = $q->https();
$simp = $s->https();
@cgi  = $q->https();
@simp = $s->https();
is($simp, $cgi, '');
is((join '', @simp), (join '', @cgi), '');

# https() - scalar context, valid argument
warn "Testing: https('Accept')\n" if $debug;
$cgi  = $q->https('Accept');
$simp = $s->https('Accept');
is($simp, $cgi, '');

# https() - scalar context, invalid argument
warn "Testing: https('Rocks')\n" if $debug;
$cgi  = $q->https('Rocks');
$simp = $s->https('Rocks');
is($simp, $cgi, '');

# protocol() - scalar and array context, void argument
warn "Testing: protocol()\n" if $debug;
$cgi  = $q->protocol();
$simp = $s->protocol();
is($simp, $cgi, '');

# url() - scalar and array context, void argument
warn "Testing: url()\n" if $debug;
$cgi  = $q->url();
$simp = $s->url();
is($simp, $cgi, '');

# self_url() - scalar and array context, void argument
warn "Testing: self_url()\n" if $debug;
$cgi  = $q->self_url();
$simp = $s->self_url();
is($simp, $cgi, '');

# state() - scalar and array context, void argument
warn "Testing: state()\n" if $debug;
$cgi  = $q->state();
$simp = $s->state();
is($simp, $cgi, '');

