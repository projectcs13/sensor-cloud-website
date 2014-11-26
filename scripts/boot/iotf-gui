#! /bin/sh
### BEGIN INIT INFO
# Provides:          rails
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start a Rails instance
# Description:       Do the simplest thing possible in keeping with
#             upstart to spin up a single Rails instance.
### END INIT INFO

# Author: Sam Pointer
#
# Do NOT "set -e"

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/home/ubuntu/.rvm/rubies/ruby-2.0.0-p451/bin/
USER="ubuntu"
PORT=3000
RAILS_ROOT="/home/ubuntu/iot-framework-gui"
COMMAND="/home/ubuntu/.rvm/gems/ruby-2.0.0-p451@railstutorial_rails_4_0/bin/rails s -p $PORT -d"
# COMMAND="rails s -p $PORT -d"
DESCRIPTION="Rails instance"

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

#
# Function that starts the daemon/service
#
do_start()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    #cd $RAILS_ROOT && sudo bash --login -c "$COMMAND"
    sudo su - ubuntu -c "cd $RAILS_ROOT; $COMMAND"
}

case "$1" in
  start)
        [ "$VERBOSE" != no ] && log_daemon_msg "Starting $DESCRIPTION"
        do_start
        case "$?" in
                0|1) [ "$VERBOSE" != no ] && log_end_msg 0 ;;
                2) [ "$VERBOSE" != no ] && log_end_msg 1 ;;
        esac
        ;;
esac
