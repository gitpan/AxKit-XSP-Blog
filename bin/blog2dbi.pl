#!/usr/bin/perl

use strict;
use Data::Dumper;

use vars qw($VERSION);
$VERSION = "0.01";

=pod

=head1 NAME

blog2dbi - loading blog entries into a database

=head1 SYNOPSIS

  blog2dbi.pl <options>

  blog2dbi.pl --dsn="dbi:mysql:database=somedb;user=somename;table=blogs" --blog_uid='http://some.blogspot.com/'

=head1 DESCRIPTION

This script expects an xblog XML document on STDIN, selects the entries therein and stores them into a relational
database. (See the distribution for the DB schema.)

=head2 Options

Following options HAVE to be provided:

=over

=item --B<dsn>=I<dsn-for-the-database> (no default)

This specifies to which database to connect, including the table where to store the entries (see above).

=cut

my $dsn;

=pod

=item --B<blog_uid>=I<full-uri-of-blog> (no default)

To identify different blogs (the database may contain entries from different blog sources) we need a unique
identifier. Best is to use the URL for the blog.

=cut

my $blog_uid;

=pod

=back

=cut


use Getopt::Long;
use Pod::Usage;

my $help;
my $about;
if (!GetOptions ('help|?|man' => \$help,
                 'blog_uid=s' => \$blog_uid,
                 'dsn=s'      => \$dsn,
                 'about!'     => \$about,
                ) || $help) {
  pod2usage(-exitstatus => 0, -verbose => 2);
}


if ($about) {
  print STDOUT "blog2dbi ($VERSION)
";
  exit;
}


use IO::Handle;
my $stdin = new IO::Handle;
unless ($stdin->fdopen(fileno(STDIN),"r")) {
    die "blog2dbi: cannot open STDIN, not funny.";
}

use XML::XPath;
my $xp = XML::XPath->new (ioref => $stdin);

##warn $xp->findvalue('/xblog/head/title');

die "blog2dbi: undefined blog uid (should be unique for a blog)" unless $blog_uid;
die "blog2dbi: undefined DSN" unless $dsn;

use DBI;
my $dbh = DBI->connect($dsn);
die "blog2dbi: cannot open blog database" unless $dbh;
##warn "removing all $blog_uid";
##my $delete  = $dbh->prepare("DELETE FROM blogs WHERE remote_id LIKE '".$blog_uid."%'");
my $delete  = $dbh->prepare("DELETE FROM blogs WHERE remote_id = ?");
##$delete->execute;
my $insert  = $dbh->prepare("INSERT INTO blogs (author_name,author_email,url,title,body,published,remote_id) VALUES (?, ?, ?, ?, ?, ?, ?)");

#use HTML::Lint;
#my $lint = HTML::Lint->new;

foreach my $e ($xp->findnodes ('//entry')) {
    my $postDate = $xp->findvalue ('postDate', $e);
    use Date::Parse;
    my $date = str2time($postDate);
    if ($date) {
	use Date::Format;
	$postDate = time2str("%Y-%m-%dT%T",$date);
    } else { # keep it as it is
    }
    warn "postDate $postDate";

    my $poid = $blog_uid.'/'. ($xp->findvalue ('postid', $e) || $xp->findvalue ('@id', $e));

    warn "removing $poid";
    $delete->execute ($poid);

#    unless ($lint->errors) {
	warn "adding $poid";
	$insert->execute (
			  $xp->findvalue ('authorName', $e),
			  $xp->findvalue ('authorEmail', $e),
			  $xp->findvalue ('url', $e),
			  $xp->findvalue ('title', $e),
			  $xp->findvalue ('content', $e),
			  $postDate,
			  $poid);
#    } else {
#	warn "HTML errors in $poid";
#    }
}
$delete->finish;
$insert->finish;
$dbh->disconnect;

=pod

=head1 AUTHOR INFORMATION

Copyright 200[2], Robert Barta <rho@bond.edu.au>, All rights reserved.

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.
http://www.perl.com/perl/misc/Artistic.html

=cut

