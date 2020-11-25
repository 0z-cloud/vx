#!/bin/sh
### BEGIN INIT INFO
# Provides:    {{ instance.name }}
# Required-Start:  $syslog $remote_fs
# Required-Stop:  $syslog $remote_fs
# Should-Start:    $local_fs
# Should-Stop:    $local_fs
# Default-Start:  2 3 4 5
# Default-Stop:    0 1 6
# Short-Description: start and stop {{ instance.name }}
# Description: Redis daemon on port {{ instance.port }}
### END INIT INFO

# {{ ansible_managed }}

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/bin/redis-server
DAEMON_ARGS={{ instance.paths.conf }}/redis.conf
NAME={{ instance.name }}
DESC={{ instance.name }}

RUNDIR={{ instance.paths.data }}
PIDFILE={{ instance.paths.pid }}/redis.pid

ULIMIT={{ instance.ulimit }}

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "sudo -u {{ instance.user }} $DAEMON $DAEMON_ARGS"

    echo -n "Starting $DESC: "

    if [ -n "$ULIMIT" ]
    then
      ulimit -n $ULIMIT
    fi

    if start-stop-daemon --start --quiet --umask 007 --pidfile $PIDFILE --chuid "{{ instance.user }}:{{ instance.group }}" --exec $DAEMON -- $DAEMON_ARGS
    then
      echo "$NAME."
    else
      echo "failed"
    fi
  ;;
  stop)
    echo -n "Stopping $DESC: "
    if start-stop-daemon --stop --retry forever/TERM/1 --quiet --oknodo --pidfile $PIDFILE --exec $DAEMON
    then
      echo "$NAME."
    else
      echo "failed"
    fi
    rm -f $PIDFILE
    sleep 1
  ;;

  restart|force-reload)
    ${0} stop
    ${0} start
  ;;

  status)
    #status_of_proc "$DAEMON" "$NAME" && exit 0 || exit $?
    if start-stop-daemon --stop --quiet --signal 0 --pidfile $PIDFILE --exec $DAEMON
    then
      echo "running"
    else
      echo "not running"
    fi
  ;;

  *)
    echo "Usage: /etc/init.d/$NAME {start|stop|restart|force-reload|status}" >&2
    exit 1
  ;;
esac

exit 0