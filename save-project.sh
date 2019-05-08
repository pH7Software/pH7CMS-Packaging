#!/bin/bash

function save-project-to-repo() {
    git remote rm origin
    git remote add origin $1
    git push
}

declare readonly gitRemotes=(
    git@bitbucket.org:pH_7/ph7cms-packaging.git
    git@gitlab.com:pH-7/pH7CMS-Packaging.git
    git@github.com:pH7Software/pH7CMS-Packaging.git
)
for remote in "${gitRemotes[@]}"
do
    save-project-to-repo $remote
done
