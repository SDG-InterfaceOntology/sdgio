Experimental approach to automatically extract an OWL representation of the goals and targets.

Opened merged.owl in Protege

The model is

    goal
      --[has-part]-->
         target
           --[has-participant]--> ENVO-continuant
           --[has-part]--> ENVO-process
           --[MENTIONS]--> Anything else

As we keep adding to SDGIO, we will keep rerunning the pipeline, and
in theory the results should improve. We will also add heuristics to
refine the semantically useless MENTIONS assertions (there are useful
to indicate that we may be missing something in the ontology).

exclusions can be added directly to the prolog

           
