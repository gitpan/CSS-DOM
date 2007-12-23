package CSS::DOM::Rule;

$VERSION = '0.01';

use warnings;
use strict;

use Exporter 'import';

require CSS::Style;

our @ISA = 'CSS::Style';

use constant do {
	my $x = 0;
	+{ map +($_ => $x++), our @EXPORT_OK = qw/
		UNKNOWN_RULE  
		STYLE_RULE    
		CHARSET_RULE  
		IMPORT_RULE   
		MEDIA_RULE    
		FONT_FACE_RULE
		PAGE_RULE
	  /}
};
our %EXPORT_TAGS = ( all => \our @EXPORT_OK );

use overload fallback => 1;
# something CSS::Style omits
# it seems that 5.8.6 can't autogenerate eq from ""

# ~~~ type
# ~~~ cssText
# ~~~ parentStyleSheet
# ~~~ parentRule
  
                              !()__END__()!

=head1 NAME

CSS::DOM::Rule - CSS rule class for CSS::DOM

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  use CSS::DOM;
  
  # ...

=head1 DESCRIPTION

This module provides the CSS rule class for L<CSS::DOM>. It inherits from
L<CSS::Style> and implements
the CSSRule DOM interface.

=head1 METHODS

(None of these have been implemented yet.)

=over 4

=item type

=item cssText

=item parentStyleSheet

=item parentRule

=back

=head1 SEE ALSO

L<DOM::CSS>
