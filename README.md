# Dockerfiles

## make Tools

Included with this is a Makefile and Tools directory for automation of local docker projects.

The mindset of these tools is to build seperate images, each that depend on the last for building up to an end application that's delivered.

### Creating your own images

Sample images from Docker Hub are provided for `hello-world` and `rainbowstream`

The `Makefile` reads the contents of each subfolder and it's next child folder, looking for a `Dockerfile` at exactly that level. It's advised to store all projects in this style:

```
distro/application/Dockerfile

centos/-base/Dockerfile
centos/httpd/Dockerfile

hub/hello-world/Dockerfile

etc/your-app/Dockerfile
```

#### Dockerfile Labels

Labels are parsed by the Tools to aid with sorting and selection of items as they are built.

Required Dockerfile Labels are:

```dockerfile
LABEL image_name=hello-world
```

Optional Labels

```dockerfile
LABEL version="1.0"
LABEL description="A CentOS container with Apache and Perl"

LABEL image_server=

LABEL filter_distro=centos
LABEL filter_app=httpd-perl
```

### Dependancy Tree

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
