#!/bin/sh
#
# This bash script is run on a daily basis by my cron daemon to
# check whether there are changes in the files and auto-commit 
# them into a new branch.
#
# The new branch in merged into the master.
#
# It uses the 'require_clean_work_tree' function.

# Get the number of changes reported by git
changeCount=`git status --porcelain | grep "??" | wc -l`

if [ $changeCount = "0" ]; then
    echo "There are no changed files."
    exit 0
fi
echo "There are $changeCount changed files."


# Found at
#    http://stackoverflow.com/questions/3878624/how-do-i-programmatically-determine-if-there-are-uncommited-changes
require_clean_work_tree () {
    # Update the index
    git update-index -q --ignore-submodules --refresh
    err=0

    # Disallow unstaged changes in the working tree
    if ! git diff-files --quiet --ignore-submodules --
    then
        echo >&2 "cannot $1: you have unstaged changes."
        git diff-files --name-status -r --ignore-submodules -- >&2
        err=1
    fi

    # Disallow uncommitted changes in the index
    if ! git diff-index --cached --quiet HEAD --ignore-submodules --
    then
        echo >&2 "cannot $1: your index contains uncommitted changes."
        git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
        err=1
    fi

    if [ $err = 1 ]
    then
        echo >&2 "Please commit or stash them."
        exit 1
    fi
}

require_clean_work_tree()


# Create a new branch
dateStr=`date '+%Y%m%d_%H%M%S'`
branchName="_autobranch_$dateStr"
echo -n "Creating new branch '$branchName' ... "
git branch $branchName
git checkout $branchName
git add -A
rc=`git commit -m "Auto commit"`

if [ $rc = 0 ]; then
    echo "Branch created."
    git checkout master
    echo -n "Merge branch into master ... "
    rc=`git merge $branch`
    if [ $rc =0  ]; then
	echo "Done."
	exit 0;
    else
	echo "Errors."
	echo $rc
    fi
else
    echo "Errors."
    exit $rc
fi


