# Overview

The images in this repository contain IBM® SDK, Java™ Technology Edition. See the license section below for restrictions relating to the use of this image. For more information about IBM® SDK, Java™ Technology Edition and API documentation, go [here](http://www.ibm.com/developerworks/java/jdk/docs.html). For tutorials, recipes and Java usage in Bluemix, go [here](http://www.ibm.com/developerworks/java).

Java is a registered trademark of Oracle and/or its affiliates.

# Images

There are two primary types of Images corresponding to the Java Packages: SDK and the JRE. These images can be used as the basis for custom built images for running your applications.

For running a pre-built jar file with the jre image:

```dockerfile
FROM ibmjava:jre
RUN mkdir /opt/app
COPY japp.jar /opt/app
CMD ["java", "-jar", "/opt/app/japp.jar"]
```

You can build and run the Docker Image as follows:

```console
docker build -t japp .
docker run -it --rm japp
```

If you want to have the jar file on the host instead of in the container, you can mount the host path onto the container as follows:

```dockerfile
FROM ibmjava:jre
CMD ["java", "-jar", "/opt/app/japp.jar"]
```

```console
docker build -t japp .
docker run -it -v /path/on/host/system/jars:/opt/app ibmjava:jre japp
```

# Using the Shared Class Cache feature

The IBM JRE provides a feature [Class data sharing](http://www-01.ibm.com/support/knowledgecenter/SSYKE2_8.0.0/com.ibm.java.lnx.80.doc/diag/understanding/shared_classes.html) which offers transparent and dynamic sharing of data between multiple Java Virtual Machines running on the same host by using shared memory backed by a file. To benefit from Class data sharing, a common location needs to be shared between containers either through the host or a data volume container.

```dockerfile
FROM ibmjava:jre
RUN mkdir /opt/shareclasses
RUN mkdir /opt/app
COPY japp.jar /opt/app
CMD ["java", "-Xshareclasses:cacheDir=/opt/shareclasses", "-jar", "/opt/app/japp.jar"]
```

```console
docker build -t japp .
docker run -it -v /path/on/host/shareclasses/dir:/opt/shareclasses japp
```

# See Also

See the Websphere-Liberty [Image](https://hub.docker.com/_/websphere-liberty/) which builds on top of the ibmjava docker image.
