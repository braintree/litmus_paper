Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-jessie64"
  config.vm.network "forwarded_port", guest: 9292, host: 9292, host_ip: "127.0.0.1"
  config.vm.provision "shell", path: "vagrant/provision.sh"
end
