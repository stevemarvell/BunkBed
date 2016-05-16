# BunkBed

A Vagrant based OpenStack implementation orchestrated with Ansible.

## Installation

The `ansible`, `vagrant` and `virtualbox` packages are requred.

Ubuntu installation:
```sh
root@host:~# apt-add-repository ppa:ansible/ansible
root@host:~# apt update
root@host:~# apt install ansible
root@host:~# apt install vagrant virtualbox
```

Ubuntu and package version check:
```
root@host:~# lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description: Ubuntu 16.04 LTS
Release: 16.04
Codename: xenial

root@host:~# ansible --version
ansible 2.0.0.2
  config file = /etc/ansible/ansible.cfg
  configured module search path = Default w/o overrides

root@host:~# vagrant --version
Vagrant 1.8.1
```
## Usage

Write an appropriate playbook.

Start and provision environment
```sh
user@host:~$ cd .../$PROJECT
user@host:~$ vagrant up
```



## Contributing

1. Fork the project repo
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
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

## TODO

* Address the above ifdown issue
* Use a current vagrant image rather than user image when above is fixes

## License

GLPv3 - see LICENSE