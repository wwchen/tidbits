#!/bin/bash

## firewall.sh
# Execute this script as root on a debian based system to enable ingress firewall

echo "Stopping firewall and allowing everyone..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "Restoring firewall configs"
iptables-restore <<EOF
*filter

# throttle ssh
-N SSH_CHECK
-A INPUT -p tcp --dport 22 -m state --state NEW -j SSH_CHECK
-A SSH_CHECK -m recent --set --name SSH
-A SSH_CHECK -m recent --update --seconds 60 --hitcount 4 --name SSH -j DROP

# trust all communications on local networks
-A INPUT -i lo -j ACCEPT
-A INPUT -s 10.0.0.0/8     -j ACCEPT
-A INPUT -s 172.16.0.0/12  -j ACCEPT
-A INPUT -s 192.168.0.0/16 -j ACCEPT
#-A INPUT -i tun+           -j ACCEPT

# don't kill existing connections and deny ping floods
-A INPUT -i eth0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i eth0 -p icmp -m icmp --icmp-type 8 -m limit --limit 1/sec -j ACCEPT

-A INPUT -p tcp --dport www     -j ACCEPT
-A INPUT -p tcp --dport https   -j ACCEPT
-A INPUT -p tcp --dport ssh     -j ACCEPT
-A INPUT -p tcp --dport telnet  -j ACCEPT
-A INPUT -p tcp --dport rsync   -j ACCEPT
-A INPUT -p udp --dport rsync   -j ACCEPT
-A INPUT -p tcp --dport smtp    -j ACCEPT

# jabber, aim, irc
-A INPUT -p tcp --dport xmpp-client -j ACCEPT
-A INPUT -p udp --dport xmpp-client -j ACCEPT
-A INPUT -p tcp --dport aol         -j ACCEPT
-A INPUT -p tcp --dport ircd        -j ACCEPT

# vnc:1
#-A INPUT -p tcp -m tcp --dport 5901 -j ACCEPT
#-A INPUT -p tcp -m tcp --dport 6001 -j ACCEPT

COMMIT
EOF

