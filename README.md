# Janus-webrtc-server-container
A generic Janus WebRTC Media Server Docker container

## Build the image 

`docker build -t janus-server .`

## Running & Config with docker

There are several things you can configure, either in a configuration file:

	<installdir>/etc/janus/janus.jcfg

*Note: If you choose this approach you will need to update the docker-compose to use the config directory as a volume*

Or passing the variables when starting Janus. For example: 

* add `-S stun_srv_addr at` the end of your docker run command to let janus discover its own public ip through stun

* add `-e` if you want to enable event handlers

## Running & Config with docker docker-compose

`docker-compose up`
