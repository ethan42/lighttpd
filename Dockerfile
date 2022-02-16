FROM debian:10-slim as builder
RUN apt-get update && apt-get install -y build-essential wget libc6-dbg
WORKDIR /build
RUN wget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.52.tar.gz \
   && tar xf lighttpd-1.4.52.tar.gz \
   && cd /build/lighttpd-1.4.52 \
   && CFLAGS=-g ./configure --without-bzip2 --without-pcre --without-zlib && CFLAGS=-g make && make install \
   && mkdir /www && echo "lighttpd 1.4.52 running!" > /www/index.html
COPY lighttpd.conf /usr/local/etc
WORKDIR /
COPY mayhem/corpus /corpus
CMD ["/usr/local/sbin/lighttpd","-D", "-f","/usr/local/etc/lighttpd.conf"]
EXPOSE 80

FROM debian:10-slim
RUN apt-get update && apt-get install -y  --no-install-recommends libc6-dbg
# Don't set workdir! corpus is relative to /
COPY mayhem/corpus /corpus
COPY --from=builder /usr/local /usr/local
RUN mkdir /www && echo "lighttpd 1.4.52 running!" > /www/index.html
CMD ["/usr/local/sbin/lighttpd","-D", "-f","/usr/local/etc/lighttpd.conf"]
EXPOSE 80
