#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;


use tests 1; # use
use_ok 'CSS::DOM::Rule::Style',;


require CSS::DOM;
(my $ss = new CSS::DOM)
 ->read_string('a{text-decoration: none} p { margin: 0 }');
my $rule = cssRules $ss ->[0];

use tests 1; # isa
isa_ok $rule, 'CSS::DOM::Rule::Style';

# ~~~ selectorText has yet to be implemented and tested

use tests 2; # style
isa_ok style $rule, 'CSS::DOM::StyleDecl', 'ret val of style';
is style $rule ->textDecoration, 'none',
	'the style decl does have the css stuff, so it’s the right one';
