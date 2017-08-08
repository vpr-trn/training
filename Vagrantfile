#Define all servers:

servers = { 
    :gitserver => {
	  :hostname => "server1",
	  :ipaddress => "192.168.50.50",
	  :role => "main"
	},
    :appserver => {
	  :hostname => "server2",
	  :ipaddress => "192.168.50.55"
	}
}

#Scrpipt for hosts file update
$scriptHostUpdate = <<SCRIPT

echo "$1 $2 $2" >> /etc/hosts  

SCRIPT

#Script for Git 
$scriptGit = <<SCRIPT
yum install git -y
git clone https://github.com/vpr-trn/training.git
cd training
git checkout task1
git pull

echo 'Printing content of test1.txt file to console:\n-----\n'
cat test1.txt
echo '-----\nend of test1.txt file'

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"
  config.vm.box_check_update = false
  
#  config.vm.provider "virtualbox" do |vb|
#    vb.gui = true
#  end
 
 servers.each do |server,options|
  config.vm.define server do |server_cfg|
    server_cfg.vm.hostname = options[:hostname]
    server_cfg.vm.network :private_network, ip: options[:ipaddress]
	if options[:role] == "main"
	  server_cfg.vm.provision :shell, :inline => $scriptGit
	end
	servers.each do |hosts,attributes|
	  server_cfg.vm.provision :shell, :inline => $scriptHostUpdate, :args =>[attributes[:ipaddress], attributes[:hostname]]
	end
	
  end
end

end

