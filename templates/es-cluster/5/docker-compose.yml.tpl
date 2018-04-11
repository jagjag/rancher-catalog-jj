version: '2'
services:
    es-master:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-sysctl{{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch-platinum:6.2.3
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=true"
            - "ELASTIC_PASSWORD=${elastic_password}"
            - "ES_JAVA_OPTS=-Xms${master_heap_size} -Xmx${master_heap_size}"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "discovery.zen.minimum_master_nodes=${minimum_master_nodes}"
            - "node.master=true"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${master_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-storage

    es-data:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-sysctl{{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch-platinum:6.2.3
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=true"
            - "ELASTIC_PASSWORD=${elastic_password}"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${data_heap_size} -Xmx${data_heap_size}"
            - "node.master=false"
            - "node.data=true"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${data_mem_limit}
        mem_swappiness: 0
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-storage
        depends_on:
            - es-master

    es-client:
        labels:
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
            io.rancher.sidekicks: es-storage{{- if eq .Values.UPDATE_SYSCTL "true" -}},es-sysctl{{- end}}
        image: docker.elastic.co/elasticsearch/elasticsearch-platinum:6.2.3
        environment:
            - "cluster.name=${cluster_name}"
            - "node.name=$${HOSTNAME}"
            - "bootstrap.memory_lock=true"
            - "xpack.security.enabled=true"
            - "ELASTIC_PASSWORD=${elastic_password}"
            - "discovery.zen.ping.unicast.hosts=es-master"
            - "ES_JAVA_OPTS=-Xms${client_heap_size} -Xmx${client_heap_size}"
            - "node.master=false"
            - "node.data=false"
        ulimits:
            memlock:
                soft: -1
                hard: -1
            nofile:
                soft: 65536
                hard: 65536
        mem_limit: ${client_mem_limit}
        mem_swappiness: 0
        ports:
            - ${es_port}:9200
        cap_add:
            - IPC_LOCK
        volumes_from:
            - es-storage
        depends_on:
            - es-master

    es-storage:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-volume:0.0.2-1
        environment:
            - SERVICE_UID=1000
            - SERVICE_GID=1000
            - SERVICE_VOLUME=/usr/share/elasticsearch/data
        volumes:
            - es-storage-volume:/usr/share/elasticsearch/data

    {{- if eq .Values.UPDATE_SYSCTL "true" }}
    es-sysctl:
        labels:
            io.rancher.container.start_once: true
        network_mode: none
        image: rawmind/alpine-sysctl:0.1
        privileged: true
        environment:
            - "SYSCTL_KEY=vm.max_map_count"
            - "SYSCTL_VALUE=262144"
    {{- end}}

    es-kibana:
        labels:
            io.rancher.container.pull_image: always
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.container.hostname_override: container_name
        image: docker.elastic.co/kibana/kibana-x-pack:6.2.3
        environment:
            ELASTICSEARCH_URL: http://es-client:9200
            ELASTICSEARCH_USERNAME: elastic
            ELASTICSEARCH_PASSWORD: ${elastic_password}
        mem_limit: ${kibana_mem_limit}
        stdin_open: true
        tty: true
    
volumes:
  es-storage-volume:
    driver: ${VOLUME_DRIVER}
    per_container: true

