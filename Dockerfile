FROM ubuntu:14.04.2
MAINTAINER Konstantinos Vandikas (konstantinos.vandikas@ericsson.com)

#update environment
RUN apt-get update
RUN apt-get -yqf upgrade

# install git and checkout source-code from github
RUN apt-get install -yq git software-properties-common curl wget make
WORKDIR /opt
RUN git clone https://github.com/EricssonResearch/iot-framework-gui.git

# build rvm requirements
RUN apt-get install -yq build-essential bison openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libxml2-dev autoconf libc6-dev ncurses-dev automake libtool

# change workdir
WORKDIR /opt/iot-framework-gui

# install ruby + other dependencies
RUN apt-get -yq install ruby2.0 ruby2.0-dev libpq-dev libsqlite3-dev

# switch to ruby 2.0
RUN rm /usr/bin/ruby /usr/bin/gem /usr/bin/irb /usr/bin/rdoc /usr/bin/erb
RUN ln -s /usr/bin/ruby2.0 /usr/bin/ruby
RUN ln -s /usr/bin/gem2.0 /usr/bin/gem
RUN ln -s /usr/bin/irb2.0 /usr/bin/irb
RUN ln -s /usr/bin/rdoc2.0 /usr/bin/rdoc
RUN ln -s /usr/bin/erb2.0 /usr/bin/erb
RUN gem update --system
RUN gem pristine --all

# install bundler
RUN gem install bundler

# install required bundles
RUN bundler install

# create database
RUN bundle exec rake db:migrate

# modify the API_URL variable

# expose port for rails
EXPOSE 3000

# Start the Rails server
RUN make run

