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
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/$user/$pass ]];
	   then 
		mkdir /home/emma/workspace/Oyster/oysterfeeds/$user;
		touch /home/emma/workspace/Oyster/oysterfeeds/$user/$pass;
		chmod 666 /home/emma/workspace/Oyster/oysterfeeds/$user/$pass; 
	   fi);
}


sub new_feed {
	my $user = Digest::MD5::md5_hex($_[2]);
	my $pass = Digest::MD5::md5_hex($_[3]);
	my $input = $_[4];
	qx(sudo echo '$input ' >> /home/emma/workspace/Oyster/oysterfeeds/$user/$pass);
	
}
