#!/bin/bash --login

# Download ruby
curl -L https://get.rvm.io

# Set bash sources, needed for ruby
grep -q -e 'source ~/.profile' ~/.bash_profile || sed -i '$ a \ source ~/.profile' ~/.bash_profile

source ~/.bash_profile

# Get latest rvm version
rvm get stable

# Get ruby requirements
rvm requirements

# Install ruby 2.0.0
rvm install 2.0.0 --with-open-ssl-dir=$HOME/.rvm/usr

# Specify which rails version to use
rvm use 2.0.0@railstutorial_rails_4_0 --create --default

# Download all the gems (libraries) specified in the Gemfile except the ones in the 'production' group
bundle install --without production

# Create the database
bundle exec rake db:migrate
