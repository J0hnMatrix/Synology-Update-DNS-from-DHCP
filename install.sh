#!/opt/bin/bash

HomesPath=/var/services/homes/admin/scripts/synology_dhcp_dns_autoupdate
BinDir=$HomesPath/bin
LogDir=$HomesPath/logs

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run by root. Please login as root or use sudo"
    exit
fi

if [ ! -d $HomesPath ]; then
   echo "The Homes directory does not exist. Please turn it on from Control panel"
   echo "User -> Advanced. Then see the section User Home. Once it is turned on"
   echo "Chnage the path on the \$HomesPath variable in these scripts"
   exit
fi

echo "Checking that source files exist"
for f in dhcp-dns diskstation_dns_modify.sh poll-dhcp-changes.sh startDHCP-DNS.sh S99pollDHCP.sh settings
do
    if [ ! -e $f ]; then
        echo "'$f' seems to be missing, aborting install"
        exit
    fi
done

# These directories should exist already. If they are missing then it could indicate another problem.
echo "Checking that system destination directories exist"
for f in /etc/logrotate.d /usr/local/etc/rc.d
do
    if [ ! -e $f ]; then
        echo "'$f' seems to be missing, aborting install"
        exit
    fi
done

echo "Creating destination directories in $HomesPath"
for d in bin dns_backups logs
do
   if [ ! -d $HomesPath/$d ]; then
      mkdir $HomesPath/$d
      echo "Created $HomesPath/$d"
   fi
done

echo "Copy files to destination directories"
cp S99pollDHCP.sh /usr/local/etc/rc.d
chmod 750 /usr/local/etc/rc.d/S99pollDHCP.sh
cp dhcp-dns  /etc/logrotate.d
chmod 644 /etc/logrotate.d/dhcp-dns
cp diskstation_dns_modify.sh poll-dhcp-changes.sh startDHCP-DNS.sh $BinDir


# Only copy the settings file if one exists. It should not be included in the release tar ball
# We do not want to update it as that is where the user will put their own local settings
if [ -e ./settings ]; then
   cp settings $BinDir
fi

# Create an empty log file so you can start to tail it before running the scripts
touch $LogDir/dhcp-dns.log

echo "Install successfully completed".

