package oysterfeeds;
use strict;
use warnings;

use Digest::MD5;
use Algorithm::HowSimilar qw(compare);
use Exporter 'import';

our @EXPORT = qw(tolog register new_feed);


sub tolog {
	print shift ( ) . "\n";
}

sub register {
	
	sub register {
	my $user = Digest::MD5::md5_hex($_[0]);
	my $pass = Digest::MD5::md5_hex($_[1]);
	qx(mkdir /home/emma/workspace/Oyster/oysterfeeds/$user);
	qx(touch "/home/emma/workspace/Oyster/oysterfeeds/$user/$pass");
		
	}
}

sub new_feed {
	return 0;
}
