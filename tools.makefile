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
actionVerbs = build run push tag
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
	@echo "## Building the docker image w/ tag ${makeBuildTag}"
	${toolPath}dkBuild.sh ${dir $@} ${makeBuildTag} | tee $@

## Run a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}run.log}: $${dir $$@}build
	@echo "## Running the docker image"
	${toolPath}dkRun.sh ${dir $@} | tee $@

## Tag a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}tag.log}: force $${dir $$@}build
	@echo "## Taggin the docker image w/ tag ${makeBuildTag}"
	${toolPath}dkTag.sh ${dir $@} ${makeBuildTag} | tee $@

## Push a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}push.log}: $${dir $$@}tag
	@echo "## Pushing the docker image w/ tag ${makeBuildTag}"
	${toolPath}dkPush.sh ${dir $@} ${makeBuildTag} | tee $@


#### ---- ---- ---- ---- ---- ---- ----

## Phony recipes
.PHONY: default debug list usage cls clean hitman repo-local force \
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

usage:
	@echo Usage:
	@echo "    make <distro>/<application>/<build|run|push>"
	@echo
	@echo Example:
	@echo "    make centos/-base/build"
	@echo

cls:
	clear

## Clean log files
clean: force
	-${foreach anDir,${dockerContextDirs},\
		${foreach anVerb,${actionVerbs},\
			rm ${anDir}${anVerb}.log ;\
		}\
	}

hitman: force clean
	dkHitman.sh
	dkHitman.sh

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

