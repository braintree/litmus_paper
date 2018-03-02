FROM debian:stretch
EXPOSE 9293/TCP
EXPOSE 9294/TCP
WORKDIR /home/litmus_paper
RUN apt-get update && apt-get install -y ruby ruby-dev git curl rsyslog build-essential
RUN gem install --no-ri --no-rdoc bundler \
  && gem install sinatra --no-ri --no-rdoc --version "~> 1.3.2" \
  && gem install remote_syslog_logger --no-ri --no-rdoc --version "~> 1.0.3" \
  && gem install unicorn --no-ri --no-rdoc --version "~> 4.6.2" \
  && gem install colorize --no-ri --no-rdoc \
  && gem install rspec --no-ri --no-rdoc --version "~> 2.9.0" \
  && gem install rack-test --no-ri --no-rdoc --version "~> 0.6.1" \
  && gem install rake --no-ri --no-rdoc --version "~> 0.9.2.2" \
  && gem install rake_commit --no-ri --no-rdoc --version "~> 0.13"
ADD . /home/litmus_paper
RUN ln -sf /home/litmus_paper/docker/litmus.conf /etc/litmus.conf \
  && ln -sf /home/litmus_paper/docker/litmus_unicorn.rb /etc/litmus_unicorn.rb
RUN gem build litmus_paper.gemspec && gem install litmus_paper*.gem

CMD ["bin/litmus", "-p", "9293", "-c", "/etc/litmus_unicorn.rb"]
