FROM ubuntu:14.04
MAINTAINER simota@me.com

ENV DEBIAN_FRONTEND noninteractive
RUN locale-gen en_US.UTF-8 && update-locale LANG=en_US.UTF-8
ENV LC_ALL C
ENV LC_ALL en_US.UTF-8

RUN dpkg-divert --local --rename --add /sbin/initctl && rm -f /sbin/initctl && ln -s /bin/true /sbin/initctl

RUN apt-get -y update && \
  apt-get -y upgrade && \
  apt-get -y install curl supervisor openssh-server \
  build-essential autoconf libssl-dev curl \
  libcurl4-gnutls-dev zlib1g zlib1g-dev libxml2 \
  libxml2-dev libxslt-dev libreadline6-dev \
  redis-server lua5.1 liblua5.1-0 liblua5.1-0-dev lua-svn && \
  apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN ln -s /usr/lib/x86_64-linux-gnu/liblua5.1.so /usr/lib/liblua.so

RUN mkdir -p /tmp/src && cd /tmp/src && \
  wget -O "nginx-1.7.4.tar.gz" "http://nginx.org/download/nginx-1.7.4.tar.gz" && \
  wget -O "pcre-8.35.tar.gz" "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.35.tar.gz" && \
  wget -O "zlib-1.2.8.tar.gz" "http://zlib.net/zlib-1.2.8.tar.gz" && \
  wget -O "openssl-1.0.1i.tar.gz" "http://www.openssl.org/source/openssl-1.0.1i.tar.gz" && \
  wget -O "nginx_devkit.tar.gz" "https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz" && \
  wget -O "nginx_lua.tar.gz" "https://github.com/openresty/lua-nginx-module/archive/v0.9.11.tar.gz"

RUN cd /tmp/src && \
  tar zxf nginx-1.7.4.tar.gz && \
  tar zxf pcre-8.35.tar.gz && \
  tar zxf zlib-1.2.8.tar.gz && \
  tar zxf openssl-1.0.1i.tar.gz && \
  tar zxf nginx_devkit.tar.gz && \
  tar zxf nginx_lua.tar.gz

RUN cd /tmp/src/nginx-1.7.4 && export LUA_LIB=/usr/lib && export LUA_INC=/usr/include/lua5.1 && \
  ./configure --prefix=/usr/local/nginx \
            --with-http_gzip_static_module \
            --with-http_ssl_module \
            --with-http_stub_status_module \
            --with-zlib=../zlib-1.2.8 \
            --with-pcre=../pcre-8.35 \
            --with-openssl=../openssl-1.0.1i \
            --add-module=../ngx_devel_kit-0.2.19 \
            --add-module=../lua-nginx-module-0.9.11 && \
  make && make install

RUN rm -rf /tmp/src

RUN mkdir -p /usr/local/lib/lua/5.1 && \
  cd /usr/local/lib/lua/5.1 && \
  wget https://raw.github.com/nrk/redis-lua/version-2.0/src/redis.lua

RUN cd /usr/local/nginx/conf && mv nginx.conf nginx.conf.org

ADD nginx.conf /usr/local/nginx/conf/nginx.conf

RUN mkdir -p /var/log/supervisor
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80 6379

CMD ["/usr/bin/supervisord"]
