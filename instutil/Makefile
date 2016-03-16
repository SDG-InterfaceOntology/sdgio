targets.ttl: The-Targets.md
	./inst2ttl.pl $< > $@.tmp && owltools $@.tmp && mv $@.tmp $@
.PRECIOUS: targets.ttl

# make like this: remake targets-ann.ttl >& DEBUG
targets-ann.ttl: targets.ttl
	blip-findall -debug ann -r gemet -r envo -i ../src/sdgio.obo -goal ix -i $< -consult annotate_goals.pro annotate_label/2 > $@.tmp  && mv $@.tmp $@

merged.owl: targets.ttl targets-ann.ttl
	owltools --catalog-xml ../src/catalog-v001.xml $^ ../src/sdgio.owl --merge-support-ontologies --merge-imports-closure -o $@

