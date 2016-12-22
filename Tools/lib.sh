#!/bin/bash
# src.sh

export DOCKER_USER=""

OUTPUT_PREFIX=""

export DOCKER_TAG=`date "+%Y%m%d_%H%M%S"`-$USER

dockerPATH=`which docker`


# ------------------------------------
# ------------------------------------

docker(){
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
	echo $OUTPUT_PREFIX" • "$@
}

# findDockerFile path/to/docker/project/or/file
findDockerFile(){
	inputPath=$1 && shift
	DOCKER_FILEPATH=""
	
	if [[ -z $inputPath ]]; then
		inputPath="."
	fi
	
	if [[ -f $inputPath ]]; then
		outputToScreen "Using File: $inputPath"
		DOCKER_FILEPATH=$inputPath
		
	elif [[ -d $inputPath ]]; then
		outputToScreen "Path is a directory"
		
		inputPath=`echo $inputPath | perl -pe "s/\/\//\//"`
		foundDockerfiles=`find $inputPath -name "Dockerfile"`
		countDockerfiles=`echo $foundDockerfiles | wc -w`
		
		if [[ "$countDockerfiles" -eq 1 ]]; then
			outputToScreen "Found file inside: $foundDockerfiles"
			DOCKER_FILEPATH=$foundDockerfiles
			
		elif [[ "$countDockerfiles" -gt 1 ]]; then
			outputToScreen "Found more than one file:"
			
			OLD_IFS="$IFS"
			IFS=
			while read anWord; do
				outputToScreen "    - $anWord"
			done <<< $foundDockerfiles
			IFS="$OLD_IFS"
			statusExit
		else
			outputToScreen "Didn't find any (obvious) files to use."
			statusExit
		fi
	fi

	export DOCKER_FILEPATH

	if [[ -n $DOCKER_FILEPATH ]]; then
		if [[ -a $DOCKER_FILEPATH ]]; then
			if [[ -d $DOCKER_FILEPATH ]]; then
				outputToScreen "Path is not a directory, not a file: $DOCKER_FILEPATH"
				statusExit
			else
				outputToScreen "File looks good from up here."
				
				export DOCKER_CONTEXT=`dirname $DOCKER_FILEPATH`
				
			fi
		else
			outputToScreen "File does not exist: $DOCKER_FILEPATH"
			statusExit
		fi
	else
		outputToScreen "Nothing to read, "
		statusExit
	fi
}

readDockerFile(){
	findDockerFile $@
	
	if [[ $? ]]; then
		
		DOCKER_LABELS=""

		outputToScreen "Time to read that file!!!"
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
							outputToScreen "Desc: $DESC_LINE"
							;;
						#
						*image_name* )
							#
							export DOCKER_IMAGE_NAME=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image Name: $DOCKER_IMAGE_NAME"
							;;
						#
						*image_user* )
							#
							export DOCKER_USER=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image user: $DOCKER_USER"
							;;
						#
						*image_server* )
							#
							export DOCKER_IMAGE_SERVER=`echo $fragment | perl -pe 's/.*=//gi'`
							outputToScreen "Image Server: $DOCKER_IMAGE_SERVER"
							;;
						#
						*filter_* )
							#
							DOCKER_LABELS=$DOCKER_LABELS" "$fragment
							outputToScreen " - label=$fragment"
							;;
						#
						* )
							# Fall through
							outputToScreen " - $fragment"
							;;
						#
					esac
					;;
				#
			esac
		done < $DOCKER_FILEPATH
		export DOCKER_LABELS
	else
		outputToScreen "Something wrong, so nothing to read."
		statusExit
	fi
	
	outputToScreen "------------------------------"
	
	DOCKER_REPOSITORY=$DOCKER_IMAGE_SERVER/$DOCKER_USER/$DOCKER_IMAGE_NAME
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

		outputToScreen "Building"
		docker build \
		-t ${DOCKER_REPOSITORY} \
		$DOCKER_CONTEXT

		tagDockerImage $1
		
		reviewImages
	fi
}

tagDockerfile(){
	projectDirectory=$1 && shift
	
	readDockerFile $projectDirectory
	
	if [[ $? ]]; then
		outputToScreen "~Not~ Building"

		tagDockerImage $1

		reviewImages
	fi
}

tagDockerImage(){
	outputToScreen "Tagging"
	if [[ -n $1 ]]; then
		outputToScreen "Was given the tag \"$1\""
		docker tag ${DOCKER_REPOSITORY} ${DOCKER_REPOSITORY}:$1
	else
		outputToScreen "Was NOT given tag. Using \"${DOCKER_TAG}\" instead"
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

		outputToScreen "Remember to use a tag from the image list"
		outputToScreen "  Filter:  "$DOCKER_IMAGES_FILTER_ARGS
		
		reviewImages
	else
		outputToScreen "Pushing the base name"
		docker push $DOCKER_REPOSITORY
		outputToScreen "Pushing with the tag given \"$1\""
		docker push $DOCKER_REPOSITORY:$1
	fi
}


# ------------------------------------
# ------------------------------------


