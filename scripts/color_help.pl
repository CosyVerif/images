#! /usr/bin/perl -nl
BEGIN {
    use Term::ANSIColor qw(:constants);
    $blue=BRIGHT_BLUE;
    $red=RED;
    $green=GREEN;
    $reset=RESET;
    $yellow=YELLOW;
    our $custom=0;
    our $dockerfiles=0;
}
#Removing final \n
chomp $_;

#if the line contains only a branch name
if(/^\s*(debian|cosy|buildeb|kernel|minimal|repo|jenkins-slave|without-recommends|)\s*$/ && $custom==0){
    $dockerfiles=0;
    print $green, $_, $reset;
}

#if the line concerns -b option
elsif(/^\s*-b <branch>,\s*--branch=BRANCH\s*$/){
    s/<branch>/$green<branch>$blue/;
    s/BRANCH/$green BRANCH/;
    s/ B/B/;
    print $blue, $_, $reset;
}

#if the line is a sequence of options
elsif(/^(((\s*-\w(\s*\<.*?\>)?)|(\s*--\w[-\w]*(=[-a-zA-Z\/]+)?)),?\s*)+$/){
    if($_=~/--dockerfiles/){
	$custom=1;
    }
    s/DOCKERFILES/$yellow DOCKERFILES$blue/g;
    s/ D/D/g;
    if($custom==1 && ($_ !~ /--dockerfiles/)){
	$custom=0;
    }
    print $blue, $_, $reset;
}

#if the line contains ** something **
elsif(/^\s*\*\*.*\*\*\s*$/){
    print $red, $_, $reset;
}

#if the line contains  ** at the beginning, it means everthing will be red until
#we find a line which ends with **
elsif(/^\s*\*\*.*$/){
    print $red, $_;
}

#if the line contains ** at the end
elsif(/^\s*.*\*\*\s*$/){
    print $_, $reset;
}

#if the line is a dockerfile name
elsif (/^\s*(with-minimal|with-kernel|with-buildeb|without-recommends|with-repo|with-jenkins-slave|with-cosy|clean|install-extrapackages|remove-packages)\s*$/){
    print $yellow,$_,$reset;
}

#if the line concerns the custom branch
elsif(/^\s*custom:DOCKERFILES\s*$/){
    $dockerfiles=0;
    my @tab=split /:/; print $green,$tab[0],$reset,":",$yellow, $tab[1],$reset;
}

#If the line contains a list of dockerfiles
elsif(/Dockerfiles\s*used/ || $dockerfiles==1){
    $dockerfiles=1;
    s/:/:$yellow/g;
    s/,(?=(\s*(with.*))|(\s*$))/$reset,$yellow/g;
    s/\./$reset./g;
    print $_;
}else{
    print $_;
}
