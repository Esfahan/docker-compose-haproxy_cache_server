#!/bin/bash
haproxy -p /run/haproxy.pid -db -f /etc/haproxy/haproxy.cfg -Ds && \
keepalived --dont-fork --dump-conf --log-console --log-detail --log-facility 7 --vrrp -f /etc/keepalived/keepalived.conf
