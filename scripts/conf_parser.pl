#! /usr/bin/perl

use strict;
use YAML::Tiny;
use Data::Dumper;
use File::Basename;

my $configfile=shift;
#Create YAML parser
my $yaml=YAML::Tiny->new;

#Reading the configuration file
$yaml=YAML::Tiny->read($configfile);

#Retrieving the data structure corresponding to the configuration file
$yaml=$yaml->[0];

#print Dumper($yaml);

#Converting that data structure into something that looks like 
#'NAME="VALUE";'.
my $res = "";
foreach my $key (keys $yaml){
    if (defined $yaml->{$key}){
	if($key eq "BRANCH"){
	    my $value=$yaml->{$key};
	    if(ref($value) eq 'ARRAY'){
		if(ref($value->[0]) eq 'HASH'){
		    my $docks=$value->[0]->{'custom'};
		    $res=$res."BRANCH=\"custom\";\n";
		    $res=$res."DOCKERFILES=\"$docks\";\n";
		}else{
		    my $branch=$value->[0];
		    $res=$res."BRANCH=\"$branch\";\n";
		    if($value->[0]=~/custom/){
			my @array=@{$value};
			shift @array;
			my $dockerfiles="";
			foreach my $dock (@array) {
			    $dockerfiles=$dockerfiles . "$dock ";
			}
			$dockerfiles=$1 if($dockerfiles=~/^(.+) $/);
			$res = $res . "DOCKERFILES=\"$dockerfiles\";\n";
		    }
		}
	    }else{
		if($value=~/custom/){
		    $value=~s/custom//;
		    $value=$1 if ($value=~/^ (.+)$/);
		    $res=$res."BRANCH=\"custom\";\n";
		    $res=$res."DOCKERFILES=\"$value\";\n";
		}else{
		    $res=$res."BRANCH=\"$value\";\n";
		}
	    }
	}elsif(ref($yaml->{$key}) eq 'ARRAY'){
	    my @array=@{$yaml->{$key}};
	    my $elems="";
	    foreach my $elem (@array) {
		$elems=$elems . "$elem ";
	    }
	    $elems=$1 if ($elems=~/^(.+) $/);
	    $res = $res . "$key=\"$elems\";\n";
	}else{
	    $res = $res. "$key=\"$yaml->{$key}\";\n";
	}
    }else{
	$res = $res . "$key=\"\";\n";
    }
}

#Checking if ARCHITECTURE is filled correctly.
$res=~/ARCHITECTURE=\"(.*?)\"/;
my $archi=$1;
if ($archi ne 'amd64' && $archi ne 'i386'){
    print "Unknown architecture $archi";
    exit 1;
}
$res=~s/ARCHITECTURE/ARCHI/;

#Checking if TYPE is filled correctly
$res=~/TYPE=\"(.*?)\"/;
if ($1 ne "image" && $1 ne "vm"){
    print "Unknown type $1";
    exit 1;
}

#Checking if BRANCH contains a correct value
$res=~/BRANCH=\"(.*?)\"/;
if ($1 ne "debian" && $1 ne "cosy" && $1 ne "buildeb" && $1 ne "kernel" &&
    $1 ne "minimal" && $1 ne "repo" && $1 ne "jenkins-slave" &&
    $1 ne "without-recommends" && $1 ne "custom"){
    print "Unknown branch $1";
    exit 1;
}

#Checking if DOCKERFILESDIRECTORY is valid
$res=~/DOCKERFILESDIRECTORY=\"(.*?)\"/;
if(! -d "$1"){
    print "Directory $1 doesn't exists";
    exit 1;
}
$res=~s/DOCKERFILESDIRECTORY/DOCKERFILESDIR/;

#Checking if DEBUGMODE contains a correct value
$res=~/DEBUGMODE=\"(.*?)\"/;
if ($1 ne "true" && $1 ne "false"){
    print "Invalid value $1 for DEBUGMODE";
    exit 1;
}

#Checking if VMFORMAT is correct
$res=~/VMFORMAT=\"(.*?)\"/;
if ($1 ne 'vmdk' && $1 ne 'qcow2' && $1 ne 'qcow' && $1 ne 'raw'){
    print "Unknown format $1";
    exit 1;
}

#Checking REMOVE
$res=~/REMOVE=\"(.*?)\"/;
if($1 ne 'yes' && $1 ne 'no'){
    print "Invalid value $1 for REMOVE";
    exit 1;
}

#Changing variable name REPOSITORY to COSYREPO 
$res=~s/REPOSITORY/COSYREPO/;

#Checking DEBIANVERSION
$res=~/REMOVE=\"(.*?)\"/;
my $debversion=$1;
if($debversion =~ /^(\d+\.?)+$/){
    print "Invalid debian version $debversion";
    exit 1;
}

#Checking VERBOSEMODE
$res=~/VERBOSEMODE=\"(.*?)\"/;
if($1 ne 'true' && $1 ne 'false'){
    print "Invalid value $1 for VERBOSEMODE";
    exit 1;
}

print $res;
