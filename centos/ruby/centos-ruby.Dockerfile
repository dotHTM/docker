FROM dothtm/centos7
MAINTAINER Mike Cramer <imanerd {at} me [dot] com>

LABEL description="A CentOS container with Apache"

LABEL image_tag=dothtm/centos7-httpd

LABEL filter_distro=centos
LABEL filter_app=httpd


RUN yum -y update && \
		yum -y install \
			&& yum clean all

