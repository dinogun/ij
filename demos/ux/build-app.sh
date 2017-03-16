#!/bin/bash
#
# (C) Copyright IBM Corporation 2016, 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
set -eo pipefail

BASEDIR=$PWD
export LOGFILE=$BASEDIR/app-build-deploy-$$.log

function timediff() {
	ssec=`date --utc --date "$1" +%s`
	esec=`date --utc --date "$2" +%s`

	diffsec=$(($esec-$ssec))
	echo $diffsec
}

function getdate() {
	date "+%Y-%m-%d %H:%M:%S"
}

rm -rf java-tomcat-example-app

echo 2>&1 | tee -a $LOGFILE
echo "#####################################################################" 2>&1 | tee -a $LOGFILE
echo "             Test application build and deploy to Bluemix            " 2>&1 | tee -a $LOGFILE
echo "#####################################################################" 2>&1 | tee -a $LOGFILE
echo 2>&1 | tee -a $LOGFILE

echo -n "Pull the latest Docker images for ibmjava:8-maven and ibmjava:8-sfj-alpine ... " 2>&1 | tee -a $LOGFILE
(docker pull ibmjava:8-sfj-alpine >> $LOGFILE)
(docker pull ibmcom/ibmjava:8-maven >> $LOGFILE)
echo "done" 2>&1 | tee -a $LOGFILE

echo -n "Cloning the latest application source tree ... " 2>&1 | tee -a $LOGFILE
(git clone https://github.com/catalyzeio/java-tomcat-example-app.git 2>> $LOGFILE)
echo "done" 2>&1 | tee -a $LOGFILE

echo -n "Build application using the IBM maven Docker Image ... " 2>&1 | tee -a $LOGFILE
pushd java-tomcat-example-app >> $LOGFILE
(docker run --user=`id -u`:`id -g` -v $PWD:/opt/myapp -w /opt/myapp -it --rm ibmcom/ibmjava:8-maven mvn package >> $LOGFILE)
popd >> $LOGFILE
echo "done" | tee -a $LOGFILE

echo -n "Build a minimal application Docker Image using the ibmjava:sfj-alpine Image ... " 2>&1 | tee -a $LOGFILE
(docker build -t myapp . >> $LOGFILE)
echo "done" | tee -a $LOGFILE
echo 2>&1 | tee -a $LOGFILE

# To run the docker image locally and test
# http://localhost:8080
# docker run -p 8080:8080 myapp

# Need to login prior to pushing images
# cf login
# cf ic login

# Tag the image with the bluemix registry
docker tag myapp:latest registry.ng.bluemix.net/dino_registry/myapp:latest

echo "Docker Image sizes" 2>&1 | tee -a $LOGFILE
echo 2>&1 | tee -a $LOGFILE
docker images | grep -e "ibmjava" -e "myapp" 2>&1 | tee -a $LOGFILE
echo 2>&1 | tee -a $LOGFILE

echo -n "Push Docker image to Bluemix ... "
sdate=$(getdate)
# Change the registry to point to your registry
docker push registry.ng.bluemix.net/dino_registry/myapp:latest
edate=$(getdate)
echo "done"

tdiff=$(timediff "$sdate" "$edate")
echo
echo "############################################"
printf "Time taken: %02d:%02d mins\n" "$((tdiff/60))" "$((tdiff%60))"
echo "############################################"
echo 

