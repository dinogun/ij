#!/bin/sh

/opt/ibm/java/jre/bin/java -version

# Turn on shared class cache with size 50 MB
#/opt/ibm/java/jre/bin/java -Xshareclasses:name=sharedCC,cacheDir=/opt/ibm/java/cache,nonfatal,silent -Xscmx50M -version
# See link for more info on Shared class cache
# http://www-01.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.lnx.80.doc/diag/appendixes/cmdline/Xshareclasses.html?lang=en


