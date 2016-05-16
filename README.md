# BunkBed

A vagrant based OpenStack implementation orchestrated with Ansible.

## Installation

```shell
root@host:~# apt-add-repository ppa:ansible/ansible
root@host:~# apt update
root@host:~# apt install ansible

root@host:~# ansible --version
ansible 2.0.0.2
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides

root@host:~# apt install vagrant virtualbox

user@host:~$ cd project
user@host:~$ vagrant up
```

## Comments

I had to use a different vagrant image because the current one has a
`hostname` and `ifdown` and patch workarounds are unwise. Better to
wait for Vagrant 1.8.2 and any appropriate updates to Ununtu.
