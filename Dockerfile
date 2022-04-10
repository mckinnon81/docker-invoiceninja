FROM wyveo/nginx-php-fpm:php74
MAINTAINER Matthew McKinnon <support@comprofix.com>


ARG INVOICEINNJA_RELEASE
ENV DEBIAN_FRONTEND noninteractive

RUN echo "**** install packages ****" && \
    apt-get update && \
    apt-get upgrade --yes && \
    apt-get install unzip curl vim --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    if [ -z ${INVOICEINNJA_RELEASE+x} ]; then \
      INVOICEINNJA_RELEASE=$(curl -sX GET "https://api.github.com/repos/invoiceninja/invoiceninja/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    curl -o \
      /tmp/invoiceninja.zip -L \
      "https://github.com/invoiceninja/invoiceninja/releases/download/${INVOICEINNJA_RELEASE}/invoiceninja.zip" && \
    mkdir -p /var/www/html/ && \
    unzip -q -o /tmp/invoiceninja.zip -d /var/www/html && \
    chown -R nginx:nginx /var/www/html && \
    chmod -R g+s /var/www/html && \
    chmod -R 775 /var/www/html/storage && \
    rm /tmp/invoiceninja.zip

COPY root/ /

WORKDIR /var/www/html
RUN composer install

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/start.sh"]
