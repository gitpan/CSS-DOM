#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;


use tests 1; # use
use_ok 'CSS::DOM::Rule', ':all';

use tests 7; # constants
{
	my $x;

	for (qw/ UNKNOWN_RULE STYLE_RULE CHARSET_RULE IMPORT_RULE
	         MEDIA_RULE FONT_FACE_RULE PAGE_RULE /) {
		eval "is $_, " . $x++ . ", '$_'";
	}
}


require CSS::DOM;
(my $ss = new CSS::DOM)
 ->read_string('a{text-decoration: none} p { margin: 0 }');
my $rule = cssRules $ss ->[0];

use tests 1; # isa
isa_ok $rule, 'CSS::DOM::Rule';

# ~~~ type, cssText, parentStyleSheet and parentRule have not yet been implemented
