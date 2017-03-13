#!/bin/bash
# push.sh


ToolsDirectory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$ToolsDirectory/lib.sh"

pushDockerfile $@

