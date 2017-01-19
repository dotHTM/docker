FROM dothtm/centos7
MAINTAINER Mike Cramer <imanerd {at} me [dot] com>

LABEL description="A CentOS container with Apache"

LABEL image_name=centos7-httpd
LABEL image_server=


LABEL filter_distro=centos
LABEL filter_app=httpd


RUN yum -y update && \
		yum -y install \
			httpd \
			mod_ssl \
			openssl \
			&& yum clean all

# Simple startup script to avoid some issues observed with container restart 
ADD run-httpd.sh /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

CMD ["/run-httpd.sh"]


