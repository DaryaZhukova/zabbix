# -*- mode: ruby -*
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

config.vm.box = "sbeliakou/centos-7.4-x86_64-minimal"

config.vm.define "server" do |server|
   config.vm.provider "virtualbox" do |x|
      x.name = "zserver"
      x.memory = "2048"
   end
   server.vm.network "private_network", ip: "192.168.14.2"
   server.vm.hostname = "zserver"
   server.vm.provision "shell", path: "script.sh"
end
config.vm.define "agent" do |agent|
   config.vm.provider "virtualbox" do |x|
      x.name = "zagent"
      x.memory = "1024"
   end
   agent.vm.network "private_network", ip: "192.168.14.3"
   agent.vm.hostname = "zagent"
   agent.vm.provision "shell", path: "agent_script.sh"
end

end
