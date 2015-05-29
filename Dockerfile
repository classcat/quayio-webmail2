FROM ubuntu:trusty
MAINTAINER ClassCat Co.,Ltd. <support@classcat.com>

########################################################################
# ClassCat/Webmail Dockerfile
#   Maintained by ClassCat Co.,Ltd ( http://www.classcat.com/ )
########################################################################

#--- HISTORY -----------------------------------------------------------
# 22-may-15 : quay.io.
# 19-may-15 : trusty.
# 17-may-15 : sed -i.bak
# 16-may-15 : php5-gd php5-json php5-curl php5-imagick libapache2-mod-php5.
# 08-may-15 : Created.
#-----------------------------------------------------------------------

RUN apt-get update && apt-get -y upgrade \
  && apt-get install -y language-pack-en language-pack-en-base \
  && apt-get install -y language-pack-ja language-pack-ja-base \
  && update-locale LANG="en_US.UTF-8" \
  && apt-get install -y openssh-server supervisor rsyslog mysql-client \
       apache2 php5 php5-mysql php5-mcrypt php5-intl \
       php5-gd php5-json php5-curl php5-imagick libapache2-mod-php5 \
  && mkdir -p /var/run/sshd \
  && sed -i.bak -e "s/^PermitRootLogin\s*.*$/PermitRootLogin yes/" /etc/ssh/sshd_config
# RUN sed -i -e 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

COPY assets/supervisord.conf /etc/supervisor/supervisord.conf

RUN php5enmod mcrypt \
  && sed -i.bak -e "s/^;date\.timezone =.*$/date\.timezone = 'Asia\/Tokyo'/" /etc/php5/apache2/php.ini

WORKDIR /usr/local
RUN apt-get install -y pwgen \
  && apt-get clean \
  && wget http://sourceforge.net/projects/roundcubemail/files/roundcubemail/1.1.1/roundcubemail-1.1.1-complete.tar.gz \
  && tar xfz roundcubemail-1.1.1-complete.tar.gz \
  && mv /var/www/html /var/www/html.orig \
  && cp -r roundcubemail-1.1.1 /var/www/html \
  && chown -R root.root /var/www/html \
  && chown www-data.www-data /var/www/html/logs \
  && chown www-data.www-data /var/www/html/temp \
  && rm -rf /var/www/html/installer

COPY assets/config.inc.php /var/www/html/config/config.inc.php

WORKDIR /opt
COPY assets/cc-init.sh /opt/bin/cc-init.sh

EXPOSE 22 80

CMD /opt/bin/cc-init.sh; /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
