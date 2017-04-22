FROM debian:wheezy

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

RUN mkdir -p /apps/angular
ADD ./apps-angular /apps/angular
WORKDIR /apps/angular
