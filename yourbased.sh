#!/usr/bin/env bash
set -ex
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get install -y tzdata unzip
gem install bundler -v 2.0.1
apt-get install -y mysql-server-5.7 mysql-client-core-5.7 mysql-client-5.7 libmysqlclient-dev
# install
wget -N http://chromedriver.storage.googleapis.com/2.35/chromedriver_linux64.zip -P ~/
unzip ~/chromedriver_linux64.zip -d ~/
rm ~/chromedriver_linux64.zip
mv -f ~/chromedriver /usr/local/share/
chmod +x /usr/local/share/chromedriver
ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
bundle install --jobs=3 --retry=3 --deployment --path=${BUNDLE_PATH:-vendor/bundle}
# before_script
mysql -u root -e 'create database questioncove_test;'
# script
RAILS_ENV=test bundle exec rake db:migrate --trace
bundle exec rake db:test:prepare
bundle exec rake
bundle exec rails test:system
