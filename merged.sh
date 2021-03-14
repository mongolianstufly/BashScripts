#!/bin/bash
#bash script to clean up branches. 
#exec 5> debug_output.txt
#BASH_XTRACEFD="5"

declare PROGNAME=$(basename $0)

retValue=0

function init {

	VerifyDir
	
	if [ "$retValue" = 0 ];then 
		GetOption
	else
		echo "unknown error"
		exit 1
	fi
}

function VerifyDir {

local isGitDir = $(git rev-parse --is-inside-work-tree)

echo $isGitDir

	if [ $? -ne 0 ];then
		echo "ERROR: not in a git repo!"
		$retValue=1
	else
		echo "In git repo"		
	fi
}

function GetOption {

local arg = $1 | tr '[:upper:]' '[:lower:]'

case $1 in
[$arg | ll]) 
	ListLocal
	;;
[$arg | dl]) 
	CleanLocal
	;;
[$arg | lr]) 
	ListRemote
	;;
[$arg | dr]) 
	CleanRemote
	;;
[$arg | lb]) 
	ListBoth
	;;
[$arg | db]) 
	ListBoth
	;;
[$arg | options]) 
	ShowOptions
	;;
*) 	
	echo "ERROR: $1 is an invalid argument"
	HelpMessage
	;;
esac
}

function ListBoth {
	ListLocal
	ListRemote
}

function CleanBoth {
	CleanLocal
	CleanRemote
}

function CleanLocal {
	echo "Fetching to get up to date."
	git fetch --all --prune
	echo "Cleaning Local branches that have been merged to master."
	git branch --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | xargs -rn1 git branch -d
	echo "Done Cleaning all Local branches."
}

function CleanRemote {
	if [ $1 = db ];then
		git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -rn1 git push origin --delete
	else
		git fetch --all --prune;git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -rn1 git push origin --delete
	fi
}

function ListLocal {
	git fetch --all --prune
	git branch --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1
}

function ListRemote {
	if [ $1 = lb ];then
		git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -L1
	else
		git fetch --all --prune;git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -L1
			if [ $? -ne 0 ]; then 
				echo ERROR: Failed to run list remote command”
				exit 1
			fi
	fi
}

function HelpMessage {
	echo "Invalid argument"
	echo "please see options by typing the command"
	echo "EXAMPLE COMMAND: git cleanup options"
	exit 1 
}

function ShowOptions {
	echo "list or delete local argument options:"
	echo "ll = list local branches"
	echo "dl = delete local branches"
	echo "----"
	echo "list or delete remote options:"
	echo "lr = list remote branches"
	echo "dr = delete remote branches"
	echo "---"
	echo "list or delete both options:"
	echo "lb = list both remote and local branches"
	echo "db = delete both remote and local branches"
	exit 0
}

## Start

	if [ $# -ne 1 ]
	then
		HelpMessage
	else
		init 1
	fi
	


