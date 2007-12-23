#!/usr/bin/perl -T

# This line of code is temporary:
use Test::More skip_all => 'not implemented yet';

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

etc. etc. etc.

I can put all the syntax errors I like here, since the script exits early.
