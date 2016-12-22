# Docker project Makefile
#   started by Mike Cramer
#   on November 15, 2016
#
# Automation for Docker build, test run, and push to registry server.
#

include tools.makefile

## Docker Application Dependancies
#    What order to build prerequisates in order.
#
# Example:
#    distro/app/build: distro/-base/build

centos/httpd/: centos/-base/ ;

centos/httpd-perl/: centos/httpd/ ;

hub/gruntySass/: hub/rubyNode/ ;