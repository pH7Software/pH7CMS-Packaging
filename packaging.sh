#!/bin/bash

##
# Title:           Packaging Automation Tool
#
# Author:          Pierre-Henry Soria <hi@ph7.me>
# Copyright:       (c) 2014-2020, Pierre-Henry Soria. All Rights Reserved.
# License:         GNU General Public License; See PH7.LICENSE.txt and PH7.COPYRIGHT.txt in the root directory.
##

function run-packaging-cleanup() {
    _remove-tmp-files
    _remove-tmp-folders
    _update-composer
    _clear-caches
    _remove-dev-files
    _remove-dev-folders
    _permissions
}


#### Private functions ####

function _permissions() {
    # Generic for folders/files
    find . -type f -print0 | sudo xargs -0 chmod 666 # for files
    find . -type d -print0 | sudo xargs -0 chmod 755 # for folders

    # Specific ones
    sudo chmod -R 777 ./_install/data/logs/
    sudo chmod -R 777 ./_install/data/caches/
    sudo chmod -R 777 ./data/system/modules/*
    sudo chmod -R 777 ./_repository/module/*
    sudo chmod -R 777 ./_repository/upgrade/*
    sudo chmod -R 777 ./_protected/app/configs/*
    sudo chmod -R 777 ./_protected/data/cache/*
    sudo chmod -R 777 ./_protected/data/backup/*
    sudo chmod -R 777 ./_protected/data/tmp/*
    sudo chmod -R 777 ./_protected/data/log/*
}

function _remove-tmp-files() {
    find . -type f \( -name '*~' -or -name '*.log' -or -name '*.tmp' -or -name '*.swp' -or -name '.directory' -or -name '._*' -or -name '.DS_Store*' -or -name 'Thumbs.db' \) -exec rm {} \;

    ## Cleaning the code
    params="-name '*.php' -or -name '*.css' -or -name '*.js' -or -name '*.html' -or -name '*.xml' -or -name '*.xsl' -or -name '*.xslt' -or -name '*.svg' -or -name '*.json' -or -name '*.yml' -or -name '*.tpl' -or -name '*.phs' -or -name '*.ph7' -or -name '*.sh' -or -name '*.sql' -or -name '*.ini' -or -name '*.md' -or -name '*.markdown' -or -name '.htaccess'"
    exec="find . -type f \( $params \) -print0 | xargs -0 perl -wi -pe"
    eval "$exec 's/\s+$/\n/'"
    eval "$exec 's/\t/    /g'"
}

function _remove-tmp-folders() {
    # elFinder cache folders
    rm -rf ./.quarantine/
    rm -rf ./.tmb/
    rm -rf ./_protected/.quarantine/
    rm -rf ./_protected/.tmb/
    # Composer cache folder
    rm -rf ./_protected/vendor/cache/
}

function _update-composer() {
    # Update Composer itself to the latest version
    composer self-update

    # Install dependencies for production only (without dev packages)
    composer install --no-dev

    # Update the libraries to their latest versions
    # composer update --no-dev

    # Optimize Composer
    composer dump-autoload --optimize --no-dev
}

function _clear-caches() {
    # public
    rm -rf ./_install/data/caches/smarty_compile/*
    rm -rf ./_install/data/caches/smarty_cache/*

    # protected
    rm -rf ./_protected/data/cache/pH7tpl_compile/*
    rm -rf ./_protected/data/cache/pH7tpl_cache/*
    rm -rf ./_protected/data/cache/pH7_static/*
    rm -rf ./_protected/data/cache/pH7_cache/*
    rm -rf ./_protected/data/backup/file/*
    rm -rf ./_protected/data/backup/sql/*
    rm ./_protected/data/tmp/*.txt
}

function _remove-dev-files() {
    ## Config Files, etc.
    rm ./_constants.php
    rm ./.gitignore
    rm ./.gitattributes
    rm ./.scrutinizer.yml
    rm ./.travis.yml
    rm ./composer.lock
    rm ./phpunit.phar
    rm ./phpunit.xml.dist
    rm ./_protected/app/configs/config.ini
    rm ./nginx.conf

    ## PHPCS
    rm ./phpcs.xml.dist
    rm ./.php_cs
    rm ./.php_cs.cache
    rm ./.php_cs.dist

    ## Docker
    rm ./Dockerfile
    rm ./docker-compose.yml
    rm ./.dockerignore
}

function _remove-dev-folders() {
    # Config folders
    rm -rf ./.github/
    rm -rf ./coverage/ # PHPUnit coverage reports
    rm -rf ./.idea/ # PHPStorm

    ## Others
    rm -f ./_protected/app/system/core/assets/cron/_delay/*
    rm -rf ./_repository/import/*
    rm -rf ./_repository/module/*
    rm -rf ./_tests/
    rm -rf ./_tools/
    rm -rf ./.git/
}

echo "Please specify the release version number (e.g., 14.8.8)"
read version
if [ ! -z "$version" ]; then
    name="pH7Builder"
    tmp_project_folder="pH7-Social-Dating-CMS"

    git clone git@github.com:pH7Software/pH7-Social-Dating-CMS.git $tmp_project_folder --depth=1

    echo "Moving to '${tmp_project_folder}/' folder."
    cd $tmp_project_folder


    echo "Cleaning up the project. Removing unnecessary folders such as dev/testing files, etc."
    run-packaging-cleanup

    echo "Creating a zip archive for v${version}"
    zip -qr ../${name}-${version}.zip .

    echo "Moving back to previous main folder '../'"
    cd ..

    echo "Removing unnecessary '${tmp_project_folder}/' folder."
    rm -rf $tmp_project_folder

    echo "Done! pH7Builder has been successfully packaged. Ready to be distributed!"
    echo "The zip file is available here: ${PWD}/${name}-${version}.zip"
else
    echo "You need to enter a version number for this release."
fi
