package CSS::DOM;

use 5.006;

$VERSION = '0.01';

use   # to keep CPANTS happy :-)
   strict;
use   # same here
   warnings;

use Scalar::Util 'weaken';

require CSS;
require CSS::DOM::StyleDecl;
require CSS::DOM::RuleList;
require CSS::DOM::Rule::Style;

our @ISA = 'CSS';

# Overrides:

sub new {
	my $self = SUPER::new {shift};
	bless $self->{styles}, 'CSS::DOM::RuleList';
	$self;
}

sub parse_string {
	my $self = shift;
	$self->SUPER::parse_string(@_);
	for(@{$self->{styles}}) {
		# ~~~ How do I determine which type of rule it is ?
		# ~~~ Duzz the lite parser even support at-rules?
		$_->isa('CSS::DOM::Rule')
			|| bless $_, 'CSS::DOM::Rule::Style';
	}
	bless $self->{styles}, 'CSS::DOM::RuleList';
}

sub purge { for (shift) {
	$_->SUPER::purge;
	bless $_->{styles}, 'CSS::DOM::RuleList';
}}


# DOM stuff:

sub type { 'text/css' }
sub disabled {
	my $old = (my $self = shift) ->{_CSS_DOM_disabled};
	@_ and $self->{_CSS_DOM_disabled} = shift;
	$old
};
sub ownerNode { shift->{_CSS_DOM_owner} }
sub set_ownerNode { weaken($_[0]->{_CSS_DOM_owner} = $_[1]) }
sub parentStyleSheet { } # ~~~ Still to be implemented. Who sets this?
sub href { shift->{_CSS_DOM_href} }
sub set_href { $_[0]->{_CSS_DOM_href} = $_[1] }

# ~~~ title
# ~~~ media

# ~~~ ownerRule

sub cssRules { wantarray ? @{shift->{styles}} : shift->{styles}; }

# ~~~ insertRule

# ~~~ deleteRule



my %features = (
#	stylesheets => { '2.0' => 1 },
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

Version 0.01

This is an alpha version. The API is still subject to change. Many features
have not been implemented yet (but patches would be welcome :-).

=for comment
This is an alpha version. If you could please test it and report any bugs
(via e-mail), I would be grateful.

=head1 SYNOPSIS

  use CSS::DOM;
  
  $sheet = new CSS::DOM;
  
  # ...

=head1 DESCRIPTION

This module provides the CSS-specific interfaces described in the W3C DOM
recommendation.

The CSS::DOM class itself implements the StyleSheet and CSSStyleSheet DOM
interfaces, and inherits from L<CSS>.

=head1 METHODS

=head2 Constructor

  $style = new CSS::DOM;

Creates a new stylesheet object.

=head2 Attributes

=item type

Returns the string 'text/css'.

=item disabled

Allows one to specify whether the style sheet is used. (This attribute is
not actually used yet by CSS::DOM.)

=item ownerNode

Returns the node that 'owns' this style sheet.

=item parentStyleSheet

This currently just returns an empty list.

=item href

Returns the style sheet's URI, if applicable.

=item title

=item media

=item ownerRule

B<These three have not yet been implemented.>

=item cssRules

In scalar context, this returns a L<CSS::DOM::RuleList> object (simply a
blessed
array reference) of L<CSS::DOM::Rule> objects. In list context it returns a
list.

=item insertRule

=item deleteRule

B<Not yet implmented.>

=item hasFeature ( $feature, $version )

You can call this either as an object or class method.

This is actually supposed to be a method of the 'DOMImplementation' object.
(See, for instance, L<HTML::DOM::Interface>'s method of the same name,
which delegates to this one.) This returns a boolean indicating whether a
particular DOM module is implemented. Right now it returns true only for
the 'CSS2' feature (version '2.0').

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
     [::MediaList              MediaList]
     [::StyleSheetList         StyleSheetList]
      ::RuleList               CSSRuleList
  ::Rule                       CSSRule
      ::Rule::Style            CSSStyleRule
     [::Rule::Media            CSSMediaRule]
     [::Rule::FontFace         CSSFontFaceRule]
     [::Rule::Page             CSSPageRule]
     [::Rule::Import           CSSImportRule]
     [::Rule::Charset          CSSCharsetRule]
     [::Rule::Unknown          CSSUnknownRule]
  ::StyleDecl                  CSSStyleDeclaration, CSS2Properties
 [::Value                      CSSValue]
     [::Value::Primitive       CSSPrimitiveValue]
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


=head1 PREREQUISITES

perl 5.6.0 or later

L<CSS.pm|CSS> version 1 or later

L<Scalar::Util>

L<Exporter> 5.57 or later

L<constant> 1.03 or later

=head1 BUGS

To report bugs, please e-mail the author.

=head1 AUTHOR & COPYRIGHT

Copyright (C) 2007 Father Chrysostomos <sprout [at] cpan
[dot] org>

This program is free software; you may redistribute it and/or modify
it under the same terms as perl.

=head1 SEE ALSO

All the classes listed above under L</CLASSES AND DOM INTERFACES>.

L<CSS.pm|CSS> and L<HTML::DOM>

The DOM Level 2 Style specification at
S<L<http://www.w3.org/TR/DOM-Level-2-Style>>
