# Docker image containing HAProxy

Basic Docker image to run haproxy on host

You need edit (add) this env:
- **LISTENPORT**: 80
- **MODE**: tcp
- **BACKENDS**: "192.168.1.10:1080 192.168.1.11:1080" 

Usage: 
docker run --rm -e LISTENPORT=80 -e MODE=tcp -e BACKENDS="192.168.1.10:1080 192.168.1.11:1080" --name haproxy -d oberthur/docker-haproxy
