FROM python:2.7

ENV ODOO_USER=odoo
ENV BASE_HOME=/opt
ENV ODOO_HOME=/odoo/server

RUN set -x; \
		apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            vim \
            node-less \
            node-clean-css \
            python-gevent \
            python-renderpm \
            python-pip \
            python-dev \
            python-setuptools \
            libevent-dev \
            libsasl2-dev \
            libldap2-dev \
            libssl-dev \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb \
		&& pip install psycogreen==1.0

RUN groupadd -r $ODOO_USER && useradd -r -g $ODOO_USER $ODOO_USER
RUN mkdir -p $BASE_HOME$ODOO_HOME

WORKDIR $BASE_HOME$ODOO_HOME

ADD ./src $BASE_HOME$ODOO_HOME
RUN pip install -r requirements.txt \
	&& pip install pyinotify \
	&& pip install XlsxWriter \
	&& pip install boto3

RUN chown $ODOO_USER:$ODOO_USER -R $BASE_HOME
RUN mkdir -p /var/lib/odoo
RUN chown $ODOO_USER:$ODOO_USER -R /var/*

USER $ODOO_USER
