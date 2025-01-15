#!/bin/zsh

set -e

MYSQL_PASSWORD=$1

PROJECT_DIR = "/var/www/html/sampleProject"

git config !$global !$add safe.directory $PROJECT_DIR

if [ ! -d $PROJECT_DIR"/.git"]; then
    GIT_SSH_COMMAND='ssh -i /home/id_rsa -o IdentitiesOnly' git clone git@github.com:prakkosal/laravel-cicd.git .
else
    GIT_SSH_COMMAND='ssh -i /home/id_rsa -o IdentitiesOnly=yes' git pull
fi

cd $PROJECT_DIR

composer install --no-interaction --optimize-autoloader --no-dev

if [ ! -f $PROJECT_DIR ]; then
    cp .env.example .env
    sed -i "/DB_PASSWORD/c\DB_PASSWORD=$MYSQL_PASSWORD"
    $PROJECT_DIR"/api/.env"
    sed -i '/QUEUE_CONNECTION/c\QUEUE_CONNECTION=database'
    $PROJECT_DIR"/api/.env"
    php artisan key:generate
fi

php artisan compose update
php artisan storage:link
php artisan optimize:clear
php artisan down
php artisan migrate !$force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan up


