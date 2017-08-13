#Number of appservers:
APPSRV_COUNT =2

#Scrpipt for appservers
$scriptAppserver = <<SCRIPT
systemctl stop firewalld
yum install tomcat tomcat-webapps tomcat-admin-webapps -y
mkdir /usr/share/tomcat/webapps/test/
echo "tomcat$1" >> /usr/share/tomcat/webapps/test/index.html
systemctl enable tomcat
systemctl start tomcat
SCRIPT

#Script for WebServer 
$scriptWebServer = <<SCRIPT
systemctl stop firewalld
yum install httpd -y
cp /vagrant/mod_jk.so /etc/httpd/modules/
rm -f /etc/httpd/conf/workers.properties

cat <<MYC >> /etc/httpd/conf/workers.properties
worker.list=lb
worker.lb.type=lb
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

SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "bertvv/centos72"
  config.vm.box_check_update = false
 
 (1..APPSRV_COUNT).each do |i|
    config.vm.define "server#{i}" do |appserver|
    appserver.vm.hostname = "server#{i}"
    appserver.vm.network :private_network, ip: "192.168.50.#{i+55}"
	appserver.vm.provision :hosts, :sync_hosts => true
    appserver.vm.provision :shell, :inline => $scriptAppserver, :args => "#{i}"
    end
 end
 
 config.vm.define "mainserver" do |server|
   server.vm.hostname = "mainserver"
   server.vm.network :private_network, ip: "192.168.50.50"
   server.vm.network :forwarded_port, guest: 80, host: 8080
   server.vm.provision :hosts, :sync_hosts => true
   server.vm.provision :shell, :inline => $scriptWebServer
   BALANCE_WORKER_STRING=""
   (1..APPSRV_COUNT).each do |i|
    BALANCE_WORKER_STRING << "worker#{i},"
    server.vm.provision :shell, :inline => "
     echo worker.worker$1.type=ajp13 >> /etc/httpd/conf/workers.properties
     echo worker.worker$1.host=server$1 >> /etc/httpd/conf/workers.properties
     echo worker.worker$1.port=8009 >> /etc/httpd/conf/workers.properties", :args => "#{i}"
   end
   server.vm.provision :shell, :inline => "
    echo worker.lb.balance_workers=$1 >> /etc/httpd/conf/workers.properties 
    systemctl enable httpd
    systemctl start httpd ", :args => BALANCE_WORKER_STRING.chomp(',')
 end 
end
