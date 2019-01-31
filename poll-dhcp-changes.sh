#!/bin/sh

while true; do    
   ATIME=`stat /etc/dhcpd/dhcpd-leases.log | grep Modify`
   
   if [[ "$ATIME" != "$LTIME" ]]; then
     date
     echo "DHCP Leases changed - Reloading DNS"
     /var/services/homes/admin/scripts/synology_dhcp_dns_autoupdate/bin/diskstation_dns_modify.sh
     LTIME=$ATIME
   fi
   sleep 5
done


