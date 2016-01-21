This folder contains scripts or other material which may be needed by users of Cygwin in Windows.
Most are modifications of existing material.


--- robot
The paths provided by Unix will not work under Windows through Cygwin. This robot launching script (which is based on the version found here: http://build.berkeleybop.org/job/robot/lastSuccessfulBuild/artifact/bin/robot) checks if cygwin is being used and then uses cygpath to allow the robot.jar file to be launched.
