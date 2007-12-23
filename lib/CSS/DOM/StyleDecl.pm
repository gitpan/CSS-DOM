package CSS::DOM::StyleDecl;

$VERSION = '0.01';

use warnings;
use strict;

use CSS::DOM::Exception 'SYNTAX_ERR';
use Scalar::Util 'weaken';

require CSS;
require CSS::Adaptor;
require CSS::Property;

sub new {
	my($class) = shift;

	my $self = bless {
		@_ ? (
			ary => $_[0]->{properties},
			owner => $_[0]
		) : (
			ary => []
		)
	}, $class;
	weaken $self->{owner} if @_;
	return $self
}

sub cssText {
	my $self = shift;
	my $out;
	if (defined wantarray) {
		$out = CSS::Adaptor->new->output_properties($$self{ary});
	}
	if(@_) {
		my $css = shift;
		!defined $css || !length $css and
			@{$$self{ary}} = (), return $out;

		require CSS;
		my $css_obj = new CSS;
		eval {
			$css_obj->read_string("foo{$css}");
			1
		} or die CSS::DOM::Exception->new(
			SYNTAX_ERR,
			$@
		);

		# I have to copy the *contents* of the array, not the ref
		# thereto, because the owner also has a reference to the
		# array in $self->{ary}, and we’d lose synchronisation.
		@{$self->{ary}} = @{$css_obj->get_style_by_selector('foo')
			->{properties}};
	}
	return $out;
}

sub getPropertyValue {
	for (@{+shift->{ary}}) {
		$_->{property} eq $_[0] and return $_->values;
	}
	''
}

# ~~~ getPropertyCSSValue
# ~~~ removeProperty
# ~~~ getPropertyPriority

sub setProperty {
	my ($self, $name, $value, $priority) = @_;

	my $prop;
	for (@{$$self{ary}}) {
		$_->{property} eq $name and $prop = $_, last
	}
	unless($prop) {
		push @{$$self{ary}}, $prop = CSS::Property->new({
			property => $name,
		});

	}

	my $css_obj = new CSS;
	eval {
		$css_obj->read_string("foo{bar: $value}");
		1
	} or die CSS::DOM::Exception->new(
		SYNTAX_ERR,
		$@
	);

	$prop->{values} =
		$css_obj->{styles}[0]{properties}[0]{values};

	return
}

# ~~~ length
# ~~~ item

sub parentRule {
	shift->{owner}
}

# stubs to prevent autoload
*getPropertyCSSValue=
*removeProperty=
*getPropertyPriority=
*length=
*item =sub{die};

#{fieldhash my %rule; sub parentRule {
#	$rule{+shift} || ()
#} sub _set_parentRule {
#	weaken($rule{$_[0]} = $_[1]);
#}}

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

CSS::DOM::Declaration - CSS style declaration class for CSS::DOM

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

  use CSS::DOM;
  
  # ...

=head1 DESCRIPTION

This module provides the CSS style declaration class for L<CSS::DOM>. It 
implements
the CSSStyleDeclaration DOM interface.

=head1 CONSTRUCTOR

You don't normally need to call this, but, in case you do, here is the
syntax:

  $style_decl = new CSS::DOM::StyleDecl $owner_rule;

C<$owner_rule>, which is optional, is expected to be a L<CSS::Style>
object, or a subclass like L<CSS::DOM::Rule>.

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

=back

This module also has methods for accessing each CSS property directly.
Simply capitalise each letter in a CSS property name that follows a hyphen,
then remove the hyphens, and you'll have the method name. E.g., call the
C<borderBottomWidth> method to get/set the border-bottom-width property.
One exception to this is that C<cssFloat> is the method used to access the
'float' property. (But you can also use the C<float> method, though it's
not part of the DOM standard.)

=head1 SEE ALSO

L<DOM::CSS>

L<DOM::CSS::Rule>
