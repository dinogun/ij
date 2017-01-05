# (C) Copyright IBM Corporation 2016, 2017.
#
# ------------------------------------------------------------------------------
#               NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
#
#                       PLEASE DO NOT EDIT IT DIRECTLY.
# ------------------------------------------------------------------------------
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

FROM ibmjava:829-jre

MAINTAINER Dinakar Guniguntala <dinakar.g@in.ibm.com> (@dinogun)

RUN apt-get update \
    && apt-get install -y --no-install-recommends procps \
    && rm -rf /var/lib/apt/lists/*

RUN ESUM="79668080e7592130c795d25d92ef4e79af62b4831a953e5f62a0a16c933f06e8" \
    && BENCHMARK_URL="http://j9.ottawa.ibm.com/j9dt/incubator/virt/docker/ibmjava/idlemicrobench.tar.gz" \
    && wget -q -O /root/idlemicrobench.tar.gz $BENCHMARK_URL \
    && cd /root \
    && tar -xvf /root/idlemicrobench.tar.gz \
    && rm -f /root/idlemicrobench.tar.gz

CMD ["/root/idlemicrobench/rundemo.sh"]
