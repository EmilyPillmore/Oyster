package oysterfeeds;
use strict;
use warnings;

use Digest::MD5;
use Algorithm::HowSimilar qw(compare);
use Exporter 'import';
use IO::File;

our @EXPORT = qw(tolog register new_feed get);


sub tolog {
	print shift ( ) . "\n";
}

sub register {
	my $user = Digest::MD5::md5_hex($_[1]);
	my $pass = Digest::MD5::md5_hex($_[2]);
	qx(mkdir /home/emma/workspace/Oyster/oysterfeeds/$user);
	qx(touch /home/emma/workspace/Oyster/oysterfeeds/$user/$pass);
	qx(chmod 666 "/home/emma/workspace/Oyster/oysterfeeds/$user/$pass");
		
}

sub get {
	my $user = Digest::MD5::md5_hex($_[1]);
	my $pass = Digest::MD5::md5_hex($_[2]);
	my $file = "/home/emma/workspace/Oyster/oysterfeeds/$user/$pass";
	if(open(my $in, "<", $file){
		my @data = split('<feed></feed>', $io);
		foreach(@data) {
			if(defined $_){
			return $_;
			}
		}
	close $in;
	}
}
sub new_feed {
	my $user = Digest::MD5::md5_hex($_[1]);
	my $pass = Digest::MD5::md5_hex($_[2]);
	my $input = $_[3];
	my $file = "/home/emma/workspace/Oyster/oysterfeeds/$user/$pass";
	if(open(my $in, "+>", $file){
		print $in "<feed>$input</feed>";
		}
	close $io;
}
