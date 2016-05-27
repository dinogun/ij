#!/bin/bash
#
# (C) Copyright IBM Corporation 2016.
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

usage() {
	echo
	echo "Usage: $0 <java_version> <target_repository>"
	echo "Eg   : $0  8 ibmcom"
	exit 1
}

if [ $# -gt 2 -o $# -eq 0 ]; then
	usage 
elif [ $# == 1 ]; then
	version=$1
	target="ibmcom"
elif [ $# == 2 ]; then
	version=$1
	target=$2
fi

SOURCE_REPO="dinogun/ij"
LOG_FILE=sync-v$version-to-$target-$$.log

function log {
	echo $@ 2>&1 | tee -a $LOG_FILE
}

log "####[I]: version is $version and target repository is $target."

checkFail() {
	if [ $? != 0 ]; then
		log $@
		exit 1
	fi
}

removeAndRetag() {
	rtarget=$1
	rtag=$2
	rpackage=$3

	docker rmi $rtarget/ibmjava:$rtag $rtarget/ibmjava:$rpackage >> $LOG_FILE 2>&1
	log "####[I]: [$SOURCE_REPO:$rtag]: Tagging image as [$rtarget/ibmjava:$rtag] ..."
	docker tag $SOURCE_REPO:$rtag $rtarget/ibmjava:$rtag >> $LOG_FILE 2>&1
	log "####[I]: [$SOURCE_REPO:$rtag]: Tagging image as [$rtarget/ibmjava:$rpackage] ..."
	docker tag $SOURCE_REPO:$rtag $rtarget/ibmjava:$rpackage >> $LOG_FILE 2>&1
}

pushToTarget() {
	ptarget=$1
	ptag=$2

	log
	log "####[I]: [$ptarget/ibmjava:$ptag]: Pushing image to hub.docker ..."
	docker push $ptarget/ibmjava:$ptag >> $LOG_FILE 2>&1
	checkFail "####[E]: [$ptarget/ibmjava:$ptag]: Image push failed, check the target repository provided. \
			   ####[E]: Are you logged-in and the userid has push authorization?"
	log "####[I]: [$ptarget/ibmjava:$ptag]: Image pushed successfully."
}

pullAndSync() {
	target=$1
	version=$2
	tag=$2-$3
	package=$3
	
	log
	log "####[I]: [$SOURCE_REPO:$tag]: Pulling image ..."
	docker pull $SOURCE_REPO:$tag >> $LOG_FILE 2>&1
	checkFail "####[E]: [$SOURCE_REPO:$tag]: Pulling image failed, exiting ..."

	removeAndRetag $target $tag $package
	pushToTarget $target $tag
	pushToTarget $target $package

	if [ $package == "jre" ]; then
		docker rmi $target/ibmjava:$version $target/ibmjava:latest >> $LOG_FILE 2>&1
		docker tag $SOURCE_REPO:$tag $target/ibmjava:$version >> $LOG_FILE 2>&1
		log "####[I]: [$SOURCE_REPO:$tag]: Tagging image as [$target/ibmjava:$version] ..."
		docker tag $SOURCE_REPO:$tag $target/ibmjava:latest >> $LOG_FILE 2>&1
		log "####[I]: [$SOURCE_REPO:$tag]: Tagging image as [$target/ibmjava:latest] ..."

		pushToTarget $target $version
		pushToTarget $target latest
	fi

	if [ $package == "jre" -o $package == "sfj" ]; then
		log
		log "####[I]: [$SOURCE_REPO:$tag-alpine]: Pulling image ..."
		docker pull $SOURCE_REPO:$tag-alpine >> $LOG_FILE 2>&1
		checkFail "####[E]: [$SOURCE_REPO:$tag-alpine]: Pulling image failed, exiting ..."
		removeAndRetag $target $tag-alpine $package-alpine
		pushToTarget $target $tag-alpine
		pushToTarget $target $package-alpine
	fi
}

pullAndSync $target $version jre
pullAndSync $target $version sfj
pullAndSync $target $version sdk

log
log "See $LOG_FILE for more details"

