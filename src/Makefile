# This Makefile is for use by the ENVO Release Manager (currently cjm)
# Also used by Jenkins: http://build.berkeleybop.org/job/build-envo
# 
# requirements: Oort (http://code.google.com/p/owltools/wiki/OortIntro)
#
# To make a release, type 'make release' in this directory

OBO=http://purl.obolibrary.org/obo
SDG=http://purl.unep.org/sdg
USECAT= --catalog-xml catalog-v001.xml
SRC= sdgio-edit.owl
ROBOT=./robot

##MODULES=exposure
MODULES=
MODULE_FILES = $(patsubst %,modules/%.owl,$(MODULES))

all: sdgio.owl

sdgio.owl: sdgio-edit.owl $(MODULE_FILES)
	robot merge -i $<  $(patsubst %,-i %,$(MODULE_FILES)) reason -r ELK -s true -o $@ convert -o sdgio.obo
sdgio.owl: sdgio-edit.owl $(ROBOT)
	$(ROBOT) merge -i $< reason -r ELK -s true -o $@ convert -o sdgio.obo


ROBOJENKINS=http://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin

robot.jar:
	wget $(ROBOJENKINS)/$@ -O $@
robot: robot.jar
	wget $(ROBOJENKINS)/$@ -O $@ && chmod +x $@


# ----------------------------------------
# Regenerate imports
# ----------------------------------------
# Uses OWLAPI Module Extraction code

# Type 'make imports/X_import.owl' whenever you wish to refresh the import for an ontology X. This is when:
#
#  1. X has changed and we want to include these changes
#  2. We have added one or more new IRIs from X into $(SRC)
#  3. We have removed references to one or more IRIs in X from $(SRC)
#
# You should NOT edit these files directly, changes will be overwritten.
#
# If you want to add something to these, edit $(SRC) and add an axiom with an IRI from X. You don't need to add any information about X.

# Base URI for local subset imports
SDG_IMPORTS_BASE_URI = $(SDG)

# Ontology dependencies
# We don't include clo, as this is currently not working
IMPORTS = pato uberon chebi ro bfo envo iao pco

# Make this target to regenerate ALL
all_imports: $(patsubst %, imports/%_import.owl,$(IMPORTS)) $(patsubst %, imports/%_import.obo,$(IMPORTS))

# We will edit this as the SDGIO needs become apparent...
KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of RO:0002176 RO:0000057 BFO:0000055 RO:0002473 RO:0002351 RO:0002131
# 'part of' 'has part' 'develops from' 'immediate_transformation_of' 'connects' 'has participant'  'realizes' 'composed primarily of' 'has member' 'overlaps'


imports/%_import.obo: imports/%_import.owl
	owltools $(USECAT) $< -o -f obo $@

# clone remote ontology locally, perfoming some excision of relations and annotations
mirror/%.owl: $(SRC)
	owltools $(OBO)/$*.owl --remove-annotation-assertions -l -s -d --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS)  -o $@
.PRECIOUS: mirror/%.owl
mirror/ro.owl: $(SRC)
	owltools $(OBO)/ro.owl --merge-imports-closure --remove-annotation-assertions -r -l -s -d -o $@
.PRECIOUS: mirror/%.owl

mirror/uberon.owl: $(SRC)
	owltools $(OBO)/uberon.owl  --remove-axiom-annotations  --make-subset-by-properties -f $(KEEPRELS) --remove-dangling-annotations --remove-annotation-assertions -l -s -d --set-ontology-id $(OBO)/uberon.owl -o $@

.PRECIOUS: mirror/%.owl
mirror/po.owl: $(SRC)
	owltools $(OBO)/po.owl --remove-annotation-assertions -l -s -d --remove-axiom-annotations --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS) --set-ontology-id $(OBO)/po.owl -o $@
.PRECIOUS: mirror/%.owl
ncbitaxon.obo:
	wget -N $(OBO)/ncbitaxon.obo
.PRECIOUS: ncbitaxon.obo
mirror/ncbitaxon.owl: ncbitaxon.obo
	OWLTOOLS_MEMORY=12G owltools $< --remove-annotation-assertions -l -s -d --remove-axiom-annotations --remove-dangling-annotations  --set-ontology-id $(OBO)/ncbitaxon.owl -o $@
.PRECIOUS: mirror/ncbitaxon.owl

mirror/pco.owl: imports/pco_basic.obo
	OWLTOOLS_MEMORY=12G owltools $< --set-ontology-id $(OBO)/pco.owl -o $@

# Use ROBOT, driven entirely by terms lists NOT from source ontology
imports/%_import.owl: mirror/%.owl imports/%_terms.txt
	robot extract -i $< -T imports/$*_terms.txt --method BOT -O $(SDG_IMPORTS_BASE_URI)/$@ -o $@


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
# Reports
# ----------------------------------------
#reports/envo-%.csv: envo.owl sparql/%.sparql
#	arq --data $< --query sparql/$*.sparql --results csv > $@.tmp && mv $@.tmp $@


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
	robot merge \
	--input sdgio-edit.owl \
	template \
	--template $< \
	annotate \
	--ontology-iri "$(DEV)$@" \
	--output $@
