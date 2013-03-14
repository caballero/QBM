#!/usr/bin/perl

# queryBioMart_AnimalGO.pl
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
mfuro
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

foreach my $sp (@species) {
    next if (-e "$sp\_go.txt");
    warn "doing $sp\n";
    open STDOUT, ">$sp\_go.txt";
    my $initializer = BioMart::Initializer->new('registryFile'=>$confFile, 'action'=>$action);
    my $registry = $initializer->getRegistry;
    my $query = BioMart::Query->new('registry'=>$registry,'virtualSchemaName'=>'default');
    my $query_runner;
    
    $query->setDataset("$sp\_gene_ensembl");
    $query->addAttribute("ensembl_gene_id");
    $query->addAttribute("ensembl_transcript_id");
    $query->addAttribute("external_gene_id");
    $query->addAttribute("external_transcript_id");
    $query->addAttribute("go_id");
    $query->addAttribute("name_1006");
    $query->formatter("TSV");

    $query_runner = BioMart::QueryRunner->new();
    $query_runner->execute($query);
    $query_runner->printResults();
    close STDOUT;
}
