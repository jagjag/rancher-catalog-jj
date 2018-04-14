Tomcat alpine and traefik 
=====================

What's inside?
--------------

* tomcat:
[Tomcat image](https://hub.docker.com/r/jagjag/alpine-tomcat/)
tomcat image base on [anapsix/docker-alpine-java](https://github.com/anapsix/docker-alpine-java) and [davidcaste/docker-alpine-tomcat](https://github.com/davidcaste/docker-alpine-tomcat)
oracle jre with unlimited JCE
standard ouput was turned off , all logs output to /logs

* App(warball) download:
there wil be a sidekick container to download a warball from specifed URL when you start this app.

* traefik labels:
traefik labels will be add to a rancher lb. and rancher lb is a proxy of tomcat instance.
So. there will be only one port to expose to the host.

1. traefik_rontend_rule: traefik.frontend.rule = Host:MyCustoDomain.com
2. traefik http/https
3. traefik port: point to rancher lb port 
