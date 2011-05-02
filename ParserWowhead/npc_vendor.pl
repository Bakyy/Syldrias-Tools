####################################################################
# Creature Parser par Totomakers & Taris						   #
# this script working with perl/Activeperl		  				   #
####################################################################
use CGI;
use strict;
use warnings;
use Carp;
use LWP::Simple;
use open OUT => ':utf8';

#######################################
#			Debug accent			  #

use encoding qw[utf8];

sub ActiverAccentDOS {
  my ($codepage) = ( `chcp` =~ m/:\s+(\d+)/ );
  foreach my $h ( \*STDOUT, \*STDERR, \*STDIN ) {
    binmode $h, ":encoding(cp$codepage)";
  }
}

ActiverAccentDOS();
#######################################
my $ligne;

#######################################
my %sql;
######################################Programme
print "
\t╔════════════════════════════════════════════════════════════╗
\t║               Vendeur liste partir de WoWhead              ║	
\t║                   By Totomakers & Taris                    ║	
\t╚════════════════════════════════════════════════════════════╝
\n";

print "\tLe programme utilise npc_vendor_entry.txt.
\n
\n";

$sql{ 'filename' } = "npc_vendor.sql";
$sql{ 'filename2' } = "npc_vendor_entry.txt";

open npc_vendor_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
print npc_vendor_fr "/*#############################################\n";
print npc_vendor_fr "#Parsing des Vendeurs par WoWHead \n";
print npc_vendor_fr "#############################################*/\n";
print npc_vendor_fr "\n";
close npc_vendor_fr;


open my($vendor), "<", $sql{ 'filename2' } or die "Can't open $sql{ 'filename2' }!";

while ($ligne = <$vendor> ) {

	chomp($ligne);
	my $page = get( "http://fr.wowhead.com/npc=".$ligne);
	
	#entry automatique 
	$sql{ 'entry' } = $ligne;
	print "Vendor entry : $ligne \n";
	
	$sql{ 'ItemId' } = '';
	open npc_vendor_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
	if($page =~/id: 'sells',(.*)}]}/)
	{
		$page = $1;
		
		#Entete SQL
		print npc_vendor_fr "UPDATE `creature_template` SET `npcflag`=`npcflag`|128 WHERE `entry` = ".$ligne."";
		print npc_vendor_fr "INSERT IGNORE INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`) VALUES ";
		while($page =~/"id":([0-9]*),"level":([0-9]*),(.*)/i )
		{
			#Ecriture dans la console
			$sql{ 'ItemId' } = $1;
			print "ItemId: ".$sql{ 'ItemId' }."\n";
		
			#Ecriture dans le SQL
			print npc_vendor_fr "\n";
			print npc_vendor_fr "(".$sql{ 'entry' }.", 0, ".$sql{ 'ItemId' }.", 0, 0, 0)";
			
			$page = $3;
			($page =~/"id":([0-9]*),"level":([0-9]*),(.*)/i) ? print npc_vendor_fr ","  : print npc_vendor_fr ";" ; 
		}
		print npc_vendor_fr "\n \n";
		print "\n";
	}
	close npc_vendor_fr;
}

print "Parsing End\n";
sleep;