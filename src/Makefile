# ----------------------------------------
# Makefile for SDGIO
# Partially aligned to the ontology-starter-kit
# https://github.com/INCATools/ontology-development-kit/blob/master/template/src/ontology/Makefile.jinja2
# ----------------------------------------
# <do not edit above this line>

# ----------------------------------------
# Standard Constants
# ----------------------------------------
# these can be overwritten on the command line

OBO=http://purl.obolibrary.org/obo
SDG=http://purl.unep.org/sdg
USECAT= --catalog-xml catalog-v001.xml
SRC= sdgio-edit.owl
ROBOT=robot
OWLTOOLS= owltools

##MODULES=exposure
## will need a module for harzards and other defined tasks
## such as land rights, chemicals and wastes, ecosystem services ...
MODULES=
MODULE_FILES = $(patsubst %,modules/%.owl,$(MODULES))

# Ontology dependencies
# We don't include clo, as this is currently not working
IMPORTS = pato uberon chebi ro bfo envo iao pco obi ogms
IMPORTS_OWL = $(patsubst %, imports/%_import.owl,$(IMPORTS)) 
# $(patsubst %, imports/%_import.obo,$(IMPORTS))

all: build
test: sdgio.owl

sdgio.owl: sdgio-edit.owl $(MODULE_FILES) 
	$(ROBOT) merge -i $<  $(patsubst %,-i %,$(MODULE_FILES)) reason -r ELK -s true annotate -V $(SDG)/releases/`date +%Y-%m-%d`/sdgio.owl -o $@
###	$(ROBOT) merge -i $<  $(patsubst %,-i %,$(MODULE_FILES)) reason -r ELK -s true annotate -V $(SDG)/releases/`date +%Y-%m-%d`/sdgio.owl -o tmp-$@ && owltools $(USECAT) tmp-$@ --remove-imports-declarations -o $@

#sdgio.owl: sdgio-edit.owl 
#	$(ROBOT) merge -i $< reason -r ELK -s true -o $@ convert -o sdgio.obo



# ----------------------------------------
# Conversions
# ----------------------------------------

sdgio-normalized.json: sdgio.owl
	rdfcat -out JSONLD $< > $@.tmp && mv $@.tmp $@
	
.PRECIOUS: sdgio.owl


sdgio.obo: sdgio.owl 
	# $(ROBOT) convert -i $< -o sdgio.obo # errors due to multiple tags, use owltools to workaround
	
	owltools $(USECAT) $< --merge-imports-closure --add-obo-shorthand-to-properties -o -f obo --no-check $@.tmp && grep -v ^owl-axioms $@.tmp > $@
	
.PRECIOUS: sdgio.owl
	
# generic conversion for OGs
%.json: %.owl 
	$(ROBOT) convert -input $< -f json -o $@

.PRECIOUS: %.owl

debug.owl: envo-edit.owl $(OWLTOOLS)
	$(OWLTOOLS) --use-catalog  $< --merge-support-ontologies --run-reasoner -r elk -u -m $@

.PRECIOUS: envo-edit.owl
	

# ----------------------------------------
# Trigger build and release
# ----------------------------------------

build: all_imports sdgio.owl sdgio.obo sdgio.json 

copy-release: 
	cp -pr catalog-v001.xml sdgio.obo sdgio.owl sdgio.json imports ../

prepare_release: build copy-release


# ----------------------------------------
# Regenerate imports
# ----------------------------------------
# Uses OWLAPI Module Extraction code

# Type 'make imports/X_import.owl' whenever you wish to refresh the import for an ontology X. This regenerates the import
# module using the 'imports/X_terms.txt' file

# Type 'make all_imports' if you want to regenerate all the imports at once.

# Base URI for local subset imports
SDG_IMPORTS_BASE_URI = $(SDG)


# Make this target to regenerate ALL
all_imports: $(IMPORTS_OWL)

# We will edit this as the SDGIO needs become apparent...
KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of RO:0002176 RO:0000057 BFO:0000055 RO:0002473 RO:0002351 RO:0002131 IAO:0000114
# 'part of' 'has part' 'develops from' 'immediate_transformation_of' 'connects' 'has participant'  'realizes' 'composed primarily of' 'has member' 'overlaps' 'has curation status'

# Use ROBOT, driven entirely by terms lists NOT from source ontology
imports/%_import.owl: mirror/%.owl imports/%_terms.txt
	$(ROBOT) extract -i $< -T imports/$*_terms.txt --method BOT -O $(SDG_IMPORTS_BASE_URI)/$@ -o $@
.PRECIOUS: imports/%_import.owl

# Use owltools to create OBO files for the imports
#imports/%_import.obo: imports/%_import.owl
#	owltools $(USECAT) $< -o -f obo $@

# clone remote ontology locally, perfoming some excision of relations and annotations
mirror/%.owl: $(SRC)
	owltools $(OBO)/$*.owl --remove-annotation-assertions -l -s -d --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS)  -o $@
.PRECIOUS: mirror/%.owl

SIMPLIFY= --merge-imports-closure --extract-mingraph --remove-abox --make-subset-by-properties -f // --remove-annotation-assertions -r -l -s -o
# currently we only need ontology metadata from iao
mirror/iao.owl: $(SRC)
	owltools $(OBO)/iao/ontology-metadata.owl $(SIMPLIFY)  $@
mirror/obi.owl: $(SRC)
	owltools $(OBO)/obi.owl --merge-imports-closure --remove-annotation-assertions -r -l -s -o $@
mirror/ogms.owl: $(SRC)
	owltools $(OBO)/ogms.owl $(SIMPLIFY) $@
mirror/bfo.owl: $(SRC)
	owltools $(OBO)/bfo.owl --merge-imports-closure --remove-annotation-assertions -r -l -s -o $@
.PRECIOUS: mirror/%.owl

# Note that we do not simplify RO - we need the relations to be imported.
mirror/ro.owl: $(SRC)
	owltools $(OBO)/ro.owl --merge-imports-closure --remove-annotation-assertions -r -l -s -d -o $@
.PRECIOUS: mirror/%.owl

mirror/uberon.owl: $(SRC)
	owltools $(OBO)/uberon.owl  --remove-axiom-annotations  --make-subset-by-properties -f $(KEEPRELS) --remove-dangling-annotations --remove-annotation-assertions -l -s -d --set-ontology-id $(OBO)/uberon.owl -o $@
.PRECIOUS: mirror/%.owl

mirror/po.owl: $(SRC)
	owltools $(OBO)/po.owl --remove-annotation-assertions -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/po.owl -o $@
.PRECIOUS: mirror/%.owl

mirror/envo.owl: $(SRC)
	owltools $(OBO)/envo.owl --remove-annotation-assertions -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/envo.owl -o $@
.PRECIOUS: mirror/%.owl

ncbitaxon.obo:
	wget -N $(OBO)/ncbitaxon.obo
.PRECIOUS: ncbitaxon.obo

mirror/ncbitaxon.owl: ncbitaxon.obo
	OWLTOOLS_MEMORY=12G owltools $< --remove-annotation-assertions -l -s -d --remove-axiom-annotations --remove-dangling-annotations  --set-ontology-id $(OBO)/ncbitaxon.owl -o $@
.PRECIOUS: mirror/ncbitaxon.owl

#mirror/pco.owl: imports/pco_basic.obo
#	owltools $< --set-ontology-id $(OBO)/pco.owl -o $@


# ----------------------------------------
# Reports
# ----------------------------------------
sdgio-merged.owl: sdgio.owl
	owltools $(USECAT) $< --merge-imports-closure -o $@
.PRECIOUS: sdgio.owl

# Generate a CSV term list from the OWL files created. 
# sdgio-basicReport.csv and sdgio-edges.csv are valid targets
reports/sdgio-%.csv: sdgio-merged.owl sparql/%.sparql
	arq --data $< --query sparql/$*.sparql --results csv > $@.tmp && mv $@.tmp $@

# ----------------------------------------
# Graph export
# ----------------------------------------
# Generate a CSV term list from the OWL files created.
#graphs/sdgio-%.csv: sdgio.owl sparql/%.sparql
#	arq --data $< --query sparql/$*.sparql --results csv > $@.tmp && mv $@.tmp $@



# CODE BELOW HERE IS FROM ENVO's MAKEFILE AND IS YET TO BE IMPLEMENTED FOR SDGIO
# ----------------------------------------
# SLIMS
# ----------------------------------------
# These all depend on envo-basic, which is the whole ontology (ie all classes), minus non-basic axioms (e.g. complex owl axioms, some relations)
#subsets/EnvO-Lite-GSC.owl: subsets/envo-basic.obo
#	owltools $< --extract-ontology-subset --subset EnvO-Lite-GSC --iri $(OBO)/envo/subsets/$@ -o $@
#subsets/EnvO-Lite-GSC.obo: subsets/EnvO-Lite-GSC.owl
#	obolib-owl2obo $< -o $@

# ----------------------------------------
# Temp
# ----------------------------------------
#mappings/gold-mapping.txt: envo-simple.obo
#	blip-findall -u metadata_nlp_parent_dist2_hook -r obol_av -i sources/gold.obo -i $< -u metadata_nlp -goal index_entity_pair_label_match "entity_pair_label_reciprocal_best_intermatch(X,Y,S)" -use_tabs -label -no_pred > $@.tmp && cut -f1-4 $@.tmp | sort -u > $@



# ----------------------------------------
# ROBO-TEMPLATES **NEW**
# ----------------------------------------
DEV := $(SDG)sdgio/dev/

modules/%.owl: templates/%.tsv
	echo '' > $@
	$(ROBOT) merge \
	--input sdgio-edit.owl \
	template \
	--template $< \
	annotate \
	--ontology-iri "$(DEV)$@" \
	--output $@
