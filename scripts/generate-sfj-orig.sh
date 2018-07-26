#!/bin/bash

function parse_platform_specific() {
    src_base=$(basename $1)
    arch_info=$(echo $src_base |cut -d "-" -f 3)

    if [ "$arch_info" == "ppc64" ]
    then
        echo "ppc64"
    elif [ "$arch_info" == "x86_64" ]
    then
        echo "amd64"
    elif [ "$arch_info" == "ppc64le" ]
    then
        echo "ppc64le"
    elif [ "$arch_info" == "s390x" ]
    then
        echo "s390x"
    elif [ "$arch_info" == "s390" ]
    then
        echo "s390"
    elif [ "$arch_info" == "i386" ]
    then
        echo "i386"
    else
        echo "unknown platform"
    fi
}

# 1. Prepare Env to make an SFJ

# 1.1. Parse arguments
argc=$#
if [ $argc != 3 ]; then
    echo " Usage: `basename $0` IBM-full-JRE-path target-path jcl-bin-path"
    exit 1
fi

# 1.2. Validate prerequisites(tools) necessary for making an SFJ 
tools="jar jarsigner pack200 strip"
for tool in $tools; do
    if [ "`which $tool`" = "" ]; then
        echo "$tool not found, please add $tool into PATH"
        exit 1
    fi
done

# 1.3. Set input of this script
src=$1
target=$2
jclbin=$3
if [ -d $target ]; then
    echo "Target already exists"
    exit 1
fi

# 1.3.1. Derive arch from src arg
lib_arch_dir=$(parse_platform_specific $src)

if [ "$lib_arch_dir" == "unknown platform" ]
then
    echo "unknown platfrom, the script exits"
    exit 1
fi

if [ "$lib_arch_dir" == "i386" -o "$lib_arch_dir" == "s390" ]
then
    proc_type="32bit"
else
    proc_type="64bit"
fi

# 1.4. Store necssary directories paths
scriptdir=`dirname $0`
basedir=`pwd`
cd $scriptdir
scriptdir=`pwd`
cd $basedir
mkdir -p $target
echo "Copyiing $src to $target..."
cp -rf $src/* $target/
cd $target
root=`pwd`

# 2. Start to trim full jre
echo "Removing files..."

# 2.1 Remove unnecessary folders and files
rm -r docs/ properties/
cd jre/bin
rm -rf classic/ j9vm/ ControlPanel jcontrol ikey* java_vm javaw* jdmpview jextract kinit klist ktab policytool pack200 unpack200
cd ../lib/
rm -rf applet/ boot/ ddr/ deploy desktop/ endorsed/
cd ext/
rm CmpCrmf.jar dnsns.jar dtfj*.jar gskikm.jar ibmcmsprovider.jar ibmjcefips.jar ibmkeycert.jar nashorn.jar traceformat.jar xmlencfw.jar

# 2.2 Special treat for fonts
cd ../fonts/
rm fonts.dir LucidaBright* LucidaSansDemiBold.ttf LucidaTypewriter*
echo '6
LucidaSansRegular.ttf -b&h-lucidasans-medium-r-normal-sans-0-0-0-0-p-0-iso8859-1
LucidaSansRegular.ttf -b&h-lucidasans-medium-r-normal-sans-0-0-0-0-p-0-iso8859-2
LucidaSansRegular.ttf -b&h-lucidasans-medium-r-normal-sans-0-0-0-0-p-0-iso8859-4
LucidaSansRegular.ttf -b&h-lucidasans-medium-r-normal-sans-0-0-0-0-p-0-iso8859-5
LucidaSansRegular.ttf -b&h-lucidasans-medium-r-normal-sans-0-0-0-0-p-0-iso8859-7
LucidaSansRegular.ttf -b&h-lucidasans-medium-r-normal-sans-0-0-0-0-p-0-iso8859-9' >> fonts.dir

# 2.3 Go on to remove unnecessary folders and files
cd ../$lib_arch_dir/
rm -rf classic/ libdeploy.so libjavaplugin_* libjsoundalsa.so libnpjp2.so libsplashscreen.so
# Only remove the default dir for 64bit versions
if [ "$proc_type" == "64bit" ]
then
    rm -rf default/
fi
cd ..
rm -rf images/icons/ locale/ oblique-fonts/ security/javaws.policy aggressive.jar deploy.jar javaws.jar jexec jlm.src.jar plugin.jar 
cd ..
rm -rf plugin/

# 2.3 Special treat for removing ZOS specific charsets 
echo "Removing charsets..."
mkdir -p $root/charsets_class
cd $root/charsets_class
jar -xf $root/jre/lib/charsets.jar
#ibmEbcdic="277 278 280 284 285 290 297 300 300A 420 420S 424 500 870 871 875
ibmEbcdic="290 300 300A 833 834 835 836 837 838 918 924 924_LF 930 930A 933 935 937 939 939A 1025 1026 1027 1046 1046S 1047_LF 1097 1112 1122 1123 1153 1364 1371 1377 1388 1390 1390A 1399 1399A 4933 16684 16684A"

# Generate sfj-excludes-charsets list as well
[ ! -e $root/jre/lib/sfj/sun/nio/cs/ext/sfj-excludes-charsets ] || rm -rf $root/jre/lib/sfj/sun/nio/cs/ext/sfj-excludes-charsets
exclude_charsets=""

for charset in $ibmEbcdic; do
    #rm sun/io/ByteToCharCp$charset.class
    #rm sun/io/CharToByteCp$charset.class
    rm sun/nio/cs/ext/IBM$charset.class
    rm -f sun/nio/cs/ext/IBM$charset\$*.class

    exclude_charsets="${exclude_charsets} IBM$charset"
done
mkdir -p $root/jre/lib/sfj/sun/nio/cs/ext
echo ${exclude_charsets} > $root/jre/lib/sfj/sun/nio/cs/ext/sfj-excludes-charsets
cp $root/jre/lib/sfj/sun/nio/cs/ext/sfj-excludes-charsets sun/nio/cs/ext/
#rm sun/io/ByteToCharDBCS_EBCDIC.class
#rm sun/io/CharToByteDBCS_EBCDIC.class
rm sun/nio/cs/ext/DBCS_IBM_EBCDIC_Decoder.class
rm sun/nio/cs/ext/DBCS_IBM_EBCDIC_Encoder.class

jar -cfm $root/jre/lib/charsets.jar META-INF/MANIFEST.MF * 
cd ..
rm -rf $root/charsets_class

# 2.4 Remove classes in rt.jar
echo "Removing classes in rt.jar..."
mkdir -p $root/rt_class
cd $root/rt_class
jar -xf $root/jre/lib/rt.jar
mkdir -p $root/rt_remaining_class
remainingClasses='com/sun/java/swing/plaf/motif/MotifLookAndFeel sun/applet/AppletAudioClip sun/awt/motif/MFontConfiguration sun/awt/X11/OwnershipListener sun/awt/X11/XAWTXSettings sun/awt/X11/XAWTLookAndFeel sun/awt/X11/XBaseWindow sun/awt/X11/XCanvasPeer sun/awt/X11/XComponentPeer sun/awt/X11/XClipboard sun/awt/X11/XCustomCursor sun/awt/X11/XDataTransferer sun/awt/X11/XEmbedCanvasPeer sun/awt/X11/XEmbeddedFrame sun/awt/X11/XEventDispatcher sun/awt/X11/XFontPeer sun/awt/X11/XMouseDragGestureRecognizer sun/awt/X11/XMSelectionListener sun/awt/X11/XRootWindow sun/awt/X11/XToolkit sun/awt/X11/XWindow sun/java2d/opengl/GLXVolatileSurfaceManager'
for class in $remainingClasses; do
    cp --parents $class.class $root/rt_remaining_class/
    cp --parents $class\$*.class $root/rt_remaining_class/ >null 2>&1
done
deleteList='com/sun/javadoc/ com/sun/jdi/ com/sun/jarsigner/ com/sun/mirror/ com/sun/source/ com/sun/istack/internal/tools/ com/sun/istack/internal/ws/ META-INF/services/com.sun.jdi.connect.Connector META-INF/services/com.sun.jdi.connect.spi.TransportService META-INF/services/com.sun.mirror.apt.AnnotationProcessorFactory META-INF/services/com.sun.tools.xjc.Plugin com/sun/tools/ sun/jvmstat/ sun/nio/cs/ext/ sun/awt/HKSCS.class sun/awt/motif/X11GB2312$Decoder.class sun/awt/motif/X11GB2312$Encoder.class sun/awt/motif/X11GB2312.class sun/awt/motif/X11GBK$Encoder.class sun/awt/motif/X11GBK.class sun/awt/motif/X11KSC5601$Decoder.class sun/awt/motif/X11KSC5601$Encoder.class sun/awt/motif/X11KSC5601.class sun/rmi/rmic/ sun/tools/asm/ sun/tools/java/ sun/tools/javac/ com/sun/tools/classfile/ com/sun/tools/javap/ sun/tools/jcmd/ sun/tools/jconsole/ sun/tools/jps/ sun/tools/jstat/ sun/tools/jstatd/ sun/tools/native2ascii/ sun/tools/serialver/ sun/tools/tree/ sun/tools/util/ sun/security/tools/JarBASE64Encoder.class sun/security/tools/JarSigner.class sun/security/tools/JarSignerParameters.class sun/security/tools/JarSignerResources.class sun/security/tools/JarSignerResources_ja.class sun/security/tools/JarSignerResources_zh_CN.class sun/security/tools/SignatureFile$Block.class sun/security/tools/SignatureFile.class sun/security/tools/TimestampedSigner.class sun/security/rsa/SunRsaSign.class sun/security/ssl/ com/sun/net/ssl/internal/ssl/ javax/crypto/ sun/security/internal/ com/sun/crypto/provider/ META-INF/services/com.sun.tools.attach.spi.AttachProvider com/sun/tools/attach/ org/relaxng/datatype/ com/sun/codemodel/ com/sun/xml/internal/dtdparser/ com/sun/xml/internal/rngom/ com/sun/xml/internal/xsom/ com/sun/tools/script/shell/ sun/tools/attach/ sun/tools/jstack/ sun/tools/jinfo/ sun/tools/jmap/ sun/awt/motif/ sun/awt/X11/ sun/applet/ sun/java2d/opengl/ com/sun/java/swing/plaf/com/sun/javadoc/ com/sun/jdi/ com/sun/jarsigner/ com/sun/mirror/ com/sun/source/ com/sun/istack/internal/tools/ com/sun/istack/internal/ws/ META-INF/services/com.sun.jdi.connect.Connector META-INF/services/com.sun.jdi.connect.spi.TransportService META-INF/services/com.sun.mirror.apt.AnnotationProcessorFactory META-INF/services/com.sun.tools.xjc.Plugin com/sun/tools/ sun/jvmstat/ sun/nio/cs/ext/ sun/awt/HKSCS.class sun/awt/motif/X11GB2312$Decoder.class sun/awt/motif/X11GB2312$Encoder.class sun/awt/motif/X11GB2312.class sun/awt/motif/X11GBK$Encoder.class sun/awt/motif/X11GBK.class sun/awt/motif/X11KSC5601$Decoder.class sun/awt/motif/X11KSC5601$Encoder.class sun/awt/motif/X11KSC5601.class sun/rmi/rmic/ sun/tools/asm/ sun/tools/java/ sun/tools/javac/ com/sun/tools/classfile/ com/sun/tools/javap/ sun/tools/jcmd/ sun/tools/jconsole/ sun/tools/jps/ sun/tools/jstat/ sun/tools/jstatd/ sun/tools/native2ascii/ sun/tools/serialver/ sun/tools/tree/ sun/tools/util/ sun/security/tools/JarBASE64Encoder.class sun/security/tools/JarSigner.class sun/security/tools/JarSignerParameters.class sun/security/tools/JarSignerResources*.class sun/security/tools/SignatureFile$Block.class sun/security/tools/SignatureFile.class sun/security/tools/TimestampedSigner.class sun/security/rsa/SunRsaSign.class sun/security/ssl/ com/sun/net/ssl/internal/ssl/ javax/crypto/ sun/security/internal/ com/sun/crypto/provider/ META-INF/services/com.sun.tools.attach.spi.AttachProvider com/sun/tools/attach/ org/relaxng/datatype/ com/sun/codemodel/ com/sun/xml/internal/dtdparser/ com/sun/xml/internal/rngom/ com/sun/xml/internal/xsom/ com/sun/tools/script/shell/ sun/tools/attach/ sun/tools/jstack/ sun/tools/jinfo/ sun/tools/jmap/ sun/awt/motif/ sun/awt/X11/ sun/applet/ sun/java2d/opengl/ com/sun/java/swing/plaf/gtk com/sun/java/swing/plaf/motif com/sun/java/swing/plaf/nimbus com/sun/java/swing/plaf/windows com/sun/corba'
for class in $deleteList; do
    rm -rf $class
done
cp -rf $root/rt_remaining_class/* ./
rm -rf $root/rt_remaining_class

# 2.6 Generate SFJ java version class
###############################################################################################################################################
####    Begin to generate SFJ java version class: Version.class                                                                             ####
###############################################################################################################################################

# a. get java version tempalte
echo "Copy jcl-bin Version.java.tmp to target's jre/lib/sfj/sun/misc/"
[ ! -e $root/jre/lib/sfj/sun/misc/ ] || rm -rf $root/jre/lib/sfj/sun/misc/
mkdir -p $root/jre/lib/sfj/sun/misc/

cp $jclbin/src/Version.java.temp  $root/jre/lib/sfj/sun/misc/
cp $root/rt_class//sun/misc/Version.class  $root/jre/lib/sfj/sun/misc/

# a.1 generate GetJavaversion.java
echo "Generate GetJavaversion.java"

echo "public class GetJavaversion {"                      > $root/jre/lib/sfj/GetJavaversion.java
echo "    public static void main(String[] args) {"       >> $root/jre/lib/sfj/GetJavaversion.java
echo "        sun.misc.Version.print();"                  >> $root/jre/lib/sfj/GetJavaversion.java
echo "        sun.misc.Version.printFullVersion(\"java\");" >> $root/jre/lib/sfj/GetJavaversion.java
echo "    }"                                              >> $root/jre/lib/sfj/GetJavaversion.java
echo "}"                                                  >> $root/jre/lib/sfj/GetJavaversion.java

# a.2 extrac full jre's Version fields to javaversion.txt
echo "Extrac full jre's Version fields to javaversion.txt"

javac -d $root/jre/lib/sfj $root/jre/lib/sfj/GetJavaversion.java
java -Xbootclasspath/p:$root/jre/lib/sfj/ -cp $root/jre/lib/sfj/ GetJavaversion > $root/jre/lib/sfj/javaversion.txt 2>&1

# b. retrive version fields and modify them to become SFJ version fields
echo "Retrive version fields and modify them to become SFJ version fields"

launcher_name="java"
java_version="1.8.0"
java_runtime_version=$(cat $root/jre/lib/sfj/javaversion.txt |awk 'NR == 2 {print $0}'|sed -e 's/^.* (build //' -e 's/)$//')
java_runtime_name=$(cat $root/jre/lib/sfj/javaversion.txt |awk 'NR == 2 {print $0}'|sed -e 's/ (build.*$//')
jcl_runtime_version=$(cat $root/jre/lib/sfj/javaversion.txt |grep  "^JCL - "|sed -e 's/^JCL - //' -e 's/ based on Oracle.*$//')
sun_build_version=$(cat $root/jre/lib/sfj/javaversion.txt |grep  "^JCL - "|sed -e 's/^.* based on Oracle //')
java_full_version=$(cat $root/jre/lib/sfj/javaversion.txt |grep  "^java full version "|sed -e 's/^java full version //')

java_runtime_version="${java_runtime_version} Small Footprint"
java_full_version="${java_full_version} Small Footprint"

# c. write the SFJ version fileds into $root/jre/lib/sfj/sun/misc/Version.java.temp and
#    rename it to Version.java
echo "Write the SFJ version fileds into target's jre/lib/sfj/sun/misc/Version.java.temp and"
echo "rename it to Version.java"

sed -i -e "s/@launcher_name@/${launcher_name}/" $root/jre/lib/sfj/sun/misc/Version.java.temp
sed -i -e "s/@java_version@/${java_version}/" $root/jre/lib/sfj/sun/misc/Version.java.temp
sed -i -e "s/@java_runtime_version@/${java_runtime_version}/" $root/jre/lib/sfj/sun/misc/Version.java.temp
sed -i -e "s/@java_runtime_name@/${java_runtime_name}/" $root/jre/lib/sfj/sun/misc/Version.java.temp
sed -i -e "s/@jcl_runtime_version@/${jcl_runtime_version}/" $root/jre/lib/sfj/sun/misc/Version.java.temp
sed -i -e "s/@sun_build_version@/${sun_build_version}/" $root/jre/lib/sfj/sun/misc/Version.java.temp
sed -i -e "s/@java_full_version@/${java_full_version}/" $root/jre/lib/sfj/sun/misc/Version.java.temp

rm $root/jre/lib/sfj/sun/misc/Version.class
mv $root/jre/lib/sfj/sun/misc/Version.java.temp $root/jre/lib/sfj/sun/misc/Version.java


# d. javac $jclbin/src/Version.java into $root/jre/lib/sfj/sun/misc/Version.class
echo "Compile javac jcl-bin src/Version.java into target's jre/lib/sfj/sun/misc/Version.class"

javac  -d $root/jre/lib/sfj/ $root/jre/lib/sfj/sun/misc/Version.java

# e. copy SFJ Version.class into $root/rt_class
echo "Copy SFJ Version.class into target's jre/lib/rt_class"

cp -rf $root/jre/lib/sfj/sun/misc/Version.class ./sun/misc/

###############################################################################################################################################
####    End to enerate SFJ java version class: Version.class                                                                               ####
###############################################################################################################################################

# 2.7. Restruct rt.jar 
jar -cfm $root/jre/lib/rt.jar META-INF/MANIFEST.MF *
cd ..
rm -rf rt_class

# 2.8. Using pack200 to strip debug info in jars
list="`find . -regex .*\.jar`"
for jar in ${list}; do
    isSigned=`jarsigner -verify $jar | grep 'jar verified'`
    if [ "$isSigned" = "" ]; then
        echo "Striping debug info in ${jar}"
        pack200 --repack --strip-debug -J-Xmx1024m ${jar}.new ${jar}
        mv ${jar}.new ${jar}
    fi
done

# 2.8. Using strip to remove debug information in share library
echo "Striping debug info in object files"
find jre/bin -type f ! -path */javad.options -exec strip -s {} \;
find jre/lib/$lib_arch_dir -regex .*\.so -exec strip -s {} \;

# 2.9. Remove temp $root/jre/lib/sfj folder
rm -rf $root/jre/lib/sfj

# 3.0. Create version.properties files
sed -i '/sdk.version/ s/$/Small Footprint/' jre/lib/version.properties

# 3.1 Complete create SFJ
echo "Done"
