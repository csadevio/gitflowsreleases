#!/usr/bin/env /bin/bash

REP_URL=${GITFLOW_REP_URL}
DIR_TMP=${GITFLOW_DIR_TMP}
VER_STATE=${GITFLOW_VER_STATE:-"release.md"}
VERSION=${GITFLOW_VERSION:-"0.1"}
BUILD_FILE=${GITFLOW_BUILD_FILE:-"build.cfg"}
BUILD_TEMPLATE=${GITFLOW_BUILD_FILE:-"build.cfgt"}
BUILD_NUMBER=${GITFLOW_BUILD_NUMBER}
BUILD_STARTAT=${GITFLOW_BUILD_STARTAT:-"0"}
HOOK_URL=${GITFLOW_HOOK_URL}
USER_NAME=${GITFLOW_USER_NAME}
USER_EMAIL=${GITFLOW_USER_EMAIL}

clonedirname=clone-$$
clonedir=$DIR_TMP/$clonedirname

export GIT_MERGE_AUTOEDIT=no

. functions.sh

check_if_empty GITFLOW_REP_URL $REP_URL
check_if_empty GITFLOW_VER_STATE $VER_STATE
check_if_empty GITFLOW_USER_NAME $USER_NAME
check_if_empty GITFLOW_USER_EMAIL $USER_EMAIL

run git config --global user.email $USER_EMAIL
run git config --global user.name $USER_NAME

clean $DIR_TMP
download $DIR_TMP $REP_URL $clonedirname

build=$BUILD_NUMBER
if [ "$build" = "" ]; then
	get_build $clonedir $VER_STATE $BUILD_STARTAT
	build=$?
fi

version="$VERSION.$build"

init $clonedir

update_and_commit $clonedir $VERSION $build $version $BUILD_TEMPLATE $BUILD_FILE

push $clonedir $HOOK_URL

exit 0
