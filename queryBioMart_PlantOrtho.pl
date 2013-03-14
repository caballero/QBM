#!/usr/bin/perl

# queryBiomart_PlantOrtho.pl
#
# (C) Juan Caballero 2013
# LICENSE: Artistic License 2.0 http://www.perlfoundation.org/artistic_license_2_0

use strict;
#use warnings;
use lib '/bio/bin/biomart-perl/lib';
use BioMart::Initializer;
use BioMart::Query;
use BioMart::QueryRunner;

my @species = qw/
                  athaliana
                  alyrata
                  bdistachyon
                  brapa
                  creinhardtii
                  cmerolae
                  gmax
                  hvulgare
                  macuminata
                  obrachyantha
                  oglaberrima
                  oindica
                  osativa
                  ppatens
                  ptrichocarpa
                  smoellendorffii
                  sitalica
                  slycopersicum
                  stuberosum
                  sbicolor
                  vvinifera
                  zmays
                /;

my $confFile = "/bio/bin/biomart-perl/conf/plantRegistry.xml";
my $action='cached';

foreach my $sp1 (@species) {
    foreach my $sp2 (@species) {
        next if ($sp1 eq $sp2);
        next if (-e "$sp1-$sp2-ortho.txt");
        warn "doing $sp1 - $sp2\n";
        my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
        my $registry = $initializer->getRegistry;
        my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');
        my $query_runner;
        open STDOUT, ">$sp1-$sp2-ortho.txt";
        $query->setDataset("$sp1\_eg_gene");
        $query->addAttribute("ensembl_gene_id");
        $query->addAttribute("ensembl_transcript_id");
        $query->addAttribute("$sp2\_eg_gene");
        $query->addAttribute("homolog_$sp2\_eg__dm_stable_id_4016_r1");
        $query->addAttribute("$sp2\_eg_homolog_ensembl_peptide");
        $query->formatter("TSV");

        $query_runner = BioMart::QueryRunner->new();
        $query_runner->execute($query);
        $query_runner->printResults();
        close STDOUT;
    }
}
