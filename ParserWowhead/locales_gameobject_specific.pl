﻿####################################################################
# Gameobject Parser par Totomakers & Taris						   #
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
\t║       Traduction des gameobject à partir de WoWhead        ║	
\t║                   By Totomakers & Taris                    ║	
\t╚════════════════════════════════════════════════════════════╝
\n";



print "
\tLe programme parseras les entry présent dans creature_parse_entry.txt
\n
\n";

$sql{ 'filename' } = "locales_gameobject.sql";
$sql{ 'filename2' } = "gob_parse_entry.txt";

open locales_gameobject_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
print locales_gameobject_fr "/*#############################################\n";
print locales_gameobject_fr "#Parsing Gameobject de Wowhead \n";
print locales_gameobject_fr "#############################################*/\n";
print locales_gameobject_fr "\n";
close locales_gameobject_fr;

open my($creatureId), "<", $sql{ 'filename2' } or die "Can't open $sql{ 'filename2' }!";
while ($ligne = <$creatureId> ) {

	chomp($ligne);
	my $page = get( "http://fr.wowhead.com/object=".$ligne."&power");
	
	#entry automatique 
	$sql{ 'entry' } = $ligne;
	print "entry : $ligne \n";
	
	#Name
	$sql{ 'Name' } = '';
	if ( $page =~/name_frfr: '(.*)'\,/i )
	{
		$sql{ 'Name' } = $1;
		print "Name: ".$sql{ 'Name' }."\n";
		$sql{ 'Name' } =~ s/'/\'/g #Fix le caractère ' qui doit être \'
	}
	
	print "\n";
	open locales_gameobject_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
	
	if($sql{ 'Name' } ne '')
	{ 
		#################Check Trad#################
		if ($sql{ 'Name' } !~ /\[/)
		{
			print locales_gameobject_fr "UPDATE `locales_gameobject` SET "; 
			################Name#################
			if($sql{ 'Name' } !~ /\[/)
			{
				print locales_gameobject_fr "`name_loc2` = '".$sql{ 'Name' }."' ";
			}
			
			#################END SQL#################
			print locales_gameobject_fr "WHERE `entry` = ".$sql{ 'entry' }.";\n";
		}
	}
	close locales_gameobject_fr;
}

print "Parsing End\n";
sleep;