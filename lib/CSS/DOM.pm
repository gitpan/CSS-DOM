package CSS::DOM;

use 5.008002;

$VERSION = '0.05';

use   # to keep CPANTS happy :-)
   strict;
use   # same here
   warnings;

use CSS::DOM::Exception
	'SYNTAX_ERR' ,'HIERARCHY_REQUEST_ERR', 'INDEX_SIZE_ERR';
use Scalar::Util 'weaken';

require CSS::DOM::RuleList;

no constant 1.03 ();
use constant::lexical {
	ruls => 0,
	ownr => 1, # owner rule
	node => 2, # owner node
	dsbl => 3,
	hrfe => 4,
	medi => 5,
	fetc => 6, # url fetcher
	prsh => 7, # parent sheet
};

sub new {
	my $self = bless[],shift;
	my %args = @_;
	if(defined(my $arg = delete $args{url_fetcher})) {
		$self->[fetc] = $arg;
	}
	$self;
}
sub _fetcher {
	my $old = (my$ self = shift)->[fetc];
	$ self -> [ fetc ] = shift if @ _ ;
	$old
}

sub parse {
	require CSS::DOM::Parser;
	goto &CSS::DOM::Parser::parse;
}


# DOM STUFF:

# StyleSheet interface:

sub type { 'text/css' }
sub disabled {
	my $old = (my $self = shift) ->[dsbl];
	@_ and $self->[dsbl] = shift;
	$old
};
sub ownerNode { defined $_[0][node]?$_[0][node]:() }
sub set_ownerNode { weaken($_[0]->[node] = $_[1]) }
sub parentStyleSheet { shift->[prsh]||() }
sub _set_parentStyleSheet { weaken($_[0]->[prsh] = $_[1]) }
sub href { shift->[hrfe] }
sub set_href { $_[0]->[hrfe] = $_[1] }
sub title { no warnings 'uninitialized';
           ''.(shift->ownerNode || return)->attr('title') }

# If you find a bug in here, Media.pm’s method probably also needs fixing.
sub media {
	wantarray ? @{$_[0]->[medi]||return} :
		($_[0]->[medi] ||= (
			require CSS::DOM::MediaList,
			CSS::DOM::MediaList->new
		))
}


# CSSStyleSheet interface:

sub ownerRule {
	shift->[ownr] || ()
}
sub _set_ownerRule {
	weaken($_[0]->[ownr] = $_[1]);
}

# If you find a bug in the following three methods, Media.pm’s methods
# probably also need fixing.
sub cssRules { 
	wantarray
		? @{shift->[ruls]||return}
		: (shift->[ruls]||=new CSS::DOM::RuleList);
}

sub insertRule { # This is supposed to raise an HIERARCHY_REQUEST_ERR if
                 # the rule cannot be inserted at the specified  index;
                 # e.g.,  if an  @import  rule is inserted after a stan-
                 # dard rule. But we don’t do that, in order to maintain
                 # future compatibility.
	my ($self, $rule_string, $index) = @_;
	
	require CSS::DOM::Parser;
	my ($at,$rule);
	{
		local *@;
		$rule = CSS::DOM::Parser::parse_statement($rule_string);
		$at = $@
	}
	$at and die new CSS::DOM::Exception SYNTAX_ERR, $at;

	$rule->_set_parentStyleSheet($self);

	my $list = $self->cssRules; # cssRules takes care of ||=
	splice @$list, $index, 0, $rule;

	$index < 0        ? $#$list + $index :
	$index <= $#$list ? $index           :
	                    $#$list
}

sub deleteRule {
	my ($self,$index) = @_;
	my $list = $self->[ruls];
	$index > $#$list and die CSS::DOM::Exception->new(
		INDEX_SIZE_ERR,
		"The index passed to deleteRule ($index) is too large"
	);
	splice @$list, $index, 1;
	return # nothing;
}



my %features = (
	stylesheets => { '2.0' => 1 },
#	css => { '2.0' => 1 },
	css2 => { '2.0' => 1 },
);

sub hasFeature {
	my($feature,$v) = (lc $_[1], $_[2]);
	exists $features{$feature} and
		!defined $v || exists $features{$feature}{$v};
}

                              !()__END__()!

=head1 NAME

CSS::DOM - Document Object Model for Cascading Style Sheets

=head1 VERSION

Version 0.05

This is an alpha version. The API is still subject to change. Many features
have not been implemented yet (but patches would be welcome :-).

The interface for feeding CSS code to CSS::DOM changed incompatibly in
version 0.03.

=for comment
This is an alpha version. If you could please test it and report any bugs
(via e-mail), I would be grateful.

=head1 SYNOPSIS

  use CSS::DOM;

  my $sheet = CSS::DOM::parse( $css_source );

  use CSS::DOM::Style;
  my $style = CSS::DOM::Style::parse(
      'background: red; font-size: large'
  );

  my $other_sheet = new CSS::DOM; # empty
  $other_sheet->insertRule(
     'a{ text-decoration: none }',
      $other_sheet->cssRules->length,
  );
  # etc.
  
  # access DOM properties
  $other_sheet->cssRules->[0]->selectorText('p'); # change it
  $style->fontSize;          # returns 'large'
  $style->fontSize('small'); # change it

=head1 DESCRIPTION

This module provides the CSS-specific interfaces described in the W3C DOM
recommendation.

The CSS::DOM class itself implements the StyleSheet and CSSStyleSheet DOM
interfaces.

=head1 CONSTRUCTORS

=over 4

=item CSS::DOM::parse( $string )

This method parses the C<$string> and returns a style sheet object. If you
just have a CSS style declaration, e.g., from an HTML C<style> attribute,
see L<CSS::DOM::Style/parse>.

=item new CSS::DOM

Creates a new, empty style sheet object. Use this only if you plan to build
the style sheet piece by piece, instead of parsing a block of CSS code.

=back

You can pass named arguments to both of those. C<parse> accepts all of
them; C<new> understands only the first:

=over

=item url_fetcher

This has to be a code ref that returns the contents
of the style sheet at the URL passed as the sole argument. E.g.,

  # Disclaimer: This does not work with relative URLs.
  use LWP::Simple;
  use CSS::DOM;
  $css = '@import "file.css"; /* other stuff ... ';
  $ss = CSS::DOM::parse $css, url_fetcher => sub { get shift };
  $ss->cssRules->[0]->styleSheet; # returns a style sheet object
                                  # corresponding to file.css

The subroutine can choose to return C<undef> or an empty list, in which 
case the @import 
rule's C<styleSheet> method will return null (empty list or C<undef>), as
it would if no C<url_fetcher> were specified.

It can also return named items after the CSS code, like this:

  return $css_code, decode => 1, encoding_hint => 'iso-8859-1';

These correspond to the next two items:

=item decode

If this is specified and set to a true value, then CSS::DOM will treat the
CSS code as a string of bytes, and try to decode it based on @charset rules
and byte order marks.

By default it assumes that it is already in Unicode (i.e., decoded).

=item encoding_hint

Use this to provide a hint as to what the encoding might be.

If this is specified, and C<decode> is not, then C<< decode => 1 >> is
assumed.

=back

=head1 STYLE SHEET ENCODING

See the options above. This section explains how and when you I<should> use
those options.

According to the CSS spec, any encoding specified in the 'charset' field on
an HTTP Content-Type header, or the equivalent in other protocols, takes
precedence. In such a case, since CSS::DOM doesn't deal with HTTP, you have
to decode it yourself.

Otherwise, you should use C<< decode => 1 >> to instruct CSS::DOM to use
byte order marks or @charset rules.

If neither of those is present, then encoding data in the referencing
document (e.g., <link charset="..."> or an HTML document's own encoding),
if available/applicable, should be used. In this case, you should use the
C<< encoding_hint >> option, so that CSS::DOM has something to fall back
to.

If you use C<< decode => 1 >> with no encoding hint, and no BOM or @charset
is to be found, UTF-8 is assumed.

=head1 SYNTAX ERRORS

The two constructors above, and also
L<C<CSS::DOM::Style::parse|CSS::DOM::Style/parse>, set C<$@> to the empty 
string upon success. If 
they
encounter a syntax error, they set C<$@> to the error and return an object
that represents whatever was parsed up to that point.

Other methods that parse CSS code might die on encountering
syntax errors, and should usually be wrapped in an C<eval>.

The parser follows the 'future-compatible' syntax described in the CSS 2.1
specification, and also the spec's rules for handling parsing errors.
Anything not handled by those two is a syntax error.

In other words, a syntax error is one of the following:

=over 4

=item *

An unexpected closing bracket, as
in these examples

  a { text-decoration: none )
  *[name=~'foo'} {}
  #thing { clip: rect( ]

=item *

An HTML comment delimiter within a rule; e.g.,

  a { text-decoration : none <!-- /* Oops! */ }
  <!-- /*ok*/ @media --> /* bad! */ print { }

=item *

An extra C<@> keyword or semicolon where it doesn't belong; e.g.,

  @media @print { .... }
  @import "file.css" @print;
  td, @page { ... }
  #tabbar td; #tab1 { }

=back

=head1 OBJECT METHODS

=head2 Attributes

=over 4

=item type

Returns the string 'text/css'.

=item disabled

Allows one to specify whether the style sheet is used. (This attribute is
not actually used yet by CSS::DOM.) You can set it by passing an argument.

=item ownerNode

Returns the node that 'owns' this style sheet.

=item parentStyleSheet

If the style sheet belongs to an '@import' rule, this returns the style
sheet containing that rule. Otherwise it returns an empty list.

=item href

Returns the style sheet's URI, if applicable.

=item title

Returns the value of the owner node's title attribute.

=item media

Returns the MediaList associated with the style sheet (or a plain list in
list context). This defaults to an
empty list. You can pass a comma-delimited string to the MediaList's
C<mediaText> method to initialise it.

(The medium information is not actually used [yet] by CSS::DOM, but you
can put it there.)

=item ownerRule

If this style sheet was created by an @import rule, this returns the rule;
otherwise it returns an empty list (or undef in scalar context).

=item cssRules

In scalar context, this returns a L<CSS::DOM::RuleList> object (simply a
blessed
array reference) of L<CSS::DOM::Rule> objects. In list context it returns a
list.

=back

=head2 Methods

=over 4

=item insertRule ( $css_code, $index )

Parses the rule contained in the C<$css_code>, inserting it the style
sheet's list of rules at the given C<$index>.

=item deleteRule ( $index )

Deletes the rule at the given C<$index>.

=item hasFeature ( $feature, $version )

You can call this either as an object or class method.

This is actually supposed to be a method of the 'DOMImplementation' object.
(See, for instance, L<HTML::DOM::Interface>'s method of the same name,
which delegates to this one.) This returns a boolean indicating whether a
particular DOM module is implemented. Right now it returns true only for
the 'CSS2' and 'StyleSheets' features (version '2.0').

=back

=head2 Non-DOM Methods

=over 4

=item set_ownerNode

This allows you to set the value of C<ownerNode>. Passing an argument to
C<ownerNode> does nothing, because it is supposed to be read-only. But you
have to be able to set it somehow, so that's why this method is here.

The style sheet will hold a weak reference to the object passed to this
method.

=item set_href

Like C<set_ownerNode>, but for C<href>.

=back

=head1 CLASSES AND DOM INTERFACES

Here are the inheritance hierarchy of CSS::DOM's various classes and the
DOM interfaces those classes implement. For brevity's sake, a simple '::'
at the beginning of a class name in the left column is used for
'CSS::DOM::'. Items in brackets do not exist yet. (See also 
L<CSS::DOM::Interface> for a
machine-readable list of standard methods.)

  Class Inheritance Hierarchy  Interfaces
  ---------------------------  ----------
  
  CSS
      CSS::DOM                 StyleSheet, CSSStyleSheet
  ::Array
      ::MediaList              MediaList
      ::StyleSheetList         StyleSheetList
      ::RuleList               CSSRuleList
  ::Rule                       CSSRule, CSSUnknownRule
      ::Rule::Style            CSSStyleRule
      ::Rule::Media            CSSMediaRule
      ::Rule::FontFace         CSSFontFaceRule
      ::Rule::Page             CSSPageRule
      ::Rule::Import           CSSImportRule
     [::Rule::Charset          CSSCharsetRule]
  ::Style                      CSSStyleDeclaration, CSS2Properties
  ::Value                      CSSValue
      ::Value::Primitive       CSSPrimitiveValue
     [::Value::List            CSSValueList]
 [::RGBColor                   RGBColor]
 [::Rect                       Rect]
 [::Counter                    Counter]

CSS::DOM does not implement the following interfaces (see L<HTML::DOM> for
these):

  LinkStyle
  DocumentStyle
  ViewCSS
  DocumentCSS
  DOMImplementationCSS
  ElementCSSInlineStyle

=head1 IMPLEMENTATION NOTES

=over 4

=item *

Attributes of objects are accessed via methods of the same name. When the
method
is invoked, the current value is returned. If an argument is supplied, the
attribute is set (unless it is read-only) and its old value returned.

=item *

Where the DOM spec. says to use null, undef or an empty list is used.

=item *

Instead of UTF-16 strings, CSS::DOM uses Perl's Unicode strings.

=item *

Each method that the specification says returns an array-like object (e.g.,
a RuleList) will return such an object in scalar context, or a simple list
in list context. You can use
the object as an array ref in addition to calling its C<item> and 
C<length> methods.

=begin for-me

If I implement any methods that make use of the DOMTimeStamp interface, I
need to document that simple Perl scalars containing the time as returned
by Perl’s built-in ‘time’ function are used.

=end for-me

=back

=head1 PREREQUISITES

perl 5.8.2 or higher

L<Exporter> 5.57 or later

L<constant::lexical>

L<Encode> 2.10 or higher

=head1 BUGS

CSS 'shorthand' properties (such as 'font') are not supported yet. Right
now they are treated as their own properties, unrelated to those they are
short for.

'!important' is not supported yet.

To report bugs, please e-mail the author.

=head1 AUTHOR & COPYRIGHT

Copyright (C) 2007 Father Chrysostomos <sprout [at] cpan
[dot] org>

This program is free software; you may redistribute it and/or modify
it under the same terms as perl.

=head1 SEE ALSO

All the classes listed above under L</CLASSES AND DOM INTERFACES>.

L<CSS::SAC>, L<CSS.pm|CSS> and L<HTML::DOM>

The DOM Level 2 Style specification at
S<L<http://www.w3.org/TR/DOM-Level-2-Style>>
