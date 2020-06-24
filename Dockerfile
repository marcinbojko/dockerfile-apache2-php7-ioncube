FROM debian:buster as build
LABEL VERSION="v0.1.0"
LABEL RELEASE="apache-ioncube"
LABEL MAINTAINER="marcinbojko"
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]
COPY /script.sh /tmp/script.sh

RUN apt update && apt install -y wget curl apt-transport-https apache2 unzip gnupg2 php php-common \
php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath libapache2-mod-php libapache2-mod-security2 tzdata \
&& apt upgrade -y \
&& ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime \
&& apt clean all \
&& rm -rf /var/lib/apt/lists/*||true \
&& service apache2 stop \
&& bash /tmp/script.sh \
&& rm -rfv /tmp/* \
&& rm -rfv /var/cache/*

EXPOSE 80
EXPOSE 443

HEALTHCHECK --interval=15s --timeout=5s CMD curl --fail http://localhost||exit 1
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
