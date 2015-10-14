FROM ubuntu:14.04.2
MAINTAINER Konstantinos Vandikas (konstantinos.vandikas@ericsson.com)

#update environment
RUN apt-get update
RUN apt-get -yqf upgrade

# install git and checkout source-code from github
RUN apt-get install -yq git software-properties-common curl wget make
WORKDIR /opt
RUN git clone https://github.com/EricssonResearch/iot-framework-gui.git

# change workdir
WORKDIR /opt/iot-framework-gui

# install iot-framework-gui
RUN make install

# modify the API_URL variable

# expose port for rails
EXPOSE 3000

# Start the Rails server
#RUN make run

