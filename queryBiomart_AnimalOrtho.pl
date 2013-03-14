#!/usr/bin/perl

# queryBiomart_AnimalOrtho.pl
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
acarolinensis
amelanoleuca
btaurus
celegans
cfamiliaris
choffmanni
cintestinalis
cjacchus
cporcellus
csavignyi
dmelanogaster
dnovemcinctus
dordii
drerio
ecaballus
eeuropaeus
etelfairi
fcatus
gaculeatus
ggallus
ggorilla
gmorhua
hsapiens
itridecemlineatus
lafricana
lchalumnae
mdomestica
meugenii
mgallopavo
mlucifugus
mmulatta
mmurinus
mmusculus
nleucogenys
oanatinus
ocuniculus
ogarnettii
olatipes
oniloticus
oprinceps
pabelii
pcapensis
pmarinus
psinensis
ptroglodytes
pvampyrus
rnorvegicus
saraneus
scerevisiae
sharrisii
sscrofa
tbelangeri
tguttata
tnigroviridis
trubripes
tsyrichta
ttruncatus
vpacos
xmaculatus
xtropicalis
/;

my $confFile = "/bio/bin/biomart-perl/conf/animalRegistry.xml";
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

        $query->setDataset("$sp1\_gene_ensembl");
        $query->addAttribute("ensembl_gene_id");
        $query->addAttribute("ensembl_transcript_id");
        $query->addAttribute("$sp2\_homolog_ensembl_gene");
#        $query->addAttribute("$sp2\_homolog_canonical_transcript_protein");
        $query->addAttribute("$sp2\_homolog_ensembl_peptide");
        $query->formatter("TSV");

        $query_runner = BioMart::QueryRunner->new();
        $query_runner->execute($query);
        $query_runner->printResults();
        close STDOUT;
        exit 1;
    }
}
