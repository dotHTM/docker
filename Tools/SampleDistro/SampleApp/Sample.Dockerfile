FROM centos:7

MAINTAINER Mike Cramer <imanerd {at} me [dot] com>

LABEL description="A base CentOS container for building others"

## Explicit declaration
LABEL image_name=dothtm/centos7
## Component declaration
# LABEL image_user=dothtm
# LABEL image_server=
# LABEL image_tag=centos7

LABEL filter_distro=centos
LABEL filter_app=base

RUN yum -y update && \
		yum install -y \
			which \
			nano && \
		yum clean all



