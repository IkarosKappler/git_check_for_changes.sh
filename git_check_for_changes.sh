#!/bin/sh
#
# This bash script is run on a daily basis by my cron daemon to
# check whether there are changes in the files and auto-commit 
# them into a new branch.
#
# The new branch in merged into the master.
#
# @author  Ikaros Kappler
# @date    2016-03-23
# @version 1.0.0


# Get the number of changes reported by git
changeCount=`git status --porcelain | wc -l`

if [ $changeCount = "0" ]; then
    echo "There are no changed files."
    exit 0
fi
echo "There are $changeCount changed files."


# Create a new branch
dateStr=`date +"%Y%m%d_%H%M%S"`
branchName="_autobranch_$dateStr"
echo "Creating new branch '$branchName' ... "

git branch $branchName
echo "Checking out ... "
git checkout -q $branchName
echo "Adding changed/new files ... "
git add -A
echo "Doing commit ... "
git commit -m "Auto commit. Date $dateStr."
rc=$? 


if [ $rc = "0" ]; then
    echo "Branch created."
    git checkout master
    echo -n "Merge branch into master ... "
    git merge "$branchName"
    rc=$?
    if [ $rc = "0" ]; then
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


