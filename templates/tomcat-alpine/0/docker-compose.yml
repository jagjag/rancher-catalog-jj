version: '2'
services:
    tc80jre8:
        image: jagjag/tomcat-alpine:tomcat80jre8
        labels:
            io.rancher.sidekicks: tc80jre8volume, tc80jre8app
            io.rancher.container.hostname_override: container_name
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
        environment:
            - "CATALINA_PID=/usr/local/tomcat/bin/CATALINA_PID"
            - "JAVA_OPTS=${java_opts}" # -server -Xms4096m -Xmx4096m -XX:NewSize=2048m -XX:MaxNewSize=2048m -XX:PermSize=256m -XX:MaxPermSize=512m -XX:+UseParallelOldGC -XX:ParallelGCThreads=4
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 102536
                hard: 102536
        mem_limit: ${mem_limit} #mem_limit = Xmx+MaxPermSize+MEMforos(cache&buffer) 4096+512+512=5G (5368709120)inbytes
        mem_swappiness: 0
        stdin_open: true
        tty: true
        volumes_from:
            - tc80jre8volume

    tc80jre8app:
        image: alpine:3.6
        stdin_open: true
        volumes_from:
            - tc80jre8volume
        links:
            - tc80jre8volume
        depends_on:
            - tc80jre8volume
        labels:
            io.rancher.container.start_once: 'true'
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
        entrypoint: "/usr/bin/wget ${war_file_url} -P /opt/apache-tomcat-8.0.50/webapps"
      
    tc80jre8volume:
        image: alpine:3.6
        labels:
            io.rancher.container.start_once: 'true'
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
        stdin_open: true
        volumes:
            - /etc/localtime:/etc/localtime:ro
            - tc80jre8logs1:/logs
            - tc80jre8apps:/opt/apache-tomcat-8.0.50/webapps

    tc80jr8lb:
        image: dir.staff.xdf.cn/rancher/lb-service-haproxy:v0.7.15
        ports:
            - ${lb_port}:${lb_port}/tcp
        labels:
            io.rancher.container.agent.role: environmentAdmin,agent
            io.rancher.container.agent_service.drain_provider: 'true'
            io.rancher.container.create_agent: 'true' 
            {{- if eq .Values.traefik_enable "true" }}
            traefik.frontend.rule: ${treafik_frontend_rule} #Host:app.xx.com
            traefik.enable: ${traefik_enable} #'true'
            traefik.default.protocol: ${treafik_default_protocal} #http
            traefik.port: ${lb_port} #'10800'
            traefik.path: ${traefik_path} # default /
            {{- end }}
        links:
            - tc80jre8:tc80jre8

volumes:
    tc80jre8logs1:
    tc80jre8apps:
        per_container: true