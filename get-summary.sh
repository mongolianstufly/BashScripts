#!/usr/bin/env bash


SUBDIRECTORY_OK=Yes
source "$(git --exec-path)/git-sh-setup"
cd_to_toplevel

commit=""
test $# -ne 0 && commit=$@
project=${PWD##*/}

#
# get date for the given <commit>
#

date() {
  git log --pretty='format: %ai' $1 | cut -d ' ' -f 2
}

#
# get active days for the given <commit>
#

active_days() {
  date $1 | sort -r | uniq | awk '
    { sum += 1 }
    END { print sum }
  '
}

#
# get the commit total
#

commit_count() {
  git log --oneline $commit | wc -l | tr -d ' '
}

#
# total file count
#

file_count() {
  git ls-files | wc -l | tr -d ' '
}

#
# list authors
#

authors() {
  git shortlog -n -s $commit | LC_ALL=C awk '
  { args[NR] = $0; sum += $0 }
  END {
    for (i = 1; i <= NR; ++i) {
      printf "%s♪%2.1f%%\n", args[i], 100 * args[i] / sum
    }
  }
  ' | column -t -s♪
}

#
# fetch repository age from oldest commit
#

repository_age() {
  git log --reverse --pretty=oneline --format="%ar" | head -n 1 | LC_ALL=C sed 's/ago//'
}

# summary

if test "$1" = "--line"; then
  shift
  git line-summary "$@"
  echo
else

  echo
  echo " project  : $project"
  echo " repo age :" $(repository_age)
  echo " active   :"  $(active_days) days
  echo " commits  :" $(commit_count)
  if test "$commit" = ""; then
    echo " files    :" $(file_count)
  fi
  echo " authors  : "
  authors
  echo

fi