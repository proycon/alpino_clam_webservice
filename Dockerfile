FROM debian:11.2-slim AS alpino
LABEL org.opencontainers.image.title="Alpino" \
      org.opencontainers.image.authors="Maarten van Gompel <proycon@anaproy.nl>" \
      org.opencontainers.image.description="Alpino" \
      org.opencontainers.image.source="https://github.com/proycon/alpino_clam_webservice"

# This is largely derived from the official docker image, which
# is a bit out-of-date at this time (old Ubuntu), and a bit too bloated
# for our use.

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        locales \
        bash \
        g++ \
        make \
        automake \
        autoconf \
        bzip2 \
        unzip \
        wget \
        curl \
        libtool \
        git \
        subversion \
        python2.7-minimal \
        python3-minimal \
        zlib1g-dev \
        ca-certificates \
        libtcl8.6 \
        libtk8.6 \
        libwww-perl \
        libxslt1.1 \
        libsm6 \
        ucto \
        tk

RUN echo "en_US UTF-8\nen_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

ENV PATH /Alpino/bin:/Alpino/Tokenization:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV ALPINO_HOME /Alpino
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Downloading the index triggers a new download of Alpino when anything in the index has changed
ADD http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/ /index
RUN cd / && rm index && \
    curl -s http://www.let.rug.nl/vannoord/alp/Alpino/versions/binary/latest.tar.gz | tar --no-same-owner -vxzf - &&\
    find /Alpino -name '.nfs*' | xargs rm -f  # Remove stale nfs files

# Add libraries to standard path
RUN ldconfig /Alpino/boost /Alpino/fadd /Alpino/unix /Alpino/TreebankTools/IndexedCorpus

ENV LD_LIBRARY_PATH :/Alpino/util:/Alpino/Tokenization:/Alpino/fadd:/Alpino/TreebankTools/IndexedCorpus:/Alpino/create_bin:/Alpino/util:/Alpino/create_bin/extralibs:/Alpino/create_bin/extralibs/boost
ENV TCL_LIBRARY /Alpino/create_bin/extralibs/tcl8.5
ENV TK_LIBRARY /Alpino/create_bin/extralibs/tk8.5

ENTRYPOINT /bin/bash

FROM alpino

ENV UWSGI_PROCESSES=2
ENV UWSGI_THREADS=2

ENV UWSGI_UID=100
ENV UWSGI_GID=100

# By default, data from the webservice will be stored on the mount you provide
ENV CLAM_ROOT=/data/alpino_webservice
ENV CLAM_PORT=80
# (set to true or false, enable this if you run behind a properly configured reverse proxy only)
ENV CLAM_USE_FORWARDED_HOST=false
# Set this for interoperability with the CLARIN Switchboard
ENV CLAM_SWITCHBOARD_FORWARD_URL=""

# By default, there is no authentication on the service,
# which is most likely not what you want if you aim to
# deploy this in a production environment.
# You can connect your own Oauth2/OpenID Connect authorization by setting the following environment parameters:
ENV CLAM_OAUTH=false
#^-- set to true to enable
ENV CLAM_OAUTH_AUTH_URL=""
#^-- example for clariah: https://authentication.clariah.nl/Saml2/OIDC/authorization
ENV CLAM_OAUTH_TOKEN_URL=""
#^-- example for clariah https://authentication.clariah.nl/OIDC/token
ENV CLAM_OAUTH_USERINFO_URL=""
#^--- example for clariah: https://authentication.clariah.nl/OIDC/userinfo
ENV CLAM_OAUTH_CLIENT_ID=""
ENV CLAM_OAUTH_CLIENT_SECRET=""
#^-- always keep this private!

# Install all global dependencies
RUN apt-get update && apt-get install -y --no-install-recommends runit curl ca-certificates nginx uwsgi uwsgi-plugin-python3 python3-pip python3-yaml python3-lxml python3-requests

# Prepare environment
RUN mkdir -p /etc/service/nginx /etc/service/uwsgi

# Patch to set proper mimetype for CLAM's logs; maximum upload size
RUN sed -i 's/txt;/txt log;/' /etc/nginx/mime.types &&\
    sed -i 's/xml;/xml xsl;/' /etc/nginx/mime.types &&\
    sed -i 's/client_max_body_size 1m;/client_max_body_size 1000M;/' /etc/nginx/nginx.conf

# Temporarily add the sources of this webservice
COPY . /usr/src/webservice

# Configure webserver and uwsgi server
RUN cp /usr/src/webservice/runit.d/nginx.run.sh /etc/service/nginx/run &&\
    chmod a+x /etc/service/nginx/run &&\
    cp /usr/src/webservice/runit.d/uwsgi.run.sh /etc/service/uwsgi/run &&\
    chmod a+x /etc/service/uwsgi/run &&\
    cp /usr/src/webservice/alpino_webservice/alpino_webservice.wsgi /etc/alpino_webservice.wsgi &&\
    chmod a+x /etc/alpino_webservice.wsgi &&\
    cp -f /usr/src/webservice/alpino_webservice.nginx.conf /etc/nginx/sites-enabled/default

# Install the the service itself
RUN cd /usr/src/webservice && pip install . && rm -Rf /usr/src/webservice
RUN ln -s /usr/local/lib/python3.*/dist-packages/clam /opt/clam

VOLUME ["/data"]
EXPOSE 80
WORKDIR /

ENTRYPOINT ["runsvdir","-P","/etc/service"]
