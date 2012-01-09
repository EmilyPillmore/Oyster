package oysterfeeds;
use warnings;
use Fcntl;
use Digest::MD5;
use Algorithm::HowSimilar qw(compare);
use Exporter 'import';
use IO::File;
use Time::HiRes qw(setitimer getitimer);

our @EXPORT = qw(tolog register new_feed feed_log ars_log bbc_log cnn_log 
				slash_log hack_log toms_log npr_log get_logs timer);
				
our @logs = ("/home/emma/workspace/Oyster/oysterfeeds/arslog",
	     "/home/emma/workspace/Oyster/oysterfeeds/cnnlog",
	     "/home/emma/workspace/Oyster/oysterfeeds/bbclog",
	     "/home/emma/workspace/Oyster/oysterfeeds/slashlog",
	     "/home/emma/workspace/Oyster/oysterfeeds/hacklog",
	     "/home/emma/workspace/Oyster/oysterfeeds/tomslog",
	     "/home/emma/workspace/Oyster/oysterfeeds/nprlog");


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

sub ars_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/arslog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/arslog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/arslog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/arslog;
		fi);
}

sub bbc_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/bbclog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/bbclog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/bbclog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/bbclog;
		fi);
}

sub cnn_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/cnnlog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/cnnlog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/cnnlog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/cnnlog;
		fi);
}

sub slash_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/slashlog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/slashlog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/slashlog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/slashlog;
		fi);
}

sub hack_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/hacklog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/hacklog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/hacklog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/hacklog;
		fi);
}

sub toms_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/tomslog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/tomslog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/tomslog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/tomslog;
		fi);
}

sub npr_log {
	my $log = $_[1];
	tolog($log);
	qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/nprlog ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/nprlog;
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/nprlog;
		else
			echo '$log ' >> /home/emma/workspace/Oyster/oysterfeeds/nprlog;
		fi);
}
sub get_logs {
	my @lines;
	foreach(@logs){
	sysopen(LOG, $_, O_RDONLY);
		while(<LOG>){
			if(defined $_){
			push(@lines, $_);
			}
		}
		close LOG;
	}
	return @lines;
}

sub timer {
	setitimer(ITIMER_VIRTUAL, 600, 600);
	return &get_logs;
}