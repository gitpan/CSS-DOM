package CSS::DOM::Value;

$VERSION = '0.06';

use warnings; no warnings qw 'utf8 parenthesis';;
use strict;

use Carp;
use CSS::DOM::Constants;
use Exporter 5.57 'import';

no constant 1.03 ();
use constant::lexical { # If you add to this list, make sure to update the
    type => 0,          # numbers in the subclasses!
    valu => 1,
};

*EXPORT_OK = $CSS::DOM::Constants::EXPORT_TAGS{value};
our %EXPORT_TAGS = ( all => \our @EXPORT_OK );

sub new {
	my $self = bless[], $_[0];
	$self->[type] = $_[1];
	$_[1] == CSS_CUSTOM
	? @_ < 3 && croak
	   'new CSS::DOM::Value(CSS_CUSTOM, $value) requires the $value'
	: $_[1] == CSS_INHERIT
		|| croak "Type must be CSS_CUSTOM or CSS_INHERIT";

	$self->[valu] = $_[2];

	$self;
}

sub new_from_tokens { # undocumented on purpose; this may get changed
	shift;
	my($types,$tokens) = @_;
	
	@$tokens == 1 && $$tokens[0] eq 'inherit'
		&& return new __PACKAGE__, CSS_INHERIT;

	# See whether it’s a valid CSS 2.1 simple value
	require CSS'DOM'Value'Primitive;
	{return CSS'DOM'Value'Primitive->new_from_tokens($types,$tokens)
		||next}

	# ~~~ add support for value lists

	return CSS'DOM'Value->new(CSS_CUSTOM, join '',@$tokens);
}

sub cssValueType { shift->[type] }

sub cssText {
	my $self = shift;
	$self->[type] == CSS_CUSTOM
		? $self->[valu] : 'inherit'
}

                              !()__END__()!

=head1 NAME

CSS::DOM::Value - CSSValue class for CSS::DOM

=head1 VERSION

Version 0.06

=head1 SYNOPSIS

  # ...

=head1 DESCRIPTION

This module implements objects that represent CSS property values. It
implements the DOM CSSValue interface.

This class itself is used for custom values (neither primitive values nor
lists) and the special 'inherit' value. Subclasses are used for the others.

=head1 METHODS

=head2 Constructor

See also L<CSS::DOM::Value::Primitive>, which has its own constructor.

You probably don't need to call this, but here it is anyway:

  $val = new CSS::DOM::Value TYPE, $css_string;

where C<TYPE> is C<CSS_INHERIT> or C<CSS_CUSTOM>. The C<$css_string> is
only used when C<TYPE> is C<CSS_CUSTOM>.

=head2 Object Methods

=over 4

=item cssText

Returns a string representation of the attribute. Pass an argument to set 
it.

=item cssValueType

Returns one of the constants below.

=back

=head1 CONSTANTS

The following constants can be imported with C<use CSS::DOM::Value ':all'>.
They represent the type of CSS value.

=item CSS_INHERIT (0)

=item CSS_PRIMITIVE_VALUE (1)

=item CSS_VALUE_LIST (2)

=item CSS_CUSTOM (3)

=head1 SEE ALSO

L<CSS::DOM>

L<CSS::DOM::Value::Primitive>

L<CSS::DOM::Value::List> (doesn't exist yet)

L<CSS::DOM::Style>
