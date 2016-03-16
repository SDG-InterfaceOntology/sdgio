#!/usr/bin/perl
use strict;

my $goal;
my $tgt;

header();

while(<>) {
    if (m@^## Goal\s+(\d+)(.*)@) {
        $goal = ":goal-$1";
        my $label = trim($2);
        ttl($goal, 'rdfs:label', lit($label));
        ttl($goal, 'rdf:type', 'SDGIO:00000000');
    }

    if (m@^ \*\s+(\d+)\.(\d+)(.*)@) {
        $tgt = ":target-$1-$2";
        my $label = trim($3);
        if ($label =~ m@^by (\d+)(.*)@i) {
            my $year = ":year-$1";
            $label = trim($2);
            ttl($tgt, 'ends-with:', $year);
            ttl($year, 'rdf:type', 'BFO:0000003');
        }
        ttl($tgt, 'rdfs:label', lit($label));
        ttl($tgt, 'part-of:', $goal);
        ttl($tgt, 'rdf:type', 'SDGIO:00000001');
    }

}

exit 0;

sub trim {
    my $s = shift;
    $s =~ s@^[\.,\s]+@@g;
    return $s;
}

sub lit {
    my $s = shift;
    return '"'.$s.'"';
}

sub ttl {
    my ($s,$p,$o) = @_;
    print "$s $p $o .\n";
}

sub header {

    print <<EOM;

\@base <http://purl.unep.org/sdg/> .
\@prefix : <http://purl.unep.org/sdg/> .
\@prefix BFO: <http://purl.obolibrary.org/obo/BFO_> .
\@prefix part-of: <http://purl.obolibrary.org/obo/BFO_0000050> .
\@prefix ends-with: <http://purl.obolibrary.org/obo/RO_0002230> .
\@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
\@prefix SDGIO: <http://purl.unep.org/sdg/SDGIO_> .

:goals a owl:Ontology .

## Auto-generated
        
EOM

}
