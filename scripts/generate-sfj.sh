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

# Section 1
# Tools provided with the JRE

# Java tools
rm -f bin/classic/*
rm -f bin/j9vm/*
# Java executable program
# Runs without using a console window.
rm -f bin/javaw
# Kerberos tools
# Obtains and caches tickets.
rm -f bin/kinit
# Displays entries in the local credentials cache and key table.
rm -f bin/klist
# Manages the principal names and service keys stored in a local key table.
rm -f bin/ktab
# Common Object Request Broker Architecture (CORBA) tool
# Transient naming service.
rm -f bin/tnameserv
# Compression tools
# Transforms a JAR file into a compressed pack200 file.
rm -f bin/pack200
# Transforms a compressed pack200 file into a JAR file.
rm -f bin/unpack200
# Desktop tool - Runs JAR files.
rm -f lib/jexec


# Section 2
# Remove Java functions

# Domain Name Service (DNS)
rm -f lib/ext/dnsns.jar
# Javascript support
rm -f lib/ext/javascript.jar
# Nashorn
rm -f lib/ext/nashorn.jar
# Uncompressed references support
rm -rf lib/$lib_arch_dir/classic
if [ "$proc_type" == "64bit" ]
then
	rm -f lib/$lib_arch_dir/default
fi

# Java language management source code support
rm -f lib/jlm.src.jar
# Aggressive performance function
rm -f lib/aggressive.jar


# Section 3
# Classes, locale, and font support
# To reduce disk footprint, certain classes in the rt.jar file are removed,
# together with some language and locale support.

# 3.1
# Classes in rt.jar

deleteList='com/sun/javadoc/ com/sun/jdi/ com/sun/jarsigner/ com/sun/mirror/ com/sun/source/ \
			com/sun/istack/internal/tools/ com/sun/istack/internal/ws/ \
			META-INF/services/com.sun.jdi.connect.Connector \
			META-INF/services/com.sun.jdi.connect.spi.TransportService \
			META-INF/services/com.sun.mirror.apt.AnnotationProcessorFactory \
			META-INF/services/com.sun.tools.xjc.Plugin \
			com/sun/tools/ sun/jvmstat/ sun/nio/cs/ext/ sun/awt/HKSCS.class \
			sun/awt/motif/X11GB2312$Decoder.class sun/awt/motif/X11GB2312$Encoder.class \
			sun/awt/motif/X11GB2312.class sun/awt/motif/X11GBK$Encoder.class \
			sun/awt/motif/X11GBK.class sun/awt/motif/X11KSC5601$Decoder.class \
			sun/awt/motif/X11KSC5601$Encoder.class sun/awt/motif/X11KSC5601.class \
			sun/rmi/rmic/ sun/tools/asm/ sun/tools/java/ sun/tools/javac/ com/sun/tools/classfile/ \
			com/sun/tools/javap/ sun/tools/jcmd/ sun/tools/jconsole/ sun/tools/jps/ \
			sun/tools/jstat/ sun/tools/jstatd/ sun/tools/native2ascii/ sun/tools/serialver/ \
			sun/tools/tree/ sun/tools/util/ sun/security/tools/JarBASE64Encoder.class \
			sun/security/tools/JarSigner.class sun/security/tools/JarSignerParameters.class \
			sun/security/tools/JarSignerResources*.class sun/security/tools/SignatureFile$Block.class \
			sun/security/tools/SignatureFile.class sun/security/tools/TimestampedSigner.class \
			sun/security/provider/Sun.class sun/security/rsa/SunRsaSign.class \
			sun/security/ssl/ com/sun/net/ssl/internal/ssl/ javax/crypto/ \
			sun/security/internal/ com/sun/crypto/provider/ \
			META-INF/services/com.sun.tools.attach.spi.AttachProvider com/sun/tools/attach/ \
			org/relaxng/datatype/ com/sun/codemodel/ com/sun/xml/internal/dtdparser/ \
			com/sun/xml/internal/rngom/ com/sun/xml/internal/xsom/ com/sun/tools/script/shell/ \
			sun/tools/attach/ sun/tools/jstack/ sun/tools/jinfo/ sun/tools/jmap/ \
			sun/awt/motif/ sun/awt/X11/ sun/applet/ sun/java2d/opengl/ com/sun/java/swing/plaf/'

# 3.2
# Locale support
rm -f lib/ext/localedata.jar lib/locale lib/charsets.jar lib/resources.jar

# 3.3
# Font support
rm -rf lib/fonts/LucidaBright*.ttf lib/fonts/LucidaSansDemiBold.ttf \
	   lib/fonts/LucidaTypewriter*.ttf lib/oblique-fonts

# Section 4
# Desktop, plug-in, and Web Start support

# Section 4.1
# Remove functions associated with a user interface
rm -rf lib/desktop lib/images/icons \
	   lib/$lib_arch_dir/libsoundalsa.so lib/$lib_arch_dir/libsplashscreen.so \
	   lib/$lib_arch_dir/libjsoundalsa.so


# Section 4.2
# Browser plug-in, Applet viewer, and Web Start support
rm -rf bin/ControlPanel bin/jcontrol bin/java_vm \
	   lib/$lib_arch_dir/libjavaplugin*.so lib/$lib_arch_dir/libnpjp2.so \
	   lib/locale lib/plugin.jar plugin \
	   bin/javaws lib/security/javaws.policy lib/javaws.jar \
	   lib/deploy lib/$lib_arch_dir/libdeploy.so lib/deploy.jar


# Section 5
# IBM security support
# Some security providers are removed from the IBM Java runtime environment (JRE) to leave only core security functions.
# IBM provides a range of security providers that implement various security algorithms and mechanisms.

# Security policy file creation and management tool
rm -f bin/policytool
# iKeyman command-line utility
rm -f bin/ikeycmd
# iKeyman utility (graphical user interface)
rm -f bin/ikeyman
# PKI Certificate Management Protocols implementation
rm -f lib/ext/CmpCrmf.jar
# JNDI implementation for Domain Name Service look-up
rm -f lib/ext/dnsns.jar
# IBM Certificate Management
rm -f lib/ext/ibmcmsprovider.jar
# IBM JCE FIPS certified cryptographic algorithms
rm -f lib/ext/ibmjcefips.jar
# IBM Key Certificate Management
rm -f lib/ext/ibmkeycert.jar
# IBM PKCS11# implementation provider
rm -f lib/ext/ibmpkcs11impl.jar
# PKCS key management
rm -f lib/ext/gskikm.jar
# IBM Simple Authentication and Security Layer (SASL) provider
rm -f lib/ext/ibmsaslprovider.jar
# IBM XML cryptography
rm -f lib/ext/ibmxmlcrypto.jar
# IBM XML security
rm -f lib/ext/ibmxmlencprovider.jar
# XML encryption
rm -f lib/ext/xmlencfw.jar 


# Section 6
# Diagnostic tool support

# Diagnostic Tool Framework for Java
rm -f lib/ext/dtfj-interface.jar lib/ext/dtfj.jar lib/ddr
# Dump utilities
rm -f bin/jdmpview lib/ext/jdmpview.jar lib/ext/dtfjview.jar bin/jextract
# Trace functions
rm -f lib/ext/traceformat.jar

