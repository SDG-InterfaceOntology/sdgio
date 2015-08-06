
GEMETS = backbone definitions groups
GEMETFS = $(patsubst %,gemet-%.rdf,$(GEMETS))

all: gemet

gemet-backbone.rdf:
	wget http://www.eionet.europa.eu/gemet/gemet-backbone.rdf -O $@

gemet-definitions.rdf:
	wget 'http://www.eionet.europa.eu/gemet/gemet-definitions.rdf?langcode=en' -O $@

gemet-groups.rdf:
	wget 'http://www.eionet.europa.eu/gemet/gemet-groups.rdf?langcode=en' -O $@

gemet-all.rdf: $(GEMETFS)
	rdfcat $^ > $@

gemet.obo: priority-gemet.tsv 
	perl -npe 's//GEMET:/' $< | cut -f1,2 | tbl2obo.pl  > $@

gemet-labels.txt: priority-gemet.tsv
	cut -f2 $<  > $@

#GEMETX = chebi
GEMETX = mesh sctid chebi eo envo to pato exo
XOBOS = $(patsubst %, xrefs-gemet-%.obo,$(GEMETX))

gemet: $(XOBOS) summary-xrefs-gemet.txt xsummary.tsv

align-gemet-%.tsv: gemet.obo
	blip-findall -debug index -i ignore_gemet.pro -i $< -r $* -u metadata_nlp -goal index_entity_pair_label_match "class(X),id_idspace(X,'GEMET'),entity_pair_label_reciprocal_best_intermatch(X,Y,S)" -select "x(X,Y,S)" -label -use_tabs -no_pred > $@.tmp && mv $@.tmp $@
.PRECIOUS: align-gemet-%.tsv

xrefs-%.obo: align-%.tsv
	cut -f1-4 $< | sort -u | tbl2obolinks.pl --rel xref - > $@

allx.obo: $(XOBOS)
	obo-cat.pl $^ > $@
#	owltools $^ --merge-support-ontologies -o -f obo $@

xsummary.tsv: allx.obo
	blip-findall -i $< -i gemet.obo -u xref_util prefixset_stats/2 -no_pred > $@.tmp &&  mysort -s -k2 -n -r $@.tmp > $@

summary-xrefs-%.txt:
	grep -c ^id: xrefs-$*-*.obo
