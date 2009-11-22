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

# This sub runs two tests
sub test_isa {
 isa_ok $_[0], 'CSS::DOM::Value::Primitive', $_[1];
 ok $_[0]->DOES('CSS::DOM::Value'), "$_[1] DOES CSS::DOM::Value";
}

use tests 4; # numbers
for(CSS::DOM::Value::Primitive->new(type => &CSS_NUMBER, value => 73)) {
 test_isa $_, 'number value';
 is $_->primitiveType, &CSS_NUMBER, 'number->primitiveType';
 is $_->getFloatValue, 73, 'number->getFloatValue';
}

use tests 4; # %
for(
 CSS::DOM::Value::Primitive->new(type => &CSS_PERCENTAGE, value => 73)
) {
 test_isa $_, '% value';
 is $_->primitiveType, &CSS_PERCENTAGE, '%->primitiveType';
 is $_->getFloatValue, 73, '%->getFloatValue';
}

use tests 4; # M
for(CSS::DOM::Value::Primitive->new(type => &CSS_EMS, value => 73)) {
 test_isa $_, 'em value';
 is $_->primitiveType, &CSS_EMS, 'em->primitiveType';
 is $_->getFloatValue, 73, 'em->getFloatValue';
}

use tests 4; # X
for(CSS::DOM::Value::Primitive->new(type => &CSS_EXS, value => 73)) {
 test_isa $_, 'ex value';
 is $_->primitiveType, &CSS_EXS, 'ex->primitiveType';
 is $_->getFloatValue, 73, 'ex>getFloatValue';
}

use tests 4; # pixies
for(CSS::DOM::Value::Primitive->new(type => &CSS_PX, value => 73)) {
 test_isa $_, 'pixel value';
 is $_->primitiveType, &CSS_PX, 'pixel->primitiveType';
 is $_->getFloatValue, 73, 'px->getFloatValue';
}

use tests 4; # cm
for(CSS::DOM::Value::Primitive->new(type => &CSS_CM, value => 73)) {
 test_isa $_, 'cm value';
 is $_->primitiveType, &CSS_CM, 'cm->primitiveType';
 is $_->getFloatValue, 73, 'cm->getFloatValue';
}

use tests 4; # mm
for(CSS::DOM::Value::Primitive->new(type => &CSS_MM, value => 73)) {
 test_isa $_, 'millimetre value';
 is $_->primitiveType, &CSS_MM, 'mm->primitiveType';
 is $_->getFloatValue, 73, 'mm->getFloatValue';
}

use tests 4; # inch
for(CSS::DOM::Value::Primitive->new(type => &CSS_IN, value => 73)) {
 test_isa $_, 'inch value';
 is $_->primitiveType, &CSS_IN, 'inch->primitiveType';
 is $_->getFloatValue, 73, 'inch->getFloatValue';
}

use tests 4; # points
for(CSS::DOM::Value::Primitive->new(type => &CSS_PT, value => 73)) {
 test_isa $_, 'pointy value';
 is $_->primitiveType, &CSS_PT, 'pointy->primitiveType';
 is $_->getFloatValue, 73, 'pointy->getFloatValue';
}

use tests 4; # pica
for(CSS::DOM::Value::Primitive->new(type => &CSS_PC, value => 73)) {
 test_isa $_, 'pica value';
 is $_->primitiveType, &CSS_PC, 'pica->primitiveType';
 is $_->getFloatValue, 73, 'pica->getFloatValue';
}

use tests 4; # degrease
for(CSS::DOM::Value::Primitive->new(type => &CSS_DEG, value => 73)) {
 test_isa $_, 'degree value';
 is $_->primitiveType, &CSS_DEG, 'degree->primitiveType';
 is $_->getFloatValue, 73, 'degree->getFloatValue';
}

use tests 4; # radians
for(CSS::DOM::Value::Primitive->new(type => &CSS_RAD, value => 73)) {
 test_isa $_, 'radian value';
 is $_->primitiveType, &CSS_RAD, 'radian->primitiveType';
 is $_->getFloatValue, 73, 'radian->getFloatValue';
}

use tests 4; # grad
for(CSS::DOM::Value::Primitive->new(type => &CSS_GRAD, value => 73)) {
 test_isa $_, 'grad value';
 is $_->primitiveType, &CSS_GRAD, 'grad->primitiveType';
 is $_->getFloatValue, 73, 'grad->getFloatValue';
}

use tests 4; # seconds
for(CSS::DOM::Value::Primitive->new(type => &CSS_S, value => 73)) {
 test_isa $_, 'sec. value';
 is $_->primitiveType, &CSS_S, 'sec.->primitiveType';
 is $_->getFloatValue, 73, 'sec.->getFloatValue';
}

use tests 4; # ms
for(CSS::DOM::Value::Primitive->new(type => &CSS_MS, value => 73)) {
 test_isa $_, 'ms value';
 is $_->primitiveType, &CSS_MS, 'ms->primitiveType';
 is $_->getFloatValue, 73, 'ms->getFloatValue';
}

use tests 4; # hurts
for(CSS::DOM::Value::Primitive->new(type => &CSS_HZ, value => 73)) {
 test_isa $_, 'hurts value';
 is $_->primitiveType, &CSS_HZ, 'hurts->primitiveType';
 is $_->getFloatValue, 73, 'hurts->getFloatValue';
}

use tests 4; # killer hurts
for(CSS::DOM::Value::Primitive->new(type => &CSS_KHZ, value => 73)) {
 test_isa $_, 'killer hurts value';
 is $_->primitiveType, &CSS_KHZ, 'killer hurts->primitiveType';
 is $_->getFloatValue, 73, 'killer hurts->getFloatValue';
}

use tests 4; # misc dim
for(
 CSS::DOM::Value::Primitive->new(
  type => &CSS_DIMENSION, value => [73, 'things']
 )
) {
 test_isa $_, 'misc dim value';
 is $_->primitiveType, &CSS_DIMENSION, 'misc dim->primitiveType';
 is $_->getFloatValue, 73, 'misc dim->getFloatValue';
}

use tests 6; # string
for(CSS::DOM::Value::Primitive->new(type => &CSS_STRING, value => 73)) {
 test_isa $_, 'string value';
 is $_->primitiveType, &CSS_STRING, 'string->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'string->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after string->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after string->getFloatValue dies';
}

use tests 6; # url
for(CSS::DOM::Value::Primitive->new(type => &CSS_URI, value => 73)) {
 test_isa $_, 'uri value';
 is $_->primitiveType, &CSS_URI, 'uri->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'uri->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after uri->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after uri->getFloatValue dies';
}

use tests 6; # identifier
for(CSS::DOM::Value::Primitive->new(type => &CSS_IDENT, value => 73)) {
 test_isa $_, 'identifier value';
 is $_->primitiveType, &CSS_IDENT, 'identifier->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'identifier->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after identifier->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after identifier->getFloatValue dies';
}

use tests 6; # attr
for(CSS::DOM::Value::Primitive->new(type => &CSS_ATTR, value => 73)) {
 test_isa $_, 'attr value';
 is $_->primitiveType, &CSS_ATTR, 'attr->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'attr->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after attr->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after attr->getFloatValue dies';
}

use tests 6; # counter
for(CSS::DOM::Value::Primitive->new(type => &CSS_COUNTER, value => [73])) {
 test_isa $_, 'counter value';
 is $_->primitiveType, &CSS_COUNTER, 'counter->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'counter->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after counter->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after counter->getFloatValue dies';
}

use tests 6; # counters
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_COUNTER, value => [73,'breen']
)) {
 test_isa $_, 'counters value';
 is $_->primitiveType, &CSS_COUNTER, 'counters->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'counters->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after counters->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after counters->getFloatValue dies';
}

use tests 6; # counters
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_COUNTER, value => [73,'breen']
)) {
 test_isa $_, 'counters value';
 is $_->primitiveType, &CSS_COUNTER, 'counters->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'counters->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after counters->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after counters->getFloatValue dies';
}

use tests 6; # rectangle
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_RECT, value => [
     [type => &CSS_PX, value => 20],
     [type => &CSS_PERCENTAGE, value => 50],
     [type => &CSS_PERCENTAGE, value => 50],
     [type => &CSS_PX, value => 50],
 ]
)) {
 test_isa $_, 'rectangle value';
 is $_->primitiveType, &CSS_RECT, 'rectangle->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'rectangle->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after rectangle->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after rectangle->getFloatValue dies';
}

use tests 6; #bed colour
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_RGBCOLOR, value => '#bed',
)) {
 test_isa $_, '#bed colour value';
 is $_->primitiveType, &CSS_RGBCOLOR, '#bed colour->primitiveType';
 ok !eval{ $_->getFloatValue;1}, '#bed colour->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after #bed colour->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after #bed colour->getFloatValue dies';
}

use tests 6; #c0ffee colour
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_RGBCOLOR, value => '#c0ffee',
)) {
 test_isa $_, '#c0ffee colour value';
 is $_->primitiveType, &CSS_RGBCOLOR, '#c0ffee colour->primitiveType';
 ok !eval{ $_->getFloatValue;1}, '#c0ffee colour->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after #c0ffee colour->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after #c0ffee colour->getFloatValue dies';
}

use tests 6; # rgb colour
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_RGBCOLOR, value => [ ([type => &CSS_NUMBER, value => 0])x3 ]
)) {
 test_isa $_, 'rgb value';
 is $_->primitiveType, &CSS_RGBCOLOR, 'rgb->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'rgb->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after rgb->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after rgb->getFloatValue dies';
}

use tests 6; # rgba colour
for(CSS::DOM::Value::Primitive->new(
 type => &CSS_RGBCOLOR, value => [ ([type => &CSS_NUMBER, value => 0])x4 ]
)) {
 test_isa $_, 'rgba value';
 is $_->primitiveType, &CSS_RGBCOLOR, 'rgba->primitiveType';
 ok !eval{ $_->getFloatValue;1}, 'rgba->getFloatValue dies';
 isa_ok $@, 'CSS::DOM::Exception',
  'class of error after rgba->getFloatValue dies';
 cmp_ok $@, '==', &CSS::DOM::Exception::INVALID_ACCESS_ERR,
  'error code after rgba->getFloatValue dies';
}
	
# These need to be applied to all the types above:
# ~~~ setFloatValue getFloatValue setStringValue
#     getStringValue getCounterValue getRectValue getRGBColorValue
