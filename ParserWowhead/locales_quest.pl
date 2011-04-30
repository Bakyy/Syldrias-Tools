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

#######################################Variables Parsing
my $pageBegin = 1;
my $pageEnd = 10000000000;
#######################################
my %sql;

######################################Programme
print "
\t╔════════════════════════════════════════════════════════════╗
\t║       Traduction des quêtes partir de WoWhead              ║	
\t║                   By Totomakers & Taris                    ║	
\t╚════════════════════════════════════════════════════════════╝
\n";



print "
\tLe programme traduiras les quêtes entre les ids $pageBegin et $pageEnd
\n
\n";

$sql{ 'filename' } = "locales_quest.sql";

open locales_quest_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
print locales_quest_fr "/*#############################################\n";
print locales_quest_fr "#Parsing quêtes de Wowhead Id : $pageBegin à $pageEnd\n";
print locales_quest_fr "#############################################*/\n";
print locales_quest_fr "\n";
close locales_quest_fr;


while ( $pageBegin <= $pageEnd ) {
	my $page = get( "http://fr.wowhead.com/quest=".$pageBegin);
	
	#entry automatique 
	$sql{ 'entry' } = $pageBegin;
	print "entry : $pageBegin \n";
	
	#Title
	$sql{ 'Title' } = '';
	if ( $page =~/<title>(.*) - Quête - World of Warcraft<\/title>/ ){
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
		if ( $sql{ 'Objectives' } =~ /&lt;(.*)\/(.*)&gt;/
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
		if ( $sql{ 'OfferRewardText' } =~ /&lt;(.*)\/(.*)&gt;/){
		$sql{ 'GenderMale' } = $1;
		$sql{ 'GenderFemale' } = $2;
		$sql{ 'OfferRewardText' } =~s/&lt;$sql{ 'GenderMale' }\//\$G$sql{ 'GenderMale' }:/g ;
		$sql{ 'OfferRewardText' } =~s/$sql{ 'GenderFemale' }&gt;/$sql{ 'GenderFemale' }/g ;
		}
		$sql{ 'OfferRewardText' } =~ s/\<br \/\>/\$B/g ;#Remplacement retour à la ligne
		$sql{ 'OfferRewardText' } =~ s/'/\\'/g ;#Remplacement Guillement
	}
	
	print "\n";
	open locales_quest_fr, ">> $sql{ 'filename' }" or die "Can't open $sql{ 'filename' }!";
	
	if($sql{ 'Title' } ne '')################Si la créature existe#################
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

	if ($pageBegin == $pageEnd)
	{
		print "Parsing End\n";
	}
	
	$pageBegin++;
}

sleep;