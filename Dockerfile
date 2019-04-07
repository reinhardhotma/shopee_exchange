FROM ruby:2.5.3
MAINTAINER Reinhard Hotma <reinhard.hotma@ui.ac.id>

RUN apt-get update && \
    apt-get install -y net-tools

ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

COPY . $APP_HOME
RUN ["chmod", "+x", "./entrypoint.sh"]

CMD ["foreman", "start"]