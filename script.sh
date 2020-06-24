#!/bin/bash
set -euxo pipefail

sed -i 's/AllowOverride None/AllowOverride All\nSetEnvIf X-Forwarded-Proto https HTTPS=on/g' /etc/apache2/apache2.conf \
&& sed -i -e 's/ServerSignature On/ServerSignature Off/g' -e '$aServerSignature Off' /etc/apache2/apache2.conf \
&& sed -i 's/max_execution_time\\s*=.*/max_execution_time=180/g' /etc/php/7*/apache2/php.ini \
&& sed -i 's/upload_max_filesize\\s*=.*/upload_max_filesize=16M/g' /etc/php/7*/apache2/php.ini \
&& sed -i 's/memory_limit\\s*=.*/memory_limit=256M/g' /etc/php/7*/apache2/php.ini \
&& sed -i 's/post_max_size\\s*=.*/post_max_size=20M/g' /etc/php/7*/apache2/php.ini


{
  echo [XDebug]
  echo xdebug.remote_enable=1
  echo xdebug.remote_connect_back=1
  echo xdebug.idekey=netbeans-xdebug
} >> /etc/php/7*/apache2/php.ini

wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && tar xvfz ioncube_loaders_lin_x86-64.tar.gz && rm -rfv ioncube_loaders_lin_x86-64.tar.gz
cp ioncube/*.so /usr/lib/php/2*/
cd /etc/php/7*/apache2/conf.d && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.3.so > 00-ioncube.ini
cd /etc/php/7*/fpm && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.3.so >> php.ini
cd /etc/php/7*/cli && echo zend_extension = /usr/lib/php/2*/ioncube_loader_lin_7.3.so >> php.ini

a2enmod php7.3 && a2enmod rewrite && a2enmod ssl && a2enmod proxy && a2enmod headers && a2enmod proxy_fcgi setenvif && a2enconf php7.3-fpm && a2enmod security2 \
&& a2ensite default-ssl \
&& chown -R www-data:www-data /var/www \
&& php -v

