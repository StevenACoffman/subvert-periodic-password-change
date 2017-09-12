#!/bin/bash
# USAGE:  $1 = docker registry repository prefix - e.g. prod, qa, etc.
#
NAME_OF_THING=active-directory-subvert-periodic-password-change
DR_RP=${1:-stevenacoffman}
img="${DR_RP}/${NAME_OF_THING}:latest"
docker build -t ${img} .
docker push ${img}
