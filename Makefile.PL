BEGIN { require 5.008 } # In 5.6, sub {} means sub {@_}
use strict;
use ExtUtils::MakeMaker;

my %prq = (
	 constant                     => 1.03, # multiple at once
	 CSS                          => 1,    # object tree interface
	'CSS::Adaptor'                => 1,
	'CSS::Style'                  => 1,
	 Exporter                     => 5.57, # use Exporter 'import';
	'Scalar::Util'                => 0,
	 strict                       => 0,
	 warnings                     => 0,
# for testing only:
	'Scalar::Util'                => 1.08, # refaddr
	'Test::More'                  => 0,
);

#eval { require Hash::Util::FieldHash } or $prq{'Tie::RefHash::Weak'} = 0;


WriteMakefile(
    NAME           => 'CSS::DOM',
    AUTHOR         => 'Father Chrysostomos <sprout & cpan . org>',
    VERSION_FROM   => 'lib/CSS/DOM.pm',
    ABSTRACT_FROM  => 'lib/CSS/DOM.pm',
    PL_FILES       => {},
    PREREQ_PM      => \%prq,
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
                        TAR => 'COPYFILE_DISABLE=1 tar' },
    clean          => { FILES => 'CSS-DOM-*' },
);
