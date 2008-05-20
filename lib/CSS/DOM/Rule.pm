package CSS::DOM::Rule;

$VERSION = '0.02';

use warnings;
use strict;

use CSS::DOM::Exception qw/ SYNTAX_ERR INVALID_MODIFICATION_ERR /;
use Exporter 5.57 'import';

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

sub type { UNKNOWN_RULE }
sub cssText {
	my $self = shift;
	my $old = $self->to_string if defined wantarray;
	if (@_) {
		my $css_obj = new CSS::DOM;
		eval {
			$css_obj ->read_string(shift);
			1
		} or die CSS::DOM::Exception->new(SYNTAX_ERR, $@);
	
		my $new_rule  =  $css_obj->{styles}[0];
		ref $new_rule eq ref $self or die CSS::DOM::Exception->new(
			INVALID_MODIFICATION_ERR,
			"The rule cannot be converted to a different type."
		);

		%{$self} = %{$new_rule};
	}
	$old;
};
# ~~~ parentStyleSheet
# ~~~ parentRule
  
                              !()__END__()!

=head1 NAME

CSS::DOM::Rule - CSS rule class for CSS::DOM

=head1 VERSION

Version 0.02

=head1 SYNOPSIS

  use CSS::DOM;
  
  # ...

=head1 DESCRIPTION

This module provides the CSS rule class for L<CSS::DOM>. It inherits from
L<CSS::Style> and implements
the CSSRule DOM interface.

=head1 METHODS

=over 4

=item type

Returns one of the constants below indicating the type of rule.

=item cssText

Returns this rule's CSS code. If you pass an argument, it will be parsed as
the new CSS code for this rule (replacing the existing data), and the old
value will be returned.

=item parentStyleSheet

=item parentRule

(These two have not yet been implemented.)

=back

=head1 EXPORTS

The following constants that indicate the type of rule will be exported on
request:

  UNKNOWN_RULE
  STYLE_RULE    
  CHARSET_RULE  
  IMPORT_RULE   
  MEDIA_RULE    
  FONT_FACE_RULE
  PAGE_RULE

=head1 SEE ALSO

L<DOM::CSS>
