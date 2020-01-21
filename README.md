# keepalived-dockerfile
Dockerfile for keepalived sservice on Alpine Linux.

Features
--------

- Supported Environment variables:
    - KEEPALIVED_ROUTER_ID - A unique number from 0 to 255 that should identify the VRRP group. Required.
    - KEEPALIVED_UNICAST_PEERS - An IP of a peer participating in the VRRP group. Required.
    - KEEPALIVED_VIRTUAL_IPS - VRRP virtual ip address. Required.
    - KEEPALIVED_STATE - Defines the server role as 'MASTER' or 'BACKUP'. Default: BACKUP
    - KEEPALIVED_PRIORITY -  Election value, the server configured with the highest priority will become the Master. Default: random 1-200
    - KEEPALIVED_INTERFACE - The host interface that keepalived will monitor and use for VRRP traffic. Default: ens192
    - KEEPALIVED_PASSWORD - A shared password used to authenticate each node in a VRRP group.

## For internal use.

## This repository is still in the alpha stage, and frequently changes. The program comes with no warranty expressed or implied.