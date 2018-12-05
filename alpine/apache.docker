FROM alpine:latest

RUN apk update
RUN apk add httpd php
RUN apk add \
        mod_ssl \
        mod_fcgid \
        mod_wsgi \
        mod_auth_gssapi \
        mod_auth_kerb \
        mod_nss
RUN yum clean all

EXPOSE 80 443

ADD apache_entry.sh /
RUN chmod -v +x /apache_entry.sh

CMD ["/apache_entry.sh"]
