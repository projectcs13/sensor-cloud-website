FROM ubuntu:14.04.2
MAINTAINER Konstantinos Vandikas (konstantinos.vandikas@ericsson.com)

# install some utilities
RUN apt-get install -yq git software-properties-common curl wget make

WORKDIR /opt
# checkout source-code from github
RUN git clone https://github.com/EricssonResearch/iot-framework-gui.git

#gpg trust
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

# compilation
WORKDIR /opt/iot-framework-gui
RUN make install

# modify the API_URL variable

# expose port
EXPOSE 3000

# Start the Rails server
RUN make run

