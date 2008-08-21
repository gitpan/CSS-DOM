package CSS::DOM::Style;

$VERSION = '0.04';

use warnings; no warnings qw' utf8';
use strict;

use CSS::DOM::Exception 'SYNTAX_ERR';
use Scalar::Util 'weaken';

# ~~~ use overload fallback => 1, '@{}' => 

sub parse {
	require CSS::DOM::Parser;
	goto &CSS::DOM::Parser::parse_style_declaration;
}

sub new {
	my($class) = shift;

	my $self = bless {}, $class;
	@_ and $self->{owner} = shift, weaken $self->{owner};
	return $self
}

sub cssText {
	my $self = shift;
	my $out;
	if (defined wantarray) {
		$out = join "; ", map "$_: " . $self->getPropertyValue($_),
			@{$$self{names}};
	}
	if(@_) {
		my $css = shift;
		!defined $css || !length $css and
			@$self{'props','names'} = (), return $out;

		require CSS::DOM::Parser;
		my $new =CSS::DOM::Parser::parse_style_declaration($css);

		@$self{'props','names'} = @$new{'props','names'};
	}
	return $out;
}

sub getPropertyValue {
	# ~~~ we don't deal with lists here yet
	exists +(my $props = shift->{props} || return '')->{
	  my $name = lc$_[0]
	}	or return return '';
	my $valref = \$props->{$name};
	return ref $$valref eq 'ARRAY'
		? (
			require CSS'DOM'Rule,
			join '', @{$$$valref[1]} ,
		): ref $$valref ? $$valref->cssText : $$valref;
}

# ~~~ getPropertyCSSValue
# ~~~ removeProperty
# ~~~ getPropertyPriority

sub setProperty {
# ~~~ We still need to deal with priority
# ~~~ tokenise doesn't actually throw an error; parser needs a parse_value thing
	my ($self, $name, $value, $priority) = @_;

	require CSS'DOM'Parser;
	my @tokens = eval { CSS'DOM'Parser'tokenise($value); }
		or die CSS::DOM'Exception->new( SYNTAX_ERR, $@);	

	my $props = $$self{props} ||= {};
	exists $$props{$name=lc$name} or push @{$$self{names}}, $name;
	$$props{$name} = \@tokens;

	return
}

# ~~~ length
# ~~~ item

sub parentRule {
	shift->{owner}
}

sub _set_property_tokens { # private
	my ($self,$name,$types,$tokens) = @_;
	my $props = $$self{props} ||= {};
	exists $$props{$name=lc$name} or push @{$$self{names}}, $name;
	$$props{$name} = [$types,$tokens];
}

# stubs to prevent autoload
*getPropertyCSSValue=
*removeProperty=
*getPropertyPriority=
*length=
*item =sub{die};

{ my $prop_re = qr/[a-z]+(?:[A-Z][a-z]+)*/;
sub can {
	return undef if $_[1] =~ /^(?:getPropertyCSSValue|removeProperty|getPropertyPriority|length|item)\z/; # ~~~ temporary
	SUPER::can { shift } @_ or
		$_[0] =~ /^$prop_re\z/o ? \&{+shift} : undef;
}
sub AUTOLOAD {
	my $self = shift;
	if(our $AUTOLOAD =~ /(?<=:)($prop_re)\z/o) {
		(my $prop = $1) =~ s/([A-Z])/-\l$1/g;
		my $val;
		defined wantarray
			and $val = $self->getPropertyValue($prop);
		@_ and $self->setProperty($prop, shift);
		return $val;
	} else {
		die "Undefined subroutine $AUTOLOAD called at ",
			join(" line ", (caller)[1,2]), ".\n";
	}
}
sub DESTROY{}
}
*cssFloat = \&float;

                              !()__END__()!

=head1 NAME

CSS::DOM::Style - CSS style declaration class for CSS::DOM

=head1 VERSION

Version 0.04

=head1 SYNOPSIS

  use CSS::DOM::Style;
  
  $style = CSS::DOM::Style::parse(' text-decoration: none ');
  
  $style->cssText; # returns 'text-decoration: none'
  $style->cssText('color: blue'); # replace contents
  
  $style->getPropertyValue('color'); # 'blue'
  $style->color;                     # same
  $style->setProperty(color=>'green'); # change it
  $style->color('green');              # same

=head1 DESCRIPTION

This module provides the CSS style declaration class for L<CSS::DOM>. (A
style declaration is what comes between the braces in C<p { margin: 0 }>.)
It 
implements
the CSSStyleDeclaration DOM interface.

=head1 CONSTRUCTORS

=over 4

=item CSS::DOM::Style::parse( $string )

This parses the C<$string> and returns a new style declaration 
object. This is useful if you have text from an HTML C<style> attribute,
for instance.

=item new CSS::DOM::Style $owner_rule

You don't normally need to call this, but, in case you do, here it is.
C<$owner_rule>, which is optional, is expected to be a L<CSS::DOM::Rule>
object, or a subclass like L<CSS::DOM::Rule::Style>.

=back

=head1 METHODS

=over 4

=item cssText ( $new_value )

Returns the body of this style declaration (without the braces). If you
pass an argument, it will parsed and replace the existing CSS data.

=item getPropertyValue ( $name )

Returns the value of the named CSS property as a string.

=item getPropertyCSSValue

=item removeProperty

=item getPropertyPriority

(not yet implmeented)

=item setProperty ( $name, $value, $priority )

Sets the CSS property named C<$name>, giving it a value of C<$value>.
C<$priority> is currently ignored (to be implemented later).

=item length

=item item ( $index )

(not yet implmeented)

=item parentRule

Returns the rule to which this declaration belongs.

=back

This module also has methods for accessing each CSS property directly.
Simply capitalise each letter in a CSS property name that follows a hyphen,
then remove the hyphens, and you'll have the method name. E.g., call the
C<borderBottomWidth> method to get/set the border-bottom-width property.
One exception to this is that C<cssFloat> is the method used to access the
'float' property. (But you can also use the C<float> method, though it's
not part of the DOM standard.)

=head1 SEE ALSO

L<CSS::DOM>

L<CSS::DOM::Rule::Style>

L<HTML::DOM::Element>
