package CSS::DOM::Value;

$VERSION = '0.05';

use warnings; no warnings qw 'utf8 parenthesis';;
use strict;

use Carp;
use CSS::DOM::Value::Primitive ':all';
use Exporter 5.57 'import';

no constant 1.03 ();
use constant::lexical { # If you add to this list, make sure to update the
    type => 0,          # numbers in the subclasses!
    valu => 1,
};

use constant do {
	my $x = 0;
	+{ map +($_ => $x++), our @EXPORT_OK = qw/
		CSS_INHERIT        
		CSS_PRIMITIVE_VALUE
		CSS_VALUE_LIST     
		CSS_CUSTOM         
	  /}
};

our %EXPORT_TAGS = ( all => \our @EXPORT_OK );

sub new {
	@_ < 3 and croak
	 "new CSS::DOM::Value with fewer than 2 args is not supported yet";
	my $self = bless[@_[1..$#_]], $_[0];
	if($_[0] eq __PACKAGE__) {
		# ~~~ what should I do here?
		$self->[type] == CSS_PRIMITIVE_VALUE
			and croak "new CSS::DOM::Value CSS_PRIMITIVE_VALUE doesn't work; use new CSS::DOM::Value::Primitive";
		$self->[type] == CSS_VALUE_LIST and
			require CSS::DOM::Value::List ,
			bless $self, 'CSS::DOM::Value::List';
	}
	$self;
}

sub new_from_tokens { # undocumented on purpose; this may get changed
	shift;
	# ~~~ deal with !important
	my($types,$tokens) = @_;

	# See whether it’s a valid CSS 2.1 simple value
	{return CSS'DOM'Value'Primitive->new_from_tokens($types,$tokens)
		||next}

	# ~~~ add support for value lists and 'inherit' and custom values

	croak "Only primitive values are supported";
	# This doesn’t work:
	#return CSS'DOM'Value->new(CSS_CUSTOM, $types, $tokens); 
}

                              !()__END__()!

=head1 NAME

CSS::DOM::Value - CSSValue class for CSS::DOM

=head1 VERSION

Version 0.05

=head1 SYNOPSIS

  # ...

=head1 DESCRIPTION

This module implements objects that represent CSS property values. It
implements the DOM CSSValue interface.

=head1 METHODS

=head2 Constructor

B<Warning:> This doesn't actually work properly yet. See also
L<CSS::DOM::Value::Primitive>, which has its own constructor.

You probably don't need to call this, but here it is anyway:

  $val = new CSS::DOM::Value TYPE, $value;

where C<TYPE> is C<CSS_INHERIT> or C<CSS_CUSTOM>.

=head2 Object Methods

=over 4

=item cssText (not yet implemented)

Returns a string representation of the attribute. Pass an argument to set 
it.

=item cssValueType (not yet implemented)

Returns the array element at the given C<$index>.

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
