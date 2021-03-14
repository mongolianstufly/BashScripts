#!/bin/bash


#check=$(echo "$1" | grep -E -?[0-9]*\.?[0-9]+$)

retValue=0
arg=$1

var1 = ""
var2 = ""
var3 = ""
var4 = ""
var5 = ""




init () {

	VerifyDir 
	if [ "$retValue" = 0 ]
	then 
		GetOption "$arg"
	else
		HelpMessage
	fi
}

VerifyDir () {

	isGitDir=$(git rev-parse --is-inside-work-tree)
	echo "$isGitDir"

	if [ ! $isGitDir ]
	then
		echo "ERROR: not in a git repo!"
		retValue=1
	else
		GetOption 		
	fi
}

function GetOption {
	## Trying to convert call to lower case.. just in case.
	## check=$( | tr '[:upper:]' '[:lower:]')
	## echo "$check"

	case $arg in
	--ll) 
		ListLocal
		;;
	--dl) 
		CleanLocal
		;;
	--lr) 
		ListRemote
		;;
	--dr) 
		CleanRemote
		;;
	--lb) 
		ListBoth
		;;
	--db) 
		CleanBoth
		;;
	--options) 
		ShowOptions
		;;
	*) 	
		echo "ERROR: $arg is an invalid argument"
		HelpMessage
		;;
	esac
}

ListBoth () {
	
	git fetch --all --prune
	ListLocal
	ListRemote
}

CleanBoth () {

	git fetch --all --prune
	CleanLocal
	CleanRemote
}

DoWork () {

	git $var1
	git $var2
	git $var3
	git $var4
	
	if $arg -eq lb || ll || dr 
	then
		git $var5
	fi
	

}
## what the fuck is going on here? ? ? ? 
## git checkout master && git pull --prune && git branch --merged master | grep -E -v "(^\*|master|RC*)" | xargs -L1 | xargs -rn1 git branch -d && git branch -r --merged master 
##| grep -E -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -rn1 git push origin --delete
CleanLocal () {
	git branch --merged master | grep -E -v "(^\*|master|RC*)" | xargs -L1 | xargs -rn1 git branch -d
}

CleanRemote () {
	git branch -r --merged master | grep -E -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -rn1 git push origin --delete
}

ListLocal () {
	git branch --merged master | grep -E -v "(^\*|master|RC*)" | xargs -L1
}

ListRemote () {
	git branch -r --merged master | grep -E -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -L1
}

ShowOptions () {
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

HelpMessage () {
	echo
	echo "please see options by typing:"
	echo "EXAMPLE COMMAND: git cleanup options"
	exit 1 
}

FirstCheck (){

	if [ $# -ne 1 ]
	then
		echo
		echo "You need to call this with an argument"
		HelpMessage
	else
		SecondCheck
	fi

}

SecondCheck (){

	if ! [ ${#arg} -ge 2 ]
	then
		echo 
		echo "arg must be 2 char long"
		HelpMessage
	else 
		ThirdCheck
	fi

}

ThirdCheck (){

	if [ "$check" != '' ]
	then
		echo 
		echo "arg may not contain numeric values"
		HelpMessage
	else 
		init "$arg"
	fi
}

FirstCheck "$arg"