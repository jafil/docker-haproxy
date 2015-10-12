# docker-haproxy-mutual-auth
Basic Docker image to run haproxy as client to connect the server with mutual auth

You need edit (add) this env:
- **LISTENPORT**: 80 or other port value
- **MODE**: mode tcp or http
- **DEFAULT**: define default backend

- **HEADERNAME**: header name used to find proper backend ```hdr_dom(${HEADERNAME}) -i ${BACKEND}```
- **BACKEND_1_HEADERVALUE**: backend name should be also equals to header value
- **BACKEND_1_ADDRESS**: backend address
- **BACKEND_1_PORT**: backend port
- **BACKEND_1_CERTIFICATE**: backend certificate file name (optional)
- **LOGGING**: enabled if we want to enable rsyslog logging (optional)

You also need to mount folder with client certificates to /usr/local/etc/haproxy/certs/

Usage: 
```
docker run --name client-way-ssl -d -v /path/to/certs/:/usr/local/etc/haproxy/certs/ -e LISTENPORT=80 -e HEADERNAME=X-SERVER_ID -e BACKEND_1_HEADERVALUE=server -e BACKEND_1_ADDRESS=my-server.com -e BACKEND_1_PORT=443 -e BACKEND_1_CERTIFICATE=my-server.crt oberthur/docker-haproxy-mutual-auth
```
