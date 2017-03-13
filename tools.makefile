## Docker project Makefile
#    started by Mike Cramer
#    on November 15, 2016
#
#  Automation for Docker build, test run, and push to registry server.
#

makeBuildTag := ${shell date "+%Y%m%d_%H%M%S"}
#-make_${USER}

## Find all Docker files and get a list of their parent directories.
#  These must be stored at the same directory depth.
#  I.E. ./distro/app/Dockerfile
searchDepthString = */*
dockerContextFiles = ${wildcard ${searchDepthString}/*Dockerfile}
dockerContextDirs = ${dir ${dockerContextFiles}}

## Actions which will build phony and clean recipes quickly

loggedVerbs = build
# tag push
phonyVerbs = clean run touch build-force

actionVerbs := ${phonyVerbs}
actionVerbs += ${loggedVerbs}


toolPath = Tools/


# tput init
tput_nrml    = ${shell tput sgr0}

tput_bold    = ${shell tput bold}
tput_undl    = ${shell tput smul}
tput_revE    = ${shell tput rev}
tput_blnk    = ${shell tput blink}

tput_black   = ${shell tput setaf 0}
tput_red     = ${shell tput setaf 1}
tput_green   = ${shell tput setaf 2}
tput_yellow  = ${shell tput setaf 3}
tput_blue    = ${shell tput setaf 4}
tput_magenta = ${shell tput setaf 5}
tput_cyan    = ${shell tput setaf 6}
tput_white   = ${shell tput setaf 7}


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

## alias

# Build verb sends to bar directory
${foreach anDir,${dockerContextDirs},${anDir}build}: $${dir $$@}

# Bare directory assumes build
${foreach anDir,${dockerContextDirs},${anDir}}: $${dir $$@}build.log

## Logged Verbs

## Build a Dockerfile and log
${foreach anDir,${dockerContextDirs},${anDir}build.log}: $${wildcard $${dir $$@}/*Dockerfile} #$${wildcard $${dir $$@}*}
	@echo "${tput_cyan}## $@${tput_nrml}"
	@echo "${tput_cyan}#  Building the docker image w/ tag ${tput_yellow}${makeBuildTag}${tput_nrml}"
	@echo -n "	${tput_green}>${tput_nrml} ${tput_bold}"
	${toolPath}dkBuild.sh ${dir $@} ${makeBuildTag} | tee $@
	@echo -n "${tput_nrml}"

# ## Tag a Dockerfile and log
# ${foreach anDir,${dockerContextDirs},${anDir}tag.log}:
# 	@echo "${tput_cyan}## $@${tput_nrml}"
# 	@echo "${tput_cyan}#  Taging the docker image w/ tag ${tput_yellow}${makeBuildTag}${tput_nrml}"
# 	${toolPath}dkTag.sh ${dir $@} ${makeBuildTag} | tee $@

# ## Push a Dockerfile and log
# ${foreach anDir,${dockerContextDirs},${anDir}push.log}:
# 	@echo "${tput_cyan}## $@${tput_nrml}"
# 	@echo "${tput_cyan}#  Pushing the docker image w/ tag ${tput_yellow}${makeBuildTag}${tput_nrml}"
# 	${toolPath}dkPush.sh ${dir $@} ${makeBuildTag} | tee $@

## Phony Verbs

# clean
${foreach anDir,${dockerContextDirs},${anDir}clean}: force
	-find ${dir $@} -iname "*.log" -delete

## Run a Dockerfile
${foreach anDir,${dockerContextDirs},${anDir}run}: $${dir $$@}build
	@echo "${tput_cyan}## $@${tput_nrml}"
	@echo "${tput_cyan}#  Running the docker image${tput_nrml}"
	@echo -n "	${tput_green}>${tput_nrml} ${tput_bold}"
	${toolPath}dkRun.sh ${dir $@} /bin/bash
	@echo -n "${tput_nrml}"

## Touch a Dockerfile
${foreach anDir,${dockerContextDirs},${anDir}touch}: $${wildcard $${dir $$@}/*Dockerfile}
	@echo "${tput_cyan}## $@${tput_nrml}"
	@echo "${tput_cyan}#  Touching ${dir $@}*Dockerfile${tput_nrml}"
	@echo -n "	${tput_green}>${tput_nrml} ${tput_bold}"
	touch ${dir $@}*Dockerfile
	@echo -n "${tput_nrml}"

## Build-force a Dockerfile
${foreach anDir,${dockerContextDirs},${anDir}build-force}: 
	${MAKE} ${dir $@}touch 
	${MAKE} ${dir $@}build



# # Directory followed by one of loggedVerbs
# ${foreach anDir,${dockerContextDirs},${foreach anVerb,${loggedVerbs},${anDir}${anVerb}}}:




#### ---- ---- ---- ---- ---- ---- ----

## The force prerequisite
force: ;

## Phony recipes
.PHONY: default debug list usage cls clean hitman-subtask hitman lsr repo-local force \
	build run tag push usage \
	${foreach anDir,${dockerContextDirs},${foreach anVerb,${actionVerbs},${anDir}${anVerb}}} \
	${foreach anDir,${dockerContextDirs},${anDir}run} \
	${foreach anDir,${dockerContextDirs},${anDir}}

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
	@echo "Usage:"
	@echo "    make <distro>/<application>/<actionVerb>"
	@echo
	@echo "  Sequenced actions defined in the project's Makefile may have other action verbs or be optional."
	@echo
	@echo "More Help:"
	@echo "    make <verb>"
	@echo
	@echo "Example:"
	@echo "    make centos/-base/build"
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

cls:
	clear

## Clean log files
clean: force
	-find . -iname "*.log" -delete

#### ---- ---- ---- ---- ---- ---- ----

serverLocalStorageReset_yesIUnderstandWhatThisIsDoing:
	rm -r /docker/*

hitman-subtask_DontRunThisByItself:
	${toolPath}dkHitman.sh
	${toolPath}dkHitman.sh

hitman_yesIUnderstandWhatThisIsDoing: force cls clean hitman-subtask_DontRunThisByItself serverLocalStorageReset_yesIUnderstandWhatThisIsDoing repo-local

lsr: repo-local

repo-local:
	docker images

#### ---- ---- ---- ---- ---- ---- ----

server: force;
	cd server && ${MAKE}

server_test: force;
	cd server && ${MAKE} test


