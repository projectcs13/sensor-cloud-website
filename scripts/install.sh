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
echo "Downloading RVM"
echo "=============================================================================="
curl -L https://get.rvm.io | bash -s

#echo "=============================================================================="
#echo "Set RVM command for access through bash shell"
#echo "=============================================================================="
grep -q -e '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' ~/.bash_profile || echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bash_profile

#echo "=============================================================================="
#echo "Set bash sources, needed for ruby"
#echo "=============================================================================="
grep -q -e 'source ~/.profile' ~/.bash_profile || echo 'source ~/.profile' >> ~/.bash_profile

echo "=============================================================================="
echo "Reload bash profile"
echo "=============================================================================="
source ~/.bash_profile

echo "=============================================================================="
echo "Reload RVM"
echo "=============================================================================="
rvm reload

echo "=============================================================================="
echo "Download and install latest RVM version"
echo "=============================================================================="
rvm get stable --auto-dotfiles

echo "=============================================================================="
echo "Reload bash profile"
echo "=============================================================================="
source ~/.bash_profile

echo "=============================================================================="
echo "Download and install any Ruby requirements"
echo "=============================================================================="
rvm requirements

echo "=============================================================================="
echo "Install Ruby 2.0.0"
echo "=============================================================================="
rvm install 2.0.0 --with-openssl-dir=$HOME/.rvm/usr

echo "=============================================================================="
echo "Reinstall Ruby 2.0.0"
echo "=============================================================================="
rvm reinstall 2.0.0

echo "=============================================================================="
echo "Specify which rails version to use"
echo "=============================================================================="
rvm use 2.0.0@railstutorial_rails_4_0 --create --default

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
