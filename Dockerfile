FROM debian:10.6

### Build tools ###
RUN apt-get -y update && \
	apt-get install -y \
		gengetopt \
		pkg-config \
		automake \
		libtool \
		cmake \
		build-essential \
		gtk-doc-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

### Utils ###
RUN apt-get update && apt-get install -y \
	vim \
	curl \
	psmisc \
	nano \
	git \
	wget \
	unzip \
	python \
	libconfig-dev

### Janus ###
RUN apt-get -y update && apt-get install -y \
	libmicrohttpd-dev \
	libjansson-dev \
	libsofia-sip-ua-dev \
	libglib2.0-dev \
	libssl-dev \
	libopus-dev \
	libogg-dev \
	libcurl4-openssl-dev \
	liblua5.3-dev \
    libusrsctp-dev \
    libwebsockets-dev \
    libnanomsg-dev \
    librabbitmq-dev && \
    apt-get clean

# libnice build
RUN cd /root && \
	git clone https://gitlab.freedesktop.org/libnice/libnice && \
	cd libnice && \
	git checkout 0.1.17 && \
	./autogen.sh && \
	./configure --prefix=/usr && \
	make && \
	make install

# srtp build
RUN cd /root && \
	wget https://github.com/cisco/libsrtp/archive/v2.3.0.tar.gz && \
	tar xfv v2.3.0.tar.gz && \
	cd libsrtp-2.3.0 && \
	./configure --prefix=/usr --enable-openssl && \
	make shared_library && \
	make install

# Datachannel build
RUN cd /root && \
    git clone https://github.com/sctplab/usrsctp && \
    cd usrsctp && \
    ./bootstrap && \
    ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6 && \
    make && make install

RUN cd /root && git clone git://git.libwebsockets.org/libwebsockets && \
	cd libwebsockets && \
	git checkout v3.2-stable && \
	mkdir build && \
	cd build && \
	cmake -DLWS_MAX_SMP=1 -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_C_FLAGS="-fpic" .. && \
	make && \
	make install

# Clone and install janus-gateway
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && \
	./autogen.sh && \
	./configure --prefix=/opt/janus \
			--disable-docs \
    		--disable-rabbitmq \
    		--disable-mqtt \
    		--disable-unix-sockets && \
	make && \
	make install && \
	make configs

#RUN sed -i "s/admin_http = no/admin_http = yes/g" /opt/janus/etc/janus/janus.transport.http.jcfg
#RUN sed -i "s/https = no/https = yes/g" /opt/janus/etc/janus/janus.transport.http.jcfg
#RUN sed -i "s/;secure_port = 8089/secure_port = 8089/g" /opt/janus/etc/janus/janus.transport.http.jcfg
#RUN sed -i "s/wss = no/wss = yes/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
#RUN sed -i "s/;wss_port = 8989/wss_port = 8989/g" /opt/janus/etc/janus/janus.transport.websockets.jcfg
#RUN sed -i "s/;rtp_port_range = 20000-40000/rtp_port_range = 10000-10300/g" /opt/janus/etc/janus/janus.jcfg

### Cleaning ###
RUN apt-get clean && apt-get autoclean && apt-get autoremove

EXPOSE 8188
EXPOSE 8088
EXPOSE 8089
EXPOSE 8889
EXPOSE 8000
EXPOSE 7088
EXPOSE 7089
EXPOSE 10000-10300/udp

ENTRYPOINT ["/opt/janus/bin/janus"]
