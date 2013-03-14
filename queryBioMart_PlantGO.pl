#!/usr/bin/perl

# queryBioMart_PlantGO.pl
# 
# (C) Juan Caballero, 2013
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

foreach my $sp (@species) {
    warn "doing $sp\n";
    open STDOUT, ">$sp\_go.txt";
    my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
    my $registry = $initializer->getRegistry;
    my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');
    my $query_runner;
    
    $query->setDataset("$sp\_eg_gene");
    $query->addAttribute("ensembl_gene_id");
    $query->addAttribute("ensembl_transcript_id");
    $query->addAttribute("external_gene_id");
    $query->addAttribute("external_transcript_id");
    $query->addAttribute("go_accession");
    $query->addAttribute("go_name_1006");
    $query->formatter("TSV");

    $query_runner = BioMart::QueryRunner->new();
    $query_runner->execute($query);
    $query_runner->printResults();
    close STDOUT;
}
