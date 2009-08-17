#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 2;
require CSS::DOM;
my $u = \'u';
my $p = \'p';
my $sheet = new CSS::DOM url_fetcher => $u, property_parser => $p;
is $sheet->url_fetcher, $u, 'url_fetcher';
is $sheet->property_parser, $p, 'property_parser';
