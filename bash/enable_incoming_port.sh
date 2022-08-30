
PORTNUM=52311
PORTPROTOCOL=udp

# http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
# http://www.tldp.org/LDP/abs/html/functions.html
# FUNCTION: check if command exists
command_exists () {
  type "$1" &> /dev/null ;
}

# open up linux firewall to accept $PORTPROTOCOL $PORTNUM - iptables
# https://linux.die.net/man/8/iptables
if command_exists iptables ; then
  iptables -A INPUT -p $PORTPROTOCOL --dport $PORTNUM -j ACCEPT
fi
# open up linux firewall to accept $PORTPROTOCOL $PORTNUM - firewall-cmd
# https://firewalld.org/documentation/man-pages/firewall-cmd
if command_exists firewall-cmd ; then
  firewall-cmd --zone=public --add-port=$PORTNUM/$PORTPROTOCOL --permanent
  firewall-cmd --reload
fi
# open up linux firewall to accept $PORTPROTOCOL $PORTNUM - firewall-offline-cmd
# https://firewalld.org/documentation/man-pages/firewall-offline-cmd.html
if command_exists firewall-offline-cmd ; then
  # this applies in anaconda at install time in particular
  firewall-offline-cmd --add-port=$PORTNUM/$PORTPROTOCOL
  firewall-offline-cmd --reload
fi
# open Debian/Ubuntu firewall:
# https://help.ubuntu.com/community/UFW
if command_exists ufw ; then
  ufw allow $PORTNUM/$PORTPROTOCOL
  # might be the same as this:
  # ufw allow proto $PORTPROTOCOL from any to any port $PORTNUM
fi

# for AIX (untested):
# https://www.ibm.com/docs/en/aix/7.3?topic=g-genfilt-command
if command_exists genfilt ; then
  genfilt -n 2 -a P -c $PORTPROTOCOL -P $PORTNUM -D "allow bigfix incoming notification"
fi
