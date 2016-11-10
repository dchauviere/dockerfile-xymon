FROM ubuntu:trusty
MAINTAINER David Chauviere <david.chauviere@orange.com>

ENV XYMON_VERSION=4.3.27

RUN apt-get update && apt-get -y install
RUN apt-get update && \
  apt-get -y install supervisor cpio curl  apache2 rrdtool ldap-utils fping libc-ares2 build-essential devscripts debhelper librrd2-dev librrd-dev libpcre3-dev libssl-dev libldap2-dev libc-ares-dev && \
  mkdir /src && \
  curl -L "https://sourceforge.net/projects/xymon/files/Xymon/${XYMON_VERSION}/xymon-${XYMON_VERSION}.tar.gz/download" | tar xzf - -C /src/ --strip-components=1 && \
  cd /src && \
  ./build/makedeb.sh ${XYMON_VERSION} && \
  apt-get -y remove build-essential devscripts debhelper librrd2-dev librrd-dev libpcre3-dev libssl-dev libldap2-dev libc-ares-dev && \
  apt-get -y autoremove && \
  apt-get -y clean && \
  dpkg -i debbuild/*.deb && \
  cd && rm -rf /src

RUN a2enmod authz_groupfile rewrite cgi
RUN ln -s /etc/apache2/conf.d/xymon /etc/apache2/conf-enabled/xymon.conf
COPY supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
EXPOSE 80 1984
