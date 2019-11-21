
# This makefile will be run by the build script or docker autobuild hooks to produce the app.jar file we need
# for this worker. 
build:
	(cd /usr/projects/query-worker-project && mvn package)

	# This parent project has many modules. Each module is a type of worker with exceptio of app-module
	# that has the shared code base for all workers.

	# Add a cp command here for each type of worker that has been created. 
	# We are eliminating the version number.
	cp /usr/projects/query-worker-project/iris-jdbc-query-worker/target/iris-jdbc-query-worker-*.jar /usr/projects/iris-jdbc-query-worker.jar