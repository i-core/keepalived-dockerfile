#!/usr/bin/env bash
# Check environment variables and set default values
_checkEnv() {
    if [ -z "${KEEPALIVED_ROUTER_ID}" ] || [ -z "${KEEPALIVED_UNICAST_PEERS}" ] || [ -z "${KEEPALIVED_VIRTUAL_IPS}" ]; then
    	echo "Error: Variables 'KEEPALIVED_ROUTER_ID' or 'KEEPALIVED_UNICAST_PEERS' or 'KEEPALIVED_VIRTUAL_IPS' is not specified!"
        exit 1
    else
        if [ -z "${KEEPALIVED_STATE}" ]; then
	        export KEEPALIVED_STATE="BACKUP"
	    fi
        if [ -z "${KEEPALIVED_PRIORITY}" ] && [ "${KEEPALIVED_STATE^^}" == "BACKUP" ]; then
	       export KEEPALIVED_PRIORITY="$(($RANDOM%199))"
	    fi
        if [ -z "${KEEPALIVED_PRIORITY}" ] && [ "${KEEPALIVED_STATE^^}" == "MASTER" ]; then
	       export KEEPALIVED_PRIORITY="200"
	    fi
        if [ -z "${KEEPALIVED_INTERFACE}" ]; then
	        export KEEPALIVED_INTERFACE="ens192"
        fi
        if [ -z "${KEEPALIVED_PASSWORD}" ]; then
	        export KEEPALIVED_PASSWORD="P@ssw0rd"
        fi
    fi
}

# Amending variables in config file
_configAmend() {
    cp -f /etc/keepalived/keepalived.tmpl /etc/keepalived/keepalived.conf

    sed -i "s/_routerid_/${KEEPALIVED_ROUTER_ID}/g" /etc/keepalived/keepalived.conf && \
    sed -i "s/_state_/${KEEPALIVED_STATE}/g" /etc/keepalived/keepalived.conf && \
    sed -i "s/_priority_/${KEEPALIVED_PRIORITY}/g" /etc/keepalived/keepalived.conf && \
    sed -i "s/_interface_/${KEEPALIVED_INTERFACE}/g" /etc/keepalived/keepalived.conf && \
    sed -i "s/_password_/${KEEPALIVED_PASSWORD}/g" /etc/keepalived/keepalived.conf && \
    
    num=`echo ${KEEPALIVED_UNICAST_PEERS} | sed 's/,/\n/g' | wc -l`
    for n in $(seq ${num}); do
        ip=$(echo ${KEEPALIVED_UNICAST_PEERS} | sed 's/,/\n/g' | sed -n ${n}p)
        sed -i "/unicast_peer/a $(echo -e ${ip})" /etc/keepalived/keepalived.conf
    done
    
    num=`echo ${KEEPALIVED_VIRTUAL_IPS} | sed 's/,/\n/g' | wc -l`
    for n in $(seq ${num}); do
        ip=$(echo ${KEEPALIVED_VIRTUAL_IPS} | sed 's/,/\n/g' | sed -n ${n}p)
        sed -i "/virtual_ipaddress/a ${ip}" /etc/keepalived/keepalived.conf
    done
}

# Starting keepalived
_startKeepalived() {
    rm -rf /var/run/keepalived
    if (pgrep -fl keepalived >/dev/null 2>&1); then
        echo "Info: keepalived process already running, killing..."
        pkill -9 keepalived
    fi
    keepalived --use-file /etc/keepalived/keepalived.conf --dont-fork --log-console &
    sleep 1
    echo "Info: keepalived process started!"

    trap _stopKeepalived SIGHUP SIGINT SIGQUIT SIGKILL SIGTERM
}

# Stopping keepalived by signal
_stopKeepalived() {
    echo "Info: killing keepalived process..."
    pkill -2 keepalived
    exit 0
}

# Checking process is running
_healthCheck() {
    while (pgrep -fl keepalived >/dev/null 2>&1)
    do
        sleep 5
    done
    echo "Error: keepalived is not running, exiting..."
    exit 1
}

_checkEnv
_configAmend
_startKeepalived
_healthCheck