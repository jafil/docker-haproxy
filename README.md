# Docker image containing HAProxy

Basic Docker image to run haproxy on host

You need edit (add) this env:
- **LISTENPORT**: 80
- **MODE**: tcp
- **BACKEND_1**: "192.168.1.10:1080 192.168.1.11:1080" 
- **BACKEND_2**: "192.168.1.10:1080 192.168.1.11:1080" 

Usage: 
```
docker run -e LISTENPORT=80 -e MODE=tcp -e BACKEND_1="192.168.1.10:1080" -e BACKEND_2="192.168.1.11:1080" --name haproxy -d oberthur/docker-haproxy
```
