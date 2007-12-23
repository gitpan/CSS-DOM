package CSS::DOM::Interface;

use Exporter 5.57 'import';
our $VERSION = '0.01';

# Every class that defines constants should be loaded here.
require CSS::DOM::Rule;

=head1 NAME

CSS::DOM::Interface - A list of CSS::DOM's interface members in machine-readable format

=head1 SYNOPSIS

  use CSS::DOM::Interface ':all';

  # ...

=begin comment
  
  # name of DOM interface (HTMLDocument):
  $HTML::DOM::Interface{"HTML::DOM"};
  
  # interface it inherits from (Document):
  $HTML::DOM::Interface{HTMLDocument}{_isa};
  
  # whether this can be used as an array
  $HTML::DOM::Interface{HTMLDocument}{_array};
  # or hash
  $HTML::DOM::Interface{HTMLDocument}{_hash};
  
  
  # Properties and Methods
  
  # list them all
  grep !/^_/, keys %{ $HTML::DOM::Interface{HTMLDocument} };
  
  # see whether a given property is supported
  exists $HTML::DOM::Interface{HTMLDocument}{foo}; # false
  
  # Is it a method?
  $HTML::DOM::Interface{HTMLDocument}{title} & METHOD; # false
  $HTML::DOM::Interface{HTMLDocument}{open}  & METHOD; # true
  
  # Does the method return nothing?
  $HTML::DOM::Interface{HTMLDocument}{open} & VOID; # true
  
  # Is a property read-only?
  $HTML::DOM::Interface{HTMLDocument}{referrer} & READONLY; # true
  
  # Data types of properties
  ($HTML::DOM::Interface{HTMLDocument}{referrer} & TYPE) == STR;  # true
  ($HTML::DOM::Interface{HTMLDocument}{title}    & TYPE) == BOOL; # false
  ($HTML::DOM::Interface{HTMLDocument}{cookie}   & TYPE) == NUM;  # false
  ($HTML::DOM::Interface{HTMLDocument}{forms}    & TYPE) == OBJ;  # false
  
  # and return types of methods:
  ($HTML::DOM::Interface{HTMLDocument}
                           ->{getElementById} & TYPE) == STR;  # false
  ($HTML::DOM::Interface{Node}{hasChildNodes} & TYPE) == BOOL; # true
  ($HTML::DOM::Interface{Node}{appendChild}   & TYPE) == NUM;  # false
  ($HTML::DOM::Interface{Node}{replaceChild}  & TYPE) == OBJ;  # true
  
  
  # Constants

  # list of constant names in the form "HTML::DOM::Node::ELEMENT_NODE";
  @{ $HTML::DOM::Interface{Node}{_constants} };

=end comment

=head1 DESCRIPTION

=for comment
The synopsis should tell you almost everything you need to know. But be
warned that C<$foo & TYPE> is meaningless when C<$foo & METHOD> and
C<$foo & VOID> are both true. For more
gory details, look at the source code. In fact, here it is:

See L<HTML::DOM::Interface> for now, for a description. This is simply the
CSS equivalent.

For gory details, look at the source code. In fact, here it is:

=cut

0 and q r

=for ;

  our @EXPORT_OK = qw/METHOD VOID READONLY BOOL STR NUM OBJ TYPE/;
  our %EXPORT_TAGS = (all => \@EXPORT_OK);

  sub METHOD   () {      1 }
  sub VOID     () {   0b10 } # for methods
  sub READONLY () {   0b10 } # for properties
  sub BOOL     () { 0b0000 }
  sub STR      () { 0b0100 }
  sub NUM      () { 0b1000 }
  sub OBJ      () { 0b1100 }
  sub TYPE     () { 0b1100 } # only for use as a mask

  %CSS::DOM::Interface = (
  	'CSS::DOM' => 'CSSStyleSheet',
  	'CSS::DOM::StyleSheetList' => 'StyleSheetList',
  	'CSS::DOM::MediaList' => 'MediaList',
  	'CSS::DOM::RuleList' => 'CSSRuleList',
  	'CSS::DOM::Rule' => 'CSSRule',
  	'CSS::DOM::Rule::Style' => 'CSSStyleRule',
  	'CSS::DOM::Rule::Media' => 'CSSMediaRule',
  	'CSS::DOM::Rule::FontFace' => 'CSSFontFaceRule',
  	'CSS::DOM::Rule::Page' => 'CSSPageRule',
  	'CSS::DOM::Rule::Import' => 'CSSImportRule',
  	'CSS::DOM::Rule::Charset' => 'CSSCharsetRule',
  	'CSS::DOM::Rule::Unknown' => 'CSSUnknownRule',
  	'CSS::DOM::StyleDecl' => 'CSSStyleDeclaration',
  	'CSS::DOM::Value' => 'CSSValue',
  	'CSS::DOM::Value::Primitive' => 'CSSPrimitiveValue',
  	'CSS::DOM::Value::List' => 'CSSValueList',
  	'CSS::DOM::RGBColor' => 'RGBColor',
  	'CSS::DOM::Rect' => 'Rect',
  	'CSS::DOM::Counter' => 'Counter',
  	 StyleSheetList => {
		_hash => 0,
		_array => 1,
  #		length => NUM | READONLY,
  #		item => METHOD | OBJ,
  	 },
  	 MediaList => {
		_hash => 0,
		_array => 1,
  #		mediaText => STR,
  #		length => NUM | READONLY,
  #		item => METHOD | STR,
  #		deleteMedium => METHOD | VOID,
  #		appendMedium => METHOD | VOID,
  	 },
  	 CSSRuleList => {
		_hash => 0,
		_array => 1,
  		length => NUM | READONLY,
  		item => METHOD | OBJ,
  	 },
  	 CSSRule => {
		_hash => 0,
		_array => 0,
  		_constants => [qw[
  			CSS::DOM::Rule::UNKNOWN_RULE
  			CSS::DOM::Rule::STYLE_RULE
  			CSS::DOM::Rule::CHARSET_RULE
  			CSS::DOM::Rule::IMPORT_RULE
  			CSS::DOM::Rule::MEDIA_RULE
  			CSS::DOM::Rule::FONT_FACE_RULE
  			CSS::DOM::Rule::PAGE_RULE
  		]],
  #		type => NUM | READONLY,
  #		cssText => STR,
  #		parentStyleSheet => OBJ | READONLY,
  #		parentRule => OBJ | READONLY,
  	 },
  	 CSSStyleRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  #		selectorText => STR,
  		style => OBJ | READONLY,
  	 },
  	 CSSMediaRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  #		media => OBJ | READONLY,
  #		cssRules => OBJ | READONLY,
  #		long => METHOD | OBJ,
  #		deleteRule => METHOD | VOID,
  	 },
  	 CSSFontFaceRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  #		style => OBJ | READONLY,
  	 },
  	 CSSPageRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  #		selectorText => STR,
  #		style => OBJ | READONLY,
  	 },
  	 CSSImportRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  #		href => STR | READONLY,
  #		media => OBJ | READONLY,
  #		styleSheet => OBJ | READONLY,
  	 },
  	 CSSCharsetRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  #		encoding => STR,
  	 },
  	 CSSUnknownRule => {
		_isa => 'CSSRule',
		_hash => 0,
		_array => 0,
  	 },
  	 CSSStyleDeclaration => {
		_hash => 0,
		_array => 1,
  		cssText => STR,
  		getPropertyValue => METHOD | STR,
  #		getPropertyCSSValue => METHOD | OBJ,
  #		removeProperty => METHOD | STR,
  #		getPropertyPriority => METHOD | STR,
  		setProperty => METHOD | VOID,
  #		length => NUM | READONLY,
  #		item => METHOD | STR,
  		parentRule => OBJ | READONLY,
  		azimuth => STR,
  		background => STR,
  		backgroundAttachment => STR,
  		backgroundColor => STR,
  		backgroundImage => STR,
  		backgroundPosition => STR,
  		backgroundRepeat => STR,
  		border => STR,
  		borderCollapse => STR,
  		borderColor => STR,
  		borderSpacing => STR,
  		borderStyle => STR,
  		borderTop => STR,
  		borderRight => STR,
  		borderBottom => STR,
  		borderLeft => STR,
  		borderTopColor => STR,
  		borderRightColor => STR,
  		borderBottomColor => STR,
  		borderLeftColor => STR,
  		borderTopStyle => STR,
  		borderRightStyle => STR,
  		borderBottomStyle => STR,
  		borderLeftStyle => STR,
  		borderTopWidth => STR,
  		borderRightWidth => STR,
  		borderBottomWidth => STR,
  		borderLeftWidth => STR,
  		borderWidth => STR,
  		bottom => STR,
  		captionSide => STR,
  		clear => STR,
  		clip => STR,
  		color => STR,
  		content => STR,
  		counterIncrement => STR,
  		counterReset => STR,
  		cue => STR,
  		cueAfter => STR,
  		cueBefore => STR,
  		cursor => STR,
  		direction => STR,
  		display => STR,
  		elevation => STR,
  		emptyCells => STR,
  		cssFloat => STR,
  		font => STR,
  		fontFamily => STR,
  		fontSize => STR,
  		fontSizeAdjust => STR,
  		fontStretch => STR,
  		fontStyle => STR,
  		fontVariant => STR,
  		fontWeight => STR,
  		height => STR,
  		left => STR,
  		letterSpacing => STR,
  		lineHeight => STR,
  		listStyle => STR,
  		listStyleImage => STR,
  		listStylePosition => STR,
  		listStyleType => STR,
  		margin => STR,
  		marginTop => STR,
  		marginRight => STR,
  		marginBottom => STR,
  		marginLeft => STR,
  		markerOffset => STR,
  		marks => STR,
  		maxHeight => STR,
  		maxWidth => STR,
  		minHeight => STR,
  		minWidth => STR,
  		orphans => STR,
  		outline => STR,
  		outlineColor => STR,
  		outlineStyle => STR,
  		outlineWidth => STR,
  		overflow => STR,
  		padding => STR,
  		paddingTop => STR,
  		paddingRight => STR,
  		paddingBottom => STR,
  		paddingLeft => STR,
  		page => STR,
  		pageBreakAfter => STR,
  		pageBreakBefore => STR,
  		pageBreakInside => STR,
  		pause => STR,
  		pauseAfter => STR,
  		pauseBefore => STR,
  		pitch => STR,
  		pitchRange => STR,
  		playDuring => STR,
  		position => STR,
  		quotes => STR,
  		richness => STR,
  		right => STR,
  		size => STR,
  		speak => STR,
  		speakHeader => STR,
  		speakNumeral => STR,
  		speakPunctuation => STR,
  		speechRate => STR,
  		stress => STR,
  		tableLayout => STR,
  		textAlign => STR,
  		textDecoration => STR,
  		textIndent => STR,
  		textShadow => STR,
  		textTransform => STR,
  		top => STR,
  		unicodeBidi => STR,
  		verticalAlign => STR,
  		visibility => STR,
  		voiceFamily => STR,
  		volume => STR,
  		whiteSpace => STR,
  		widows => STR,
  		width => STR,
  		wordSpacing => STR,
  		zIndex => STR,
  	 },
  	 CSSValueList => {
		_isa => 'CSSValue',
		_hash => 0,
		_array => 0,
  #		length => NUM | READONLY,
  #		item => METHOD | OBJ,
  	 },
  	 RGBColor => {
		_hash => 0,
		_array => 0,
  #		red => OBJ | READONLY,
  #		green => OBJ | READONLY,
  #		blue => OBJ | READONLY,
  	 },
  	 Rect => {
		_hash => 0,
		_array => 0,
  #		top => OBJ | READONLY,
  #		right => OBJ | READONLY,
  #		bottom => OBJ | READONLY,
  #		left => OBJ | READONLY,
  	 },
  	 Counter => {
		_hash => 0,
		_array => 0,
  #		identifier => STR | READONLY,
  #		listStyle => STR | READONLY,
  #		separator => STR | READONLY,
  	 },
  	 CSSStyleSheet => {
  		type => STR | READONLY,
		_hash => 0,
		_array => 0,
  		disabled => BOOL,
  		ownerNode => OBJ | READONLY,
  		parentStyleSheet => OBJ | READONLY,
  		href => STR | READONLY,
  #		title => STR | READONLY,
  #		media => OBJ | READONLY,
  #		ownerRule => OBJ | READONLY,
  		cssRules => OBJ | READONLY,
  #		long => METHOD | OBJ,
  #		deleteRule => METHOD | VOID,
  	 },
  );

__END__

=head1 SEE ALSO

L<HTML::DOM>
