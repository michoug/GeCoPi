#!/usr/bin/env perl
## gecopi.pl
## Pipeline for genome conparison

use strict;
use warnings;
use Modern::Perl;

#Check dependencies

# use List::MoreUtils qw(uniq);
# use Bio::DB::EUtilities;
use Getopt::Long;
use FindBin;
use File::Which;
use File::Basename;
use Pod::Usage;
use File::Spec;
use Bio::DB::SeqFeature::Store;
use Bio::DB::SeqFeature::Store::GFF3Loader;
# use Statistics::R;
use Bio::SeqIO;
use File::Path::Tiny;
use DBI;
use Term::ReadKey;
# use Date::Format;
# use DateTime;
# use Bio::DB::Fasta;
# use Bio::PrimarySeqI;
# use Data::Dumper;
# use List::Util 'first';
# use File::Tee qw(tee);
# use DateTime::Format::Duration;

#my $script_dir = $FindBin::Bin;
#print "\n\n$script_dir\n\n";

sub usage {
"Usage: ".basename($0)." -gff1 -fasta1 -gff2 -fasta2 -t[--help]\n".
"Pipeline for genome conparison\n".
"Options:\n".
"-gff1: gff file of the genome to analyse\n".
"-fasta1: fasta file of the genome to analyse\n".
"-gff2: gff file of the reference genome\n".
"-fasta2: fasta file of the reference genome\n".
"-t|--threads: Number of threads\n".
"-h|--help:  Print usage statement\n";
}

my $help;

my $gffInt;
my $gffRef;
my $fastaInt;
my $fastaRef;
my $threads;

#options of the script

if (!GetOptions(
    'gff1=s'=> \$gffInt,
    'fasta1=s'=> \$fastaInt,
    'gff2=s'=> \$gffRef,
    'fasta2=s'=> \$fastaRef,
    't|threads'=> \$threads,
    'h|help' => \$help)
    )
{
	die "$!".usage();
}

if (defined $help and $help)
{
	print usage();
	exit 0;
}

die "Error: no gff1 file defined\n".usage if (not defined $gffInt);
die "Error: no fasta1 file defined\n".usage if (not defined $fastaInt);
die "Error: no gff2 file defined\n".usage if (not defined $gffRef);
die "Error: no fasta2 file defined\n".usage if (not defined $fastaRef);
$threads = 1 if (not defined $fastaRef);

my $final_dir = "Results";
File::Path::Tiny::mk($final_dir) or die $!;

#Let's check the files

checkFastaFile($fastaInt);
checkFastaFile($fastaRef);
checkGFFFile($gffInt);
checkGFFFile($gffRef);
my $genomeInt = GenomeName($fastaInt);
my $genomeRef = GenomeName($fastaRef);

say "I'm going to create databases for the two genomes";
say "What is your mysql username ?";
my $user = <STDIN>;
chomp $user;

say "What is your mysql password ?";
ReadMode('noecho');
my $password = ReadLine(0);
chomp $password;
ReadMode 'normal';

createDatabase($genomeInt);
createDatabase($genomeRef);


load_gff($genomeInt,$gffInt,$fastaInt);
load_gff($genomeRef,$gffRef,$fastaRef);

## Subroutines

sub checkFastaFile{
    my $file = $_[0];
    chomp $file;
    die "This is not a fasta file \n" if($file !~ /\.fa/);
    my $seqio = Bio::SeqIO->new(-file => $file, -format => "fasta");
    my $seq = $seqio->next_seq;
    #print 1 if $seq;
}

sub checkGFFFile{
    my $file = $_[0];
    chomp $file;
    die "This is not a gff file \n" if($file !~ /\.gff/);

}    
sub createDatabase{
    my $genome = $_[0];
    my $host = "localhost";
    my $dsn = "dbi:mysql:host=$host";
    my $dbh = DBI->connect($dsn, $user,$password);
    
    print 1 == $dbh->do("create database IF NOT EXISTS $genome") ? "The $genome database is created or does already exists\n":"Error\n";
    
}

sub GenomeName{
    my $genome = $_[0];
    $genome =~ s/\..*//g;
    $genome =~ s/.*\///g;
    return $genome;
}

sub load_gff {
    #modify from the bp_load_gff script
    # $Id: bp_load_gff.pl,v 1.1 2008-10-16 17:01:27 lstein Exp
    my $database = $_[0];
    my $gff = $_[1];
    #my $fasta = $_[2];
    
    my $DSN = "dbi:mysql:$database";
    my $ADAPTOR = 'DBI::mysql';
    my $SUMMARY_STATS	= 0;
    my $NOSUMMARY_STATS  = 0;
    
    my $store = Bio::DB::SeqFeature::Store->new
    (
        -dsn        => $DSN,
        -adaptor    => $ADAPTOR,
        -user       => $user,
        -pass       => $password,
        -write      => 1,
        -create     => 1,
        -fts        => 1,
    )
    or die "Couldn't create connection to the database";

    $store->init_database('erase') ;
    $SUMMARY_STATS++               ; # this is a good thing

    my $loader = Bio::DB::SeqFeature::Store::GFF3Loader->new
    (
        -store              => $store,
        -sf_class           => 'Bio::DB::SeqFeature',
        -verbose            => 1,
        -summary_stats      => $NOSUMMARY_STATS ? 0 : $SUMMARY_STATS
    )
    or die "Couldn't create GFF3 loader";

    # on signals, give objects a chance to call their DESTROY methods
    #$SIG{TERM} = $SIG{INT} = sub {  undef $loader; undef $store; die "Aborted..."; };

    $loader->load($gff);
    #$loader->load($fasta);


}

