#Define varibles for servers

srvFirstIP = "192.168.50.50"
srvFirstHostName = "server1"
srvSecondIP = "192.168.50.55"
srvSecondHostName = "server2"

$scriptHostUpdate = <<SCRIPT

echo "$1 $2 $2" >> /etc/hosts  

SCRIPT

$scriptGit = <<SCRIPT
sudo yum install git -y
cd /home
git clone https://github.com/vpr-trn/training.git
cd training
git checkout task1
git pull

echo 'Printing content of test1.txt file to console:\n-----\n'
cat test1.txt
echo '-----\nend of test1.txt file'

SCRIPT

#echo '192.168.50.55 server2 server2' >> /etc/hosts  

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"
  config.vm.box_check_update = false
  
#  config.vm.provider "virtualbox" do |vb|
#    vb.gui = true
#  end
 
  config.vm.define "server1" do |server1|
    server1.vm.hostname = srvFirstHostName
    server1.vm.network "private_network", ip: srvFirstIP
	server1.vm.provision :shell, :inline => $scriptHostUpdate, :args =>[srvSecondIP,srvSecondHostName]
	server1.vm.provision :shell, :inline => $scriptGit
  end

  config.vm.define "server2" do |server2|
    server2.vm.hostname = srvSecondHostName
	server2.vm.network "private_network", ip: srvSecondIP
	server2.vm.provision :shell, :inline => $scriptHostUpdate, :args =>[srvFirstIP,srvFirstHostName]
  end

end

