FROM ubuntu:trusty

ENV XYMON_VERSION=4.3.28

RUN apt-get update && apt-get -y install
RUN apt-get update && \
  apt-get -y install supervisor cpio curl  apache2 rrdtool ldap-utils fping libc-ares2 build-essential devscripts debhelper librrd2-dev librrd-dev libpcre3-dev libssl-dev libldap2-dev libc-ares-dev && \
  mkdir /src && \
  curl -L "https://sourceforge.net/projects/xymon/files/Xymon/${XYMON_VERSION}/xymon-${XYMON_VERSION}.tar.gz/download" | tar xzf - -C /src/ --strip-components=1 && \
  cd /src && \
  ./build/makedeb.sh ${XYMON_VERSION}

FROM ubuntu:trusty
COPY --from=0 /src/debbuild/*.deb /tmp/
RUN apt-get update && \
  apt-get -y install apache2 supervisor curl fping rrdtool libldap-2.4-2 librrd4 && \
  dpkg -i /tmp/*.deb && \
  apt-get clean
RUN a2enmod authz_groupfile rewrite cgi && \
  ln -s /etc/apache2/conf.d/xymon /etc/apache2/conf-enabled/xymon.conf
COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint /entrypoint

ENTRYPOINT ["/entrypoint"]
EXPOSE 80 1984
