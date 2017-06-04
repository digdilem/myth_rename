#!/usr/bin/perl
#
# myth renamer, simple and after the original was broken by the narrow-minded developers who don't like you reading the file system directly.
# By Simon Avery
#
# v.2 - 08/07/2010 - Added escaping for /\ in subtitle.
# v.3 - 31/07/2010 - Added more escaping for ' and ` in program name

use DBI; # For db
#
my $dbh; # Global mysql handle
my $dsn = "DBI:mysql:database=mythconverg;host=localhost";
my $mysql_username = 'mythtv';
my $mysql_password = 'mythtv';

my $tv_path = '/data/tv';
my $idle_time = 100; # Seconds since file was last modified to test whether still being recorded.

# first, step through tv_path and look for anything that's named in a recorded format

opendir(my $dh, $tv_path) || die("Can't open tv_path: $tv_path\n");
eval { $dbh = DBI->connect($dsn, $mysql_username, $mysql_password) };
$dbh->{mysql_auto_reconnect} = 1;
if ($@) { print "Connection to mysql db failed: $@"; exit 1; }

#print "reading dir: $tv_path\n";
while(my $file = readdir $dh) {
	next unless (-f "$tv_path/$file");
	if ( ($file =~ /\d{5,}.mpg$/) || ($file =~ /\d{5,}.ts$/) ) {

		# Check if it's still being updated.
		my $lasttime = (stat ("$tv_path/$file"))[9];


		my $difftime = time() - $lasttime;
		if ($difftime <= $idle_time) {
			print "================== File $file still being written, ignoring.\n";
			next;
			}

		my $sql = "SELECT * FROM `mythconverg`.`recorded` WHERE `basename` = '$file' LIMIT 1";
		our $sth = $dbh->prepare($sql);
		$sth->execute();
		while (my $a = $sth->fetchrow_hashref) {
			my $starttime = $a->{'starttime'};
			$starttime =~ s/\-//g;
			$starttime =~ s/\://g;
			$starttime =~ s/\ //g;
			my $subtit = sprintf("%.30s",$a->{'subtitle'});

			my $newfilename = $a->{'title'} . "_" . $starttime . "_" . $subtit . ".mpg";

			# convert spaces to underscores
			$newfilename =~ s/ /_/g;
			$newfilename =~ s/\:/_/g;
			$newfilename =~ s/\?/_/g;
			$newfilename =~ s/\!/_/g;

			$newfilename =~ s/\///g;
			$newfilename =~ s/\\//g;
			$newfilename =~ s/\'//g;
			$newfilename =~ s/\`//g;

			print "New filename: $newfilename\n";
			# Update database with new filename
			my $safe_newfilename = $dbh->quote($newfilename);

			# Rename file on filesystem
			rename("$tv_path/$file", "$tv_path/$newfilename") or die("Error renaming $tv_path/$file to $tv_path/$newfilename : $!\n");
			}
		}
	}

closedir $dh;

