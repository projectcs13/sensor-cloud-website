#!/bin/bash --login
touch ~/.bash_profile

# Download ruby
curl -L https://get.rvm.io | bash -s

# Set rvm commandbash sources, needed for ruby
grep -q -e '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' ~/.bash_profile || echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile

# Set bash sources, needed for ruby
grep -q -e 'source ~/.profile' ~/.bash_profile || echo 'source ~/.profile' >> ~/.bash_profile

# Reload bash profile
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
