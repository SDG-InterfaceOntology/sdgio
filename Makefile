test:
	cd src && make

sdgio-bundle.owl: sdgio.owl
	owltools --use-catalog $< --merge-imports-closure -o $@
#	robot  merge -i $< -o $@  https://github.com/ontodev/robot/issues/50
