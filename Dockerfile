FROM debian:jessie
MAINTAINER Jahroots "Jahroots@gmail.com"

RUN apt-get update
RUN apt-get install -y apache2 libapache2-mod-php5 php5-gd php5-cli php5-sqlite php5-json git curl supervisor

RUN a2enmod rewrite expires
RUN service apache2 restart
RUN cd /var/www/html && \ 
	git clone git://github.com/Jalle19/xbmc-video-server.git && \
	cd xbmc-video-server && \
	curl -sS https://getcomposer.org/installer | php && \
	php composer.phar install && \
	./src/protected/yiic createinitialdatabase && \
	./src/protected/yiic setpermissions

RUN mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD 000-default.conf /etc/apache2/sites-available/000-default.conf

### Clean
RUN apt-get -y autoclean
RUN apt-get -y clean
RUN apt-get -y autoremove

EXPOSE 80
CMD ["/usr/bin/supervisord", "-n"]