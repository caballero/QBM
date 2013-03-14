#!/usr/bin/perl

# buildTables.pl
# 
# (C) Juan Caballero, 2013
# LICENSE: Artistic License 2.0 http://www.perlfoundation.org/artistic_license_2_0

use strict;
use warnings;

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

my %gen_go;
my %gen_cnt;
my %gen_ortho;

foreach my $sp (@species) {
    warn "loading gene counts for $sp\n";
    open CNT, "$sp\_count.txt" or die;
    while (<CNT>) {
        chomp;
        my ($gen, $cnt) = split (/\t/, $_);
        $gen_cnt{$sp}{$gen} = $cnt;
    }
}

foreach my $sp (@species) {
    next if (-e "$sp\_table.txt");
    warn "getting GO for $sp\n";
    open  GO, "$sp\_go.txt" or die;
    while (<GO>) {
        chomp;
        my ($genID, $trnID, $genAlt, $trnAlt, $goID, $goDesc) = split (/\t/, $_);
        $goID = 'NA' unless (defined $goID);
        $gen_go{$sp}{$genID} .= "$goID,";
    }
    close GO;
    foreach my $gen (keys %{ $gen_go{$sp} }) {
        $gen_go{$sp}{$gen} =~ s/,$//;
        $gen_go{$sp}{$gen} = getUniq($gen_go{$sp}{$gen});
    }
    last;
}

foreach my $sp1 (@species) {
    next if (-e "$sp1\_table.txt");
    foreach my $sp2 (@species) {
        next if ($sp1 eq $sp2);
        warn "obtaining orthologs between $sp1 and $sp2\n";
        open ORT, "$sp1-$sp2-ortho.txt" or die;
        while (<ORT>) {
            chomp;
            my ($gen1, $trn1, $gen2) = split (/\t/, $_);
            next unless (defined $gen2);
            $gen_ortho{"$sp1:$gen1"}{$sp2}{$gen2} = 1;
        }
        close ORT;
    }
    last;
}

foreach my $sp1 (@species) {
    next if (-e "$sp1\_table.txt");
    warn "writting results for $sp1\n";
    open OUT, ">$sp1\_table.txt";
    while (my ($gen, $cnt) = each %{ $gen_cnt{$sp1} }) {
        next if ($cnt < 2);
        my $go = 'NA';
        $go = $gen_go{$sp1}{$gen} if (defined $gen_go{$sp1}{$gen});
        print OUT "$gen\t$cnt\t$go\n";
        foreach my $sp2 (@species) {
            next if ($sp1 eq $sp2);
            my $ortho = '';
            foreach my $gen2 (keys %{ $gen_ortho{"$sp1:$gen"}{$sp2} }) {
                my $cnt2 = 'NA';
                $cnt2 = $gen_cnt{$sp2}{$gen2} if (defined $gen_cnt{$sp2}{$gen2});
                $ortho .= "\t\t$gen2\t$cnt2\n";
            }
            print OUT "\t$sp2\n$ortho" if (defined $ortho);
        }
    }
    close OUT;
    last;
}

sub getUniq {
    my @list = split (/,/, $_[0]);
    my %list;
    foreach my $x (@list) {
        $list{$x} = 1;
    }
    return join ",", keys %list;
}
