#Your mother's favorite strict
use warnings;
use Socket;
use Data::Dumper;
use Digest::MD5;
use threads;
use Encode;

#IRC module
use POE qw(Component::IRC
			Component::IRC::Plugin::Connector
			Component::IRC::Plugin::CTCP
			Component::IRC::Plugin::NickReclaim
			Component::SSLify);
#RSS get module
use LWP::Simple;
use XML::Simple;
use HTML::Entities;
use WWW::Shorten::TinyURL;
use Encode;

#Internal modules
tolog("Loading oysterfeeds...");
use oysterfeeds;
tolog("Loading oystercommands...");
use oystercommands;
tolog("Loading oystergtk...");

#Daemon set
exit if fork;

#Version & deaths
my $version = "1.0 beta RSSfeed/Epic Trollbot";
my @diecpu = ('car crash', 'aids collision', 'plane crash', 'boat accident', 'pit full of snakes');
my %connections;
#Kill children >:C
$SIG {CHLD} = "IGNORE";

#Load user Feeds
tolog("Loading userFeeds");

tolog("Connecting...");

#Threaded Init()

threads->create(init());
exit;

#IRC initialization
sub init {
	
	my $irc_server = "storm.psych0tik.net";
	my $irc_port = 6697;
	my $irc_nick = "Oyster";
	my $irc_name = "Oyster";
	my $irc_username = "Oyster";
	my @irc_channels = {'#hbh-news', '#hbh'};
			
		#CONNDEF
		my $conn = POE::Component::IRC->spawn(
			server=> $irc_server,
			port => $irc_port,
			nick => $irc_nick,
			ircname => $irc_name,
			UseSSL => "true",			
			Username => $irc_username) or die "ERROR: This should not have happened: $!\n";
			
		#plugins
		#CTCP autoresponder
		$conn->plugin_add( 'CTCP' => POE::Component::IRC::Plugin::CTCP->new(
			version => $irc_name,
			userinfo => $irc_name));
			
			
		# Nick reclaimer
		$conn -> plugin_add ( 'NickReclaim' => POE::Component::IRC::Plugin::NickReclaim -> new( 
			poll => 30 ) 
		);
		
		# Connection keeper
		$conn -> plugin_add ( 'Connector' => POE::Component::IRC::Plugin::Connector -> new ( ) );

		# Copy parms to conn for later reference
		$conn -> {SERVER} = $irc_server;
		$conn -> {PORT} = $irc_port;
		$conn -> {NICK} = $irc_nick;
		$conn -> {NAME} = $irc_name;
		$conn -> {USERNAME} = $irc_username;
		#$conn -> {MTK_CHANNELS} = @irc_channels;
		#heap based channel joining is unecessary, but i'd like to add this implementation.
		$conn -> {SELF} = $conn;
		$conn -> {CONN_HASH} = %connections;
		$conn -> {LOCAL_ADDR} = "Localhost";
		# Plugin settings for each channel.

		# FYI
		tolog ( "STARTUP: Creating $irc_server connection object..." );
		POE::Session -> create(
			package_states => [
				'main' => [ qw( 
						_start
						irc_001
						irc_public
						irc_msg
						irc_340
					) ],
			],
			heap => { irc => $conn },
		);
	

	# IRC is GO!
	tolog ( "STARTUP: IRC starting." );

	# POE is GO!
	$poe_kernel -> run();
}
	
######### EVENT HANDLERS BELOW THIS LINE

# Called whenever a connection starts.
sub _start {
	my ( $kernel, $heap ) = @_[KERNEL,HEAP];

	# Connect (finally!)
	my $irc_session = $heap -> {irc} -> session_id();
	$kernel -> post ( $irc_session => register => 'all' );
	tolog ( "STARTUP: Connecting to " . $heap -> {irc} -> {SERVER} . "..." );
	$kernel -> post ( $irc_session => connect => { } );
	return ( undef );
}

# Happens on connect
sub irc_001 {
	my ($kernel,$sender) = @_[KERNEL,SENDER];
	my $irc = $sender -> get_heap ( );

	tolog ( "STARTUP: Connected to " . $irc -> {SERVER} );

	if ( $irc -> {LOCAL_ADDR} eq "auto" ) {
		# Get local ip
		tolog ( "STARTUP: Getting IP from sever." );
		# Get address from irc server
		$kernel -> post( $sender => quote => "USERIP " . $irc -> {NICK} );
	}
	
	# Join some channels.
		
		tolog ( "STARTUP: Joining: #hbh" );
		$kernel -> post( $sender => join => '#hbh' );
		tolog ( "STARTUP: Joining: #hbh-news" );
		$kernel -> post( $sender => join => '#hbh-news' );
}

# Recieved public message
sub irc_public {
	my ( $kernel, $heap, $sender, $speaker, $rspto, $message ) 
		= @_[KERNEL,HEAP,SENDER,ARG0,ARG1,ARG2];
	irc_any_message ( $kernel, $heap, $sender, $speaker, $rspto, $message, 0 );
	
}

# /msg recieved, fiddles a little with rspto
sub irc_msg {
	my ( $kernel, $heap, $sender, $rspto, $ignore_me, $message ) 
		= @_[KERNEL,HEAP,SENDER,ARG0,ARG1,ARG2];
	my $rspto_arr = [ ( split /!/, $rspto ) [ 0 ] ];
	irc_any_message ( $kernel, $heap, $sender, $rspto, $rspto_arr, $message, 1 ); 
}

# Recieved ANY message
sub irc_any_message { 
	my ( $kernel, $heap, $sender, $speaker, $rspto, $message, $private ) = @_;
	my $irc = $sender -> get_heap ( );

	my $rspsimple = @{ $rspto } [ 0 ];
	my $sndsimple = ( split /!/, $speaker ) [ 0 ];
	
	# Addressed?
	my $addressed = 0;
	my $mynick = $irc->{NICK};
	if ( $message =~ /^(\@$mynick|\@$mynick:|$mynick:)(\s*)(.*)/i ) {
		$message = $3;
		$addressed = 1;
	}

	# Private messages are sorta "adressed"
	if ( $private ) {
		$addressed = 1;
	}
	
	# Command section        
	# UTILITIES
	
	if($message =~ /^\!version/){
		$irc->yield('privmsg' => $rspto => "v$version");
	}
	elsif ($message =~ /^\!reconnect/) {
        	$irc->yield(privmsg => $rspto => 'Reconnecting...');
        	$irc->yield(quit =>); #Disconnect from the server.
        	&_start; #Reconnect by rerunning &_start.
    	}
	elsif($message =~ /^\!help/){
		$irc->yield('privmsg' =>$sndsimple => "Command list for Oyster v$version");
		$irc->yield('privmsg' =>$sndsimple => "!heyya, !cough, !chillout, !molest, !stfu, !fuck_CPUkiller, !dickbutt");
		$irc->yield('privmsg' =>$sndsimple => "Feeds include: !bbc, !ars, !toms, !cnn, !hacking, !slashdot, !sexy, !queer, !sputnik,  the!npr.");
		$irc->yield('privmsg' =>$sndsimple => "!feed - Usage: !feed <rss feed>");
		$irc->yield('privmsg' =>$sndsimple => "!get_feeds - Usage: !get_feeds <user> <pass>");
		$irc->yield('privmsg' =>$sndsimple => "!new_feed - Usage: !new_feed <user> <pass> <rssfeed>");
		$irc->yield('privmsg' =>$sndsimple => "!register - Usage: !register <username> <pass>");
		$irc->yield('privmsg' =>$sndsimple => "All passwords are hashed upon entry into register. Please do not give yours out!");
	}
	elsif($message =~ /^\!quit/){
		
		if ($sndsimple eq "Arabian") {
		$irc->yield(quit =>);
		$irc->yield(unregister => 'all'); 
		exit 0;
		}
		else { $irc->yield('privmsg' => $rspto=> "$sndsimple: no, u");
			$irc->yield('privmsg' => $rspto => "$sndsimple: http://www.youtube.com/watch?v=6GggY4TEYbk");
		
		};
	}
	elsif($message =~ /^\!cough/){
    	$irc->yield('privmsg' => $rspto => "*grabs cough's sac.*");
    	$irc->yield('privmsg' => $rspto => "cough for me boy. >:C");
	}
    elsif($message =~ /^\!chillout/){
    	my $recv = (split(' ', $message))[1];
    	if(defined $recv){
    		$irc->yield('privmsg' => $rspto => "$recv: chillout dawg, think about CPUkiller in a $diecpu[rand($#diecpu + 1)] :P");
		}
    	else {
    		$irc->yield('privmsg' => $rspto => "$sndsimple: chillout dawg, think about CPUkiller in a $diecpu[rand($#diecpu + 1)] :P");	
       }
    }
    elsif($message =~ /^\!snake/){
    	my $recv = (split(' ',$message))[1];
    	if(defined $recv && ($recv ne "Oyster" || $recv ne "Arabian" || $recv ne "Spyware")){
    		$irc->yield('privmsg' => $rspto => "$recv: snake? SNAKE!? SNAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKE!!!!");
    		$irc->yield('privmsg' => $rspto => "$recv: http://www.youtube.com/watch?v=K8uLT_EIJjs");
		}
		else {
			$irc->yield('privmsg' => $rspto => "$sndsimple: snake? SNAKE!? SNAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAKE!!!!");
    		$irc->yield('privmsg' => $rspto => "$sndsimple: http://www.youtube.com/watch?v=K8uLT_EIJjs");
		}
    }
    elsif($message =~ /^\!heyya/){
		$irc->yield('privmsg' => $rspto => "$sndsimple: http://www.youtube.com/watch?v=6GggY4TEYbk");
		
	}
	elsif($message =~ /^\!version/){
		$irc->yield('privmsg' => $rspto => "$sndsimple: v$version");
		
	}
	elsif($message =~ /^\!dickbutt/){
		$irc->yield('privmsg' => $rspto => "$sndsimple: frosted butts.");
		
	}
	elsif($message =~ /^\!stfu/){
		@speak = split(' ', $message);
		$recv = $speak[1];
		if($recv eq "Oyster" || $recv eq "Arabian"){
			$irc->yield('privmsg' => $rspto=> "$sndsimple: no, u");
			$irc->yield('privmsg' => $rspto => "$sndsimple: http://www.youtube.com/watch?v=6GggY4TEYbk");
		}
		else {
		chomp($recv);	
		$irc->yield('privmsg' => $rspto => "$recv: SHUT YOUR WHORE MOUTH. >:C");
		}
		
	}
	elsif($message =~ /^\!fuck_CPUkiller/){
			$irc->yield('privmsg' => $rspto => "CPUkiller: NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER NIGGER http://www.youtube.com/watch?v=6GggY4TEYbk");		
		
	}

    elsif($message =~ /^\!molest/){
		@lol = split(' ', $message);
		@speaker = split('!', $speaker);
		$speaker = $speaker[0];
		my $recv = $lol[1];
		$irc->yield('privmsg' => $rspto => "$speaker molests $recv so thoroughly it leaves him simultaneously traumatized, and unnervingly begging for moooooooorre.");
	}
	elsif($message =~/^Thanks?\s?you,?\s*Oyster/i){
		$irc->yield('privmsg' => $rspto => "You're welcome, $sndsimple :)");
	}
	elsif($message =~/(hello|hi|heya|hej|hey|hiya|hoi)+ oyster/i){
		
		$irc->yield('privmsg' => $rspto => "Hello, $sndsimple :)");
	}
    	
    ####RSS FEEDS####
    
	elsif($message =~ /^\!bbc/){
		my $xml = oystercommands->bbc();
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto  => "[Bbc] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
	}
	elsif($message =~ /^\!ars/){
		my $xml = oystercommands->ars();		
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto  => "[Ars-Tech] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
	}
	elsif($message =~ /^\!slashdot/){
		my $xml = oystercommands->slashdot();		
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto  => "[/.] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
       }
	}
	elsif($message =~ /^\!cnn/){
		my $xml = oystercommands->cnn();
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto => "[Cnn] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
	}
	elsif($message =~ /^\!sputnik/){
		my $xml = oystercommands->sputnik();
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto => "[Sputnik] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
	}
	elsif($message =~ /^\!sexy/){
		my $xml = oystercommands->sexy();		
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto => "[Sexy] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
	}
	elsif($message =~ /^\!hacking/){
		my $xml = oystercommands->hacking();
		while(defined $xml){		
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto => "[Ycomb] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
		}
		}
	}
	elsif($message =~ /^\!queerty/){
		my $xml = oystercommands->queerty();
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto => "[Queerty] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
		
	}
	elsif($message =~ /^\!npr/){
		my $xml = oystercommands->npr();
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $rspto => "[Npr] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));
        }
	}
	elsif($message =~ /^\!toms/){
		my $xml = oystercommands->toms();
		for(my $i=0; $i<3; $i++){
		$irc->yield('privmsg' => $rspto => "[Tom's] $xml->{channel}->{item}->[$i]->{title} - ". &makeashorterlink(($xml->{channel}->{item}->[$i]->{link})));	
		}
	}
	elsif($message =~ /^\!feed/){
		my $url = (split(' ', $message))[1];
		my $rss = get('$url');
		my $rssd = Encode::encode("utf8", $rss);
		if(defined $rssd){
		my $xml = XMLin($rssd);
		
		for(my $i=0; $i<3; $i++){
        $irc->yield('privmsg' => $sndsimple => "[Title] $xml->{channel}->{item}->[$i]->{title} - ".&makeashorterlink($xml->{channel}->{item}->[$i]->{link}));
        }
	}	
	else{
		$irc->yield('privmsg' => $rspto => "$sndsimple: Either you suck at typing, or the XML is malformed.");
		}
	}
	
	# User Feed Commands
	
	elsif($message =~ /^\!register/){
		my @args = split(' ', $message);
		if(defined $args[2]){
			oysterfeeds->register(@args);
			$irc->yield('privmsg' => $rspto => "$sndsimple: Registration successful, $sndsimple!");
			}
		else {
			$irc->yield('privmsg' => $rspto => "$sndsimple: More parameters required!");
		}
	}
	elsif($message =~ /^\!get_feeds/){
		my @args = split(' ', $message);
		if(defined $args[2]){
		my @xml = oystercommands->get_feeds(@args);
		for(my $i = 0; $i < @xml; $i++){
			my $rss = get("$xml[$i]"); 
			my $rssd = Encode::encode("utf8", $rss);
			my $retval = XMLin($rssd);
			
			for(my $i = 0;$i < 4; $i++){
				$irc->yield('privmsg' => $sndsimple => "$sndsimple: [Title] $retval->{channel}->{item}->[$i]->{title} - ".&makeashorterlink($retval->{channel}->{item}->[$i]->{link}));
			}}
		}
		else {
			$irc->yield('privmsg' => $sndsimple => "$sndsimple: More parameters required!");
		}
	}
    
	elsif($message =~ /^\!new_feed/){
		my @args = split(' ', $message);
		if(defined $args[2]){
			oysterfeeds->new_feed(@args);
			$irc->yield('privmsg' => $rspto => "$sndsimple: new feed successfully added!");
		}
		else {
			$irc->yield('privmsg' => $rspto => "$sndsimple: More parameters required!");
		}	
	}
}
sub irc_340 {
	my ( $kernel, $heap, $sender,$arg1 ) 
		= @_[KERNEL,HEAP,SENDER,ARG1];
	my $irc = $sender -> get_heap ( );
	$irc -> {MTK_ACTUALADDR} = ( ( $arg1 =~ /@(.*)/ ) [ 0 ] );
	tolog ( "GENERAL: New IP recieved ( $arg1 ) => " . $irc -> {MTK_ACTUALADDR} );

}