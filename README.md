# Telegram MTProto Proxy (Official version fork)

[![Build Status](https://travis-ci.org/p1ratrulezzz/MTProxy-1.svg?branch=master)](https://travis-ci.org/p1ratrulezzz/MTProxy-1)

## Credits

Check the original repo https://github.com/TelegramMessenger/MTProxy and it is preferred to use it than this one as this repo won't be much maintained.
But, of course, information from this fork can be useful too.

## Disclaimer

Please, in case of any issues while build or etc, create an issue on original [repo page](https://github.com/TelegramMessenger/MTProxy)! 

## Building, installation and setting a promoted channel

## Docker

A tutorial for docker is available here https://p1ratrulezzz.me/2018/06/creating-your-own-official-mtproto-proxy-with-channel-promotion-very-easy-way.html and on the official repo https://hub.docker.com/r/telegrammessenger/proxy/


## Building and installation manually


### Installing dependencies, cloning

```bash
  apt-get install libssl-dev zlib1g-dev build-essential
  cd /opt
  git clone -b '0.0.3' https://github.com/p1ratrulezzz/MTProxy-1.git MTProxy
```

Note: I recommend to use v0.0.3 because in v0.0.4 advertising doesn't work apparently...

### Building

```bash
  cd /opt/MTProxy
  make
  curl -s https://core.telegram.org/getProxySecret -o proxy-secret
  curl -s https://core.telegram.org/getProxyConfig -o proxy-multi.conf
  ln -s /opt/MTProxy/objs/bin/mtproto-proxy /usr/bin/mtproto-proxy
  cp resources/init.d.script.sh /etc/init.d/mtproto-proxy
  chmod +x /etc/init.d/mtproto-proxy
  cp resources/options.template.txt ./options.txt
  systemctl daemon-reload
```

### Configuration

How to generate secrets?

```bash
  head -c 16 /dev/urandom | xxd -ps
```

```
-P <proxy tag> -- (optional) Obtain a proxy tag from telegram bot @MTProxybot if you want to attach any channel as a "Proxy sponsor channel"
-u nobody -- nobody is the user name. mtproto-proxy calls setuid() to drop privilegies
-p 8888 -- is the local port. You can use it to get statistics from mtproto. Like wget localhost:8888/stats
-H 6968,6669 -- on which PORTS to listen for connections (You can set multiple ports using comma to split [see more](https://github.com/TelegramMessenger/MTProxy/issues/84#issuecomment-401022826))
-S <secret> -- secret, any 32byte string (md5hash). Generate it using _head -c 16 /dev/urandom | xxd -ps_
-S <secret2> -- another secret. Optionally, you can setup several passwords (secrets) per one server,
-S <secret3> -- just pass as many -S flags as you want
-M 0 -- quantity of workers (slave processes). Zero means only one process.
--address <public_ip_here> -- set IP address got from ifconfig OR set to 0.0.0.0 which means to listen to all interfaces
--cpu-threads 2 -- threads per process. The value 2 is recommended.
--max-accept-rate 10 -- how many requests per second will be accepted. For powerful servers its possible to set 1000. For minimum users set to 10
-C 60000 -- Max connections to serve. This value was taken from docker config.
```

### Run the server for testing

```bash
  mtproto-proxy $(cat options.txt)
```

If there are no errors and Telegram client can connect, close it using Ctrl+C then run as a daemon

```bash
  service mtproto-proxy start
  service mtproto-proxy status
```

And there should be a process and Active daemon running. Check again if you can connect using Telegram client and enable the service to autorun on every reboot

```bash
  systemctl enable mtproto-proxy
```