#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 1; # use
use_ok 'CSS::DOM::Value', ':all';

use tests 4; # constants
{
	my $x;

	for (qw/ CSS_INHERIT CSS_PRIMITIVE_VALUE CSS_VALUE_LIST
	         CSS_CUSTOM /) {
		eval "is $_, " . $x++ . ", '$_'";
	}
}

#use tests 1; # constructor & isa
# ~~~ constructor doesn’t work yet
#isa_ok CSS::DOM::Value->new(&CSS_INHERIT), 'CSS::DOM::Value';

# ~~~ more tests

# So far, I only have cssText and cssValueType tests for primitive values.
# Each subclass implements them itself, so I have to test each case.

# ~~~ cssValueType has yet to be implemented
SKIP:{skip"notimplementedyet",22}

use tests 2; # numbers
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_NUMBER, 73
		),;
	is $val->cssText, '73', 'number value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'number value ->cssValueType';
}

use tests 2; # %
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_PERCENTAGE, 73
		),;
	is $val->cssText, '73%', '% value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'% value ->cssValueType';
}

use tests 2; # ems
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_EMS, 73
		),;
	is $val->cssText, '73em', 'em value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'em value ->cssValueType';
}

use tests 2; # exes
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_EXS, 73
		),;
	is $val->cssText, '73ex', 'ex value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'ex value ->cssValueType';
}

use tests 2; # pixels
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_PX, 73
		),;
	is $val->cssText, '73px', 'pixel value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'px value ->cssValueType';
}

use tests 2; # cm
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_CM, 73
		),;
	is $val->cssText, '73cm', 'cm value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'cm value ->cssValueType';
}

use tests 2; # mm
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_MM, 73
		),;
	is $val->cssText, '73mm', 'mm value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'mm value ->cssValueType';
}

use tests 2; # inches
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_IN, 73
		),;
	is $val->cssText, '73in', 'inch value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'inch value ->cssValueType';
}

use tests 2; # points
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_PT, 73
		),;
	is $val->cssText, '73pt', 'point value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'point value ->cssValueType';
}

use tests 2; # picas
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_PC, 73
		),;
	is $val->cssText, '73pc', 'pica value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'pica value ->cssValueType';
}

use tests 2; # degrees
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_DEG, 73
		),;
	is $val->cssText, '73deg', 'degree value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'degree value ->cssValueType';
}

use tests 2; # radians
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_RAD, 73
		),;
	is $val->cssText, '73rad', 'radian value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'radian value ->cssValueType';
}

use tests 2; # grad
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_GRAD, 73
		),;
	is $val->cssText, '73grad', 'grad value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'grad value ->cssValueType';
}

use tests 2; # seconds
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_S, 73
		),;
	is $val->cssText, '73s', 'second value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'second value ->cssValueType';
}

use tests 2; # milliseconds
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_MS, 73
		),;
	is $val->cssText, '73ms', 'millisecond value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'millisecond value ->cssValueType';
}

use tests 2; # hertz
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_HZ, 73
		),;
	is $val->cssText, '73Hz', 'hertz value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'hertz value ->cssValueType';
}

use tests 2; # kilohertz
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_KHZ, 73
		),;
	is $val->cssText, '73kHz', 'kilohertz value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'kilohertz value ->cssValueType';
}

use tests 2; # miscellaneous dimension
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_DIMENSION,
			73, 'woboodles'
		),;
	is $val->cssText, '73woboodles', 'misc dim  value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'misc dim  value ->cssValueType';
}

use tests 2; # string
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_STRING, 73
		),;
	is $val->cssText, "'73'", 'string  value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'string  value ->cssValueType';
}

use tests 2; # URI IMU
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_URI, 73
		),;
	is $val->cssText, "url(73)", 'URI  value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'URI  value ->cssValueType';
}

use tests 2; # ident
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_IDENT, 'red'
		),;
	is $val->cssText, "red", 'ident  value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'ident  value ->cssValueType';
}

use tests 2; # attr
{
	my $val = CSS::DOM::Value::Primitive->new(
			&CSS::DOM::Value::Primitive::CSS_ATTR, 'red'
		),;
	is $val->cssText, "attr(red)", 'attr  value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'attr  value ->cssValueType';
}

# ~~~ not yet supported: counter, rect, rgbcolor
#use tests 3; # counter
#{
#	my $val = CSS::DOM::Value::Primitive->new(
#			&CSS::DOM::Value::Primitive::CSS_URI, 'red'
#		),
#		'attr value';
#	is $val->cssText, "attr('red')", 'attr  value ->cssText';
#	is $val->cssValueType, &CSS_PRIMITIVE_VALUE,
#		'attr  value ->cssValueType';
#}

# ~~~ tests for writing cssText, and the errors that might be tossed
	

