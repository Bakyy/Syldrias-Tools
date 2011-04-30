####################################################################
# Quest Parser par Totomakers & Taris						       #
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

#######################################
my %sql;
my $ligne;
######################################Programme
print "
\t╔════════════════════════════════════════════════════════════╗
\t║       Traduction des quêtes partir de WoWhead              ║	
\t║                   By Totomakers & Taris                    ║	
\t╚════════════════════════════════════════════════════════════╝
\n";



print "
\tLe programme traduiras les quêtes dont les Id dans quest_parse_entry
\n
\n";

$sql{ 'filename' } = "locales_quest.sql";
$sql{ 'filename2' } = "quest_parse_entry.txt";

open locales_quest_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
print locales_quest_fr "/*#############################################\n";
print locales_quest_fr "#Parsing quêtes de Wowhead \n";
print locales_quest_fr "#############################################*/\n";
print locales_quest_fr "\n";
close locales_quest_fr;


open my($questId), "<", $sql{ 'filename2' } or die "Can't open $sql{ 'filename2' }!";
while ($ligne = <$questId> ) {
	
	chomp($ligne);
	my $page = get( "http://fr.wowhead.com/quest=".$ligne);
	
	#entry automatique 
	$sql{ 'entry' } = $ligne;
	print "entry : $ligne \n";
	
	#Title
	$sql{ 'Title' } = '';
	if ( $page =~/<title>(.*) - Quête - World of Warcraft<\/title>/ )
	{
		$sql{ 'Title' } = $1;
		print "Title: ".$sql{ 'Title' }." \n";
		$sql{ 'Title' } =~ s/'/\\'/g #Remplacement Guillement
	}

	#Details
	$sql{ 'Details' } = '';
	if ( $page =~/<h3>Description<\/h3>\n\n(.*)/)
	{
		$sql{ 'Details' } = $1;
		$sql{ 'Details' } =~ s/&lt;nom&gt;/\$N/g ;#Remplacement Nom par fonction MaNGOS
		$sql{ 'Details' } =~ s/&lt;classe&gt;/\$C/g ;#Remplacement Classe par fonction MaNGOS
		$sql{ 'Details' } =~ s/&lt;race&gt;/\$R/g ;#Remplacement Race par fonction MaNGOS
		if ( $sql{ 'Details' } =~ /&lt;(.*)\/(.*)&gt;/)
		{
			$sql{ 'GenderMale' } = $1;
			$sql{ 'GenderFemale' } = $2;
			$sql{ 'Details' } =~s/&lt;$sql{ 'GenderMale' }\//\$G$sql{ 'GenderMale' }:/g ;
			$sql{ 'Details' } =~s/$sql{ 'GenderFemale' }&gt;/$sql{ 'GenderFemale' }/g ;
		}
		$sql{ 'Details' } =~ s/\<br \/\>/\$B/g ;#Remplacement retour à la ligne
		$sql{ 'Details' } =~ s/'/\\'/g ;#Remplacement Guillement
	}
	
	#Objectives
	$sql{ 'Objectives' } = '';
	if ( $page =~/<\/h1>\n\n(.*)/i)
	{
		$sql{ 'Objectives' } = $1;
		$sql{ 'Objectives' } =~ s/&lt;nom&gt;/\$N/g ;#Remplacement Nom par fonction MaNGOS
		$sql{ 'Objectives' } =~ s/&lt;classe&gt;/\$C/g ;#Remplacement Classe par fonction MaNGOS
		$sql{ 'Objectives' } =~ s/&lt;race&gt;/\$R/g ;#Remplacement Race par fonction MaNGOS
		if ( $sql{ 'Objectives' } =~ /&lt;(.*)\/(.*)&gt;/)
		{
			$sql{ 'GenderMale' } = $1;
			$sql{ 'GenderFemale' } = $2;
			$sql{ 'Objectives' } =~s/&lt;$sql{ 'GenderMale' }\//\$G$sql{ 'GenderMale' }:/g ;
			$sql{ 'Objectives' } =~s/$sql{ 'GenderFemale' }&gt;/$sql{ 'GenderFemale' }/g ;
		}
		$sql{ 'Objectives' } =~ s/\<br \/\>/\$B/g;#Remplacement retour à la ligne
		$sql{ 'Objectives' } =~ s/'/\\'/g ;#Remplacement Guillement
	}

	#OfferRewardText 
	$sql{ 'OfferRewardText' } = '';
	if ( $page =~/<div id="lknlksndgg-completion" style="display: none">(.*)/i)
	{
		$sql{ 'OfferRewardText' } = $1;
		$sql{ 'OfferRewardText' } =~ s/&lt;nom&gt;/\$N/g ;#Remplacement Nom par fonction MaNGOS
		$sql{ 'OfferRewardText' } =~ s/&lt;classe&gt;/\$C/g ;#Remplacement Classe par fonction MaNGOS
		$sql{ 'OfferRewardText' } =~ s/&lt;race&gt;/\$R/g ;#Remplacement Race par fonction MaNGOS
		
		if ( $sql{ 'OfferRewardText' } =~ /&lt;(.*)\/(.*)&gt;/)
		{
			$sql{ 'GenderMale' } = $1;
			$sql{ 'GenderFemale' } = $2;
			$sql{ 'OfferRewardText' } =~s/&lt;$sql{ 'GenderMale' }\//\$G$sql{ 'GenderMale' }:/g ;
			$sql{ 'OfferRewardText' } =~s/$sql{ 'GenderFemale' }&gt;/$sql{ 'GenderFemale' }/g ;
		}
		
		$sql{ 'OfferRewardText' } =~ s/\<br \/\>/\$B/g : ;#Remplacement retour à la ligne
		$sql{ 'OfferRewardText' } =~ s/'/\\'/g ;#Remplacement Guillement
	}
	
	print "\n";
	open locales_quest_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
	
	if($sql{ 'Title' } ne '')
	{ 
		#################Check Trad#################
		if ($sql{ 'Title' } !~ /\[/)
		{
			print locales_quest_fr "UPDATE `locales_quest` SET "; 
			################Title#################
			if($sql{ 'Title' } !~ /\[/)
			{
				print locales_quest_fr "`Title_loc2` = '".$sql{ 'Title' }."' ";
			}
			#################Details#################
			if($sql{ 'Details' } ne '' && $sql{ 'Details' } !~ /\[/)
			{ 
				print locales_quest_fr ",`Details_loc2` = '".$sql{ 'Details' }."' ";
				$sql{ 'Details' } = '';
			};
			
			###############Objectives####################
			if($sql{ 'Objectives' } ne '' && $sql{ 'Objectives' } !~ /\[/)
			{ 
				print locales_quest_fr ",`Objectives_loc2` = '".$sql{ 'Objectives' }."' ";
				$sql{ 'Objectives' } = '';
			};

			###############OfferRewardText####################
			if($sql{ 'OfferRewardText' } ne '' && $sql{ 'OfferRewardText' } !~ /\[/)
			{ 
				print locales_quest_fr ",`OfferRewardText_loc2` = '".$sql{ 'OfferRewardText' }."' ";
				$sql{ 'OfferRewardText' } = '';
			};
			
			#################END SQL#################
			print locales_quest_fr "WHERE `entry` = ".$sql{ 'entry' }.";\n";
		}
	}
	close locales_quest_fr;
}

print "Parsing End\n";
sleep;