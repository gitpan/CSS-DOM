#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 1;
use_ok "CSS::DOM::Interface";

use tests 2;
ok *CSS::DOM::Interface{HASH}, 'the hash is there';
ok exists $CSS::DOM::Interface{CSSStyleSheet}, 'CSSStyleSheet',;
	# I almost missed this.

use tests 9; # changes in 0.02
ok exists $CSS::DOM::Interface{CSSStyleSheet}{title},'CSSStyleSheet title';
ok exists $CSS::DOM::Interface{CSSStyleSheet}{media},'CSSStyleSheet media';
ok exists $CSS::DOM::Interface{CSSStyleSheet}{ownerRule},
	'CSSStyleSheet ownerRule';
ok exists $CSS::DOM::Interface{CSSStyleSheet}{insertRule},
	'CSSStyleSheet insertRule';
ok exists $CSS::DOM::Interface{CSSStyleSheet}{deleteRule},
	'CSSStyleSheet deleteRule';
ok exists $CSS::DOM::Interface{MediaList}{mediaText}, 'MediaList';
ok exists $CSS::DOM::Interface{StyleSheetList}{length}, 'StyleSheetList';
ok exists $CSS::DOM::Interface{CSSRule}{type}, 'CSSRule.cssText';
ok exists $CSS::DOM::Interface{CSSRule}{cssText}, 'CSSRule.cssText';
