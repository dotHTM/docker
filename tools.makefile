## Docker project Makefile
#    started by Mike Cramer
#    on November 15, 2016
#
#  Automation for Docker build, test run, and push to registry server.
#

makeBuildTag := ${shell date "+%Y%m%d_%H%M%S"}-make_${USER}

## Find all Docker files and get a list of their parent directories.
#  These must be stored at the same directory depth.
#  I.E. ./distro/app/Dockerfile
searchDepthString = */*
dockerContextFiles = ${wildcard ${searchDepthString}/Dockerfile}
dockerContextDirs = ${dir ${dockerContextFiles}}

## Actions which will build phony and clean recipes quickly
actionVerbs = build run tag push
toolPath = Tools/

.SECONDEXPANSION:

#### ---- ---- ---- ---- ---- ---- ----

## Default action when running `make` without an argument

default: cls list usage;

#### ---- ---- ---- ---- ---- ---- ----

## Dependancies are handled by your project's Makefile or GNUmakefile.
#  Include this file in your project makefile with the line:
#       include tools.makefile
#  Then define a list of recipes with dependancies.
#    Example:
#       distro/app/build: distro/-base/build

#### ---- ---- ---- ---- ---- ---- ----

## Per-Action recipes

## Build a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}build.log}: $${dir $$@}Dockerfile
	@echo "## $@"
	@echo "#  Building the docker image w/ tag ${makeBuildTag}"
	${toolPath}dkBuild.sh ${dir $@} ${makeBuildTag} | tee $@

## Run a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}run.log}: $${dir $$@}build
	@echo "## $@"
	@echo "#  Running the docker image"
	${toolPath}dkRun.sh ${dir $@} | tee $@

## Tag a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}tag.log}: force $${dir $$@}build
	@echo "## $@"
	@echo "#  Taggin the docker image w/ tag ${makeBuildTag}"
	${toolPath}dkTag.sh ${dir $@} ${makeBuildTag} | tee $@

## Push a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}push.log}: $${dir $$@}tag
	@echo "## $@"
	@echo "#  Pushing the docker image w/ tag ${makeBuildTag}"
	${toolPath}dkPush.sh ${dir $@} ${makeBuildTag} | tee $@


#### ---- ---- ---- ---- ---- ---- ----

## Phony recipes
.PHONY: default debug list usage cls clean hitman-subtask hitman lsr repo-local force \
	build run tag push usage \
	${foreach anDir,${dockerContextDirs},${foreach anVerb,${actionVerbs},${anDir}${anVerb}}} \
	${foreach anDir,${dockerContextDirs},${anDir}} \
	${foreach anDir,${dockerContextDirs},${anDir}touch}

#### ---- ---- ----

debug:
	@echo "------"
	@ENV
	@echo "------"
	@echo "makeBuildTag: "
	@echo "    ${makeBuildTag}\n"
	@echo "dockerContextFiles: "
	@echo "    ${dockerContextFiles}\n"
	@echo "dockerContextDirs: "
	@echo "    ${dockerContextDirs}\n"
	@echo "------"

#### ---- ---- ----

## List the project's contained Dockerfiles
list:
	@echo Dirs found w/ contexts:
	@${foreach anDir,${dockerContextDirs},echo "    "${anDir};}
	@echo
	@echo Actions available:
	@${foreach anVerb,${actionVerbs},echo "    "${anVerb};}
	@echo

build:
	@echo "Usage:"
	@echo "  make <distro>/<application>/[build[.log]]"
	@echo 
	@echo "'build' depends on the existance of a Dockerfile in the given path"

run:
	@echo "Usage:"
	@echo "  make <distro>/<application>/run[.log]"
	@echo 
	@echo "'run' depends on 'build'"

tag:
	@echo "Usage:"
	@echo "  make <distro>/<application>/tag[.log]"
	@echo 
	@echo "'tag' depends on 'build'"
	@echo "'tag' is forced"

push:
	@echo "Usage:"
	@echo "  make <distro>/<application>/push[.log]"
	@echo 
	@echo "'push' depends on 'tag' which is forced"

usage:
	@echo "Usage:"
	@echo "    make <distro>/<application>/<actionVerb>"
	@echo
	@echo "Example:"
	@echo "    make centos/-base/build"
	@echo

cls:
	clear

## Clean log files
clean: force
	-rm ${searchDepthString}/*.log

hitman-subtask:
	dkHitman.sh
	dkHitman.sh

hitman: force cls clean hitman-subtask repo-local

lsr: repo-local

repo-local:
	docker images

## The force prerequisite
force: ;

## Shorter phony action recipes
${foreach anDir,${dockerContextDirs},${foreach anVerb,${actionVerbs},${anDir}${anVerb}}}: $$@.log

${foreach anDir,${dockerContextDirs},${anDir}}: $$@build.log

${foreach anDir,${dockerContextDirs},${anDir}touch}: force $${dir $$@}Dockerfile
	touch ${dir $@}Dockerfile

#### ---- ---- ---- ---- ---- ---- ----

