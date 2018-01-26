#!/usr/bin/env perl
## check_depedencies_gecopi.pl
## Check that all the external softwares/perl modules are installed and accessibles

use strict;
use warnings;
use Modern::Perl;

#Check dependencies

# use List::MoreUtils qw(uniq);
# use Bio::DB::EUtilities;
use Getopt::Long;
use FindBin;
use File::Basename;
use Bio::Tools::GFF;
# use Statistics::R;
use Bio::SeqIO;
use File::Path::Tiny;
use File::Which;
use Term::ReadKey;
use DBI;
# use Date::Format;
# use DateTime;
use Bio::DB::Fasta;
# use Bio::PrimarySeqI;
# use Data::Dumper;
# use List::Util 'first';
# use File::Tee qw(tee);
# use DateTime::Format::Duration;

#my $script_dir = $FindBin::Bin;
#print "\n\n$script_dir\n\n";


#Help of the script

sub usage {
"Usage: ".basename($0)." [--help]\n".
"Checks for software dependencies\n".
"Options:\n".
"-h|--help:  Print usage statement\n";
#"-os:  ask either linux or mac\n";
}

my $help;

#options of the script

if (!GetOptions(
    'h|help' => \$help))
{
	die "$!".usage;
}

if (defined $help and $help)
{
	print usage;
	exit 0;
}



print "Checking for Software dependencies...\n";

check_software();

sub check_software
{
	print "Checking for Makeblastdb ... ";
	my $makeblastdb = which('makeblastdb');

	chomp $makeblastdb;
	if (not -e $makeblastdb)
	{
		die "error: Makeblastdb could not be found on PATH\n"
	}
	else
	{
		print "OK\n";
	}
	
	
	print "Checking for blast ... ";
	my $blast = which('blastp');
	chomp $blast;
	if (not -e $blast)
	{
		die "error: blast could not be found on PATH\n"
	}
	else
	{
		print "OK\n";
	}
    
    print "Checking for last ... ";
    my $last = which('lastal');
	chomp $last;
	if (not -e $last)
	{
		die "error: last could not be found on PATH\n"
	}
	else
	{
		print "OK\n";
	}

	print "Checking for maf-convert ... ";
    my $mafConvert = which('maf-convert');
	chomp $mafConvert;
	if (not -e $mafConvert)
	{
		die "error: last could not be found on PATH\n"
	}
	else
	{
		print "OK\n";
	}
	
	print "Checking for diamond ... ";
    my $diamond = which('diamond');
	chomp $diamond;
	if (not -e $diamond)
	{
		die "error: diamond could not be found on PATH\n"
	}
	else
	{
		print "OK\n";
	}
}