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
chomp $_;
if(/^\s*(debian|cosy|buildeb|kernel|minimal|repo|jenkins-slave|without-recommends|)\s*$/ && $custom==0){
    $dockerfiles=0;
    print $green, $_, $reset;
}
elsif(/^\s*-b <branch>,\s*--branch=BRANCH\s*$/){
    s/<branch>/$green<branch>$blue/;
    s/BRANCH/$green BRANCH/;
    s/ B/B/;
    print $blue, $_, $reset;
}
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
elsif(/^\s*\*\*.*\*\*\s*$/){
    print $red, $_, $reset;
}
elsif(/^\s*\*\*.*$/){
    print $red, $_;
}
elsif(/^\s*.*\*\*\s*$/){
    print $_, $reset;
}
elsif (/^\s*(with-minimal|with-kernel|with-buildeb|without-recommends|with-repo|with-jenkins-slave|with-cosy|clean|install-extrapackages|remove-packages)\s*$/){
    print $yellow,$_,$reset;
}
elsif(/^\s*custom:DOCKERFILES\s*$/){
    $dockerfiles=0;
    my @tab=split /:/; print $green,$tab[0],$reset,":",$yellow, $tab[1],$reset;
}
elsif(/Dockerfiles\s*used/ || $dockerfiles==1){
    $dockerfiles=1;
    s/:/:$yellow/g;
    s/,(?=(\s*(with.*))|(\s*$))/$reset,$yellow/g;
    s/\./$reset./g;
    print $_;
}else{
    print $_;
}
