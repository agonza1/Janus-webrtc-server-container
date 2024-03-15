FROM debian:12.5

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
	python-is-python3 \
	meson \
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
meson --prefix=/usr build && ninja -C build && ninja -C build install

# srtp build
RUN cd /root && \
	wget https://github.com/cisco/libsrtp/archive/v2.6.0.tar.gz && \
	tar xfv v2.6.0.tar.gz && \
	cd libsrtp-2.6.0 && \
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

# Clone and install janus-gateway
RUN cd /root && git clone https://github.com/meetecho/janus-gateway.git
RUN cd /root/janus-gateway && \
	./autogen.sh && \
	./configure --prefix=/opt/janus \
	--disable-docs \
	--disable-rabbitmq \
	--disable-mqtt \
	--disable-nanomsg \
	--disable-unix-sockets && \
	make && \
	make install && \
	make configs

### Cleaning ###
RUN apt-get clean && apt-get autoclean && rm -rf /var/lib/apt/lists/* && apt-get autoremove

EXPOSE 8188
EXPOSE 8088
EXPOSE 8089
EXPOSE 8889
EXPOSE 8000
EXPOSE 7088
EXPOSE 7089
EXPOSE 10000-10300/udp

ENTRYPOINT ["/opt/janus/bin/janus"]
