use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	      'NAME'		=> 'AxKit::XSP::Blog',
	      'VERSION_FROM'	=> 'Blog.pm', # finds $VERSION
	      'EXE_FILES'     => [ 'bin/getblog.pl', 'bin/blog2dbi.pl' ],
	      'PREREQ_PM'		=> {
		  DBI                                        => 1.21,
		  Apache::AxKit::Language::XSP::SimpleTaglib => 0.1,
		  AxKit                                      => 1.6,
		  Net::Blogger                               => 0.8.2,
		  Getopt::Long                               => 2.32,
		  Pod::Usage                                 => 1.14,
		  XML::Writer                                => 0.4,
		  IO                                         => 1.20,
		  Time::Local                                => undef,
		  Date::Format                               => 2.22,
		  IO::Handle                                 => 1.21,
		  XML::XPath                                 => 1.12,
		  
	      },
	      ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
	       (ABSTRACT_FROM => 'Blog.pm', # retrieve abstract from module
		AUTHOR     => 'Robert Barta <rho@bond.edu.au>') : ()),
	      );
