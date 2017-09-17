#
# Cookbook:: task6
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.
#yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

package "yum-utils" do
  action :install
end

execute "add docker repo" do
  command "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"
  action :run
end

package "docker-ce" do
  action :install
end

service "docker" do
  action [:enable, :start]
end

file '/etc/docker/daemon.json' do
  content '{ "insecure-registries": ["192.168.50.50:5000"] }'
  mode '0644'
  owner 'root'
  group 'root'
end

service "docker" do
  action [:restart]
end