#!/usr/bin/perl

use strict;
use Data::Dumper;
use Net::Blogger;

use vars qw($VERSION);
$VERSION = "0.01";

=pod

=head1 NAME

getblog - fetching XML-RPC based weblogs

=head1 SYNOPSIS

  getblog.pl <options> | xmllint --format -

  getblog.pl --Username=someuser --Password=cekrat  --Proxy='http://plant.blogger.com/api/RPC2' --blogname='blog name' > save.xblog

=head1 DESCRIPTION

This script takes the options to contact a weblog server via XML-RPC. It will
download the last entries and will create an XML document on STDOUT.

As this script is based on Net::Blogger, it supports the same engines mentioned
there.

=head2 Options

Following options are understood:

=over

=item --B<Username>=I<username> (no default)

If the user name is necessary to get access to the weblog you can set it.

=cut

my $Username;

=pod

=item --B<Password>=I<password> (no default)

Here you can set the password for the user name.

=cut

my $Password;

=pod

=item --B<AppKey>=I<appkey> (default: DDA6B2B7721C8B11DA4E6388CC0287CB0F33F2EB)

The application has usurped one key. You can override this if you own another key.

=cut

my $AppKey = 'DDA6B2B7721C8B11DA4E6388CC0287CB0F33F2EB';

=pod

=item --B<debug> (default: off)

If set, there will be some debugging info on STDOUT. This means that the output is not
any longer ONE XML document.

=cut

my $debug = 0;

=pod

=item --B<Proxy>=I<xml-rpc-proxy> (no default)

This is used to specify the XML-RPC proxy on the server there (this is NOT your HTTP_PROXY).

=cut

my $Proxy;

=pod

=item --B<blogid>=I<id> (no default)

To specify your particular blog you can either use the id or the name (see I<blogname> option).

=cut

my $blogid;

=pod

=item --B<blogname>=I<blogname> (no default)

If this option is provided a request against the server will be used to determine the id
of the blog for this particular user.

=cut

my $blogname;

=pod

=item --B<nrposts>=I<integer> (default: 20)

Here you can control how many entries should be downloaded.

=cut

my $nrposts = 20;

=back

=cut

use Getopt::Long;
use Pod::Usage;

my $help;
my $about;
if (!GetOptions ('help|?|man' => \$help,
                 'Username=s' => \$Username,
                 'Password=s' => \$Password,
		 'AppKey=s'   => \$AppKey,
		 'debug!'     => \$debug,
		 'Proxy=s'    => \$Proxy,
		 'blogid=s'   => \$blogid,
		 'blogname=s' => \$blogname,
		 'nrposts=i'  => \$nrposts,
                 'about!'     => \$about,
                ) || $help) {
  pod2usage(-exitstatus => 0, -verbose => 2);
}


if ($about) {
  print STDOUT "getblog ($VERSION)
";
  exit;
}


my $blogger = Net::Blogger->new (debug => $debug);

$blogger->Proxy    ($Proxy)    if $Proxy;
$blogger->Username ($Username) if $Username;
$blogger->Password ($Password) if $Password;
$blogger->AppKey   ($AppKey);

if ($blogname && $blogid) {
  warn "getblog: Ignoring the blog name, using the id only.";
} elsif ($blogname) {
  $blogid = $blogger->GetBlogId(blogname => $blogname);
  $blogger->BlogId($blogid);
} elsif ($blogid) {  # I am happy with that
  $blogger->BlogId($blogid);
} else {
  die "getblog: You have to provide either the id or a name of the blog";
}

##my $blogid = '3799973';
##my $log_url = 'http://drrho.blogspot.com';

##warn Dumper ($blogger->getUsersBlogs());

#$VAR1 = [
#	 {
#            'lastPublished' => '20020923T03:07:31',
#            'url' => 'http://drrho.blogspot.com',
#            'blogid' => '3799973',
#            'isAdmin' => '1',
#            'blogName' => 'rho test',
#            'showTitle' => '0'
#	    }
#	 ];

#warn "error". $blogger->LastError();



#warn "id '$id'";


my ($ok,@p) = $blogger->getRecentPosts(numposts => $nrposts);


#$VAR1 = {
#          'userid' => '884230',
#          'title' => '',
#          'status' => '1',
#          'postDate' => '20020921T23:27:58',
#          'lastModified' => '20020922T07:48:03',
#          'content' => 'and a second post',
#          'dateCreated' => '20020921T23:27:58',
#          'postid' => '81911053',
#          'authorName' => 'Robert Barta'
#	  };

my $blog_uid = $blogger->Proxy.'/'.$blogid;

use XML::Writer;
use IO;

my $writer = new XML::Writer();

$writer->startTag("xblog");
$writer->startTag('head');

# we cannot know everything
#my $title = 'No Title';
#my $desc  = 'This blog is a community effort covering news and thoughts on Topic Map technology and advances.';
#my $url   = 'http://topicmaps.it.bond.edu.au/';

$writer->dataElement('title', $blogname) if $blogname;
#$writer->dataElement('url',   $url);
#$writer->dataElement('description', $desc);
$writer->endTag('head');

$writer->startTag('blog');

my $currentday;
foreach my $p (@p) {
  $p->{postDate} =~ s/(\d{4})(\d{2})(\d{2})T/$1-$2-$3 /;
  use Time::Local;
  use Date::Format;
  my $day = time2str("%a, %B %o",timelocal(0,0,0,$3,$2-1,$1));
  if ($day ne $currentday) {
    $writer->endTag('day') if $currentday;
    
    $writer->startTag('day', date => $day);
    $currentday = $day;
  }
  
  my $poid = $blog_uid.'/'.$p->{postid};
  
  $writer->startTag('entry', date => $p->{postDate}, id => $p->{postid});
  foreach my $q (qw(title status postDate lastModified content dateCreated authorName)) {
    $writer->dataElement ($q, $p->{$q});
  }
  
  $writer->endTag('entry');
  
}
$writer->endTag('day') if $currentday;

$writer->endTag('blog');

$writer->endTag("xblog");
$writer->end();

exit;

=pod

=head1 AUTHOR INFORMATION

Copyright 200[2], Robert Barta <rho@bond.edu.au>, All rights reserved.

This library is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.
http://www.perl.com/perl/misc/Artistic.html

=cut

__END__



