package AxKit::XSP::Blog;

$AxKit::XSP::Blogs::VERSION = 0.01;

use Apache::AxKit::Language::XSP::SimpleTaglib;

$NS = 'http://ns.it.bond.edu.au/xsp/blog/v1';

package AxKit::XSP::Blog::Handlers;

use strict;
use DBI;


=pod

=head1 NAME

AxKit::XSP::Blog - XSP taglib to include Blogs (weblogs)

=head1 DESCRIPTION

Blogs (weblogs)

  http://whatis.techtarget.com/definition/0,,sid9_gci213547,00.html

can carry diary-like information. The idea of this package is to access these
diary entries via an DBI database and expand them into an XSP page.

How these entries find their way into the database is outside the scope of this
package. (See the README in the distribution.)

=head2 XSP Tags

The package's namespace is

    http://ns.it.bond.edu.au/xsp/blog/v1

(Note: what is the I<official>?)

which implies that you have to use an appropriate namespace declaration in your
XSP files:

    <xsp:page xmlns:xsp="http://www.apache.org/1999/XSP/Core"
              ....
              xmlns:b="http://ns.it.bond.edu.au/xsp/blog/v1"
              >

Inside such an XSP page you can then use the C<blog> tag to embed weblog
data:

        <b:blog src = "dbi:mysql:database=topicmaps;user=nobody;table=blogs" />

The taglib will open a database connection, will create the blog XML representation
and will return that to the AxKit processor.

The following attributes can be used:

=over

=item I<src>: 

This will contain the DBI specification (L<DBI>). Note that the string may contain C<table=I<where_are_the_blogs>>
to change the table in which the blog entries expected. If that is missing C<blogs> is assumed.

=item I<youngest>:

This attribute allows to specify a date/time in the format YYYY-MM-DD HH:MM to control which the youngest
entry (inclusive) should be.

=item I<oldest>:

This attribute allows to specify a date/time in the format YYYY-MM-DD HH:MM to control which the oldest
entry (inclusive) should be.

=item I<limit>:

Controls how many entries should be returned.

=item I<url>, I<title>, I<description>:

Control the URL, the title or the description which will appear in the outgoing blog structure 
(see the distribution for the Blog DTD used). If one of them is missing, then C<''>, C<WebLog>, C<No description>
are the default values, respectively.

=back

Example:

    <b:blog youngest = "2002-09-25 00:00"
            oldest   = "2002-09-22 00:00"
            src      = "dbi:mysql:database=topicmaps;user=nobody;table=blogs"
            limit    = "5"
            url      = "http://www.example.com/"
            title    = "My Blog"
    />

=head2 Database Schema

The following SQL schema is used (find a .mysql file in the distribution):

    CREATE TABLE blogs (
      id int(11) NOT NULL auto_increment,
      author varchar(128) default NULL,
      author_email varchar(128) default NULL,
      url varchar(255) default NULL,
      title varchar(128) default NULL,
      body text,
      published datetime default NULL,
      fetched timestamp(14) NOT NULL,
      remote_id varchar(128) default NULL,
      KEY id (id)
    );  

=head2 Blog XML DTD

The following structure is currently used:

    <!ELEMENT xblog (head blog)>

    <!ELEMENT head  (title? url? description?)>

    <!ELEMENT blog  (day*)>

    <!ELEMENT day   (entry*)>
    <!ATTLIST day   date>

    <!ELEMENT entry (title? status? postDate? lastModified? content author_name? author_email? url?>
    <!ATTLIST entry date?
                    id>


=cut

sub blog :  attribOrChild(youngest) attribOrChild(oldest) attribOrChild(src) attribOrChild(limit) attribOrChild(title) attribOrChild(description) attribOrChild(url) struct {
    return << 'EOC';
    use Data::Dumper;
    warn "my atts $attr_youngest, $attr_oldest, $attr_src, $attr_limit";

    my $s = { 'xblog' => {
                      'head' => {
		          'title'       => $attr_title       || 'WebLog',
		          'description' => $attr_description || 'No description',
                          'url'         => $attr_url         || ''
			  },
		      }
	   };
    if ($attr_src =~ m/^dbi:/i) { # fetch from DB
	my $dbh = DBI->connect($attr_src);
	warn "AxKit::XSP::Blog: Could not open datbase '$attr_src'!" unless $dbh;

	$attr_src =~ /table=([^;]+)/;
	my $table = $1 || 'blogs';

	my $sth = $dbh->prepare('SELECT id, published, author_name, author_email, url, body, title, date_format(published,"%a, %M %D") AS day
                                     FROM '.$table.' ORDER BY published DESC');
	eval {
	    $sth->execute;
	}; if ($@) {
	    warn "AxKit::XSP::Blog: database problem ($@)";
	}

	my $day;
	my $count = 0;
	while (my $h = $sth->fetchrow_hashref) {
	    warn "found date ".$h->{day}." published ".$h->{published}. "old $attr_oldest, youg $attr_youngest";
	    next if defined $attr_oldest   && $h->{published} lt $attr_oldest;
	    next if defined $attr_youngest && $attr_youngest  lt $h->{published};
	    last if defined $attr_limit    && $count++        >= $attr_limit;
	    unless ($day->{'@date'} && $day->{'@date'} eq $h->{day}) { # we encountered an old day
		push @ {$s->{xblog}->{blog}->{day}}, $day if $day;     # append it to the day list
		$day = { '@date' => $h->{day} };
	    }
	    push @{$day->{'entry'}}, { '@id'          => $h->{id},
				       '@date'        => $h->{published},
				       'author'       => $h->{author_name},
				       'author_email' => $h->{author_email},
				       'url'          => $h->{url},
				       'body'         => $h->{body},
				       'title'        => $h->{title},
				   };
	}
	push @ {$s->{xblog}->{blog}->{day}}, $day if $day;     # append it to the day list
	$sth->finish;
	$dbh->disconnect;
    } else { # assume it is an URL
	die "AxKit::XSP::Blog: loading from file not (yet) implemented";
#	use LWP::Simple;
#	$s = get($attr_src);
#	warn "found =================$s================";
    }
    $s;
EOC
}

=pod

=head1 TODO

=over

=item include directly blog.xml files (how to do that with SimpleTagLib?)

=back

=head1 SEE ALSO

L<AxKit>, L<Apache::AxKit::Language::XSP::SimpleTaglib>, L<DBI>

=head1 AUTHOR INFORMATION

Copyright 200[2], Robert Barta <rho@bond.edu.au>, All rights reserved.

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.
http://www.perl.com/perl/misc/Artistic.html

=cut

1;

