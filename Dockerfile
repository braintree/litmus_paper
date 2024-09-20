FROM debian:bookworm-slim

EXPOSE 9293/TCP

ENV APP_USER litmus_paper
ENV SSL_CERT_FILE=/home/${APP_USER}/combined_cacerts.pem
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ruby \
    ruby-dev \
    bundler \
    git \
    curl \
    rsyslog \
    procps \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN addgroup --gid 1000 --system $APP_USER && \
    adduser --disabled-password --uid 1000 --ingroup $APP_USER --system $APP_USER

ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_APP_CONFIG $GEM_HOME
ENV PATH $GEM_HOME/bin:$PATH

COPY --chown=$APP_USER:$APP_USER litmus_paper.gemspec /home/$APP_USER/
COPY --chown=$APP_USER:$APP_USER lib/litmus_paper/version.rb /home/$APP_USER/lib/litmus_paper/version.rb
COPY --chown=$APP_USER:$APP_USER Gemfile* /home/$APP_USER/
COPY --chown=$APP_USER:$APP_USER . /home/$APP_USER

WORKDIR /home/$APP_USER

COPY combined_cacerts.pem /home/${APP_USER}/combined_cacerts.pem
RUN git config --global --add safe.directory /home/litmus_paper
RUN bundle config --global silence_root_warning true frozen 1 && \
  bundle install \
  -j2 \
  --retry 3 \
  # Remove unneeded files (cached *.gem, *.o, *.c)
  && rm -rf /usr/local/bundle/cache/*.gem \
  && find /usr/local/bundle/gems/ -name "*.c" -delete \
  && find /usr/local/bundle/gems/ -name "*.o" -delete

RUN ln -sf /home/$APP_USER/docker/litmus.conf /etc/litmus.conf \
  && ln -sf /home/$APP_USER/docker/litmus_unicorn.rb /etc/litmus_unicorn.rb
RUN gem build litmus_paper.gemspec && gem install litmus_paper*.gem
RUN chown -R $APP_USER:$APP_USER /home/$APP_USER

# Drop to app user
USER $APP_USER

CMD ["bin/litmus", "-p", "9293", "-c", "/etc/litmus_unicorn.rb"]
