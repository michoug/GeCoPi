#!/usr/bin/env perl
## last pipeline
## Script that is going to be used in the gecopi pipeline

use strict;
use warnings;
use Modern::Perl;
use Bio::DB::Fasta;


my $threads = 4;

my $fastaFile1 = "../Testfiles/PseudomonasM18.fasta";
my $fastaFile2 = "../Testfiles/PseudomonasPAO1.fasta";

# Get total length of the fasta files
# Assume that there is only one sequence

my $lengthFasta1 = getSeqLength($fastaFile1);
my $lengthFasta2 = getSeqLength($fastaFile2);

#last commands

my $lastdb = `lastdb -cR01 tmp/file1 $fastaFile1` if ! -e "tmp/file1.bck";
system("lastal -P $threads tmp/file1 $fastaFile2 | maf-convert tab > tmp/lastAl.tab") if ! -e "tmp/lastAl.tab";



getUniqCoordinate($lengthFasta1,"tmp/lastAl.tab",1);
getUniqCoordinate($lengthFasta2,"tmp/lastAl.tab",2);

sub getUniqCoordinate{

    #The goal of this subroutine is to get the coordinates of the unique sequences that are not aligned between the two genomes

    my $totalLength = $_[0];
    my $tmpFile = $_[1];
    my $fileNumber = $_[2];

    my @limit = (0,$totalLength);

    open(FILE, "$tmpFile");
    while(<FILE>)
    {
        next if /^\#/;
        my @line = split /\t/;
        #say "$line[2]\t$line[3]";
        if($fileNumber == "1"){
            my $k = $line[2]+$line[3]+1;
            push @limit, $line[2];
            push @limit, $k;
        }

        elsif($fileNumber == "2"){
            my $k = $line[7]+$line[8]+1;
            push @limit, $line[7];
            push @limit, $k;
        }
        
        
    }
    close FILE;

    @limit = sort { $a <=> $b } @limit; # Sort array by number

    shift @limit; #Remove first value
    my $last = pop @limit;
    
    if($totalLength > $last){
        #check that we don't forget any sequence at the end
        push @limit, $last;
        push @limit, $totalLength;
    }

    my $tmp = &natatime(2, @limit); # Creates an array iterator, for looping over an array in chunks of 2 items at a time



    open(TAB, '>', "tmp/UniqFile$fileNumber\.tab");
    

    while (my @vals = $tmp->())
    {
        
        my $length = $vals[1] - $vals[0];
        #next if $length < 1000;
        #my $i = join "\t",@vals;
        say TAB "$vals[0]\t$vals[1]\t$length";
    }
    close TAB;
}

    

sub getSeqLength{

    # Get total sequence length from fasta file
    my $file = $_[0];
    my $dbFasta = Bio::DB::Fasta->newFh("$file");
    my $lengthFasta;
    while (my $seq = <$dbFasta>) {
        $lengthFasta  = $seq->length;
    }
    return($lengthFasta)
}

sub natatime ($@)
{
    ## Function form List::MoreUtils;

    my $n = shift;
    my @list = @_;

    return sub
    {
        return splice @list, 0, $n;
    }
}

