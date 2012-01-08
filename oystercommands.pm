package oystercommands;

use warnings;

use Switch;
use XML::Simple;
use LWP::Simple;
use HTML::Entities;
use Encode;
use Exporter 'import';

our @EXPORT = qw(bbc hacking ars npr slashdot queerty 
				cnn sexy sputnik toms get_feeds);

sub get_feeds {
	my $user = Digest::MD5::md5_hex($_[2]);
	my $pass = Digest::MD5::md5_hex($_[3]);
	my $file = "/home/emma/workspace/Oyster/oysterfeeds/$user/$pass";
	my @lines;
	sysopen(MYFILE, $file, O_RDONLY);
	while(<MYFILE>){
		push(@lines, $_);
	}
	return @lines;
	close MYFILE;
}

sub bbc {
	my $rss = get('http://newsrss.bbc.co.uk/rss/newsonline_uk_edition/technology/rss.xml');
	my $rssd = Encode::decode_utf8($rss);
	my $xml = XMLin($rssd);
	return $xml;	
}
sub hacking {
	my $rss = get('http://news.ycombinator.com/bigrss');
	$rssd = Encode::encode("utf8", $rssd);
	my $xml = XMLin($rss);
	return $xml;
}
sub toms {
	my $rss = get('http://www.tomshardware.com/feeds/rss2/tom-s-hardware-us,18-2.xml');
	$rssd = Encode::encode("utf8", $rssd);
	my $xml = XMLin($rss);
	return $xml;
}
sub cnn {
	my $rss = get('http://rss.cnn.com/rss/cnn_world.rss');
	my $rssd = Encode::decode_utf8($rss);
	my $xml = XMLin($rssd);
	return $xml;
}
sub npr {
	my $rss = get('http://www.npr.org/rss/rss.php?id=1001');
	my $rssd = Encode::encode("utf8", $rss);
	my $xml = XMLin($rssd);
	return $xml;
}
sub sexy {
	my $rss = get('http://camillecrimson.com/blog/feed/');
	my $rssd = Encode::decode_utf8($rss);
	my $xml = XMLin($rssd);
	return $xml;
}
sub sputnik {
	my $rss = get('http://feeds.feedburner.com/SputnikmusicNews');
	my $rssd = Encode::encode("utf8", $rss);
	my $xml = XMLin($rssd);
	return $xml;
}
sub ars {
	my $rss = get('http://feeds.arstechnica.com/arstechnica/index?format=xml');
	my $rssd = Encode::encode("utf8", $rss);
	my $xml = XMLin($rssd);
	return $xml;
}
sub slashdot {
	my $rss = get('http://pipes.yahoo.com/pipes/pipe.run?_id=77cb5ca692815f096364cc4f98e3244a&_render=rss');
	my $rssd = Encode::decode_utf8($rss);
	my $xml = XMLin($rssd);
	return $xml;
}
sub queerty {
	my $rss = get('http://feeds.feedburner.com/queerty2');
	my $rssd = Encode::encode("utf8", $rss);
	my $xml = XMLin($rssd);
	return $xml;
}1