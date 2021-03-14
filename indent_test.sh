#!/bin/bash


check=`echo "$1" | grep -E ^\-?[0-9]*\.?[0-9]+$`

returnValue=0
arg=$1

init () {

VerifyDir {
if [ "$retValue" = 0 ];then
GetOption $arg
else
echo "unknown error"
HelpMessage
exit 1
fi
}

VerifyDir () {

local isGitDir=$(git rev-parse --is-inside-work-tree)
echo $isGitDir

if [ $? -ne 0 ];then
echo "ERROR: not in a git repo!"
$retValue=1
else
GetOption
echo "In git repo"
fi
}

function GetOption {

local check=$arg | tr '[:upper:]' '[:lower:]'

echo $check

case $arg in
[$check | ll])
ListLocal
;;
[$check | dl])
CleanLocal
;;
[$check | lr])
echo "List remote branches!"
ListRemote
;;
[$check | dr])
CleanRemote
;;
[$check | lb])
ListBoth
;;
[$check | db])
ListBoth
;;
[$check | options])
ShowOptions
;;
*)
echo "ERROR: $arg is an invalid argument"
HelpMessage
;;
esac
}

ListBoth () {
ListLocal
ListRemote
}

CleanBoth () {
CleanLocal
CleanRemote

CleanLocal () {
echo "Fetching to get up to date."
git fetch --all --prune
echo "Cleaning Local branches that have been merged to master."
git branch --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | xargs -rn1 git branch -d
echo "Done Cleaning all Local branches."
}

CleanRemote () {
if [ $arg = db ];then
git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -rn1 git push origin --delete
else
git fetch --all --prune;git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -rn1 git push origin --delete
fi
}
ListLocal () {
git fetch --all --prune
git branch --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1
}

ListRemote () {
if [ $arg = lb ];then
git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -L1
else
git fetch --all --prune;git branch -r --merged master | egrep -v "(^\*|master|RC*)" | xargs -L1 | awk '{split($0,a,"/"); print a[2]}' | xargs -L1
if [ $? -ne 0 ]; then
echo ERROR: Failed to run list remote command”
exit 1
fi
fi
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
exit 1
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
exit 1
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
exit 1
else
init $arg
fi
}

