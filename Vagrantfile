$provision_script = <<SCRIPT
apt-get install -y ruby ruby-dev git curl rsyslog
cd /vagrant
gem install --no-ri --no-rdoc bundler
bundle install
cp /vagrant/vagrant/litmus.conf /etc/litmus.conf
cp /vagrant/vagrant/litmus_unicorn.rb /etc/litmus_unicorn.rb
gem build /vagrant/litmus_paper.gemspec
gem install /vagrant/litmus_paper*.gem
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.box = "debian/contrib-jessie64"
  config.vm.network "forwarded_port", guest: 9292, host: 9292, host_ip: "127.0.0.1"
  config.vm.provision "shell", inline: $provision_script
end
