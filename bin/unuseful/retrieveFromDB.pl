#!/usr/bin/perl
use 5.018;
use warnings;
use strict;
use Bio::DB::SeqFeature::Store;

my $db = Bio::DB::SeqFeature::Store->new( -adaptor => 'DBI::mysql',
                                            -dsn     => 'dbi:mysql:pao1',
                                            -password => 'Gr$g1987'
                                            );
                                            

#@features = $db->get_features_by_location(-seq_id=>'AAG08954.1',-start=>1,-end=>1000);
#my @features = $db->get_features_by_location(-seq_id=>'AE004091.2',-start=>4000,-end=>600000);

#my $sequence = $db->fetch_sequence(-seq_id=>'AE004091.2',-start=>1,-end=>10000);
#my @ids = $db->seq_ids();
#print @features;



#print $sequence;

my @features = $db->get_features_by_attribute(product => "50S ribosomal*");

for my $i (@features)
{
    print $i;
}