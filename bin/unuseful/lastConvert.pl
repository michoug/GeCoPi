#!/usr/bin/perl

use strict;
use warnings;

my @filename;
my $row = 0;

system("perl -pe 's/^#.*\\s*//g' $ARGV[0] | sort -k3,3n -k4,4nr > t");
open FILE ,"t";

while(<FILE>){
    chomp;
    my @line = split '\t';
    
    next if $line[3] < 500;
    $line[2]++;
    my $end1 = $line[2] + $line[3];
    $line[7]++;
    my $end2;
    if($line[9] eq '-')
    {
      
      my $start = $line[10]-$line[7]+$line[8];
      $end2 = $line[10]-$line[7] ;
      $line[7] = $start;
    }
    else{
      $end2 = $line[7] + $line[8];
    }
    #print "$line[2]\t$end1\t$line[7]\t$end2\t$line[9]\n";
    my @int = ("$line[3]", "$line[2]","$end1","$line[7]","$end2");
    for my $column (@int){
      push @{$filename[$row]}, $column;  
    }
    $row++;
}

my $value = 0;

foreach $row (0..@filename-1)
{
  if($filename[$row][0]>10000){
     print "$filename[$row][1]\t$filename[$row][2]\t$filename[$row][3]\t$filename[$row][4]\n";
     $value = $filename[$row][2];
  }  
  elsif($filename[$row][1] > $value){   
     print "$filename[$row][1]\t$filename[$row][2]\t$filename[$row][3]\t$filename[$row][4]\n";
     $value = $filename[$row][2];
  }
}

close FILE;