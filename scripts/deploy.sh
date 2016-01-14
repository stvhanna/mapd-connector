#!/bin/bash

# show the command being run
set -x

# tell jenkins to fail if any of the commands fail
set -e

# If the last commit was from jenkins, do nothing
if [[ `git log -1 | grep "Jenkins MapD"` ]] &&
   !([[ `git log -1 | grep "Update Thrift"` ]]); then
 echo "Ignoring superfluous build spawned by jenkins"
 exit 0
fi

# remove the previous temp branch
if [[ `git branch | grep temp` ]]; then
    git branch -d temp
fi

# checkout a new temp branch
git checkout -b temp

# bump the version
SEM_VAR=`bash get_latest_semvar_tag.sh | awk 'NR==0; END{print}'`
cd ..
npm --no-git-tag-version version $SEM_VAR

# Build the library
npm install
npm run build

# Add and commit the new version
cd scripts
git commit -a -m "`bash package_version.sh`"

# push the new version to github
git push origin temp:master

# publish the module to npm
cd ..
npm publish

