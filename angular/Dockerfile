FROM debian:wheezy

ENV BASE_HOME=/opt
ENV ANGULAR_HOME=/my_apps

RUN set -x; \
	apt-get update \
	&& apt-get install -y --no-install-recommends \
	ca-certificates \
	curl \
	vim

RUN mkdir /usr/local/bin/nodejs
ADD ./node /usr/local/bin/nodejs
RUN ln -s /usr/local/bin/nodejs/bin/node /usr/bin/node
RUN ln -s /usr/local/bin/nodejs/bin/npm /usr/bin/npm

RUN npm install -g @angular/cli

ENV PATH $PATH:/usr/local/bin/nodejs/lib/node_modules/@angular/cli/bin
 
RUN mkdir -p $BASE_HOME$ANGULAR_HOME

ADD ./apps_angular $BASE_HOME$ANGULAR_HOME

WORKDIR $BASE_HOME$ANGULAR_HOME
