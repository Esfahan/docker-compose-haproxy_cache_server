# docker-compose-haproxy_cache_server
This is a loadbalancer and a cache server(Reverse Proxy) with HAProxy and KeepAlived and Nginx on docker-compose.  
HAProxy uses port 80, Nginx uses port 8080.

## Requirements
- CentOS 7.x
- docker
- docker-compose 

## Structure
This docker-compose is for lb01, 02.  
You need to make the web-servers yourself.

                             VIP
    ------------------------------------------------------- 
    +------- lb01 -------+           +------- lb02 -------+
    | +- container_1 -+  |           | +- container_1 -+  |
    | | HAProxy       |  |           | | HAProxy       |  |
    | | KeepAlive     |  |           | | KeepAlive     |  |
    | +---------------+  |           | +---------------+  |
    |         |          |           |         |          |
    | +- container_2 -+  |           | +- container_2 -+  |
    | | Nginx         |  |           | | Nginx         |  |
    | | (ReverseProxy)|  |           | | (ReverseProxy)|  |
    | +---------------+  |           | +---------------+  |
    +--------------------+           +--------------------+
              |                                 |
              |                                 |
    +--- web-server_1 ---+           +--- web-server_2 ---+
    |   your web server  |           |   your web server  |
    +--------------------+           +--------------------+


## Settings
Modify your hosts to each confs below.

### Nginx
Write your web servers.

- rproxy/conf/rproxy.conf

```
upstream web {
    least_conn;
    server {{YOUR_WEB_SERVER_1}} weight=5 max_fails=3 fail_timeout=10s;
    server {{YOUR_WEB_SERVER_2}} weight=5 max_fails=3 fail_timeout=10s;
}
```

### HAProxy
Write ip-addresses of your nginx servers as the reverse proxies.

- haproxy/files/haproxy/haproxy.cfg

```
backend app
    balance     roundrobin
    server  app1 {{YOUR_NGINX_IPADDR_1}}:8080 check
    server  app2 {{YOUR_NGINX_IPADDR_2}}:8080 check
```

### KeepAlived
Write your virtual ip-addresses.

- haproxy/files/keepalived/lb01/keepalived.conf
- haproxy/files/keepalived/lb02/keepalived.conf

```
    virtual_ipaddress {
        {{YOUR_VIP}}
    }
```

### haproxy container
When you create a master server(lb01), modify docker-compose.yml like below.


```yaml
version: '3'
services:
    rproxy:
        build: ./rproxy
        hostname: rproxy_app
        network_mode: "host"

    # It's for master
    haproxy:
        build:
          context: ./haproxy
          dockerfile: Dockerfile_lb01
        hostname: haproxy_app
        network_mode: "host"

    # It's for slave
    #haproxy:
    #    build:
    #      context: ./haproxy
    #      dockerfile: Dockerfile_lb02
    #    hostname: haproxy_app
    #    network_mode: "host"
```

For a slave server(lb02), modify it like below.

```yaml
version: '3'
services:
    rproxy:
        build: ./rproxy
        hostname: rproxy_app
        network_mode: "host"

    # It's for master
    #haproxy:
    #    build:
    #      context: ./haproxy
    #      dockerfile: Dockerfile_lb01
    #    hostname: haproxy_app
    #    network_mode: "host"

    # It's for slave
    haproxy:
        build:
          context: ./haproxy
          dockerfile: Dockerfile_lb02
        hostname: haproxy_app
        network_mode: "host"
```

## Usage
Run the command below on lb01, lb02 with [modifing docker-compose.yml](#haproxy-container) like above.

```
$ sudo docker-compose up -d --build
```

Down

```
$ sudo docker-compose down -v
```
