#!/bin/bash --login
touch ~/.bash_profile

install_boot_script() {  # $1 is the script
   sudo cp $PWD/scripts/boot/$1 /etc/init.d
   if [ $? -ne 0 ]; then
      echo "Call the script from the project folder"
   else
      echo "Success!"
      sudo chmod +x /etc/init.d/$1
      sudo update-rc.d $1 defaults
   fi
}

echo "=============================================================================="
echo "Install Ruby 2.0.0"
echo "=============================================================================="
apt-get install -yq git software-properties-common curl wget make build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool ruby2.0 ruby2.0-dev libpq-dev libsqlite3-dev

echo "=============================================================================="
echo "Specify which rails version to use"
echo "=============================================================================="
# switch to ruby 2.0
rm /usr/bin/ruby /usr/bin/gem /usr/bin/irb /usr/bin/rdoc /usr/bin/erb
ln -s /usr/bin/ruby2.0 /usr/bin/ruby
ln -s /usr/bin/gem2.0 /usr/bin/gem
ln -s /usr/bin/irb2.0 /usr/bin/irb
ln -s /usr/bin/rdoc2.0 /usr/bin/rdoc
ln -s /usr/bin/erb2.0 /usr/bin/erb
gem update --system
gem pristine --all

echo "=============================================================================="
echo "Specify which rails version to use"
echo "=============================================================================="
gem install bundler

echo "=============================================================================="
echo "Download and install all gems except the 'production' group"
echo "=============================================================================="
bundle install --without production

echo "=============================================================================="
echo "Creates the database to be used for Ruby on Rails"
echo "=============================================================================="
bundle exec rake db:migrate

echo "=============================================================================="
echo "Install a script to run the app as a Linux service"
echo "=============================================================================="
install_boot_script "iotf-gui"
