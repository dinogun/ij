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

FROM ubuntu:14.04

MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)

RUN apt-get update \
    && apt-get install -y wget unzip \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_VERSION=8 \
    JAVA_RMF=0.2.0 \
    JAVA_TYPE="jre" \
    JAVA_EDITION="javase" \
    RUNTIMES_URL="http://j9.ottawa.ibm.com/j9dt/incubator/virt/dhe/ibmruntimes/java/"

# Install JRE if the downloaded md5sum matches what is available in the .yml file
RUN TARCH=$(uname -p) \
    && JAVA_VRMF=$JAVA_VERSION.$JAVA_RMF \
    && YML_FILENAME=ibm-java-$JAVA_TYPE-$JAVA_VERSION.$JAVA_RMF-linux-$TARCH-$JAVA_EDITION.yml \
    && wget -q -O /tmp/$YML_FILENAME $RUNTIMES_URL/$JAVA_VERSION/$YML_FILENAME \
    && JAVA_URL=$(cat /tmp/$YML_FILENAME | sed -n '/'$JAVA_VRMF'/{n;p}' | sed -n 's/\s*uri:\s//p' | tr -d '\r') \
    && wget -q $JAVA_URL -U UA-IBM-JAVA-Docker -O /tmp/ibm-java.bin \
    && ESUM=$(cat /tmp/$YML_FILENAME | sed -n '/'$JAVA_VRMF'/,/md5sum/p' | sed -n 's/\s*md5sum:\s//p' | tr -d '\r') \
    && ASUM=$(md5sum /tmp/ibm-java.bin | cut -d" " -f1) \
    && if [ "$ESUM" = "$ASUM" ]; then \
          chmod +x /tmp/ibm-java.bin; \
          echo "INSTALLER_UI=silent" > /tmp/response.properties; \
          echo "USER_INSTALL_DIR=/opt/ibm/java" >> /tmp/response.properties; \
          echo "LICENSE_ACCEPTED=TRUE" >> /tmp/response.properties; \
          mkdir /opt/ibm; \
          /tmp/ibm-java.bin -i silent -f /tmp/response.properties; \
          rm -f /tmp/response.properties; \
       else \
          echo "ERROR: md5sum of the downloaded file does not match"; \
          exit 1; \
       fi \
    && rm -f /tmp/ibm-java.bin

ENV JAVA_HOME=/opt/ibm/java \
    PATH=/opt/ibm/java/jre/bin:$PATH
