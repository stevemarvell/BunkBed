#!/bin/bash

# Updating /etc/lvm/lvm.conf

echo "Updating LVM filters"
sudo sed -i -e 's/filter = \[ "a\/.*\/" \]/filter = \[ "r|\/dev\/sdb|", "r|\/dev\/disk\/*|", "r|\/dev\/block\/*|", "a|.*|" \]/g' /etc/lvm/lvm.conf

# filter = [ "a/.*/" ]

# filter = [ "r|/dev/sdb|", "r|/dev/disk/*|", "r|/dev/block/*|", "a|.*|" ]

echo "Disabling LVM cache"
sudo sed -i -e 's/write_cache_state = 1/write_cache_state = 0/g' /etc/lvm/lvm.conf
# Remove all stale cache entries
echo "Removing stale LVM cache entries"
sudo rm /etc/lvm/cache/.cache
sudo touch /etc/lvm/cache/.cache
#write_cache_state = 1
# write_cache_state = 0
echo "Restarting Ram Disk"
sudo update-initramfs -u

#Updating DRBD resource config

echo 
if [ ! -f "/etc/drbd.d/pg.res" ];
then
echo "Creating Resource file"
sudo touch /etc/drbd.d/pg.res
echo "resource pg {" >> /etc/drbd.d/pg.res
#echo "  device minor 0;" >> /etc/drbd.d/pg.res
#echo "  disk /dev/sdb;" >> /etc/drbd.d/pg.res

echo "  syncer {" >> /etc/drbd.d/pg.res
echo "    rate 1000M;" >> /etc/drbd.d/pg.res
echo "    verify-alg md5;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res

echo "  on node1 {" >> /etc/drbd.d/pg.res
echo "    device minor 0;" >> /etc/drbd.d/pg.res
echo "    disk /dev/sdb;" >> /etc/drbd.d/pg.res
echo "    address 10.1.1.31:7788;" >> /etc/drbd.d/pg.res
echo "    meta-disk internal;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res
echo "  on node2 {" >> /etc/drbd.d/pg.res
echo "    device minor 0;" >> /etc/drbd.d/pg.res
echo "    disk /dev/sdb;" >> /etc/drbd.d/pg.res
echo "    address 10.1.1.32:7788;" >> /etc/drbd.d/pg.res
echo "    meta-disk internal;" >> /etc/drbd.d/pg.res
echo "  }" >> /etc/drbd.d/pg.res
echo "}" >> /etc/drbd.d/pg.res
fi

#modprobe drbd
#echo 'drbd' >> /etc/modules
#update-rc.d drbd defaults

#sudo /etc/init.d/drbd restart

echo "Disabling DRBD autostart"
sudo update-rc.d drbd disable

echo "Creating DRBD Metadata"
yes yes | sudo drbdadm create-md pg

echo "Add DRBD to Kernel Modules"
sudo modprobe drbd
echo 'drbd' >> /etc/modules

echo "Attach DRBD device"
sudo drbdadm up pg

node=$(hostname)
node=$(echo $node)
echo "$node is active. Generating SSH Tunnel."

if [[ $node = "konstantin-MS-16G1" ]]; then
 echo "bla2"
fi


if [[ $node = "node1" ]]; then
 if [ ! -d "/vagrant/.ssh" ]; then
    echo "Create SSH directory."
    sudo mkdir /vagrant/.ssh
 fi
 if [ ! -f "/vagrant/.ssh/id_rsa1" ]; then
    echo "Generate SSH key."
    sudo ssh-keygen -t rsa <<EOF
/vagrant/.ssh/id_rsa1
EOF
 fi
elif [[ $node = "node2" ]]; then
 if [ ! -d "/vagrant/.ssh" ]; then
    echo "Create SSH directory."
    sudo mkdir /vagrant/.ssh
 fi
 if [ ! -f "/vagrant/.ssh/id_rsa2" ]; then
    echo "Create SSH directory."
    sudo ssh-keygen -t rsa <<EOF
/vagrant/.ssh/id_rsa2
EOF
 fi
else
 echo "Node not found."
fi


# Copy keypairs to each node
if [[ $node = "node1" ]]; then
 if [ ! -d "~root/.ssh" ]; then
  echo "Create root SSH directory to allow public keys."
  sudo mkdir ~root/.ssh
 fi
 if [ ! -f "~root/.ssh/authorized_keys" ]; then
  echo "Copy public keys into SSH directory."
  sudo cat /vagrant/.ssh/id_rsa1.pub >> ~root/.ssh/authorized_keys
  sudo cat /vagrant/.ssh/id_rsa2.pub >> ~root/.ssh/authorized_keys
 fi
 # Add node2 to list of known hosts
 echo "Adding nodes to list of known hosts."
 sudo ssh-keyscan -t rsa 10.1.1.31 >> ~/.ssh/known_hosts
 sudo ssh-keyscan -t rsa 10.1.1.32 >> ~/.ssh/known_hosts
 # Disable strict host key checking
 echo "Disabling strict host key checking."
 echo "Host node2" >> /etc/ssh/ssh_config
 echo "   Hostname 10.1.1.32" >> /etc/ssh/ssh_config
 echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
 echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
elif [[ $node = "node2" ]]; then
# Boot into node2 and authorize public keys
 if [ ! -d "~root/.ssh" ]; then
  echo "Create root SSH directory to allow public keys."
  sudo mkdir ~root/.ssh
 fi
 if [ ! -f "~root/.ssh/authorized_keys" ]; then
  sudo cat /vagrant/.ssh/id_rsa1.pub >> ~root/.ssh/authorized_keys
  sudo cat /vagrant/.ssh/id_rsa2.pub >> ~root/.ssh/authorized_keys
 fi
 # Disable strict host key checking
 echo "Host node1" >> /etc/ssh/ssh_config
 echo "   Hostname 10.1.1.31" >> /etc/ssh/ssh_config
 echo "   StrictHostKeyChecking no" >> /etc/ssh/ssh_config
 echo "   UserKnownHostsFile=/dev/null" >> /etc/ssh/ssh_config
 # Add node1 to list of known hosts
 sudo ssh-keyscan -t rsa 10.1.1.31 >> ~/.ssh/known_hosts
 sudo ssh-keyscan -t rsa 10.1.1.32 >> ~/.ssh/known_hosts
 # SSH into node1 and authorize public keys
 sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
if [ ! -d "~root/.ssh" ];
then
  sudo mkdir ~root/.ssh
fi
then
 sudo cat /vagrant/.ssh/id_rsa1.pub >> ~root/.ssh/authorized_keys
 sudo cat /vagrant/.ssh/id_rsa2.pub >> ~root/.ssh/authorized_keys
fi
sudo service drbd start
exit
EOF



#sshpass -p "vagrant" ssh -oStrictHostKeyChecking=no -t -t vagrant@node2

#Back in node2
actual=$(hostname)
echo "SSH back to $actual"
sudo service drbd start
numLines=20
timeToSleep=5
echo "Lines: $numLines + TTS: $timeToSleep"
#exit
# SSH into node1 and authorize public keys
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
sudo drbdadm -- --overwrite-data-of-peer primary pg
until tail -n $numLines /proc/drbd | grep -q "UpToDate/UpToDate"; do 
  echo -ne 'synchronizing. \r'
  sleep $timeToSleep
  echo -ne 'synchronizing.. \r'
  sleep $timeToSleep
  echo -ne 'synchronizing... \r'
  sleep $timeToSleep
done
echo "DRBD sync'ed."
sudo mkfs.xfs -f /dev/drbd0 && sudo pvcreate /dev/drbd0 && sudo vgcreate VG_PG /dev/drbd0 && sudo lvcreate -L 4500M -n LV_DATA VG_PG
sudo mkfs.xfs -d agcount=8 /dev/VG_PG/LV_DATA
sudo mkdir -p -m 0700 /db/pgdata
exit
EOF

actual=$(hostname)
echo "SSH back to $actual"
sudo mkdir -p -m 0700 /db/pgdata
sudo ln -s ../share/postgresql-common/pg_wrapper /usr/bin/pgbench
export ais_port=5405
export ais_mcast=226.94.1.1
export ais_addr=`ip addr | grep "inet " | tail -n 1 | awk '{print $4}' | sed s/255/0/`
sudo sed -i.bak "s/.*mcastaddr:.*/mcastaddr:\ $ais_mcast/g" /etc/corosync/corosync.conf
sudo sed -i.bak "s/.*mcastport:.*/mcastport:\ $ais_port/g" /etc/corosync/corosync.conf
sudo sed -i.bak "s/.*bindnetaddr:.*/bindnetaddr:\ $ais_addr/g" /etc/corosync/corosync.conf

# SSH into node1 and authorize public keys
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
sudo mkfs.xfs -d agcount=8 /dev/VG_PG/LV_DATA
sudo mount -t xfs -o noatime,nodiratime,attr2 /dev/VG_PG/LV_DATA /db/pgdata
sudo chown postgres:postgres /db/pgdata
sudo chmod 0700 /db/pgdata
sudo pg_dropcluster 9.1 main --stop
sudo pg_createcluster -d /db/pgdata -s /var/run/postgresql 9.1 hapg
exit
EOF
actual=$(hostname)
echo "SSH back to $actual"
sudo rm -Rf /db/pgdata/*
sudo update-rc.d postgresql disable
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
sudo update-rc.d postgresql disable
sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/9.1/hapg/postgresql.conf
sudo ln -s ../share/postgresql-common/pg_wrapper /usr/bin/pgbench
sudo service postgresql start
sudo su -c 'createdb pgbench' - postgres
sudo su -c 'pgbench -i -s 5 pgbench' - postgres
exit
EOF

actual=$(hostname)
echo "SSH back to $actual"es

#Sync corosync.conf
export ais_port=5405
export ais_mcast=226.94.1.1
export ais_addr=`ip addr | grep "inet " | tail -n 1 | awk '{print $4}' | sed s/255/0/`
sudo sed -i.bak "s/.*mcastaddr:.*/mcastaddr:\ $ais_mcast/g" /etc/corosync/corosync.conf
sudo sed -i.bak "s/.*mcastport:.*/mcastport:\ $ais_port/g" /etc/corosync/corosync.conf
sudo sed -i.bak "s/.*bindnetaddr:.*/bindnetaddr:\ $ais_addr/g" /etc/corosync/corosync.conf
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
export ais_port=5405
export ais_mcast=226.94.1.1
export ais_addr=`ip addr | grep "inet " | tail -n 1 | awk '{print $4}' | sed s/255/0/`
sudo sed -i.bak "s/.*mcastaddr:.*/mcastaddr:\ $ais_mcast/g" /etc/corosync/corosync.conf
sudo sed -i.bak "s/.*mcastport:.*/mcastport:\ $ais_port/g" /etc/corosync/corosync.conf
sudo sed -i.bak "s/.*bindnetaddr:.*/bindnetaddr:\ $ais_addr/g" /etc/corosync/corosync.conf
sudo sed -i 's/=no/=yes/' /etc/default/corosync
sudo sed -i -e 's/ver:       0/ver:       1/g' /etc/corosync/corosync.conf
cat <<-END >>/etc/corosync/service.d/pcmk
service {
# Load the Pacemaker Cluster Resource Manager
name: pacemaker
ver: 0
}
END
sudo service corosync start
exit
EOF
sudo sed -i 's/=no/=yes/' /etc/default/corosync
sudo sed -i -e 's/ver:       0/ver:       1/g' /etc/corosync/corosync.conf
cat <<-END >>/etc/corosync/service.d/pcmk
service {
# Load the Pacemaker Cluster Resource Manager
name: pacemaker
ver: 0
}
END
sudo service corosync start
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
sudo service pacemaker start
exit
EOF
sudo service pacemaker start
# Pacemaker Configuration
sshpass -p "vagrant" ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t -t vagrant@node1 <<EOF
echo "SSH into node1"
sudo crm configure property stonith-enabled="false"
sudo crm configure property no-quorum-policy="ignore"
sudo crm configure property default-resource-stickiness="100"
sudo crm configure primitive drbd_pg ocf:linbit:drbd params drbd_resource="pg" op monitor interval="15" op start interval="0" timeout="240" op stop interval="0" timeout="120"
sudo crm configure ms ms_drbd_pg drbd_pg meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
sudo crm configure primitive pg_lvm ocf:heartbeat:LVM params volgrpname="VG_PG" op start interval="0" timeout="30" op stop interval="0" timeout="30"
sudo crm configure primitive pg_fs ocf:heartbeat:Filesystem params device="/dev/VG_PG/LV_DATA" directory="/db/pgdata" options="noatime,nodiratime" fstype="xfs" op start interval="0" timeout="60" op stop interval="0" timeout="120"
sudo crm configure primitive pg_lsb lsb:postgresql op monitor interval="30" timeout="60" op start interval="0" timeout="60" op stop interval="0" timeout="60"
sudo crm configure primitive pg_vip ocf:heartbeat:IPaddr2 params ip="10.1.1.30" iflabel="pgvip" cidr_netmask="24" nic="eth2" op monitor interval="5"
sudo crm configure group PGServer pg_lvm pg_fs pg_lsb pg_vip
sudo crm configure colocation col_pg_drbd inf: PGServer ms_drbd_pg:Master
sudo crm configure order ord_pg inf: ms_drbd_pg:promote PGServer:start
exit
EOF

else
 echo "nothing"
fi



#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa1.pub vagrant@node2
#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa2.pub vagrant@node2
#sudo ssh-copy-id -i /vagrant/.ssh/id_rsa2.pub vagrant@node1

#cat ~/.ssh/*.pub | ssh vagrant@node2 'umask 077; cat >>.ssh/authorized_keys'
# Wait until synchronized

# sudo crm configure primitive drbd_pg ocf:linbit:drbd  params drbd_resource="pg" op monitor interval="60s" op monitor interval="10" role="Master" op monitor interval="30" role="Slave" op start interval="0" timeout="240" op stop interval="0" timeout="120"
# sudo crm configure ms ms_drbd_pg drbd_pg meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
# sudo crm configure primitive pg_lvm ocf:heartbeat:LVM params volgrpname="VG_PG" op start interval="0" timeout="30" op stop interval="0" timeout="30"
# sudo crm configure primitive pg_fs ocf:heartbeat:Filesystem params device="/dev/VG_PG/LV_DATA" directory="/db/pgdata" options="noatime,nodiratime" fstype="xfs" op start interval="0" timeout="60" op stop interval="0" timeout="120"
# sudo crm configure primitive pg_lsb lsb:postgresql op monitor interval="30" timeout="60" op start interval="0" timeout="60" op stop interval="0" timeout="60"
# sudo crm configure primitive pg_vip ocf:heartbeat:IPaddr2 params ip="10.1.1.30" iflabel="pgvip" cidr_netmask="24" nic="eth2" op monitor interval="5"
# sudo crm configure group PGServer pg_lvm pg_fs pg_lsb pg_vip
# sudo crm configure colocation col_pg_drbd inf: PGServer ms_drbd_pg:Master
# sudo crm configure order ord_pg inf: ms_drbd_pg:promote PGServer:start
#sudo crm resource migrate PGServer node2
