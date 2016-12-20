# Dockerfiles

## make Tools

Included with this is a Makefile and Tools directory for automation of local docker projects.

The mindset of these tools is to build seperate images, each that depend on the last for building up to an end application that's delivered.

To build a dependancy tree, find the section in the Makefile with the comment:

```makefile
## Docker Application Dependancies
```

Add your stages and dependancies in the following style:

```makefile
#    distro/app/build: distro/-base/build

centos/httpd/build: centos/-base/build
centos/httpd-perl/build: centos/httpd/build
centos/mariadb/build: centos/-base/build
centos/mysql/build: centos/-base/build
```

Sample images from Docker Hub are provided for `hello-world` and `rainbowstream`
