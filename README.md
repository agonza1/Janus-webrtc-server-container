# Janus-webrtc-server-container
A generic Janus WebRTC Media Server Docker container

## Build the image 

`docker build -t janus-server .`

## Running & Config with docker

There are several things you can configure, either in a configuration file:

	<installdir>/etc/janus/janus.jcfg

*Note: If you choose this approach you will need to update the docker-compose to use the config directory as a volume*

Or passing the variables when starting Janus. For example: 

* add `-n` followed by the debug level from 1-7 (7=maximum)

* add `-S stun_srv_addr` at the end of your docker run command to let janus discover its own public ip through stun

* add `-d` followed by the server name you want to use

* add `-e` if you want to enable event handlers

## Running & Config with docker docker-compose

`docker-compose up`

## Validate it is running

You can validate it is running and see the server info by going to http://localhost:8088/janus/info