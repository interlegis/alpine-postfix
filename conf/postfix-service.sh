#!/bin/bash

function log {
  echo `date` $ME - $@
}

function serviceConf {
  # Substitute configuration
  for VARIABLE in `env | cut -f1 -d=`; do
    sed -i "s={{ $VARIABLE }}=${!VARIABLE}=g" /etc/postfix/*.cf
  done

  # Override Postfix configuration
  if [ -f /overrides/postfix.cf ]; then
    while read line; do
      postconf -e "$line"
    done < /overrides/postfix.cf
    echo "Loaded '/overrides/postfix.cf'"
  else
    echo "No extra postfix settings loaded because optional '/overrides/postfix.cf' not provided."
  fi

  # Include table-map files
  if ls -A /overrides/*.map 1> /dev/null 2>&1; then
    cp /overrides/*.map /etc/postfix/
    postmap /etc/postfix/*.map
    rm /etc/postfix/*.map
    chown root:root /etc/postfix/*.db
    chmod 0600 /etc/postfix/*.db
    echo "Loaded 'map files'"
  else
    echo "No extra map files loaded because optional '/overrides/*.map' not provided."
  fi
}

function serviceStart {
  serviceConf
  # Actually run Postfix
  log "[ Starting Postfix... ]"
  rm -f /var/run/rsyslogd.pid
  nohup /usr/lib/postfix/master &
  echo $! > /var/run/postfix.pid
  nohup rsyslogd -n &
}

function serviceStop {
  log "[ Stopping Postfix... ]"
  kill `cat /var/run/postfix.pid`
}

function serviceRestart {
  log "[ Restarting Postfix... ]"
  serviceStop
  serviceStart
  /opt/monit/bin/monit reload
}

export DOMAIN=${DOMAIN:-"localhost"}
export MESSAGE_SIZE_LIMIT=${MESSAGE_SIZE_LIMIT:-"50000000"}
export RELAYNETS=${RELAYNETS:-""}
export RELAYHOST=${RELAYHOST:-""}

case "$1" in
  "start")
    serviceStart &>> /proc/1/fd/1
  ;;
  "stop")
    serviceStop &>> /proc/1/fd/1
  ;;
  "restart")
    serviceRestart &>> /proc/1/fd/1
  ;;
  *) echo "Usage: $0 restart|start|stop"
  ;;
esac
