FROM ruby:2.6.5-alpine3.11

EXPOSE 9293/TCP
EXPOSE 9294/TCP

ENV APP_USER litmus_paper
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apk add --update --no-cache \
  build-base \
  linux-headers \
  tzdata \
  rsyslog \
  libgcc libstdc++ \
  git \
  curl \
  procps

# Create non-root user
RUN addgroup -g 1000 -S $APP_USER && \
    adduser -u 1000 -S $APP_USER -G $APP_USER -D

ADD litmus_paper.gemspec /home/$APP_USER/
ADD lib/litmus_paper/version.rb /home/$APP_USER/lib/litmus_paper/version.rb
ADD Gemfile* /home/$APP_USER/

WORKDIR /home/$APP_USER

RUN bundle config --global frozen 1 && \
  bundle install \
  -j2 \
  --retry 3 \
  # Remove unneeded files (cached *.gem, *.o, *.c)
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

ADD . /home/$APP_USER
RUN ln -sf /home/$APP_USER/docker/litmus.conf /etc/litmus.conf \
  && ln -sf /home/$APP_USER/docker/litmus_unicorn.rb /etc/litmus_unicorn.rb
RUN gem build litmus_paper.gemspec && gem install litmus_paper*.gem
RUN chown -R $APP_USER:$APP_USER /home/$APP_USER

# Drop to app user
USER $APP_USER

CMD ["bin/litmus", "-p", "9293", "-c", "/etc/litmus_unicorn.rb"]
