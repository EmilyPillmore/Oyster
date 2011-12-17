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
	my $user = Digest::MD5::md5_hex($_[0]);
	my $pass = Digest::MD5::md5_hex($_[1]);
	qx(mkdir /home/emma/workspace/Oyster/oysterfeeds/$user);
	qx(touch "/home/emma/workspace/Oyster/oysterfeeds/$user/$pass");
		
}

sub get {
	my $user = Digest::MD5::md5_hex($_[0]);
	my $pass = Digest::MD5::md5_hex($_[1]);
	my $io = IO::File->new("+>> /home/emma/workspace/Oyster/oysterfeeds/$user/$pass");
	if(defined $io){
		my @data = split('<feed></feed>', $io);
		foreach(@data) {
			if(defined $_){
			return $_;
			}
		}
	}
	undef $io;
}
sub new_feed {
	my $user = Digest::MD5::md5_hex($_[0]);
	my $pass = Digest::MD5::md5_hex($_[1]);
	my $input = $_[2];
	my $io = IO::File->new("+>> /home/emma/workspace/Oyster/oysterfeeds/$user/$pass");
	if(defined $io){
		print $io "<feed>$input</feed>";
		}
	undef $io;
}
