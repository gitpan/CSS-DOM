package CSS::DOM::Value::Primitive;

$VERSION = '0.03';

use warnings; no warnings qw 'utf8 parenthesis';;
use strict;

use Carp;
use Exporter 5.57 'import';

no constant 1.03 ();
use constant::lexical { # Don’t conflict with the superclass!
    type => 2,
    valu => 3,
    unit => 4,
};

use constant do {
	my $x = 0;
	+{ map +($_ => $x++), our @EXPORT_OK = qw/
		CSS_UNKNOWN    
		CSS_NUMBER     
		CSS_PERCENTAGE 
		CSS_EMS        
		CSS_EXS        
		CSS_PX         
		CSS_CM         
		CSS_MM         
		CSS_IN         
		CSS_PT         
		CSS_PC         
		CSS_DEG        
		CSS_RAD        
		CSS_GRAD       
		CSS_MS         
		CSS_S          
		CSS_HZ         
		CSS_KHZ        
		CSS_DIMENSION  
		CSS_STRING     
		CSS_URI        
		CSS_IDENT      
		CSS_ATTR       
		CSS_COUNTER    
		CSS_RECT       
		CSS_RGBCOLOR   
	  /}
};

our %EXPORT_TAGS = ( all => \our @EXPORT_OK );

my %lentypes = ( # length suffix -> CSSPrimitiveValue type constant;
	''   => CSS_NUMBER,
	'%'  => CSS_PERCENTAGE,
	'em' => CSS_EMS,
	'ex' => CSS_EXS,
	'px' => CSS_PX,
	'cm' => CSS_CM,
	'mm' => CSS_MM,
	'in' => CSS_IN,
	'pt' => CSS_PT,
	'pc' => CSS_PC,
	 deg => CSS_DEG,
	 rad => CSS_RAD,
	grad => CSS_GRAD,
	'ms' => CSS_MS,
	's'  => CSS_S,
	'hz' => CSS_HZ,
	 khz => CSS_KHZ,
);
	
sub new_from_tokens { # This is a private method inconsistent in its behav-
                      # iour with the superclass’s method,  because it
                      # returns nothing if the tokens are not valid.
	my($class,$types,$tokens) = @_;
	require CSS'DOM'Parser;
	if($types =~
	    /^(?:
	      (d?)[1%D]
	       |
	      ([u#'])
	       |
	      (i) # (?:si)?) # ~~~ How do we distinguish between ‘font:
	       |             #     Lucida Grande’ and ‘font: bold italic’?
	      (fs?$CSS'DOM'Parser'any_re*\)?)
	    )\z/
	   and !$1 || $$tokens[0] eq '+' || $$tokens[0] eq '-'
	   and $2 ne '#' || do {
		$$tokens[$-[2]] =~ /#(?:[a-fA-F0-9]{3}|[a-fA-F0-9]{6})\z/
	   }
	) {
		my $type;
		if(defined $1) {
			my $sign = $1 ? shift @$tokens : '';
			$sign eq '+' and $sign = '';
			shift(@$tokens) =~ /([\d.]+)(.*)/;
			return new $class
				exists $lentypes{$2} ? $lentypes{$2} :
					CSS_DIMENSION,
				"$sign$1",
				$2;
		}
		elsif($2) {
			my $val = shift @$tokens;
			if($2 eq "'") {
				return new $class CSS_STRING,
					CSS'DOM'Parser'unescape(
						substr $val, 1, -1
					);
			}
			elsif($2 eq 'u') {
				$val =~ s/^url\([ \t\r\n\f]*//;
				$val =~ s/\)?[ \t\r\n\f]*\z//;
				return new $class CSS_URI,
					CSS'DOM'Parser'unescape $val;
			}
			else { #
				$val =~ /#(.|..)(.|..)(.|..)/;
				return new $class CSS_RGBCOLOR,
					[hex $1, hex $2, hex $3];
			}
		}
		elsif($3) {
			return new $class CSS_IDENT,
				CSS'DOM'Parser'unescape(shift @$tokens)
			if @$tokens == 1;
			return new $class CSS_STRING, join ' ', map
				CSS'DOM'Parser'unescape($$tokens[$_*2]),
				0..$#$tokens/2;
		}
		else { # function
			# ~~~ We need to deal with counter/rect/rgb/attr
			# constants are CSS_UNKNOWN CSS_ATTR CSS_COUNTER 
			# CSS_RECT CSS_RGBCOLOR
			return # unwist for now
		}
	}

}


sub new {
	@_ < 3 and croak
	 "new CSS::DOM::Value::Primitive with fewer than 2 args is not supported yet";
	my $self = bless[], shift;
	@$self[type,valu,unit] = @_;
	$self;
}

my @unit_suffixes;
$unit_suffixes[CSS_PERCENTAGE ] = '%';
$unit_suffixes[CSS_EMS        ] = 'em';
$unit_suffixes[CSS_EXS        ] = 'ex';
$unit_suffixes[CSS_PX         ] = 'px';
$unit_suffixes[CSS_CM         ] = 'cm';
$unit_suffixes[CSS_MM         ] = 'mm';
$unit_suffixes[CSS_IN         ] = 'in';
$unit_suffixes[CSS_PT         ] = 'pt';
$unit_suffixes[CSS_PC         ] = 'pc';
$unit_suffixes[CSS_DEG        ] = 'deg';
$unit_suffixes[CSS_RAD        ] = 'rad';
$unit_suffixes[CSS_GRAD       ] = 'grad';
$unit_suffixes[CSS_MS         ] = 'ms';
$unit_suffixes[CSS_S          ] = 's';
$unit_suffixes[CSS_HZ         ] = 'Hz';
$unit_suffixes[CSS_KHZ        ] = 'kHz';

sub cssText { 
	my $self = shift;
	croak "cssText can't be set yet" if@_;
	for($self->[type]) {
		# ~~~ What about the clip() function?
		$_ == CSS_ATTR and return 'attr(' . $self->[valu] . ')';
#~~~ what's the format?		$_ == CSS_COUNTER && return 'counter(' . $self->[value] . ')';
		$_ == CSS_URI and return 'url(' . $self->[valu].  ')';
		$_ == CSS_RECT and return 'rect(' . $self->[valu].')';
		$_ == CSS_RGBCOLOR and return 'rgb(' . $self->[valu].')'; # ~~~ deal with different colour formats
		$_ == CSS_STRING and do {
			(my $str = $self->[valu]) =~ s/'/\\'/g;;
			return "'$str'";
		};
		return $self->[valu]. (
			$_ == CSS_DIMENSION && defined $self->[unit]
				? $self->[unit]
				: $unit_suffixes[$_] || ''
		);
	}
}

                              !()__END__()!

=head1 NAME

CSS::DOM::Value::Primitive - CSSPrimitiveValue class for CSS::DOM

=head1 VERSION

Version 0.03

=head1 SYNOPSIS

  # ...

=head1 DESCRIPTION

This module implements objects that represent CSS primitive property 
values (as opposed to lists). It
implements the DOM CSSPrimitiveValue interface and inherits from 
L<CSS::DOM::Value>.

=head1 METHODS

=head2 Constructor

You probably don't need to call this, but here it is anyway:

  $val = new CSS::DOM::Value::Primitive TYPE, $value, $unit_text;

where C<TYPE> is one of the constants listed below. If C<TYPE> is 
C<CSS_DIMENSION>, then C<$unit_text> is the name of the unit. Otherwise it
is ignored.

=for comment
I don’t think we need this after all.
  $val = new CSS::DOM::Value::Primitive $string # (not yet implemented)

=head2 Object Methods

=over 4

=item cssText

Returns a string representation of the attribute. Pass an argument to set 
it B<(not yet supported)>.

=back

The rest have still to be implemented.

=begin comment

=item cssValueType (not yet implemented)

Returns the array element at the given C<$index>.

=back

=end comment

=head1 CONSTANTS

The following constants can be imported with 
C<use CSS::DOM::Value::Primitive ':all'>.
They represent the type of primitive value.

=item CSS_UNKNOWN    

=item CSS_NUMBER     

=item CSS_PERCENTAGE 

=item CSS_EMS        

=item CSS_EXS        

=item CSS_PX         

=item CSS_CM         

=item CSS_MM         

=item CSS_IN         

=item CSS_PT         

=item CSS_PC         

=item CSS_DEG        

=item CSS_RAD        

=item CSS_GRAD       

=item CSS_MS         

=item CSS_S          

=item CSS_HZ         

=item CSS_KHZ        

=item CSS_DIMENSION  

=item CSS_STRING     

=item CSS_URI        

=item CSS_IDENT      

=item CSS_ATTR       

=item CSS_COUNTER    

=item CSS_RECT       

=item CSS_RGBCOLOR   

=head1 SEE ALSO

L<CSS::DOM>

L<CSS::DOM::Value>

L<CSS::DOM::Value::List> (doesn't exist yet)

L<CSS::DOM::Style>
