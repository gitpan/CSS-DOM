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

use tests 1; # type
is $ss->type, 'text/css', 'type';

use tests 3; # disabled
ok!$ss->disabled              ,     'get disabled';
ok!$ss->disabled(1),          , 'set/get disabled';
ok $ss->disabled              ,     'get disabled again';
$ss->disabled(0);

use tests 2; # (set_)ownerNode
{
	my $foo = [];
	$ss->set_ownerNode($foo);
	is $ss->ownerNode, $foo, 'ownerNode';
	undef $foo;
	is $ss->ownerNode, undef, 'ownerNode is a weak refeerenc';
}

use tests 1; # parentStyleSheet
{
	is +()=$ss->parentStyleSheet, 0, 'parentStyleSheet';
}

use tests 1; # (set_)href
{
	$ss->set_href('eouvoenth');
	is $ss->href, 'eouvoenth', 'href';
}

use tests 1; # title
{
	sub foo'attr { return shift->{+shift} }
	$ss->set_ownerNode(my $foo = bless {title => 'tilde'}, 'foo');
	is $ss->title, 'tilde', 'title';
}

use tests 2; # media
{
	isa_ok $ss->media, 'CSS::DOM::MediaList';
	$ss->media->mediaText('screen, printer');
	is_deeply [$ss->media], [screen=>printer=>],
		'media in list context';
}
