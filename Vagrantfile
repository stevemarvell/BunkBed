Vagrant.configure("2") do |config|

  ##############################################
  #
  # Boxes
  #

  #  config.vm.box = "ubuntu/xenial64"
  config.vm.box = "geerlingguy/ubuntu1604"
  #  config.vm.box = "ubuntu/wily64"

  config.vm.provider :libvirt do |libvirt|

    libvirt.memory = 256
    libvirt.cpus = 2

    # nested virtual machine wizardry
    libvirt.nested = true

    libvirt.driver = "kvm"

    libvirt.connect_via_ssh = false
    libvirt.id_ssh_key_file = File.expand_path("vagrant_rsa")
  end

  #
  ##############################################

  ##############################################
  #
  # SSH
  #

  # vagrant issues #1673..fixes hang with configure_networks

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # use secure key
  
  config.ssh.insert_key = false

  # this is so we can set our own key but use insecure one first

  config.ssh.private_key_path  = [
    "vagrant_rsa",
    "~/.vagrant.d/insecure_private_key"
  ]

  config.vm.provision "file",
                      source: "vagrant_rsa.pub",
                      destination: "~/.ssh/authorized_keys"

  #  config.vm.provision "shell", path: "guest_ssh.sh"

  #
  ##############################################

  ##############################################
  #
  # Filesystem
  #

  # enable shared folder

  config.vm.synced_folder "share", "/share", create: "true"

  # disable "this" director as /vagrant
  # config.vm.synced_folder '.', '/vagrant', :disabled => true

  #
  ##############################################

  ##############################################
  #
  # VMs
  #
  
  # number of nodes

  N = 2
  
  (1..N).each do |node_id|
    
    config.vm.define "node#{node_id}" do |node|

      node.vm.hostname = "node#{node_id}"

      node.vm.network "private_network", ip: "192.168.144.#{50+node_id}"

      # This doesn't work because of the idfown problem is 16.04
      # node.vm.network "private_network", ip: "10.11.12.#{50+node_id}"

      ##############################################
      #
      # Ansible
      #
      # Only execute the Ansible provisioner once
      # all the nodes are up and ready.
      #
      
      if node_id == N

        node.vm.provision :ansible do |ansible|
          
          ansible.inventory_path="virtual"
          ansible.playbook = "playbooks/site.yml"
          ansible.limit = "nodes"
          
        end
        
      end

      #
      ##############################################
      
    end
  end

  #
  ##############################################

end
