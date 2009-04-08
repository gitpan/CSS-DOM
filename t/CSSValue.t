#!/usr/bin/perl -T

use strict; use warnings;
our $tests;
BEGIN { ++$INC{'tests.pm'} }
sub tests'VERSION { $tests += pop };
use Test::More;
plan tests => $tests;

use tests 1; # use
use_ok 'CSS::DOM::Value', ':all';

require CSS::DOM::Value::Primitive;

use tests 4; # constants
{
	my $x;

	for (qw/ CSS_INHERIT CSS_PRIMITIVE_VALUE CSS_VALUE_LIST
	         CSS_CUSTOM /) {
		eval "is $_, " . $x++ . ", '$_'";
	}
}

use tests 2; # constructor & isa
isa_ok +CSS::DOM::Value->new(&CSS_INHERIT), 'CSS::DOM::Value';
isa_ok +CSS::DOM::Value->new(&CSS_CUSTOM, "top left"), 'CSS::DOM::Value';


# --- cssText and cssValueType --- #

# Each subclass implements them itself, so I have to test each case. And I
# also have to make sure that getPropertyCSSValue produces the right
# thing, too.


require CSS::DOM::Style;
my $s = new CSS'DOM'Style;

# this runs 4 tests
sub test_value {
	my($s,$class,$args,$valstr,$type,$name) = @_;
	my $donefirst;
	$s->setProperty('foo', $valstr);
	for my $val (
		"CSS::DOM::Value$class"->new( @$args ),
		$s->getPropertyCSSValue('foo')
	) {
		$name .= " (from getPCV)" x $donefirst++;
		is $val->cssText, $valstr, "$name ->cssText";
		is $val->cssValueType, $type,
			"$name ->cssValueType";
	}
}

use tests 8;
test_value $s, "", [&CSS_INHERIT], 'inherit', &CSS_INHERIT, 'inherit';
test_value $s, "", [&CSS_CUSTOM,"top left"], 'top left', &CSS_CUSTOM,
	'custom value';

use tests 108;
for( #    constant    constructor args     css str          test name
	[ number     => ['73'             ], '73'         , 'number'   ],
	[ percentage => ['73'             ], '73%'        , '%'        ],
        [ ems        => ['73'             ], '73em'       , 'em'       ],
        [ exs        => ['73'             ], '73ex'       , 'ex'       ],
        [ px         => ['73'             ], '73px'       , 'px'       ],
        [ cm         => ['73'             ], '73cm'       , 'cm'       ],
        [ mm         => ['73'             ], '73mm'       , 'mm'       ],
        [ in         => ['73'             ], '73in'       , 'inch'     ],
        [ pt         => ['73'             ], '73pt'       , 'point'    ],
        [ pc         => ['73'             ], '73pc'       , 'pica'     ],
        [ deg        => ['73'             ], '73deg'      , 'degree'   ],
        [ rad        => ['73'             ], '73rad'      , 'radian'   ],
        [ grad       => ['73'             ], '73grad'     , 'grad'     ],
        [ s          => ['73'             ], '73s'        , 'second'   ],
        [ ms         => ['73'             ], '73ms'       , 'ms'       ],
        [ Hz         => ['73'             ], '73Hz'       , 'hertz'    ],
        [ kHz        => ['73'             ], '73kHz'      , 'kHertz'   ],
        [ dimension  => ['73', 'woboodles'], '73woboodles', 'misc dim' ],
	[ string     => ['73'             ], "'73'"       , 'string'   ],
	[ uri        => ['73'             ], "url(73)"    , 'URI'      ],
	[ ident      => ['red'            ], "red"        , 'ident'    ],
	[ attr       => ['red'            ], "attr(red)"  , 'attr'     ],
	[ counter    => ['red'            ], 'counter(red)', 'counter' ],
	[ counter    => ['red',undef,'lower-roman'],
		'counter(red, lower-roman)',        'counter with style'],
	[ counter    => ['red','. '],
		"counters(red, '. ')",              'counters'],
	[ counter    => ['red','. ','upper-latin'],
		"counters(red, '. ', upper-latin)", 'counters with style'],
	[ rect       => ['1px','2em','auto','4cm'],
		"rect(1px, 2em, auto, 4cm)", 'rect'],
) {
	test_value $s, "::Primitive",
		[
			&{\&{"CSS::DOM::Value::Primitive::CSS_\U$$_[0]"}},
			@{$$_[1]}
		],
		$$_[2], &CSS_PRIMITIVE_VALUE, $$_[3]
}


# ~~~ not yet supported: rgbcolor

# ~~~ tests for writing cssText, and the errors that might be tossed
	

