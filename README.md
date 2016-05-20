# BunkBed

A Vagrant based OpenStack implementation orchestrated with Ansible.

## Installation

Ubuntu installation:
```sh
root@host:~# apt-add-repository ppa:ansible/ansible
root@host:~# apt update
root@host:~# apt install ansible
root@host:~# apt install vagrant qemu-kvm libvirt-bin libvirt-dev
root@host:~# apt install virt-manager 
```

Libvirt installation:
```sh
user@host:~$ vagrant plugin install vagrant-libvirt
user@host:~$ vagrant plugin install vagrant-mutate
```

If you get this type of message when installing the above:
```
/usr/lib/ruby/2.3.0/rubygems/specification.rb:946:in `all=': undefined method `group_by' for nil:NilClass (NoMethodError)
```
Then you have encountered a vagrant bug in 1.8.1 (https://github.com/mitchellh/vagrant/issues/7073) see https://github.com/mitchellh/vagrant/pull/7198 for fix.



Ubuntu version check:
```sh
user@host:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description: Ubuntu 16.04 LTS
Release: 16.04
Codename: xenial
```

Package version check:
```sh
user@host:~$ ansible --version
ansible 2.0.0.2
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides

user@host:~$ vagrant --version
Vagrant 1.8.1

user@host:~$ vagrant plugin list
vagrant-libvirt (0.0.33)
vagrant-mutate (1.1.0)

user@host:~$ vagrant plugin list
vagrant-libvirt (0.0.33)
vagrant-mutate (1.1.0)
```

Virtual machine installation:
```sh
user@host:~$ newgrp libvirtd

# user@host:~$ vagrant box add ubuntu/xenial64
user@host:~$ vagrant box add geerlingguy/ubuntu1604
```

You are likely to have needed to install a non-libvert box and mutate it.
```sh
user@host:~$ vagrant box list
geerlingguy/ubuntu1604 (virtualbox, 1.0.1)
ubuntu/xenial64        (virtualbox, 20160516.1.0)

# user@host:~$ vagrant mutate ubuntu/xenial64 libvirt
user@host:~$ vagrant mutate geerlingguy/ubuntu1604 libvirt
user@host:~$ vagrant box list
geerlingguy/ubuntu1604 (libvirt, 1.0.1)
geerlingguy/ubuntu1604 (virtualbox, 1.0.1)
# ubuntu/xenial64        (libvirt, 20160516.1.0)
# ubuntu/xenial64        (virtualbox, 20160516.1.0)
```

## Usage

### Configuration

Generate keys for vagrant
```
user@host:.../project$ ssh-keygen -t rsa -N "" -f vagrant_rsa -C vagrant
```

Network check
```
eno1      Link encap:Ethernet  HWaddr b8:ae:ed:ea:f1:42  
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
          Interrupt:16 Memory:df100000-df120000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:311 errors:0 dropped:0 overruns:0 frame:0
          TX packets:311 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1 
          RX bytes:23077 (23.0 KB)  TX bytes:23077 (23.0 KB)

virbr0    Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
          inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.255.0
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

wlp1s0    Link encap:Ethernet  HWaddr 00:c2:c6:c8:af:8c  
          inet addr:192.168.0.2  Bcast:192.168.0.255  Mask:255.255.255.0
          inet6 addr: fe80::c707:9b71:4bb1:4c75/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:150 errors:0 dropped:0 overruns:0 frame:0
          TX packets:213 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:12556 (12.5 KB)  TX bytes:21031 (21.0 KB)
```

Update `.../project/playbooks/virtual` appropriately.
```
localhost  ansible_connection=local
vm1        ansible_host=192.168.122.51
vm2        ansible_host=192.168.122.52
...
```

Update `.../project/Vagrantfile` appropriately.
```
...
      node.vm.network "private_network", ip: "192.168.122.#{50+node_id}"
...
```

Ensure public key is in your ssh `authorized_keys` file.

**TODO**

Write an appropriate playbook.

Concoct generic security script for guest_ssh.sh

Provision inter node private network when Ubuntu sorts itself out

### Execution

Start and provision environment
```sh
user@host:.../project$ vagrant up
```

**WARNING** If you bring up anything that is not the maximum number of
  nodes individually, you will not get the ansible provision. Use
  this for two nodes, for instance. 

Instead to bring up a single node, ensure you use, say
```sh
user@host:.../project$ vagrant up node2
```

### Confirmation

```
user@host:.../project$ ssh -i vagrant_rsa vagrant@192.168.122.51
vagrant@node1:~$

user@host:.../project$ ssh -i vagrant_rsa vagrant@192.168.122.52
vagrant@node2:~$

user@host:~/...project$ curl 192.168.122.51
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Hello World</title>
    </head>
    <body>
        <h1>Hello World</h1>
        <p>
            Hosted on node1
        </p>
    </body>
</html>

user@host:~/...project$ curl 192.168.122.52
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Hello World</title>
    </head>
    <body>
        <h1>Hello World</h1>
        <p>
            Hosted on node2
        </p>
    </body>
</html>

```

## Contributing

1. Fork the project repo
2. Create your feature branch: `git checkout -b myfeature`
3. Commit your changes: `git commit -am 'Added my feature'`
4. Push to the branch: `git push origin myfeature`
5. Submit a pull request

## Credits

Steve Marvell (SM) - Systems Architect - Unipart Digital

## History

TODO

## Comments

I had to use a different vagrant image because the currently
maintained one has a `hostname` and `ifdown` and patch workarounds are
unwise. Better to wait for Vagrant 1.8.2 and any appropriate updates
to Ununtu 16.04. - SM

Had to downgrade to wily64 to get multiple network cards to work.

## TODO

* Address the above ifdown issue
* Use a current vagrant image rather than user image when above is fixes
* Create keys for inter box ssh

## License

GLPv3 - see LICENSE

### LOADS TODO

convert existing image

sudo apt install libguestfs-tools

sysarch@biscuit:~/...project$ virsh  net-dumpxml generic

sysarch@biscuit:~/...project$ sudo ls /var/lib/libvirt/images
generic.qcow2

sysarch@biscuit:~/...project$ virsh --connect qemu:///system list --all
 Id    Name                           State
----------------------------------------------------
 26    generic                        running

sysarch@biscuit:~/...project$ virsh --connect qemu:///system shutdown generic
Domain generic is being shutdown

sysarch@biscuit:~/...project$ virt-clone --connect=qemu:///system -o generic -n generic2 -f ~/generic2.gcow2

virt-clone --connect=qemu:///system -o vanilla -n generic -f ~/generic.gcow2

sysarch@biscuit:~/...project$ virsh  dumpxml  generic | grep "mac address"
      <mac address='52:54:00:f5:ef:16'/>
      
sysarch@biscuit:~/...project$ virsh  dumpxml  generic2 | grep "mac address"
      <mac address='52:54:00:aa:67:87'/>

sysarch@biscuit:~$ virsh net-list --all
 Name                 State      Autostart     Persistent
----------------------------------------------------------
 default              active     yes           yes

sysarch@biscuit:~$ brctl show
bridge name	bridge id		STP enabled	interfaces
virbr0		8000.000000000000	yes		
sysarch@biscuit:~/test$ virsh net-dumpxml default 
<network>
  <name>default</name>
  <uuid>5fcd1e5d-15f9-4d1d-9a56-2766d165236b</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:60:e3:61'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
sysarch@biscuit:~/test$ virsh  dumpxml  vanilla | grep "mac address"      <mac address='52:54:00:0e:db:75'/>
sysarch@biscuit:~/test$ virsh  dumpxml  generic | grep "mac address"
      <mac address='52:54:00:c5:16:d5'/>
sysarch@biscuit:~/test$ virsh net-update default add ip-dhcp-host "<host mac='52:54:00:0e:db:75' name='vanilla' ip='192.168.122.10' />" --live --config
Updated network default persistent config and live state
sysarch@biscuit:~/test$ virsh net-update default add ip-dhcp-host "<host mac='52:54:00:c5:16:d5' name='generic' ip='192.168.122.20' />" --live --config
Updated network default persistent config and live state
sysarch@biscuit:~/test$ virsh net-dumpxml default 
<network>
  <name>default</name>
  <uuid>5fcd1e5d-15f9-4d1d-9a56-2766d165236b</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:60:e3:61'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
      <host mac='52:54:00:0e:db:75' name='vanilla' ip='192.168.122.10'/>
      <host mac='52:54:00:c5:16:d5' name='generic' ip='192.168.122.20'/>
    </dhcp>
  </ip>
</network>



sysarch@biscuit:~$ virsh start vanilla

sysarch@biscuit:~/test$ virsh ttyconsole vanilla
/dev/pts/1

sysarch@biscuit:~/test$ virsh edit vanilla
Domain vanilla XML configuration not changed.

sysarch@biscuit:~/test$ export VISUAL="emacsclient"
sysarch@biscuit:~/test$ export EDITOR="emacsclient"
sysarch@biscuit:~/test$ virsh edit vanilla
Waiting for Emacs...
Domain vanilla XML configuration edited.

sysarch@biscuit:~/test$ 
sysarch@biscuit:~/test$ virsh restart vanilla
error: unknown command: 'restart'
sysarch@biscuit:~/test$ virsh reboot vanilla


virsh shutoff thing

grub for console

sysarch@biscuit:~/test$ virsh start vanilla
