FROM debian:buster

RUN apt-get update && apt-get install -y wget curl apt-transport-https apache2 unzip gnupg2 php php-common \
php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd  php-mbstring php-curl php-xml php-pear php-bcmath libapache2-mod-php tzdata \
&&  ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime \
&& service apache2 stop

RUN sed -i 's/AllowOverride None/AllowOverride All\nSetEnvIf X-Forwarded-Proto https HTTPS=on/g' /etc/apache2/apache2.conf \
&& sed -i 's/max_execution_time\\s*=.*/max_execution_time=180/g' /etc/php/7*/apache2/php.ini \
&& sed -i 's/upload_max_filesize\\s*=.*/upload_max_filesize=16M/g' /etc/php/7*/apache2/php.ini \
&& sed -i 's/memory_limit\\s*=.*/memory_limit=256M/g' /etc/php/7*/apache2/php.ini \
&& sed -i 's/post_max_size\\s*=.*/post_max_size=20M/g' /etc/php/7*/apache2/php.ini


# add dotdeb to apt sources list
# RUN echo 'deb http://packages.dotdeb.org buster all' > /etc/apt/sources.list.d/dotdeb.list

## add dotdeb key for apt
# RUN curl http://www.dotdeb.org/dotdeb.gpg | apt-key add -

# RUN apt-get update

#RUN apt-get install -y php7.0 php7.0-curl php7.0-gd php7.0-mbstring php7.0-imagick php7.0-mysql php7.0-xdebug php7.0-simplexml php7.0-zip php7.0-apcu php7.0-apcu-bc php7.0-sqlite3 

#set timezone
# RUN apt-get -y install tzdata && ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime

#configure apache
# RUN ["bin/bash", "-c", "sed -i 's/AllowOverride None/AllowOverride All\\nSetEnvIf X-Forwarded-Proto https HTTPS=on/g' /etc/apache2/apache2.conf"]

# RUN service apache2 stop

#configure php
# RUN ["bin/bash", "-c", "sed -i 's/max_execution_time\\s*=.*/max_execution_time=180/g' /etc/php/7*/apache2/php.ini"]
# RUN ["bin/bash", "-c", "sed -i 's/upload_max_filesize\\s*=.*/upload_max_filesize=16M/g' /etc/php/7*/apache2/php.ini"]
# RUN ["bin/bash", "-c", "sed -i 's/memory_limit\\s*=.*/memory_limit=256M/g' /etc/php/7*/apache2/php.ini"]
# RUN ["bin/bash", "-c", "sed -i 's/post_max_size\\s*=.*/post_max_size=20M/g' /etc/php/7*/apache2/php.ini"]

#configure XDebug
RUN ["bin/bash", "-c", "echo [XDebug] >> /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "echo xdebug.remote_enable=1 >> /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "echo xdebug.remote_connect_back=1 >> /etc/php/7*/apache2/php.ini"]
RUN ["bin/bash", "-c", "echo xdebug.idekey=netbeans-xdebug >> /etc/php/7*/apache2/php.ini"]

#install ioncube
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz
RUN tar xvfz ioncube_loaders_lin_x86-64.tar.gz
RUN ["bin/bash", "-c", "cp ioncube/*.so /usr/lib/php/2*/"]
RUN ["bin/bash", "-c", "cd /etc/php/7*/apache2/conf.d && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.3.so > 00-ioncube.ini"]
RUN ["bin/bash", "-c", "cd /etc/php/7*/fpm && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.3.so >> php.ini"]
RUN ["bin/bash", "-c", "cd /etc/php/7*/cli && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.3.so >> php.ini"]


# Configure apache
RUN a2enmod php7.3 && a2enmod rewrite && a2enmod ssl && a2enmod proxy && a2enmod headers \
&& a2ensite default-ssl \
&& chown -R www-data:www-data /var/www \
&& php -v

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
#RUN service apache2 restart

EXPOSE 80
EXPOSE 443

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
