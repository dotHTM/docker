# Dockerfiles and GNU Makefile

Started November 2016 by Mike Cramer

# Building Docker Containers with GNU make

## Structure

The project makefile consists of two parts: the project `Makefile` and the reusable `tools.makefile`.

The project `Makefile` consists of the `include tools.makefile` line and docker project dependancies (building docker images in stages).

To add a new `Dockerfile` project, create directories in the format `distro/application` in the root of the project folder, and create a `Dockerfile` inside. Create or add any additional project specific files such as application source or config files that will not need to be modified by an admin or developer later.

**Sample:**

- Project root
	- distro
		- application
			- `Dockerfile`
			- `run.sh`
			- `static-config`
			- any other static files

Consider that any files added to the Docker Image though this method will be available to any other Container built from it. This section should be kept to a minimum, enough to define the application source, installation scripts, default configuration, or an entry-point script. Many of these can be overridden later, so it’s best to consider what’s needed for an application in general, not a specific implementation.

Implementation of the final configuration for the end-use will be done in a `docker-compose.yaml` file for local development and later deployment to the actual server that the application will be run from.

## Automatic Make Recipes

The `Makefile` will scan the project directory looking for `Dockerfile`s exactly two directories deep. A collection of action verbs will be combined with those available paths.

To get a basic list of recipes that the Makefile knows about, from the project root, run `$ make`

**Sample output:**

```text
$ make

Dirs found w/ contexts:
    centos/-base/
    centos/httpd-perl/
    centos/httpd/
    centos/manage-pna-apache/
    centos/mariadb/
    centos/mysql/
    hub/hello-world/
    rhel7/-base/

Actions available:
    build
    run
    tag
    push

Usage:
    make <distro>/<application>/<build|run|push>

Example:
    make centos/-base/build
```

The Project’s `Makefile` determines the dependancies of each step for `make` to build. The developer should know from the creation of their `Dockerfile` which image their application depends on.

Notice how the above sample usage text lists directories in alphabetical order, not build dependency order.

## Actions

Actions will trigger any child items down to the requested verb:

- `build`
	- `run`
	- `tag` (forced)
		- `push`

If you are looking at the project for the first time after cloning it from git, then you can immediately jump into a specific running container with a command like `$ make centos/httpd-perl/run` which will run all build dependancies in order, then the run script for the final Docker Context.

Notice that to `tag` or `push`, does not require `run` for the Container. Also, `tag` always triggers the recipe, even if the `Dockerfile` hasn’t been updated. This ensures that any `push` commands will always have a similar repository tag with all other build steps.

So long as the local Docker Registry hasn’t been reset, any previous step that involved a `build` or `tag` will still be available on the local development machine to be rolled back. It’s important to remember this later for development when considering to use a Docker Image with the `:latest` tag or a specific, known good configuration by it’s build timestamp tag.

This last point will also be somewhat true for the designated Docker Registry server, which might be cleaned up with a later data management decision.

## Adding a new Application

The scripts used by `make` in this project first read the Dockerfile of a given directory, and assign Labels for later search and filtering use. At present, the only required Label by the tools is `image_name` but the present recommended Labels are:

- `image_name`
- `image_server`
- `filter_distro`
- `filter_app`

Such as in this example:

```dockerfile
FROM centos7-httpd
MAINTAINER Michael Cramer <user@email.com>

LABEL version="1.0"
LABEL description="A CentOS container with Apache and Perl"

LABEL image_name=centos7-httpd_perl
LABEL image_server=

LABEL filter_distro=centos
LABEL filter_app=httpd-perl

RUN yum -y update && \
		yum -y install \
			perl \
			mod_perl \
			sendmail \
			&& yum clean all
```

The Labels `image_server` and `image_name` are the most vital, as they will be used to direct the pushed image to the correct registry server and repo respectively.

After Label declarations, commands for building the image are used.

