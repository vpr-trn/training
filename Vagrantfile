#Define all servers:
APPSRV_COUNT =2

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

#Scrpipt for appservers
$scriptAppserver = <<SCRIPT
echo "192.168.50.50 webserver webserver" >> /etc/hosts  
systemctl stop firewalld
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
mkdir /usr/share/tomcat/webapps/test/
echo "tomcat$1" >> /usr/share/tomcat/webapps/test/index.html
systemctl enable tomcat
systemctl start tomcat


SCRIPT

#Script for WebServer 
$scriptWebServer = <<SCRIPT
echo "192.168.50.56 server1 server1" >> /etc/hosts
echo "192.168.50.57 server2 server2" >> /etc/hosts
systemctl stop firewalld
yum install httpd -y
cp /vagrant/mod_jk.so /etc/httpd/modules/
rm -f /etc/httpd/conf/workers.properties

cat <<MYC >> /etc/httpd/conf/workers.properties
worker.list=lb
worker.lb.type=lb
worker.lb.balance_workers=worker1, worker2
worker.worker1.type=ajp13
worker.worker1.host=server1
worker.worker1.port=8009
worker.worker2.type=ajp13
worker.worker2.host=server2
worker.worker2.port=8009
MYC

rm -f /etc/httpd/conf.d/web.conf

cat <<MYC >> /etc/httpd/conf.d/web.conf
LoadModule    jk_module  modules/mod_jk.so
JkWorkersFile conf/workers.properties
JkShmFile /tmp/shm
JkLogFile logs/mod_jk.log
JkLogLevel info
JkMount /test* lb
MYC

systemctl enable httpd
systemctl start httpd

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"
  config.vm.box_check_update = false
  
#  config.vm.provider "virtualbox" do |vb|
#    vb.gui = true
#  end

 config.vm.define "mainserver" do |server|
   server.vm.hostname = "mainserver"
   server.vm.network :private_network, ip: "192.168.50.50"
   server.vm.network :forwarded_port, guest: 80, host: 8080
   server.vm.provision :shell, :inline => $scriptWebServer
 end
 
 (1..APPSRV_COUNT).each do |i|
    config.vm.define "server#{i}" do |appserver|
      appserver.vm.hostname = "server#{i}"
	  appserver.vm.network :private_network, ip: "192.168.50.#{i+55}"
      appserver.vm.provision :shell, :inline => $scriptAppserver, :args => "#{i}"
    end
 end
 
end
