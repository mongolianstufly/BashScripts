#!/usr/bin/env bash

project=${PWD##*/}

#
# list the last modified author for each line
#
single_file() {
  while read data
  do
    if [[ $(file "$data") = *text* ]]; then
      git blame --line-porcelain "$data" 2>/dev/null | grep "^author\ " | LC_ALL=C sed -n 's/^author //p';
    fi
  done
}

#
# list the author for all file
#
lines() {
  git ls-files | single_file
}

#
# count the line count
#
count() {
  lines | wc -l
}

#
# sort by author modified lines
#
authors() {
  lines | sort | uniq -c | sort -rn
}

#
# list as percentage for author modified lines
#
result() {
  authors | awk '
    { args[NR] = $0; sum += $0 }
    END {
      for (i = 1; i <= NR; ++i) {
        printf " %s, %2.1f%%\n", args[i], 100 * args[i] / sum
      }
    }
    ' | column -t -s,
}

# summary

echo
echo " project  : $project"
echo " lines    : $(count)"
echo " authors  :"
result
echo
