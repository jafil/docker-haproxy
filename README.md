# docker-haproxy
Simple TCP Proxy 
Usage: 
docker run --net=host --privileged=true -e LISTENPORT=80 -e SERVER=192.13.39.209 -e SERVERPORT=80 --name haproxy -d dockerproxy
