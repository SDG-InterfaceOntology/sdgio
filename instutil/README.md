Experimental approach to automatically extract an OWL representation of the goals and targets.

Opened merged.owl in Protege

The model is

    goal
      --[has-part]-->
         target
           --[has-participant]--> ENVO-continuant
           --[has-part]--> ENVO-process
           --[MENTIONS]--> Anything else

As we keep adding to SDGIO, we will keep rerunning the pipeline, and in theory the results should improve

exclusions can be added directly to the prolog

           
