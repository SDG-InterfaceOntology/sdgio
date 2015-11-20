
GEMETS = backbone definitions groups skoscore
GEMETFS = $(patsubst %,gemet-%.rdf,$(GEMETS))

all: gemet summary-xrefs-gemet.txt xsummary.tsv no-align.tsv

gemet-backbone.rdf:
	wget http://www.eionet.europa.eu/gemet/gemet-backbone.rdf -O $@

gemet-definitions.rdf:
	wget 'http://www.eionet.europa.eu/gemet/gemet-definitions.rdf?langcode=en' -O $@

gemet-skoscore.rdf:
	wget 'http://www.eionet.europa.eu/gemet/gemet-skoscore.rdf?langcode=en' -O $@

gemet-groups.rdf:
	wget 'http://www.eionet.europa.eu/gemet/gemet-groups.rdf?langcode=en' -O $@

gemet-all.rdf: $(GEMETFS)
	rdfcat $^ > $@

gemet-full.obo: gemet-all.rdf
	./translate-gemet-rdf.py > $@.tmp && hacky-fix-gemet-ids.pl $@.tmp > $@.tmp2 && owltools $@.tmp2 -o -f obo $@

# This is the version from the spreadsheet
gemet.obo: priority-gemet.tsv 
	perl -npe 's//GEMET:/' $< | cut -f1,2 | tbl2obo.pl  > $@

gemet-labels.tsv: priority-gemet.tsv
	cut -f2 $<  > $@

GEMETX = ncbitaxon mondo oba mesh sctid chebi eo envo to po pato exo taxrank
XOBOS = $(patsubst %, xrefs-gemet-%.obo,$(GEMETX))
IOBOS = $(patsubst %, -r %,$(GEMETX))
LABELS = $(patsubst %, labels-%.tsv,$(GEMETX))

gemet: $(XOBOS) 

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

gemet-bestmatches.tsv: allx.obo
	blip-findall -i $< -i gemet.obo -consult sdgutil gemet_rpt/3 -no_pred > $@.tmp && sort -u $@.tmp > $@

summary-xrefs-%.txt:
	grep -c ^id: xrefs-$*-*.obo

no-align.tsv: allx.obo gemet.obo 
	blip-findall -i $< -i gemet.obo -i gemet-full.obo -consult sdgutil no_align/2 -no_pred -label -use_tabs | sort -u > $@

labels: $(LABELS)
labels-%.tsv:
	blip-findall -r $* -consult synreport.pro rpt/3 -grid -use_tabs -no_pred > $@


envo-rpt.tsv: no-align.tsv
	egrep '(ANTHROPOSPHERE|ATMOSPHERE|BIOSPHERE|ENVIRONMENT_natural|HYDROSPHERE|LITHOSPHER|WASTES)' $< > $@

# OBOL
compositional.obo:
	obol -debug qobol qobol -i related_to.obo -i gemet.obo $(IOBOS) -idspace GEMET -tag gemet -undefined_only true -export obo > $@

compositional-rest.obo:
	obo-subtract.pl compositional.obo allx.obo > $@


# EXPERIMENTAL

%-ann.ttl: %.obo
	blip  -i $< ontol-annotate  -to ttl > $@.tmp && mv $@.tmp $@

%-ann.owl: %.obo %-ann.ttl
	owltools $^ --merge-support-ontologies -o $@

MONTS =  envo po pato exo
IMONTS=  $(patsubst %, -r %,$(MONTS))
omine.tsv:
	blip-findall -debug index -debug ominfo -goal init_ontominer  -u ontominer -i gemet-full.obo $(IMONTS) concept_enriched/7 -label -no_pred > $@.tmp && mysort -k 3 -n -r $@.tmp > $@

pred_rel.tsv: omine.tsv
	blip-findall -debug index -goal init_ontominer  -u ontominer -i gemet-full.obo $(IMONTS) has_differentia/5 -label -no_pred  > $@


links.obo:
	blip-findall  -goal init_ontominer  -u ontominer -i gemet-full.obo direct_concept_token/2 -no_pred | tbl2obolinks.pl --rel mentions > $@


#targets-annotated.txt: targets.txt
#	blip -debug index -r envo -i gemet-full.obo annotate $< > $@
##	blip $(IOBOS) annotate $< > $@

targets-annotated.txt: targets.txt
	/ann-tgts.pl $< > $@
