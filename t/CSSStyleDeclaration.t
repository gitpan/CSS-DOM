#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;


use tests 1; # use
use_ok 'CSS::DOM::Style',;

use tests 3; # first make sure we can use it without loading CSS::DOM
{
	my $owner = {properties => []};
	my $decl = new CSS::DOM::Style $owner;
	is $decl->parentRule, $owner, 'constructor sets the parentRule';
	undef $owner;
	is $decl->parentRule, undef, 'holds a weak ref to its parent';
	
	$decl->cssText('margin-top: 76in'); # Wow, what a big margin!
	is $decl->marginTop, '76in', 'seems to be working orphanedly';
}
	

require CSS::DOM;
my $ss = CSS::DOM'parse ('a{text-decoration: none} p { margin: 0 }');
my $rule = cssRules $ss ->[0];
my $decl = $rule->style;

use tests 1; # isa
isa_ok $decl, 'CSS::DOM::Style';

use tests 3; # cssText
is $decl->cssText, 'text-decoration: none', 'get cssText';
is $decl->cssText('text-decoration: underline'), 'text-decoration: none',
	'get/set cssText';
is $decl->cssText, 'text-decoration: underline', 'get cssText again';

use tests 1; # getPropertyValue
is $decl->getPropertyValue('text-decoration'), 'underline',
	'getPropertyValue';

# ~~~ getPropertyCSSValue, removeProperty, getPropertyPriority

use tests 5; # setProperty
is +()=$decl->setProperty('color', 'red'), 0, 'setProperty ret val';
is $decl->getPropertyValue('color'), 'red', 'effect of setProperty';
ok!eval{$decl->setProperty('color', '}');1}, 'setProperty chokes on }';
cmp_ok $@,'==',&CSS::DOM::Exception::SYNTAX_ERR,
	'setProperty throws the right error';
$decl->setProperty('cOlOr', 'blue');
is $decl->color, 'blue', 'setProperty lcs the property names';

# ~~~ length, item

use tests 1; # parentRule
use Scalar::Util 'refaddr';
is refaddr $rule, refaddr $decl->parentRule, 'parentRule';
