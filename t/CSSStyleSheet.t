#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use CSS::DOM::Exception;

use tests 1; # use
use_ok 'CSS::DOM';

use tests 2; # constructor and inheritance
isa_ok my $ss = new CSS::DOM, 'CSS::DOM';
isa_ok $ss, 'CSS';

use tests 2; # (_set_)ownerRule
{
	my $foo = [];
	$ss->_set_ownerRule($foo);
	is $ss->ownerRule, $foo, 'ownerRule';
	undef $foo;
	is $ss->ownerRule, undef, 'ownerRule is a weak refeerenc';
}

use tests 2; # cssRules
{
	$ss->read_string('a{text-decoration: none} p { margin: 0 }');
	is +()=$ss->cssRules, 2, 'cssRules in list context';
	isa_ok my $rules = cssRules $ss, 'CSS::DOM::RuleList',
		'cssRules in scalar context';
}

use tests 8; # insertRule
{
	$ss->purge;
	$ss->read_string('a{text-decoration: none} p { margin: 0 }');
	
	is $ss->insertRule('b { font-weight: bold }', 0), 0,
		'retval of insertRule';
	is_deeply [map $_->selectors, $ss->cssRules], [qw/ b a p /],
		'result of insertRule with 0 for the index';
	is $ss->cssRules->[0]->properties, 'font-weight: bold',
		'Are the contents of insertRule\'s new rule present?';
	isa_ok $ss->cssRules->[0], 'CSS::DOM::Rule';

	is $ss->insertRule('i {}', -1), 2,
		'retval of insertRule with negative index';
	is_deeply [map $_->selectors, $ss->cssRules], [qw/ b a i p /],
		'result of insertRule with negative index';

	local $SIG{__WARN__} = sub{};
	is $ss->insertRule('u {}', 27), 4,
		'retval of insertRule with large index';
	is_deeply [map $_->selectors, $ss->cssRules], [qw/ b a i p u /],
		'result of insertRule with large index';
}

use tests 4; # deleteRule
{
	$ss->purge;
	$ss->read_string('a{text-decoration: none} p { margin: 0 }
		i {}');
	is +()=$ss->deleteRule(1), 0, 'retval of deleteRule';
	is_deeply [map $_->selectors, $ss->cssRules], [qw/ a i /],
		'result of deleteRule';
	eval {
		$ss->deleteRule(79);
	};
	isa_ok $@, 'CSS::DOM::Exception', 'exception thrown by deleteRule';
	cmp_ok $@, '==', CSS::DOM::Exception::INDEX_SIZE_ERR,
		'error raised by deleteRule';

}