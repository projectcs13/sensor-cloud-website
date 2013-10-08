#!/bin/bash --login
touch ~/.bash_profile

echo "Download ruby version manager"
curl -L https://get.rvm.io | bash -s

echo "Set rvm command and bash sources, needed for ruby"
grep -q -e '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' ~/.bash_profile || echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile

echo "Set bash sources, needed for ruby"
grep -q -e 'source ~/.profile' ~/.bash_profile || echo 'source ~/.profile' >> ~/.bash_profile

echo "Reload bash profile"
source ~/.bash_profile

echo "Get latest rvm version"
rvm get stable

echo "Get ruby requirements"
rvm requirements

echo "Install ruby 2.0.0"
rvm install 2.0.0 --with-openssl-dir=$HOME/.rvm/usr

echo "Specify which rails version to use"
rvm use 2.0.0@railstutorial_rails_4_0 --create --default

echo "Download all the gems (libraries) specified in the Gemfile except the ones in the 'production' group"
bundle install --without production

echo "Create the database"
bundle exec rake db:migrate
