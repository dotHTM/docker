#!/bin/bash
# src.sh

export DOCKER_USER=""

OUTPUT_PREFIX=""

export DOCKER_TAG=`date "+%Y%m%d_%H%M%S"`-$USER

dockerPATH=`which docker`

# ------------------------------------

tput init
tput_nrml=`tput sgr0`       # ${tput_nrml}

tput_bold=`tput bold`       # ${tput_bold}
tput_undl=`tput smul`       # ${tput_undl}
tput_revE=`tput rev`        # ${tput_revE}
tput_blnk=`tput blink`      # ${tput_blnk}

tput_black=`tput setaf 0`   # ${tput_black}
tput_red=`tput setaf 1`     # ${tput_red}      Error message
tput_green=`tput setaf 2`   # ${tput_green}
tput_yellow=`tput setaf 3`  # ${tput_yellow}   Details
tput_blue=`tput setaf 4`    # ${tput_blue}
tput_magenta=`tput setaf 5` # ${tput_magenta}
tput_cyan=`tput setaf 6`    # ${tput_cyan}     Information Message
tput_white=`tput setaf 7`   # ${tput_white}


# ------------------------------------

echo
echo " -> lib.sh"

# ------------------------------------
# ------------------------------------

docker(){
	echo
	echo "	${tput_green}\$${tput_nrml} ${tput_bold}$dockerPATH $@${tput_nrml}"
	echo
	$dockerPATH $@
}


# ------------------------------------
# ------------------------------------


debugVariables(){
	echo
	env | sort | grep DOCKER_
	echo
}

statusExit(){
	debugVariables
	exit 1
}

outputToScreen(){
	echo $OUTPUT_PREFIX" • "$@${tput_nrml}
}

# findDockerFile path/to/docker/project/or/file
findDockerFile(){
	inputPath=$1 && shift
	DOCKER_FILEPATH=""
	
	if [[ -z $inputPath ]]; then
		inputPath="."
	fi
	
	if [[ -f $inputPath ]]; then
		outputToScreen "${tput_cyan}Using File: $inputPath"
		DOCKER_FILEPATH=$inputPath
		
	elif [[ -d $inputPath ]]; then
		outputToScreen "${tput_cyan}Path is a directory"
		
		inputPath=`echo $inputPath | perl -pe "s/\/\//\//"`
		foundDockerfiles=`find $inputPath -name "*Dockerfile"`
		countDockerfiles=`echo $foundDockerfiles | wc -w`
		
		outputToScreen "Found these items:"
		for anFile in $foundDockerfiles; do
			outputToScreen " - "$anFile
		done
		
		if [[ "$countDockerfiles" -eq 1 ]]; then
			outputToScreen "${tput_cyan}Found file inside: $foundDockerfiles"
			DOCKER_FILEPATH=$foundDockerfiles
			
		elif [[ "$countDockerfiles" -gt 1 ]]; then
			outputToScreen "${tput_red}Found more than one file:"
			
			OLD_IFS="$IFS"
			IFS=
			while read anWord; do
				outputToScreen "    - $anWord"
			done <<< $foundDockerfiles
			IFS="$OLD_IFS"
			statusExit
		else
			outputToScreen "${tput_red}Didn't find any (obvious) files to use."
			statusExit
		fi
	fi

	export DOCKER_FILEPATH

	if [[ -n $DOCKER_FILEPATH ]]; then
		if [[ -a $DOCKER_FILEPATH ]]; then
			if [[ -d $DOCKER_FILEPATH ]]; then
				outputToScreen "${tput_red}Path is not a directory, not a file: $DOCKER_FILEPATH"
				statusExit
			else
				outputToScreen "${tput_cyan}File looks good from up here."
				
				export DOCKER_CONTEXT=`dirname $DOCKER_FILEPATH`
				
			fi
		else
			outputToScreen "${tput_red}File does not exist: $DOCKER_FILEPATH"
			statusExit
		fi
	else
		outputToScreen "${tput_red}Nothing to read, "
		statusExit
	fi
}

readDockerFile(){
	findDockerFile $@
	
	if [[ $? ]]; then
		
		DOCKER_LABELS=""

		outputToScreen "${tput_cyan}Time to read that file!!!"
		outputToScreen "------------------------------"
		
		
		while read line; do
			case $line in
				LABEL* )
					#
					fragment=`echo $line | perl -pe 's/LABEL\s+//gi'`
					case $fragment in
						*desc* )
							#
							# Ignore for now, essentially a comment
							DESC_LINE=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Desc: ${tput_yellow}$DESC_LINE"
							;;
						#
						*image_name* )
							#
							export DOCKER_IMAGE_NAME=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image Name: ${tput_yellow}$DOCKER_IMAGE_NAME"
							;;
						#
						*image_user* )
							#
							export DOCKER_USER=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image user: ${tput_yellow}$DOCKER_USER"
							;;
						#
						*image_server* )
							#
							export DOCKER_IMAGE_SERVER=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image Server: ${tput_yellow}$DOCKER_IMAGE_SERVER"
							;;
						#
						*image_tag* )
							#
							export DOCKER_OVERRIDE_TAG=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image tag: ${tput_yellow}$DOCKER_OVERRIDE_TAG"
							;;
						#
						*filter_* )
							#
							DOCKER_LABELS=$DOCKER_LABELS" "$fragment
							outputToScreen " - ${tput_yellow}label=$fragment"
							;;
						#
						* )
							# Fall through
							outputToScreen " - ${tput_yellow}$fragment"
							;;
						#
					esac
					;;
				#
			esac
		done < $DOCKER_FILEPATH
		export DOCKER_LABELS
	else
		outputToScreen "${tput_red}Something is wrong, so nothing to read."
		statusExit
	fi
	
	outputToScreen "------------------------------"
	
	if [[ -z $DOCKER_OVERRIDE_TAG ]]; then
		DOCKER_REPOSITORY=$DOCKER_IMAGE_SERVER/$DOCKER_USER/$DOCKER_IMAGE_NAME
	else
		DOCKER_REPOSITORY=$DOCKER_OVERRIDE_TAG
	fi
	
	export DOCKER_REPOSITORY=`echo $DOCKER_REPOSITORY | perl -pe 's/\/\//\//' | perl -pe 's/^\///' | perl -pe 's/^\///' `

}

reviewImages(){
	for anLabel in $DOCKER_LABELS; do
		export DOCKER_IMAGES_FILTER_ARGS=$DOCKER_IMAGES_FILTER_ARGS" -f label="$anLabel
	done
	outputToScreen DOCKER_IMAGES_FILTER_ARGS = $DOCKER_IMAGES_FILTER_ARGS
	docker images $DOCKER_IMAGES_FILTER_ARGS
}


buildDockerfile(){
	projectDirectory=$1 && shift
	
	readDockerFile $projectDirectory
	
	if [[ $? ]]; then

		outputToScreen "${tput_cyan}Building"
		docker build -t \
		${DOCKER_REPOSITORY} \
		$DOCKER_CONTEXT \
		-f $DOCKER_FILEPATH \
		&& tagDockerImage $1 \
		&& reviewImages
		
	fi
}

tagDockerfile(){
	projectDirectory=$1 && shift
	
	readDockerFile $projectDirectory
	
	if [[ $? ]]; then
		outputToScreen "${tput_cyan}~Not~ Building"

		tagDockerImage $1 \
		&& reviewImages
	fi
}

tagDockerImage(){
	outputToScreen "${tput_cyan}Tagging"
	if [[ -n $1 ]]; then
		outputToScreen "Was given the tag \"${tput_yellow}$1${tput_nrml}\""
		docker tag ${DOCKER_REPOSITORY} ${DOCKER_REPOSITORY}:$1
	else
		outputToScreen "Was NOT given tag. Using \"${tput_yellow}${DOCKER_TAG}${tput_nrml}\" instead"
		docker tag ${DOCKER_REPOSITORY} ${DOCKER_REPOSITORY}:${DOCKER_TAG}
	fi
}

runCommand(){
	docker run -ti --rm $@
}

runDockerFile(){
	projectDirectory=$1 && shift
	
	readDockerFile $projectDirectory
	
	runCommand ${DOCKER_REPOSITORY} $@
	

}

pushDockerfile(){
	projectDirectory=$1 && shift
	
	readDockerFile $projectDirectory

	if [[ -z $1 ]]; then

		outputToScreen "${tput_cyan}Remember to use a tag from the image list"
		outputToScreen "  Filter:  "$DOCKER_IMAGES_FILTER_ARGS
		
		reviewImages
	else
		outputToScreen "Pushing the base name"
		docker push $DOCKER_REPOSITORY \
		&& outputToScreen "Pushing with the tag given \"${tput_yellow}$1${tput_nrml}\"" \
		&& docker push $DOCKER_REPOSITORY:$1
	fi
}


# ------------------------------------
# ------------------------------------




