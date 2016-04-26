# Supported tags and respective `Dockerfile` links

-	[`8-sdk`, `8`, `sdk` (*ibmjava/8-sdk/x86_64/Dockerfile*)](https://github.com/ibmruntimes/ci.docker/blob/master/ibmjava/8-sdk/x86_64/Dockerfile)
-	[`8-jre`, `jre` (*ibmjava/8-jre/x86_64/common/Dockerfile*)](https://github.com/ibmruntimes/ci.docker/blob/master/ibmjava/8-jre/x86_64/Dockerfile)
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

The Dockerfiles and associated scripts are licensed under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).

Licenses for the products installed within the images are as follows:

-	[IBM® SDK, Java™ Technology Edition](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=&li_formnum=L-JWOD-9SYNCP&title=IBM%C2%AE+SDK%2C+Java+Technology+Edition%2C+Version+8.0&l=en) (International License Agreement for Non-Warranted Programs)

Note: These licenses do not permit further distribution and that terms IBM® SDK, Java™ Technology Edition images restrict usage to a developer machine or build server only.

For issues relating specifically to this Docker image, please use the [GitHub issue tracker](https://github.com/ibmruntimes/ci.docker/issues). For more general issues relating to IBM® SDK, Java™ Technology Edition you can get help [here](https://www.ibm.com/developerworks/community/forums/html/forum?id=11111111-0000-0000-0000-000000000367).

