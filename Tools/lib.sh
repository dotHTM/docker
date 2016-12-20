#!/bin/bash
# src.sh

export DOCKER_USER=""

OUTPUT_PREFIX=""

export DOCKER_TAG=`date "+%Y%m%d_%H%M%S"`-$USER

# ------------------------------------
# ------------------------------------


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
	
	# echo "inputPath = $inputPath"
	
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
	export DOCKER_REPOSITORY=`echo $DOCKER_REPOSITORY | perl -pe 's/\/\//\//' `

}

reviewImages(){
	for anLabel in $DOCKER_LABELS; do
		export DOCKER_IMAGES_FILTER_ARGS=$DOCKER_IMAGES_FILTER_ARGS" -f label="$anLabel
	done
	echo DOCKER_IMAGES_FILTER_ARGS = $DOCKER_IMAGES_FILTER_ARGS
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

		outputToScreen "Tagging"
		if [[ -n $1 ]]; then
			docker tag ${DOCKER_REPOSITORY} ${DOCKER_REPOSITORY}:$1
		else
			docker tag ${DOCKER_REPOSITORY} ${DOCKER_REPOSITORY}:${DOCKER_TAG}
		fi
		
		reviewImages
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

			echo "Remember to use a tag from the image list"
			echo "  Filter:  "$DOCKER_IMAGES_FILTER_ARGS
			
			reviewImages
		else
			docker push $DOCKER_REPOSITORY
			docker push $DOCKER_REPOSITORY:$1
		fi
}


# ------------------------------------
# ------------------------------------


