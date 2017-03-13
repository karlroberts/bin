#!/bin/bash

# You can get the commit id of any ref using git rev-parse <ref>, so you can do
# this for master and origin/master and compare them. If they are equal, the
# branches are the same. If they're unequal, you want to know which is ahead of
# the other. Using git merge-base master origin/master will tell you the common
# ancestor of both branches, and if they haven't diverged this will be the same
# as one or the other. If you get three different ids, the branches have diverged.
# 
# To do this properly, eg in a script, you need to be able to refer to the
# current branch, and the remote branch it's tracking. The bash prompt-setting
# function in /etc/bash_completion.d has some useful code for getting branch
# names. However, you probably don't actually need to get the names. Git has
# some neat shorthands for referring to branches and commits (as documented in
# git rev-parse --help). In particular, you can use @ for the current branch (assuming
# you're not in a detached-head state) and @{u} for its upstream branch (eg
# origin/master). So git merge-base @ @{u} will return the (hash of) the commit
# at which the current branch and its upstream diverge and git rev-parse @ and
# git rev-parse @{u} will give you the hashes of the two tips. This can be
# summarized in the following script:

echoerr() { cat <<< "$@" 1>&2; }

testPullPush() {
  GITDIR=$(realpath $1)
  UPSTREAM=${2:-'@{u}'}
  LOCAL=$(git -C $GITDIR rev-parse @)
  echoerr LOCAL is $LOCAL
  REMOTE=$(git -C $GITDIR rev-parse "$UPSTREAM")
  echoerr REMOTE is $REMOTE
  BASE=$(git -C $GITDIR merge-base @ "$UPSTREAM")
  echoerr BASE is $BASE

  if [ FOO"$LOCAL" = FOO"$REMOTE" ]; then
    echo "Up-to-date"
  elif [ FOO"$LOCAL" = FOO"$BASE" ]; then
    echo "Need to pull"
  elif [ FOO"$REMOTE" = FOO"$BASE" ]; then
    echo "Need to push"
  else
    echo "Diverged"
  fi
}


testDirRecursive() {
  
  THE_DIR=$1
  #echo THE_DIR is $THE_DIR
  for d in $(ls -d ${THE_DIR}/*/ 2>/dev/null )
  do
    LISTING=$(realpath $d)
    #echo LISTING is $LISTING
    # test if we are a git dir recurse if we ar not
    if $(git -C $LISTING rev-parse -q 2>/dev/null)
    then
      echo
      echo $LISTING is a git dir
      testPullPush $LISTING
    else
      #echo $LISTING is not a git dir, digging into it further
      testDirRecursive $LISTING
    fi
  done
}

# kick it off with the param at $1
if [ -z "$1" ]
then
  SOME_DIR=`pwd`
  echoerr "setting start dir to pwd = $SOME_DIR"
else
  SOME_DIR=$(realpath $1)
fi

if [ -d $SOMEDIR ]
then
  echoerr ok starting on dir $SOME_DIR
  testDirRecursive $SOME_DIR
else
  echoerr oops $SOME_DIR is not a directory
fi

