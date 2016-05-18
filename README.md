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
```
## a patch may be required

user@host:~$ vagrant plugin install vagrant-libvirt
user@host:~$ vagrant plugin install vagrant-mutate
```

# sudo adduser $USER libvirtd ???

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
```

Virtual machine installation:
```sh
# user@host:~$ vagrant box add ubuntu/xenial64
user@host:~$ vagrant box add geerlingguy/ubuntu1604
 
user@host:~$ vagrant box list
geerlingguy/ubuntu1604 (virtualbox, 1.0.1)
ubuntu/xenial64        (virtualbox, 20160516.1.0)


user@host:~$ vagrant mutate geerlingguy/ubuntu1604 libvirt
user@host:~$ vagrant mutate ubuntu/xenial64 libvirt
user@host:~$ vagrant box list
geerlingguy/ubuntu1604 (libvirt, 1.0.1)
geerlingguy/ubuntu1604 (virtualbox, 1.0.1)
ubuntu/xenial64        (libvirt, 20160516.1.0)
ubuntu/xenial64        (virtualbox, 20160516.1.0)

user@host:~$ 
user@host:~$ 
user@host:~$ 

```

## Usage

### Configuration
```
user@host:.../project$ ssh-keygen -t rsa -N "" -f vagrant_rsa -C vagrant
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

Instead to brin up a single node, ensure you use, say
```sh
user@host:.../project$ vagrant up node2
```

### Confirmation

```
user@host:.../project$ ssh -i vagrant_rsa vagrant@192.168.144.51
vagrant@node1:~$
user@host:.../project$ ssh -i vagrant_rsa vagrant@192.168.144.52
vagrant@node2:~$
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

## License

GLPv3 - see LICENSE