package oysterfeeds; #Do NOT use strict while using Fcntl and IO::file.
use warnings;
use Fcntl;
use Digest::MD5;
use Exporter 'import';
use IO::File;
use Time::HiRes qw(setitimer getitimer);

our @EXPORT = qw(tolog register new_feed feed_log get_logs timer);
 
#Array of log file absolute paths
our @logs = ("/home/emma/workspace/Oyster/oysterfeeds/arslog",
				"/home/emma/workspace/Oyster/oysterfeeds/cnn.log",
				"/home/emma/workspace/Oyster/oysterfeeds/bbc.log",
				"/home/emma/workspace/Oyster/oysterfeeds/slash.log",
				"/home/emma/workspace/Oyster/oysterfeeds/hack.log",
				"/home/emma/workspace/Oyster/oysterfeeds/toms.log",
				"/home/emma/workspace/Oyster/oysterfeeds/npr.log");

#Simple console output subroutine
sub tolog {
	print shift ( ) . "\n";
}

#User Registration function
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

#User-specific feed parsing to be used in conjunction with registration function
sub new_feed {
	my $user = Digest::MD5::md5_hex($_[2]);
	my $pass = Digest::MD5::md5_hex($_[3]);
	my $input = $_[4];
	qx(sudo echo '$input ' >> /home/emma/workspace/Oyster/oysterfeeds/$user/$pass);
	
}

#parse log files and return an array of most recent titles for XML feeds
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

#Add most recent title to log for that feed for update function
sub feed_log(\$\$) {
		qx(if [[ ! -f /home/emma/workspace/Oyster/oysterfeeds/$_[1].log ]];
		then 
			touch /home/emma/workspace/Oyster/oysterfeeds/$_[1].log;
			echo '$_[2] ' > /home/emma/workspace/Oyster/oysterfeeds/$_[1].log;
		else
			echo '$_[2] ' > /home/emma/workspace/Oyster/oysterfeeds/$_[1].log;
		fi);
}

#in progress for Auto-updated feeds along with Get_logs
sub timer {
	setitimer(ITIMER_VIRTUAL, 600, 600);
	return &get_logs;
}