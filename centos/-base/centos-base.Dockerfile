FROM centos:7
MAINTAINER Mike Cramer <imanerd {at} me [dot] com>


LABEL description="A base CentOS container for building others"

LABEL image_tag=dothtm/centos7

LABEL filter_distro=centos
LABEL filter_app=base

RUN yum -y update && \
		yum install -y \
			which \
			nano && \
		yum clean all

