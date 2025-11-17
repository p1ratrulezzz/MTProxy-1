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
  git clone -b '0.0.7' https://github.com/p1ratrulezzz/MTProxy-1.git MTProxy
```

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

Edit options.txt file and set there desired values described below

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
... where:
- `nobody` is the username. `mtproto-proxy` calls `setuid()` to drop privileges.
- `443` is the port, used by clients to connect to the proxy.
- `8888` is the local port. You can use it to get statistics from `mtproto-proxy`. Like `wget localhost:8888/stats`. You can only get this stat via loopback.
- `<secret>` is the secret generated at step 3. Also you can set multiple secrets: `-S <secret1> -S <secret2>`.
- `proxy-secret` and `proxy-multi.conf` are obtained at steps 1 and 2.
- `1` is the number of workers. You can increase the number of workers, if you have a powerful server.

That's it. Now you can close the SSH connection to your VPS and keep using Telegram with your new server! The statistics of usage of the server are accessible via Telegram bot @MTProxybot

### Random padding to protect from banning

Add 'dd' prefix to any secret key you share with public. For example, my original secret is SECRET, so in url you share add 'dd' to it:

https://t.me/proxy...&secret=ddSECRET

And the secret will be 2 more characters long (34 chars). Note that this is not supported in older client versions.

### FakeTLS transport support

This enables the Telegram client traffic masking on client side by wrapping it into TLS traffic. The Telegram traffic will be nothing that a usual HTTPS traffic to your provider. It is recommended to set workers (-M 0) to zero to make it work better and to set port to 443 (-H 443).

As usual, create a 32 character secret

```bash
  export SECRET=$(head -c 16 /dev/urandom | xxd -ps)
  echo $SECRET
```
You will see your secret as "abcd......efd"

Now, choose a domain with TLS 1.3 support (it should have an HTTPS certificate and support TLS 1.3), or choose some public domain like yandex.ru

Now, encode this domain using

```bash
export DOMAIN=$(echo yandex.ru | tr -d '\n' | xxd -ps -c 200)
echo Use this secret in client: "ee${SECRET}${DOMAIN}"
```

And you will see:

```
Use this secret in client: "eeabcdef....efg"
```

And the secret will be quite long. 

Now, form the url to use it for connecting to your server using this long secret:

https://t.me/proxy...&secret=LONG_SECRET

For making the generation easier use this JS tool: https://github.p1ratrulezzz.me/MTProxy-1/mtpgen.html (mirror) or http://seriyps.ru/mtpgen.html

And run the MTProto proxy as following:

```bash
mtproto-proxy -S abcd......efd -H 443 -M 0 --domain yandex.ru 
```

Note: the --domain must be the same domain as you have encoded it above and included into your secret! Otherwise, it will not work.

Enabling FakeTLS will block old users with old method of conneciton.

### Share with friends

Generate the  link tg://proxy?server=SERVER_NAME&port=6968&secret=SECRET and https://t.me/proxy?server=SERVER_NAME&port=6968&secret=SECRET
