#!/bin/bash

function check_if_empty
{
	if [ "$2" = "" ]; then
		echo "\$$1 was empty"
		exit 1
	fi
}

function run
{
	echo "$0 $*"
	eval $*
	ec=$?
	if [ $ec != 0 ]; then
	  	printf "Error : [%d] when executing command: '$*'" $ec
  		exit $ec
	fi
}

function clean
{
	# 1 = Temp directory
	if [ -e "$1" ]; then
		run rm -rf $1
	fi
	run mkdir $1
}

function download
{
	# 1 = Tmp directory
	# 2 = Git repo url
	# 3 = target dir
	run cd $1
	run git clone $2 $3
}

function init
{
	# 1 = Repo clone directory
	if [ ! -e "$1" ]; then
		echo "$1 does not exists"
		exit 1
	fi
	cd $1
	run git config --add gitflow.prefix.feature feature/
	run git config --add gitflow.prefix.release release/
	run git config --add gitflow.prefix.hotfix hotfix/
	run git config --add gitflow.prefix.support support/
	run git config --add gitflow.prefix.versiontag v
	run git config --add gitflow.path.hooks $1/.git/hooks
	run git flow init -d -f
}

function get_build
{
	# 1 = Repo clone directory
	# 2 = Version state file (release.md)
	# 3 = Build start at
	cd $1
	s=$2
	v=$3;
	if [ -e "$s" ]; then
		v=`cat $s | cut -f3 -d"."`
	fi
	return `expr $v + 1`
}

function make_version
{
	# 1 = version
	# 2 = build number
	v=$1
	b=$2
	echo "$v.$b"
}

function update_and_commit
{
	# 1 = clone directory
	# 2 = version (0.1)
	# 3 = build (1)
	# 4 = version_and_build (0.1.1)
	# 5 = build.template
	# 6 = build.file
	d=$1
	v=$2
	b=$3
	vb=$4
	bt=$5
	bf=$6
	run cd $d
	run git flow release start "$vb"
	echo "echo $vb > release.md"
	echo "$vb" > release.md
	run git add release.md
	if [ -e "$bt" ]; then
		cat $bt | sed "s/{{version}}/$v/gi" | sed "s/{{build}}/$b/gi" | sed "s/{{version_and_build}}/$vb/gi" > $bf
		run git add $bf
		echo "git commit -m \"Added v$vb to release.cmd and updated $bf\""
		git commit -m "Added v$vb to release.cmd and updated $bf"
	else
		#run git commit -m "Added v$vb to release.cmd"
		echo "git commit -m \"Added v$vb to release.cmd\""
		git commit -m "Added v$vb to release.cmd"
	fi
	#run git flow release finish "$vb" -m "new release ($vb)"
	echo "git flow release finish -m \"new release ($vb)\"--showcommands \"$vb\""
	git flow release finish -m "new release ($vb)" --showcommands "$vb"
}

function push
{
	# 1 = clone directory
	# 2 = hooks
	d=$1
	h=$2
	run cd $d
	run git push --tags
	run git push origin develop
	run git push origin master
	
	if [ ! "$h" = "" ]; then
		run "curl $h"
	fi
}
