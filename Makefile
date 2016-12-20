# Docker project Makefile
#   started by Mike Cramer
#   on November 15, 2016
#
# Automation for Docker build, test run, and push to registry server.
#

makeBuildTag := ${shell date "+%Y%m%d_%H%M%S"}-make_${USER}

## Find all Docker files and get a list of their parent directories. These must be stored at the same directory depth. I.E. ./distro/app/Dockerfile
searchDepthString = */*
dockerContextFiles = ${wildcard ${searchDepthString}/Dockerfile}
dockerContextDirs = ${dir ${dockerContextFiles}}

## Actions which will build phony and clean recipes quickly
actionVerbs = build run push
toolPath = Tools/

.SECONDEXPANSION:

#### ---- ---- ---- ---- ---- ---- ----

## Default action when running `make` without an argument

default: clearScreen list usage;

#### ---- ---- ---- ---- ---- ---- ----

## Docker Application Dependancies
#    What order to build prerequisates in order.
#
# Examples:
#    distro/app/build: distro/-base/build
#
#    centos/httpd/build: centos/-base/build
#    centos/httpd-perl/build: centos/httpd/build
#    centos/mariadb/build: centos/-base/build
#    centos/mysql/build: centos/-base/build

#### ---- ---- ---- ---- ---- ---- ----

## Per-Action recipes

## Build a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}build.log}: $${dir $$@}Dockerfile
	${toolPath}dkBuild.sh ${dir $@} ${makeBuildTag} | tee $@

## Run a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}run.log}: $${dir $$@}build $${dir $$@}Dockerfile
	${toolPath}dkRun.sh ${dir $@} | tee $@

## Push a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}push.log}: $${dir $$@}build $${dir $$@}Dockerfile
	${toolPath}dkPush.sh ${dir $@} ${makeBuildTag} | tee $@

#### ---- ---- ---- ---- ---- ---- ----

## Phony recipes
.PHONY: default list clean force usage clearScreen \
	${foreach anDir,${dockerContextDirs},${foreach anVerb,${actionVerbs},${anDir}${anVerb}}} 

#### ---- ---- ----

## List the project's contained Dockerfiles
list:
	@echo Dirs found w/ contexts:
	@${foreach anDir,${dockerContextDirs},echo "    "${anDir};}
	@echo
	@echo Actions available:
	@${foreach anVerb,${actionVerbs},echo "    "${anVerb};}
	@echo

usage:
	@echo Usage:
	@echo "    make <distro>/<application>/<build|run|push>"
	@echo
	@echo Example:
	@echo "    make centos/-base/build"
	@echo

clearScreen:
	clear

## Clean log files
clean:
	-${foreach anDir,${dockerContextDirs},\
		${foreach anVerb,${actionVerbs},\
			rm ${anDir}${anVerb}.log ;\
		}\
	}

## The force prerequisite
force: ;

## Shorter phony action recipes
${foreach anDir,${dockerContextDirs},${foreach anVerb,${actionVerbs},${anDir}${anVerb}}}: $$@.log

#### ---- ---- ---- ---- ---- ---- ----

