FROM dothtm/centos7-httpd
MAINTAINER Mike Cramer <imanerd {at} me [dot] com>

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

