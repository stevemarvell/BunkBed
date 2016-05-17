# This guide is optimized for Vagrant 1.7 and above.
# Although versions 1.6.x should behave very similarly, it is recommended
# to upgrade instead of disabling the requirement below.

Vagrant.require_version ">= 1.7.0"

Vagrant.configure(2) do |config|

#  config.vm.box = "geerlingguy/ubuntu1604"
  config.vm.box = "ubuntu/wily64"

  # use secure key
  
#  config.ssh.insert_key = false
#  config.ssh.private_key_path = File.expand_path("./id_rsa")
#  config.ssh.forward_agent = true
  
  # number of machines
  
  N = 2
  
  (1..N).each do |machine_id|
    
    config.vm.define "machine#{machine_id}" do |machine|

      machine.vm.hostname = "machine#{machine_id}"

      machine.vm.network "private_network", ip: "192.168.144.#{50+machine_id}"

      machine.vm.network "private_network", ip: "10.11.12.#{50+machine_id}"
      
      machine.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
      end
      
      ##############################################
      # Only execute the Ansible provisioner once
      # all the machines are up and ready.
      #
      
      if machine_id == N

        machine.vm.provision :ansible do |ansible|
          
          ansible.inventory_path="./hosts"
          ansible.limit = "vms"
          
          ansible.playbook = "provision.yml"
          
        end
        
      end

      #
      ##############################################
      
    end
  end
end
