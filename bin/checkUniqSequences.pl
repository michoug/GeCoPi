#!/usr/bin/env perl
## checkUniqSequences.pl
## Blast/Diamond uniq sequences against local database

use strict;
use warnings;
use Modern::Perl;
use Bio::DB::Fasta;

my $threads = 4;

my $fastaFile1 = "../TestFiles/PseudomonasM18.fasta";
my $fastaFile2 = "../TestFiles/PseudomonasPAO1.fasta";

my $UniqFile1 = "tmp/UniqFile1.tab";
my $UniqFile2 = "tmp/UniqFile2.tab";


getSeqFromCoordinates($fastaFile1,$UniqFile1);
getSeqFromCoordinates($fastaFile2,$UniqFile2);

sub getSeqFromCoordinates{

    # Get different sequences from Coordinates
    my $file = $_[0];
    my $tabfile = $_[1];

    
    
    open(TAB, $tabfile) or die;
    while(<TAB>){
        chomp;
        my @line = split /\t/;
        #say "$line[0]-$line[1]";
        next if $line[1] - $line[0] < 5000;
        my $dbFasta = Bio::DB::Fasta->newFh("$file") or die;

        while (my $seq = <$dbFasta>) 
        {     
            my $header = $seq->display_id();
            # say $header;
            my $substring = $seq->subseq("$line[0]","$line[1]");

            open(FASTA,'>',"tmp/$header\_$line[0]-$line[1].fasta") or die $!;
            print FASTA ">$header|$line[0]-$line[1]\n$substring";
            close FASTA;
        }

    }

    close TAB;

     
    
    
    
}
