FROM ubuntu:latest
RUN apt update
RUN apt install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php
RUN apt update
RUN apt install nginx php7.4 php7.4-common php7.4-cli php-mail php7.4-fpm php7.4-gd php7.4-mysql php7.4-mbstring php7.4-curl php7.4-xml php7.4-zip php7.4-json php7.4-imagick php7.4-xmlrpc php7.4-bz2 php7.4-dev php7.4-opcache php5.6 php5.6-common php5.6-cli php5.6-fpm php5.6-gd php5.6-mysql php5.6-mbstring php5.6-curl php5.6-xml php5.6-zip php5.6-json php5.6-imagick sendmail php5.6-xmlrpc php5.6-bz2 php5.6-dev php5.6-opcache nano inetutils-tools net-tools mariadb-client -yy 
# Install supervisor
RUN apt-get install -qq -y supervisor
RUN mkdir -p /var/log/supervisor
ADD config/docker-entrypoint.sh / 
RUN rm -rf /etc/nginx/sites-enabled/default /etc/php/7.4/fpm/pool.d/www.conf /etc/php/5.6/fpm/pool.d/www.conf
ADD config/nginx/ogame.conf /etc/nginx/sites-enabled/
ADD config/php-fpm/ogame.conf /etc/php/7.4/fpm/pool.d/
ADD config/php-fpm/ogame-fpm.conf /etc/php/5.6/fpm/pool.d/
ADD config/lol /bin/
ADD config/supervisord/supervisord.conf /etc/supervisor/conf.d/
RUN ls -la /etc/php/7.4/fpm/pool.d/
ENV PHP_MEMORY_LIMIT=128Mb
ENV PHP_MAX_POST=128Mb
ENV MAX_UPLOAD=128Mb
ENV PHP_MAX_FILE_UPLOAD=128Mb

RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.4/fpm/php-fpm.conf \
    && sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/7.4/fpm/php.ini \
    && sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php/7.4/fpm/php.ini \
    && sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" /etc/php/7.4/fpm/php.ini \
    && sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" /etc/php/7.4/fpm/php.ini \
    && sed -i "s|post_max_size =.*|post_max_size = ${PHP_MAX_POST}|" /etc/php/7.4/fpm/php.ini \
    && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini \
    && sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/5.6/fpm/php-fpm.conf \
    && sed -i "s|;date.timezone =.*|date.timezone = ${TIMEZONE}|" /etc/php/5.6/fpm/php.ini \
    && sed -i "s|memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|" /etc/php/5.6/fpm/php.ini \
    && sed -i "s|upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|" /etc/php/5.6/fpm/php.ini \
    && sed -i "s|max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|" /etc/php/5.6/fpm/php.ini \
    && sed -i "s|post_max_size =.*|post_max_size = ${PHP_MAX_POST}|" /etc/php/5.6/fpm/php.ini \
    && sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini

RUN apt install -yy mc htop wget
RUN cd /opt && wget https://nodejs.org/dist/v14.15.1/node-v14.15.1-linux-x64.tar.xz && tar -xvf node-v14.15.1-linux-x64.tar.xz
RUN cp -R /opt/node-v14.15.1-linux-x64/bin/* /bin/ && \
    cp -R /opt/node-v14.15.1-linux-x64/lib/* /usr/lib/
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN mkdir /ogame
COPY src2/ /ogame/
RUN chown -R www-data:www-data /ogame
WORKDIR /ogame/
RUN cd /ogame/ && composer install --no-dev && composer install --dev && npm ci

# RUN cd /ogame/BattleEngine && gcc battle.c -lm -o battle
# RUN chown www-data:www-data /ogame/BattleEngine/battle
ENTRYPOINT [ "/docker-entrypoint.sh" ]

