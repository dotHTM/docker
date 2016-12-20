FROM moby.gw.utexas.edu:5000/centos7
MAINTAINER Mike Cramer <imanerd {at} me [dot] com>


LABEL description="A CentOS container with mysql"

LABEL image_name=centos7-httpd
LABEL image_server=

LABEL filter_distro=centos
LABEL filter_app=mysql

RUN yum -y update && yum clean all
RUN yum -y install scl-utils && yum clean all

RUN yum install -y centos-release-SCL && yum clean all

RUN yum install -y --enablerepo=centosplus mysql55-mysql-server && yum clean all

VOLUME /var/lib/mysql

ADD my.cnf /opt/rh/mysql55/root/etc/my.cnf
ADD docker-entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

EXPOSE 3306

CMD ["/entrypoint.sh"]
