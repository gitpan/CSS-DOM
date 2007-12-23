#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 1; # use
use_ok 'CSS::DOM';

use tests 2; # constructor and inheritance
isa_ok my $ss = new CSS::DOM, 'CSS::DOM';
isa_ok $ss, 'CSS';

use tests 2; # (set_)ownerNode
{
	my $foo = [];
	$ss->set_ownerNode($foo);
	is $ss->ownerNode, $foo, 'ownerNode';
	undef $foo;
	is $ss->ownerNode, undef, 'ownerNode is a weak refeerenc';
}

use tests 2; # cssRules
{
	$ss->read_string('a{text-decoration: none} p { margin: 0 }');
	is +()=$ss->cssRules, 2, 'cssRules in list context';
	isa_ok my $rules = cssRules $ss, 'CSS::DOM::RuleList',
		'cssRules in scalar context';
}

# ~~~ insertRule, deleteRule (to be implemented)
