#!/bin/sh
# Wrapper script for docker.
#
# This is used primarily for wrapping the GNU Make workflow.
# Instead of typing "make TARGET", type "./run.sh make TARGET".
# This will run the make workflow within a docker container.
#
# The SDGIO repo doesn't yet use the src/ontology folder;
# so we map to .
#
# See README-editors.md for more details.
docker run -v $PWD/../:/work -w /work/src/ {% if project.robot_java_args is defined %}-e ROBOT_JAVA_ARGS='{{ project.robot_java_args }}' {% endif %}--rm -ti obolibrary/odkfull "$@"
