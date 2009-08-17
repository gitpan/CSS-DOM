#!/usr/bin/perl -T

use strict; use warnings; no warnings qw 'qw regexp once utf8 parenthesis';
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
require CSS::DOM::PropertyParser;
my $s = new CSS'DOM'Style
 property_parser => my $spec = $CSS::DOM::PropertyParser::Default;

# The default parser has no properties with a simple string, attr or
# counter value. They all take a list. So we add a few just to make test-
# ing easier:
$spec->add_property(s => {
 format => '<string>',
});
$spec->add_property(a => {
 format => '<attr>',
});
$spec->add_property(c => {
 format => '<counter>',
});

# This runs 4 tests if the $property accepts $valstr.
# It runs 2 otherwise.
sub test_value {
	my($s,$property,$class,$args,$valstr,$type,$name) = @_;
	my $donefirst;
	$s->setProperty($property, $valstr) if $property;
	for my $val (
		"CSS::DOM::Value$class"->new( @$args ),
		$property ? $s->getPropertyCSSValue($property) : ()
	) {
		$name .= " (from getPCV)" x $donefirst++;
		is $val->cssText, $valstr, "$name ->cssText";
		is $val->cssValueType, $type,
			"$name ->cssValueType";
	}
}

use tests 8;
test_value $s,"top","", [&CSS_INHERIT], 'inherit', &CSS_INHERIT, 'inherit';
test_value $s,"background-position", "", [&CSS_CUSTOM,"top left"],
 'top left', &CSS_CUSTOM, 'custom value';

use tests 106;
for( #constant   constructor args      prop       css str      test name
 [ number     => ['73'             ], 'z-index', '73'       , 'number'   ],
 [ percentage => ['73'             ], 'top'    , '73%'      , '%'        ],
 [ ems        => ['73'             ], 'top'    , '73em'     , 'em'       ],
 [ exs        => ['73'             ], 'top'    , '73ex'     , 'ex'       ],
 [ px         => ['73'             ], 'top'    , '73px'     , 'px'       ],
 [ cm         => ['73'             ], 'top'    , '73cm'     , 'cm'       ],
 [ mm         => ['73'             ], 'top'    , '73mm'     , 'mm'       ],
 [ in         => ['73'             ], 'top'    , '73in'     , 'inch'     ],
 [ pt         => ['73'             ], 'top'    , '73pt'     , 'point'    ],
 [ pc         => ['73'             ], 'top'    , '73pc'     , 'pica'     ],
 [ deg        => ['73'             ], 'azimuth', '73deg'    , 'degree'   ],
 [ rad        => ['73'             ], 'azimuth', '73rad'    , 'radian'   ],
 [ grad       => ['73'             ], 'azimuth', '73grad'   , 'grad'     ],
 [ s          => ['73'             ], 'pause-after', '73s'  , 'second'   ],
 [ ms         => ['73'             ], 'pause-after', '73ms' , 'ms'       ],
 [ Hz         => ['73'             ], 'pitch'  , '73Hz'     , 'hertz'    ],
 [ kHz        => ['73'             ], 'pitch'  , '73kHz'    , 'kHertz'   ],
 [ dimension  => ['73', 'wob'      ], ''       , '73wob'    , 'misc dim' ],
 [ string     => ['73'             ], 's'      , "'73'"     , 'string'   ],
 [ uri        => ['73'             ], 'cue-after', "url(73)", 'URI'      ],
 [ ident      => ['red'            ], 'color'  , "red"      , 'ident'    ],
 [ attr       => ['red'            ], 'a'      , "attr(red)", 'attr'     ],
 [ counter    => ['red'            ], 'c'    , 'counter(red)', 'counter' ],
 [ counter    => ['red',undef,'lower-roman'], 'c',
  'counter(red, lower-roman)',        'counter with style'],
 [ counter    => ['red','. '], 'c',
  "counters(red, '. ')",              'counters'],
 [ counter    => ['red','. ','upper-latin'], 'c',
  "counters(red, '. ', upper-latin)", 'counters with style'],
 [ rect       => ['1px','2em','auto','4cm'], 'clip',
  "rect(1px, 2em, auto, 4cm)", 'rect'],
) {
	test_value $s, $$_[2], "::Primitive",
		[
			&{\&{"CSS::DOM::Value::Primitive::CSS_\U$$_[0]"}},
			@{$$_[1]}
		],
		$$_[3], &CSS_PRIMITIVE_VALUE, $$_[4]
}


# ~~~ not yet supported: rgbcolor

# ~~~ tests for writing cssText, and the errors that might be tossed
	

