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

#######################################Variables Parsing
my $pageBegin = 1;
my $pageEnd = 3871203;
#######################################
my %sql;

######################################Programme
print "
\t╔═══════════════════════════════════════════════════════════╗
\t║       Traduction des créatures à partir de WoWhead        ║	
\t║                   By Totomakers & Taris                   ║	
\t╚═══════════════════════════════════════════════════════════╝
\n";



print "
\tLe programme traduiras les objets entre les ids $pageBegin et $pageEnd
\n
\n";

$sql{ 'filename' } = "locales_creature.sql";

open locales_creature_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
print locales_creature_fr "/*#############################################\n";
print locales_creature_fr "#Parsing Créature de Wowhead Id : $pageBegin à $pageEnd\n";
print locales_creature_fr "#############################################*/\n";
print locales_creature_fr "\n";
close locales_creature_fr;


while ( $pageBegin <= $pageEnd ) {
	my $page = get( "http://fr.wowhead.com/npc=".$pageBegin."&power");
	
	#entry automatique 
	$sql{ 'entry' } = $pageBegin;
	print "entry : $pageBegin \n";
	
	#Name
	$sql{ 'Name' } = '';
	if ( $page =~/name_frfr: '(.*)'\,/i )
	{
		$sql{ 'Name' } = $1;
		print "Name: ".$sql{ 'Name' }."\n";
		$sql{ 'Name' } =~ s/'/\\'/g #Fix le caractère ' qui doit être \'
	}
	
	#SubName
	$sql{ 'SubName' } = '';
	if ( $page =~/<\/b><\/td><\/tr><tr><td>(.*)<\/td>(.*)<\/td><\/tr><tr><td>/i )
	{
		$sql{ 'SubName' } = $1;
		print "SubName : ".$sql{ 'SubName' }."\n";
		$sql{ 'SubName' } =~ s/'/\\'/g
	}
	
	print "\n";
	open locales_creature_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
	
	if($sql{ 'Name' } ne '')################Si la créature existe#################
	{ 
		#################Check Trad#################
		if ($sql{ 'Name' } !~ /\[/ && $sql{ 'SubName' } !~ /\[/)
		{
			print locales_creature_fr "UPDATE `locales_creature` SET "; 
			################Name#################
			if($sql{ 'Name' } !~ /\[/)
			{
				print locales_creature_fr "`name_loc2` = '".$sql{ 'Name' }."' ";
			}
			#################Subname#################
			if($sql{ 'SubName' } ne '' && $sql{ 'SubName' } !~ /\[/)
			{ 
				print locales_creature_fr ",`description_loc2` = '".$sql{ 'SubName' }."' ";
				$sql{ 'SubName' } = '';
			};
			
			#################END SQL#################
			print locales_creature_fr "WHERE `entry` = ".$sql{ 'entry' }.";\n";
		}
	}
	close locales_creature_fr;

	if ($pageBegin == $pageEnd)
	{
		print "Parsing End\n";
	}
	
	$pageBegin++;
}

sleep;