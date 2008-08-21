package CSS::DOM::Rule::Style;

$VERSION = '0.04';

use warnings;
use strict;

use CSS::DOM::Exception qw/ SYNTAX_ERR /;
 use        CSS::DOM::Rule;

our @ISA = 'CSS::DOM::Rule';

no constant 1.03 ();
use constant::lexical { # Don't let this conflict with the superclass.
	styl => 2,
	selc => 3,
};

# overrides:
sub type { CSS::DOM::Rule::STYLE_RULE }
sub cssText {
	my $self = shift;
	my $old;
	if(defined wantarray) {
		my $sel = $self->selectorText;
		length $sel and $sel .= ' ';
		$old = "$sel\{ "
			. $self->[styl]->cssText ." }\n";
	}
	if (@_) {
		my $new_rule  =  $self->_parse(shift);
		@$self[styl,selc] = @$new_rule[styl,selc];
	}
	$old;
};


# CSSStyleRule interface:

sub selectorText { # ~~~ syntax_err
	my $old = (my $self = shift)->[selc];
#	warn "@{$$old[1]}";# if ref $old eq 'ARRAY' and wantarray;
	$old = join '', @{$$old[1]}
		if ref $old eq 'ARRAY' and defined wantarray;
	$self->[selc] = "".shift if @_;
	$old;
}

sub _set_selector_tokens {
	shift->[selc] = \@_;
}

sub style {
	$_[0]->[styl] ||= do {
		require CSS::DOM::Style;
		new CSS::DOM::Style shift
	};
}

                              !()__END__()!

=head1 NAME

CSS::DOM::Rule::Style - CSS style rule class for CSS::DOM

=head1 VERSION

Version 0.04

=head1 SYNOPSIS

  use CSS::DOM;
  my $ruleset = CSS::DOM->parse(
      'p:firstline, h3 { font-weight: bold }'
  )->cssRules->[0];

  $ruleset->selectorText;      # 'p:firstline, h3'
  $ruleset->style;             # a CSS::DOM::Style object
  $ruleset->style->fontWeight; # 'bold'

=head1 DESCRIPTION

This module implements CSS style rules for L<CSS::DOM>. It inherits 
from
L<CSS::DOM::Rule> and implements
the CSSStyleRule DOM interface.

=head1 METHODS

=over 4

=item selectorText

Returns a string representing the selector(s). Pass an argument to set it.

=item style

Returns the CSS::DOM::Style object representing the declaration block
of this rule.

=back

=head1 SEE ALSO

L<CSS::DOM>

L<CSS::DOM::Style>

L<CSS::DOM::Rule>
