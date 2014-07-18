#! /usr/bin/perl -l

use strict;

my $i=$ARGV[0];
my$tag=$ARGV[1];
open DOCK, ">Dockerfile$i" or die("$!");
print DOCK "FROM build$i";
print DOCK "RUN apt-get update";
print DOCK "RUN echo deb http://132.227.76.2:4142/debian wheezy-unstable/ >> /etc/apt/sources.list";
print DOCK "RUN wget -O - http://132.227.76.2:4142/gpgkey | apt-key add -";
print DOCK 'RUN apt-get update';
print DOCK 'RUN apt-get install -y --force-yes buildeb lsb-release';
my $deps = $ENV{'BUILDDEPENDS'};
my @depends=split /,/, $deps;
for(my $j=0;$j<@depends+0;$j++){
    $depends[$j]=~s/(.+?)\s\([<>=][=]?\s(.+)\)/$1\=$2/, $depends[$j];
}
$deps=join "", @depends;
print DOCK "RUN apt-get install -y --force-yes $deps";
print DOCK "WORKDIR /build";
print DOCK "RUN awk -v rtag=`lsb_release -cs`-$tag 'BEGIN {RS=\"\";}{ if(\$0 ~ /DISTRIBUTION/) print \"DISTRIBUTION : \"rtag; else print \$0; }' $ENV{'CONFIGFILE'} > /build/tmp";
print DOCK "RUN mv /build/tmp $ENV{'CONFIGFILE'}";
print DOCK "RUN buildeb -c $ENV{'CONFIGFILE'} -d $ENV{'MAKEFILEDIR'} -l -v";
close DOCK;
