# This Makefile is for use by the SDGIO Release Managers (currently cjm and plb)
# As used by Jenkins: http://build.berkeleybop.org/job/build-envo
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
## will need a module for harzards and other defined tasks
## such as land rights, chemicals and wastes, ecosystem services ...
MODULES=
MODULE_FILES = $(patsubst %,modules/%.owl,$(MODULES))

# Ontology dependencies
# We don't include clo, as this is currently not working
IMPORTS = pato uberon chebi ro bfo envo iao pco obi ogms
IMPORTS_OWL = $(patsubst %, imports/%_import.owl,$(IMPORTS)) $(patsubst %, imports/%_import.obo,$(IMPORTS))

all: all_imports sdgio.owl
test: sdgio.owl

sdgio.owl: sdgio-edit.owl $(MODULE_FILES)  $(ROBOT)
	$(ROBOT) merge -i $<  $(patsubst %,-i %,$(MODULE_FILES)) reason -r ELK -s true annotate -V $(SDG)/releases/`date +%Y-%m-%d`/sdgio.owl -o $@
###	$(ROBOT) merge -i $<  $(patsubst %,-i %,$(MODULE_FILES)) reason -r ELK -s true annotate -V $(SDG)/releases/`date +%Y-%m-%d`/sdgio.owl -o tmp-$@ && owltools $(USECAT) tmp-$@ --remove-imports-declarations -o $@
sdgio.obo: sdgio.owl $(ROBOT)
	$(ROBOT) convert -i $< -o sdgio.obo
#sdgio.owl: sdgio-edit.owl $(ROBOT)
#	$(ROBOT) merge -i $< reason -r ELK -s true -o $@ convert -o sdgio.obo

# The URL below will pull the latest, successful ROBOT build from the Berkeley servers.
# ROBOT itself is in the "robot.jar" file, so it will execute across platforms with Java. There is a
# launch script "robot" which is called later in this file. If you're running Cygwin,
# that script will use cygpath to make sure everything is findable.
ROBOJENKINS=http://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin

robot.jar:
	wget $(ROBOJENKINS)/$@ -O $@
robot: robot.jar
	wget $(ROBOJENKINS)/$@ -O $@ && chmod +x $@ && touch $@

release: sdgio.owl sdgio.obo
	cp $^ ../ && cp imports/* ../imports


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
KEEPRELS = BFO:0000050 BFO:0000051 RO:0002202 immediate_transformation_of RO:0002176 RO:0000057 BFO:0000055 RO:0002473 RO:0002351 RO:0002131
# 'part of' 'has part' 'develops from' 'immediate_transformation_of' 'connects' 'has participant'  'realizes' 'composed primarily of' 'has member' 'overlaps'

# Use ROBOT, driven entirely by terms lists NOT from source ontology
imports/%_import.owl: mirror/%.owl imports/%_terms.txt $(ROBOT)
	$(ROBOT) extract -i $< -T imports/$*_terms.txt --method BOT -O $(SDG_IMPORTS_BASE_URI)/$@ -o $@
.PRECIOUS: imports/%_import.owl

# Use owltools to create OBO files for the imports
imports/%_import.obo: imports/%_import.owl
	owltools $(USECAT) $< -o -f obo $@

# clone remote ontology locally, perfoming some excision of relations and annotations
mirror/%.owl: $(SRC)
	owltools $(OBO)/$*.owl --remove-annotation-assertions -l -s -d --remove-dangling-annotations --make-subset-by-properties -f $(KEEPRELS)  -o $@
.PRECIOUS: mirror/%.owl

SIMPLIFY= --merge-imports-closure --extract-mingraph --remove-abox --make-subset-by-properties -f // --remove-annotation-assertions -r -l -s -o
# we need to remove text defs from IAO as they conflict
mirror/iao.owl: $(SRC)
	owltools $(OBO)/iao.owl $(SIMPLIFY)  $@
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

ncbitaxon.obo:
	wget -N $(OBO)/ncbitaxon.obo
.PRECIOUS: ncbitaxon.obo

mirror/ncbitaxon.owl: ncbitaxon.obo
	OWLTOOLS_MEMORY=12G owltools $< --remove-annotation-assertions -l -s -d --remove-axiom-annotations --remove-dangling-annotations  --set-ontology-id $(OBO)/ncbitaxon.owl -o $@
.PRECIOUS: mirror/ncbitaxon.owl

mirror/pco.owl: imports/pco_basic.obo
	owltools $< --set-ontology-id $(OBO)/pco.owl -o $@


	
# ----------------------------------------
# Reports
# ----------------------------------------
# Generate a CSV term list from the OWL files created.
#reports/sdgio-%.csv: sdgio.owl sparql/%.sparql
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
