FROM moby.gw.utexas.edu:5000/centos7
MAINTAINER Mike Cramer <imanerd {at} me [dot] com>

LABEL description="A CentOS container with mariadb"

LABEL image_name=centos7-httpd
LABEL image_server=

LABEL filter_distro=centos
LABEL filter_app=mariadb

# ------------------------------------

RUN yum -y update && \
		yum -y install \
			perl \
			mod_perl \
			sendmail \
			&& yum clean all

RUN yum -y install --setopt=tsflags=nodocs epel-release && \ 
    yum -y install --setopt=tsflags=nodocs mariadb-server bind-utils pwgen psmisc hostname && \ 
    yum -y erase vim-minimal && \
    yum -y update && yum clean all


# Fix permissions to allow for running on openshift
COPY fix-permissions.sh ./
RUN ./fix-permissions.sh /var/lib/mysql/   && \
    ./fix-permissions.sh /var/log/mariadb/ && \
    ./fix-permissions.sh /var/run/

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

# Place VOLUME statement below all changes to /var/lib/mysql
VOLUME /var/lib/mysql

# By default will run as random user on openshift and the mysql user (27)
# everywhere else
USER 27

EXPOSE 3306
CMD ["mysqld_safe"]
