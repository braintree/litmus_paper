#!/bin/bash

apt-get install -y ruby ruby-dev git curl rsyslog
cd /vagrant
gem install --no-ri --no-rdoc bundler
bundle install
cp /vagrant/vagrant/litmus.conf /etc/litmus.conf
cp /vagrant/vagrant/litmus_unicorn.rb /etc/litmus_unicorn.rb
gem build /vagrant/litmus_paper.gemspec
gem install /vagrant/litmus_paper*.gem
