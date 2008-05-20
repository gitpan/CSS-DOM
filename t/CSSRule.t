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

# ~~~ I need to add other types here, once CSS::DOM supports them.
use tests 1; # type
$ss->insertRule('a{}', 0);
is $ss->cssRules->[0]->type, &STYLE_RULE;

use tests 3; # cssText
{
	$ss->insertRule('b{font-family: Monaco}', 0);
	my $rule = $ss->cssRules->[0];

	is $rule->cssText, "b { font-family: Monaco }\n", 'get cssText';
	is $rule->cssText("a{color: blue}"), "b { font-family: Monaco }\n",
		'get/set cssText';
	is $rule->cssText, "a { color: blue }\n", 'get cssText again';

	# ~~~ write tests for the errors once CSS::DOM is capable of
	#     producing them
}

# ~~~ parentStyleSheet and parentRule have not yet been implemented
