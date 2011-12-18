package oysterfeeds;
use warnings;
use Digest::MD5;
use Algorithm::HowSimilar qw(compare);
use Exporter 'import';
use IO::File;

our @EXPORT = qw(tolog register new_feed);


sub tolog {
	print shift ( ) . "\n";
}

sub register {
	my $user = Digest::MD5::md5_hex($_[2]);
	my $pass = Digest::MD5::md5_hex($_[3]);
	qx(mkdir /home/emma/workspace/Oyster/oysterfeeds/$user);
	qx(touch /home/emma/workspace/Oyster/oysterfeeds/$user/$pass);
	qx(sudo chmod 666 /home/emma/workspace/Oyster/oysterfeeds/$user/$pass);

}


sub new_feed {
	my $user = Digest::MD5::md5_hex($_[2]);
	my $pass = Digest::MD5::md5_hex($_[3]);
	my $input = $_[4];
	qx(sudo echo '$input ' > /home/emma/workspace/Oyster/oysterfeeds/$user/$pass);
	
}
