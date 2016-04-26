# Overview

The images in this repository contain IBM® SDK, Java™ Technology Edition. See the license section below for restrictions relating to the use of this image. For more information about IBM® SDK, Java™ Technology Edition, see the [Java developerWorks site](http://www.ibm.com/developerworks/java) and [documentation](http://www.ibm.com/developerworks/java/jdk/docs.html)

Java is a registered trademark of Oracle and/or its affiliates.

# Images

There are two primary types of Images corresponding to the Java Packages: SDK and the JRE. These images can be used as the basis for custom built images for running your applications.

For running a pre-built jar file with the jre image

```dockerfile
FROM ibmjava:jre
RUN mkdir /opt/app
COPY japp.jar /opt/app
CMD ["java", "-jar", "/opt/app/japp.jar"]
```

You can build and run the Docker Image as follows

```console
docker build -t japp .
docker run -it --rm japp
```

If you want to have the jar file on the host instead of in the container, you can mount the host path onto the container as follows

```dockerfile
FROM ibmjava:jre
CMD ["java", "-jar", "/opt/app/japp.jar"]
```

```console
docker run -it -v /path/on/host/system/jars:/opt/app ibmjava:jre japp.jar
```

# See Also

See the Websphere-Liberty [Image](https://hub.docker.com/_/websphere-liberty/) which builds on top of the ibmjava docker image.

