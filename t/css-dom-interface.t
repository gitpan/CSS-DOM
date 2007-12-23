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
ok exists $CSS::DOM::Interface{CSSStyleSheet}, 'CSSStyleSheet',
	# I almost missed this.