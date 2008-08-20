package CSS::DOM::Parser;

$VERSION = '0.03';

use strict; use warnings; no warnings qw 'utf8 parenthesis';
use re 'taint';

use Carp 1.01 qw 'shortmess croak';
use CSS::DOM;
use CSS::DOM::Rule::Style;
use CSS::DOM::Style;

our @CARP_NOT = qw "CSS::DOM CSS::DOM::Rule::Media";


# Tokeniser regexps

my $token_re;

# This one has to be outside the scope, because we need it in tokenise.
my $_optspace   = qr/[ \t\r\n\f]*/;
{

# Vars beginning with _ here are not token regexps, but are used to
# build them.
my $_escape =qr/\\(?:[0-9a-f]{1,6}(?:\r\n|[ \n\r\t\f])?|[^\n\r\f0-9a-f])/i;
my $_id_start = qr/[_a-zA-Z]|[^\0-\177]|$_escape/;
my $_id_cont   = qr/[_a-zA-Z0-9-]|[^\0-\177]|$_escape/;
my $_nl        = qr/\r\n?|[\n\f]/;
my $_invalid_qq = qr/"[^\n\r\f\\"]*(?:(?:\\$_nl|$_escape)[^\n\r\f\\"]*)*/;
my $_invalid_q  = qr/'[^\n\r\f\\']*(?:(?:\\$_nl|$_escape)[^\n\r\f\\']*)*/;

my $ident = qr/-?$_id_start$_id_cont*/;
my $at    = qr/\@$ident/;
my $str   = qr/$_invalid_qq(?:"|\z)|$_invalid_q(?:'|\z)/;
my $invalid = qr/$_invalid_qq|$_invalid_q/;
my $hash     = qr/#$_id_cont+/;
my $num      = qr/(?=\.?[0-9])[0-9]*(?:\.[0-9]*)?/;
my $percent  = qr/$num%/;
my $dim      = qr/$num$ident/;
my $url      = qr/url\($_optspace(?:
		$str
	  	  |
		[^\0- "'()\\\x7f]*(?:$_escape[^\0- "'()\\\x7f]*)*
	)$_optspace(?:\)|\z)/x;
my $uni_range = qr/U\+[0-9A-F?]{1,6}(?:-[0-9a-f]{1,6})?/i;
my $space     = qr/(?:[ \t\r\n\f]+|\/\*.*?(?:\*\/|\z))[ \t\r\n\f]*
                   (?:\/\*.*?(?:\*\/|\z)[ \t\r\n\f]*)*/xs;
my $function  = qr/$ident\(/;

# Literal tokens are as follows:
#  <!-- --> ; { } ( ) [ ] ~= |= , :

# The order of some tokens is important. $url, $uni_range and $function
# have to come before $ident. $url has to come before $function. $percent
# and $dim have to come before $num. 
$token_re = qr/\G(?:
        ($url)|($uni_range)|($function)|($ident)|($at)|($str)|($invalid)|
        ($hash)|($percent)|($dim)|($num)|(<!--|-->)|(;)|({)|(})|(\()|(\))
       |(\[)|(])|($space)|(~=)|(\|=)|(,)|(:)|(.)
)/xs;

} # end of tokeniser regexps

# tokenise returns a string of token types in addition to the array of
# tokens so that we can apply grammar rules using regexps. The types are
# as follows:
#  u  url
#  U  unicode range
#  f  function
#  i  identifier
#  @  at keyword
#  '  string
#  "  invalid string (unterminated)
#  #  hash
#  %  percentage
#  D  dimension
#  1  number  (not 0, because we want it true)
#  <  html comment delimiter
#  s  space/comments
#  ~  ~=
#  |  |=
#  d  delimiter (miscellaneous character)
# The characters ;{}()[],: represent themselves. The comma and colon are
# actually delimiters according to the CSS 2.1 spec, but it’s more conveni-
# ent to have them as their own tokens.
# ~~~ It might actually make the code cleaner if we make them all their own
# tokens, in which case we can provide a $delim_re for matching against a
# token type string.

sub tokenise { for (shift) {
	my($tokens,@tokens)='';
	while(/$token_re/gc){
		my $which = (grep defined $+[$_], 1..$#+)[0];
		no strict 'refs';
		push @tokens, $$which;
		no warnings qw]qw];
		$tokens .=
		  qw/u U f i @ ' " # % D 1 < ; { } ( ) [ ] s ~ | , : d/
				[$which-1];

		# We need to close unterminated tokens for the sake of
		# serialisation. If we don’t, then too many other parts of
		# the code base have to deal with it.
		if($tokens =~ /'\z/) {
			$tokens[-1] =~ /^(')[^'\\]*(?:\\.[^'\\]*)*\z
			                 |
			                ^(")[^"\\]*(?:\\.[^"\\]*)*\z/xs
			and $tokens[-1] .= $1 || $2;
		}
		elsif($tokens =~ /u\z/) {
			(my $copy = $tokens[-1]) =~ s/^url\($_optspace(?:
				(')[^'\\]*(?:\\.[^'\\]*)*
			 	  |
				(")[^"\\]*(?:\\.[^"\\]*)*
				  |
				[^)\\]*(?:\\.[^)\\]*)*
			)//sox;
			my $str_delim = $1||$2;
			$str_delim and $copy!~s/^['"]$_optspace//o
				and $tokens[-1] .= $str_delim;
			$copy or $tokens[-1] .= ')';
		}
	}
	# This can’t ever happen:
	pos and pos() < length
	 and die "CSS::DOM::Parser internal error (please report this):"
		." Can't tokenise " .substr $_,pos;

	# close bracketed constructs: again, we do this here so that other
	# pieces of code scattered all over the place (including the reg-
	# exps below,  which  would  need  things  like  ‘(?:\)|\z)’)
	# don’t have to.
	my $brack_count = (()=$tokens=~/[(f]/g)-(()=$tokens=~/\)/g)
	                + (()=$tokens=~/\[/g)-(()=$tokens=~/]/g)
	                + (()=$tokens=~/{/g)-(()=$tokens=~/}/g);
	my $tokens_copy = reverse $tokens;
	for(1..$brack_count) {
		$tokens_copy =~ s/.*?([[{(f])//;
		push @tokens,  $1 eq'['?']':$1 eq'{'?'}':')';
		$tokens .= $tokens[-1];
	}

	return $tokens,\@tokens,  ;
}}

# Each statement is either an @ rule or a ruleset (style rule)
# @ rule syntax is
#       @ s? any*  followed by block or ;
# A block is  { s? (any|block|@ s?|; s?)* } s?
# ruleset syntax is
#       any* { s? [d,:]? ident s? : s? (any|block|@ s?)+
#             (; s? [d,:]? ident s? : s? (any|block|@ s?)+)* } s?
# "any" means
#       ( [i1%D'd,:u#U~|] | f s? any* \) | \(s? any \) | \[ s? any \] ) s?
# That’s the ‘future-compatible’ CSS syntax. Below, we sift out the valid
# CSS 2.1 rules to put them in the right classes. Everything else goes in
# ‘Unknown’.

# Methods beginning with _parse truncate the arguments (a string of token
# types and an array ref of tokens) and return an object.  What’s left  of
# the args is whatever couldn’t be parsed. If the args were parsed in their
# entirety, they end up blank.

our $any_re; our $block_re;
no warnings 'regexp';
# Although we include invalid strings (") in the $any_re, they are not
# actually valid, but cause the enclosing property declaration or rule to
# be ignored.
$any_re = 
    qr/(?:
        [i1%D'"d,:u#U~|]
          |
        [f(]s?(??{$any_re})*\)
          |
        \[s?(??{$any_re})*]
    )s?/x;
$block_re =
    qr/{s?(?:(??{$any_re})|(??{$block_re})|[\@;]s?)*}s?/;

sub parse { # Don’t shift $_[0] off @_. We’d end up copying it if we did
            # that--something we ought to avoid, in case it’s huge.
	my $pos = pos $_[0];
	my($types,$tokens,) = tokenise $_[0];
	my $sheet = new CSS::DOM @_[1..$#_];
	my $stmts = $sheet->cssRules;
	eval { for($types) {
		while($_) {
			s/^([s<]+)//
				and splice @$tokens, 0, length $1;
			my $tokcount = @$tokens;
			if(/^@/) {
				push @$stmts,
					_parse_at_rule($_,$tokens,$sheet);
			}
			else {
				@$stmts != push @$stmts, _parse_ruleset(
					$_,$tokens,
				) and $$stmts[-1]
					->_set_parentStyleSheet($sheet);
			}
			if($tokcount == @$tokens) {
				$types and _expected("rule",$tokens)
			}
		}
	}};
	pos $_[0] = $pos;
	return $sheet;
}

sub parse_statement {
	my $pos = pos $_[0];
	my($types,$tokens,) = tokenise $_[0];
	my $stmt;
	for($types) {
		s/^s//
			and shift @$tokens;
		if(/^@/) {
			$stmt = _parse_at_rule($_,$tokens);
		}
		else {
			#use DDS; Dump [$_,$tokens];
			$stmt = _parse_ruleset(
				$_,$tokens,
			) or last;
#			use DDS; Dump $stmt;
		}
	}
	pos $_[0] = $pos;
	$@ = length $types ? shortmess "Invalid CSS statement"
			: '';
	return $stmt;
}

sub parse_style_declaration {
	my $pos = pos $_[0];
#use DDS; Dump tokenise $_[0]; pos $_[0] = $pos;
	my @tokens = tokenise $_[0];
	$tokens[0] =~ s/^s// and shift @{$tokens[1]};
	$@ = (my $style = _parse_style_declaration(@tokens) and!$tokens[0])
		? '' : shortmess 'Invalid style declaration';
	pos $_[0] = $pos;
	return $style;
}

# This one will die if it fails to match a rule. We only call it when we
# are certain that we could only have an @ rule.
# This accepts as an optional third arg the parent rule or stylesheet.
sub _parse_at_rule { for (shift) { for my $tokens (shift) {
	my $unesc_at = lc unescape(my $at = shift @$tokens);
	my $type;
	s/^@//;
	if($unesc_at eq '@media'
	   && s/^(s?is?(?:,s?is?)*\{)//) {
		# There’s a good chance
		# this is a  @media rule,
		# but if what follows this
		# regexp match  turns  out
		# not to be a valid set of
		# rulesets,  we  have  an
		# unknown rule.
		my $header = $1;
		my @header = splice @$tokens,
				0,
				length $1;
		# set aside all body tokens in case this turns out to be
		# an unknown rule
		my ($body,@body);
		"{$_" =~ /^$block_re/
			? ($body = substr($_,0,$+[0]-1),
			   @body = @$tokens[0..$+[0]-2])
			: croak "Invalid block in \@media rule";

#use DDS; Dump $body, \@body;
		# We need to record the number of tokens we have now, so
		# that, if we revert to ‘unknown’ status, we can remove the
		# right number of tokens.
		my $tokens_to_begin_with = length;
		s/^s// and shift @$tokens;
		my @rulesets;
		while($_) {
			push @rulesets, _parse_ruleset ($_, $tokens)||last;
		}
		 
		if(s/^}s?//) {
			splice @$tokens, 0, $+[0];
			require CSS::DOM::Rule::Media;
			my $rule = new CSS::DOM::Rule::Media $_[0]||();
			@{$rule->cssRules} = @rulesets;
			$_->_set_parentRule($rule),
			$_[0] &&$_->_set_parentStyleSheet($_[0])
				for @rulesets;
			my $media = $rule->media;
			while($header =~ /i/g) {
				push @$media, unescape($header[$-[0]]);
			}
			return $rule;
		}
		else {
			 # ignore rules w/invalid strings
			$body =~ /"/ and return;

			my $length = $tokens_to_begin_with-length $body;
			$_ = $length ? substr $_, -$length : '';
			@$tokens = @$tokens[-$length..-1];

			$body =~ s/s\z// and pop @body;
			require CSS::DOM::Rule;
			(my $rule = new CSS::DOM::Rule $_[0]||())
				->_set_tokens(
					"\@$header$body",
					[$at,@header,@body]
				);
			return $rule;
		}
	}
	elsif($unesc_at eq '@page'
	   && s/^((?:s?:i)?)(s?{s?)//) {
		my $selector = "\@$1";
		my @selector = ('@page', splice @$tokens, 0, $+[1]);
		my @block_start =
			splice @$tokens, 0, length(my $block_start = $2);

		# Unfortunately, these two lines may turn out to
		# be a waste.
		require CSS::DOM::Rule::Page;
		my $style = (my $rule = new CSS::DOM::Rule::Page $_[0]||())
			-> style;

		$style = _parse_style_declaration($_,$tokens,$style);
		if($style) {
			s/^}s?// and splice @$tokens, 0, $+[0]; # remove }
			$rule->selectorText(join '', @selector);
			return $rule;
		}
		else {
			"{$_" =~ /^$block_re/
				or croak "Invalid block in \@page rule";
			$selector .= $block_start .substr($_,0,$+[0]-1,''),
			push @selector, @block_start ,
				splice @$tokens, 0, $+[0]-1;

			 # ignore rules w/invalid strings
			$selector =~ /"/ and return; 

			$selector =~ s/s\z// and pop @selector;

			require CSS'DOM'Rule;
			(my $rule = new CSS::DOM::Rule $_[0]||())
				->_set_tokens(
					$selector,\@selector
					# not exactly a selector any more
				);
			return $rule;
		}
	}
	elsif($unesc_at eq '@import'
	   && s/^s?([u'])s?(is?(?:,s?is?)*)?(?:;s?|\z)//) {
		my($url_type,$media_token_types) = ($1,$2);
		my $url = $$tokens[$-[1]];
		my @media_tokens = $2?@$tokens[$-[2]..$+[2]]:();
		splice @$tokens, 0, $+[0];
		require CSS::DOM::Rule::Import;
		my $rule = new CSS::DOM::Rule::Import $_[0]||();
		$rule->_set_url_token($url_type,$url);
		@media_tokens or return $rule;
		my $media = $rule->media;
		while($media_token_types =~ /i/g) {
			push @$media, unescape($media_tokens[$-[0]]);
		}
		return $rule;
	}
	# ~~~ put other rule types here
	else { # unwist
#warn $_;
		s/^(s?(??{$any_re})*(?:(??{$block_re})|(?:;s?|\z)))//
			or croak "Invalid $at rule";
		my ($types,@tokens) = ("\@$1",$at,splice @$tokens,0,$+[0]);
		$types =~ /"/ and return; # ignore rules w/invalid strings
		$types =~ s/s\z// and pop @tokens;
		require CSS'DOM'Rule;
		(my $rule = new CSS::DOM::Rule $_[0]||())
			->_set_tokens(
				$types, \@tokens
			);
		return $rule;
	}
}}}

sub _parse_ruleset { for (shift) {
	# Just return if there isn’t a ruleset
	s/(^($any_re*)\{s?(?:$any_re|$block_re|[\@;]s?)*}s?)//x
	 or return;
	index $2,'"' =>== -1 or
		splice (@{+shift}, 0, $+[0]), return;

	for(my $x = $1) {
	my $tokens = [splice @{+shift}, 0, $+[0]];

	(my $ruleset = new CSS::DOM::Rule::Style $_[0]||())
		->_set_selector_tokens(_parse_selector($_,$tokens));

	s/^{s?// and splice @$tokens, 0, $+[0]; # remove {

#use DDS; Dump$_,$tokens;
	_parse_style_declaration($_,$tokens,$ruleset->style);

	s/^}s?// and splice @$tokens, 0, $+[0]; # remove }


	return $ruleset
			
}}}

sub _parse_selector { for (shift) { for my $tokens (shift) {
	my($selector,@selector) = '';
	if(s/^($any_re+)//) {
		$selector = $1;
		push @selector, splice @$tokens, 0, length $1;
	}
	$selector =~ s/s\z// and pop @selector;
	return $selector, \@selector;	
}}}

# This one takes an optional extra arg; namely, the style decl object to
# add properties to.
sub _parse_style_declaration { for (shift) { for my $tokens (shift) {
	# return if there isn’t one
	/^(?:$any_re|$block_re|[\@;]s?)*(?:}s?|\z)/x
	 or return;

	my $style = shift||new CSS::DOM::Style;

	{
		if(s/^is?:s?((?:$any_re|$block_re|\@s?)+)//) {
			my ($prop) = splice @$tokens, 0, $-[1];
			my $types = $1;
			my @tokens = splice @$tokens, 0, length $1;
			unless($types =~ /"/) { # ignore invalid strings
				$types =~ s/s\z// and pop @tokens;;
				$style->_set_property_tokens(
					unescape($prop),$types,\@tokens
				);
			}
			s/^;s?// and splice(@$tokens, 0, $+[0]), redo;
		}
		elsif(s/^;s?//) {
			splice @$tokens, 0, $+[0]; redo;
		}
		else {
			# Ignorable declaration
			s/^(?:$any_re|$block_re|\@s?)*//;
			splice @$tokens, 0, $+[0];
			s/^;s?// and splice(@$tokens, 0, $+[0]), redo;
		}
		# else last
	}

	return $style;
}}}

sub _expected {
	my $tokens = pop;
	croak
		"Syntax error: expected $_[0] but found '"
		.join('',@$tokens[
			0..(10<$#$tokens?10 : $#$tokens)
		]) . ($#$tokens > 10 ? '...' : '') . "'";
}

sub unescape($) {
	my $val = shift;
	$val =~ s/\\(?:
		([a-fA-F0-9]{1,6})(?:\r\n|[ \n\r\t\f])?
		  |
		([^\n\r\f0-9a-f])
		  |
		(\r\n?|[\n\f])
	)/
		defined $1 ? chr hex $1 :
		defined $2 ? $2 :
		             ''
	/gex;
	$val;
}

                              **__END__**

=head1 NAME

CSS::DOM::Parser - Parser for CSS::DOM

=head1 VERSION

Version 0.03

=head1 DESCRIPTION

This is a private module (at least for now). Don't use it directly.

=head1 SEE ALSO

L<CSS::DOM>
