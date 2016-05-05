### Overview

The images in this repository contain IBM® SDK, Java™ Technology Edition. See the license section for restrictions that relate to the use of this image. For more information about IBM® SDK, Java™ Technology Edition and API documentation, see the [IBM Knowledge Center](http://www.ibm.com/support/knowledgecenter/SSYKE2/welcome_javasdk_family.html). For tutorials, recipes, and Java usage in Bluemix, see [IBM developerWorks](http://www.ibm.com/developerworks/java).

Java and all Java-based trademarks and logos are trademarks or registered trademarks of Oracle and/or its affiliates.

### Images

There are two primary types of images: the Software Developers Kit (SDK) and the Java Runtime Environment (JRE). These images can be used as the basis for custom built images for running your applications.

To run a pre-built jar file with the JRE image, use the following commands:

```dockerfile
FROM ibmjava:jre
RUN mkdir /opt/app
COPY japp.jar /opt/app
CMD ["java", "-jar", "/opt/app/japp.jar"]
```

You can build and run the Docker Image as shown in the following example:

```console
docker build -t japp .
docker run -it --rm japp
```

If you want to have the jar file on the host instead of in the container, you can mount the host path onto the container by using the following commands:

```dockerfile
FROM ibmjava:jre
CMD ["java", "-jar", "/opt/app/japp.jar"]
```

```console
docker build -t japp .
docker run -it -v /path/on/host/system/jars:/opt/app japp
```

### Using the Class Data Sharing feature

IBM SDK, Java Technology Edition provides a feature called [Class data sharing](http://www-01.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.lnx.80.doc/diag/understanding/shared_classes.html). This mechanism offers transparent and dynamic sharing of data between multiple Java virtual machines running on the same host thereby reducing the amount of physical memory consumed by JVM instances. By providing partially verified classes and possibly pre-loaded classes in memory, this mechanism also improves the start up time of JVM.

To enable class data sharing among "JVM's" running in different containers on the same host, a common location must be shared between containers. This can be either through the host or a data volume container. When enabled, class data sharing creates a named "class cache", which is a memory-mapped file, at the common location. This feature is enabled by passing "-Xshareclasses" option to the JVM which can be done in Dockerfile as illustrated below:

```dockerfile
FROM ibmjava:jre
RUN mkdir /opt/shareclasses
RUN mkdir /opt/app
COPY japp.jar /opt/app
CMD ["java", "-Xshareclasses:cacheDir=/opt/shareclasses", "-jar", "/opt/app/japp.jar"]
```

The "cacheDir" sub-option specifies the location of the "class cache", which is "/opt/sharedclasses" in the above example. When sharing through host, a host path is to be mounted onto the container at the location the JVM expects the "class cache". For example:

```console
docker build -t japp .
docker run -it -v /path/on/host/shareclasses/dir:/opt/shareclasses japp
```

When sharing through data volume container, create a named data volume container that shares a volume which is same as the the location of the "class cache" to be used by the JVM:

```console
docker create -v /opt/shareclasses --name classcache japp /bin/true
```

Then start your JVM container using --volumes-from flag to mount the shared volume, as illustrated below:

```console
docker run -it --volumes-from classcache japp
```

### See Also

See the [Websphere-Liberty image](https://hub.docker.com/_/websphere-liberty/), which builds on top of this IBM docker image for Java.
