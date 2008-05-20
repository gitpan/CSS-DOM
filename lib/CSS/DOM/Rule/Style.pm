package CSS::DOM::Rule::Style;

$VERSION = '0.02';

use warnings;
use strict;

 use        CSS::DOM::Rule;

our @ISA = 'CSS::DOM::Rule';

# override:
sub type { CSS::DOM::Rule::STYLE_RULE }


# CSSStyleRule interface:

# ~~~ selectorText

sub style {
	$_[0]->{_CSS_DOM_decl} ||= do {
		require CSS::DOM::StyleDecl;
		new CSS::DOM::StyleDecl shift
	};
}

                              !()__END__()!

=head1 NAME

CSS::DOM::Rule::Style - CSS style rule class for CSS::DOM

=head1 VERSION

Version 0.02

=head1 SYNOPSIS

  use CSS::DOM;
  
  # ...

=head1 DESCRIPTION

This module implements CSS style rules for L<CSS::DOM>. It inherits 
from
L<CSS::DOM::Rule> and implements
the CSSStyleRule DOM interface.

=head1 METHODS

=over 4

=item selectorText

(not yet implemented)

=item style

Returns the CSS::DOM::StyleDecl object representing the declaration block
of this rule.

=back

=head1 SEE ALSO

L<DOM::CSS>
