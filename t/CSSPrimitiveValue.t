#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 1; # use
use_ok 'CSS::DOM::Value::Primitive', ':all';

use tests 26; # constants
{
	my $x;

	for (qw/ UNKNOWN NUMBER PERCENTAGE EMS EXS PX CM MM IN PT PC DEG
	         RAD GRAD MS S HZ KHZ DIMENSION STRING URI IDENT ATTR
	         COUNTER RECT RGBCOLOR /) {
		eval "is CSS_$_, " . $x++ . ", '$_'";
	}
}

use CSS::DOM;

#use tests 1; # unknown
# ~~~ How do we get an unknown primitive value? If we have a value that is
#     unrecognised, what determines whether it becomes a custom value or
#     an unknown primitive value? What should I test for?

use tests 22; # isa
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_NUMBER, 73),
	'CSS::DOM::Value::Primitive',  'number value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_PERCENTAGE, 73),
	'CSS::DOM::Value::Primitive',  '% value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_EMS, 73),
	'CSS::DOM::Value::Primitive',  'em value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_EXS, 73),
	'CSS::DOM::Value::Primitive',  'ex value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_PX, 73),
	'CSS::DOM::Value::Primitive',  'pixel value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_CM, 73),
	'CSS::DOM::Value::Primitive',  'cm value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_MM, 73),
	'CSS::DOM::Value::Primitive',  'millimetre value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_IN, 73),
	'CSS::DOM::Value::Primitive',  'inch value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_PT, 73),
	'CSS::DOM::Value::Primitive',  'pointy value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_PC, 73),
	'CSS::DOM::Value::Primitive',  'pica value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_DEG, 73),
	'CSS::DOM::Value::Primitive',  'degree value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_RAD, 73),
	'CSS::DOM::Value::Primitive',  'radian value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_GRAD, 73),
	'CSS::DOM::Value::Primitive',  'grad value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_S, 73),
	'CSS::DOM::Value::Primitive',  'sec. value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_MS, 73),
	'CSS::DOM::Value::Primitive',  'ms value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_HZ, 73),
	'CSS::DOM::Value::Primitive',  'hurts value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_KHZ, 73),
	'CSS::DOM::Value::Primitive',  'killer hurts value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_DIMENSION, 73, 'things'),
	'CSS::DOM::Value::Primitive',  'misc dim value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_STRING, 73),
	'CSS::DOM::Value::Primitive',  'string value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_URI, 73),
	'CSS::DOM::Value::Primitive',  'uri value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_IDENT, 73),
	'CSS::DOM::Value::Primitive',  'uri value';
isa_ok +CSS::DOM::Value::Primitive->new(&CSS_ATTR, 'href'),
	'CSS::DOM::Value::Primitive',  'attr value';
# ~~~ counter rect rgbcolor
	
# These need to be applied to all the types above:
# ~~~ primitiveType setFloatValue getFloatValue setStringValue
#     getStringValue getCounterValue getRectValue getRGBColorValue
