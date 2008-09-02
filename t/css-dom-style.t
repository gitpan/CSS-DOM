#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 4;
require CSS::DOM::Style;
my $style = CSS::DOM::Style'parse('margin-top: 2px');
$style->modification_handler(sub { ++$}; ${{} .= shift});
$style->cssText('margin-bottom: 600%');
is $}, 1, 'cssText triggers mod hander';
is ${{}, $style, '$style is passed to the handler';
$style->setProperty('foo' => 'bar');
is $}, 2, 'setProperty triggers th ohnadler';
$style->fooBar('baz');
is $}, 3, 'AUTOLOAD triggers the handler';

# ~~~ removeProperty
# ~~~ modifications to CSSValue objects and their sub-objects (RGBColor etc
