---
title: On-demand Service Broker Documentation
owner: London Services Enablement
---

# Setting up a local environment

This guide describes how to create and manage an on-demand service broker using PCF Dev and BOSH lite, which are tools that allow you run bosh and Cloud Foundry in VMs on your local development machine. For this tutorial we will be using the [kafka-service-adapter](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter) and the a test [kafka service release](https://github.com/pivotal-cf-experimental/kafka-example-service-release)

## Prerequisites

- [PCF Dev](https://docs.pivotal.io/pcf-dev/#installing)
- [BOSH lite](https://github.com/cloudfoundry/bosh-lite#install-bosh-lite)

> _NB: In order for PCFDev to route requests to the deployments on BOSH lite ensure you run the script `bin/add-route` in the BOSH lite repository. You may need to run this again if your networking is reset (e.g. reboot, or connecting to a different network)._

## Steps

1. Ensure you are targeting your BOSH lite, that was just provisioned.

    ```
    bosh target
    Current target is https://192.168.50.4:25555 (Bosh Lite Director)
    ```

1. Upload the [BOSH lite stemcell](http://bosh.cloudfoundry.org/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent)

    ```
    bosh upload stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3147
    ```

1. Clone the [kafka service release](https://github.com/pivotal-cf-experimental/kafka-example-service-release) in your workspace.

    ```
    git clone https://github.com/pivotal-cf-experimental/kafka-example-service-release.git
    ```
1. Create and Upload the kafka service release on the director

    ```
    cd kafka-example-service-release
    bosh create release --name kafka-example-service
    bosh upload release
    ```
1. Clone the [kafka service adapter release](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release) and run `git submodule update --init` to bring in the adapter's dependencies

    ```
    git clone https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release.git
    cd kafka-example-service-adapter-release
    git submodule update --init --recursive
    ```

1. Create and Upload the kafka example service adapter release on the director

    ```
    bosh create release --name kafka-example-service-adapter
    bosh upload release
    ```

1. Clone the [on demand service broker release](https://github.com/pivotal-cf/on-demand-service-broker-release)

    ```
    git clone https://github.com/pivotal-cf/on-demand-service-broker-release.git
    cd on-demand-service-broker-release
    git submodule update --init --recursive
    ```

1. Create and upload the [on demand service broker release](https://github.com/pivotal-cf/on-demand-service-broker-release)

    ```
    bosh create release --name on-demand-service-broker
    bosh upload release
    ```

1. Create a new directory in your workspace and a `cloud_config.yml` for the bosh lite director.

    For example:

    ```yaml
    ---
    azs:
    - name: z1

    vm_types:
    - name: container
      cloud_properties: {}

    networks:
    - name: kafka
      type: manual
      subnets:
      - range: 10.244.1.0/24
        gateway: 10.244.1.1
        az: lite
        cloud_properties: {}
        az: z1

    disk_types:
    - name: ten
      disk_size: 10_000
      cloud_properties: {}

    azs:
    - name: lite
      cloud_properties: {}

    compilation:
      workers: 2
      reuse_compilation_vms: true
      network: kafka
      az: lite
      cloud_properties: {}
    ```

1. Update the bosh lite cloud config.

    ```
    bosh update cloud-config cloud_config.yml
    ```

1. Get BOSH lite director information

    ```
    bosh status
    ```

    Will result in a output like:

    ```
    → bosh status
    Config
                 /Users/pivotal/.bosh_config

    Director
      Name       Bosh Lite Director
      URL        https://192.168.50.4:25555
      Version    1.3215.0 (00000000)
      User       admin
      UUID       17a45148-1d00-43bc-af28-9882e5a6535a
      CPI        warden_cpi
      dns        disabled
      compiled_package_cache enabled (provider: local)
      snapshots  disabled
    ```
    Note the director URL and director UUID as they will be used in the next step.

1. Create a bosh lite manifest for the deployment.

    Please replace `REPLACE_WITH_BOSH_LITE_UUID` and `REPLACE_WITH_BOSH_LITE_IP` with information obtained from the previous step, and create a file called `deployment_manifest.yml`

    ```yaml
    ---
    name: kafka-on-demand-broker

    director_uuid: <REPLACE_WITH_BOSH_LITE_UUID>

    releases:
      - name: &broker-release on-demand-service-broker
        version: latest
      - name: &service-adapter-release kafka-example-service-adapter
        version: latest
      - name: &service-release kafka-example-service
        version: latest

    stemcells:
      - alias: trusty
        os: ubuntu-trusty
        version: latest

    instance_groups:
      - name: broker
        azs: [z1]
        instances: 1
        jobs:
          - name: broker
            release: *broker-release
            properties:
              port: 8080
              username: broker #or replace with your own
              password: password #or replace with your own
              disable_ssl_cert_verification: true
              bosh:
                url: <REPLACE_WITH_BOSH_LITE_IP>
                authentication:
                  basic:
                    username: admin
                    password: admin
              service_adapter:
                path: /var/vcap/packages/kafka-service-adapter/bin/service-adapter
              service_deployment:
                releases:
                  - name: *service-release
                    version: latest
                    jobs: [kafka_server, zookeeper_server]
                stemcell:
                  os: ubuntu-trusty
                  version: latest
              service_catalog:
                id: D94A086D-203D-4966-A6F1-60A9E2300F72
                service_name: kafka-service-with-odb
                service_description: Kafka Service
                bindable: true
                plan_updatable: true
                tags: [kafka]
                plans:
                  - name: small
                    plan_id: 11789210-D743-4C65-9D38-C80B29F4D9C8
                    description: A Kafka deployment with a single instance of each job and persistent disk
                    instance_groups:
                      - name: kafka_server
                        vm_type: container
                        instances: 1
                        azs: [z1]
                        persistent_disk: ten
                        azs: [lite]
                        networks: [kafka]
                      - name: zookeeper_server
                        vm_type: container
                        instances: 1
                        azs: [z1]
                        persistent_disk: ten
                        azs: [lite]
                        networks: [kafka]
                    properties:
                      auto_create_topics: true
                      default_replication_factor: 1
          - name: kafka-service-adapter
            release: *service-adapter-release

        vm_type: container
        persistent_disk_type: ten
        stemcell: trusty
        azs: [lite]
        networks:
          - name: kafka

    update:
      canaries: 1
      canary_watch_time: 30000-180000
      update_watch_time: 30000-180000
      max_in_flight: 4
    ```

1. Deploy using the manifest from the previous step

    ```
    bosh deployment deployment_manifest.yml
    bosh deploy
    ```

1. Find out the ip address of the broker that was deployed with the `instances` BOSH command

    ```
    bosh instances
    ```

    Sample output:

    ```
    Acting as client 'admin' on deployment 'kafka-on-demand-broker' on 'Bosh Lite Director'

    Director task 147

    Task 147 done

    +--------------------------------------------------+---------+-----+-----------+------------+
    | Instance                                         | State   | AZ  | VM Type   | IPs        |
    +--------------------------------------------------+---------+-----+-----------+------------+
    | broker/0 (59231277-d7b8-46bb-8bbb-8154b6bae347)* | running | n/a | container | 10.244.1.2 |
    +--------------------------------------------------+---------+-----+-----------+------------+

    (*) Bootstrap node

    Instances total: 1
    ```
    Note the IP address of the broker.

1. Create a service broker on PCF dev and enable access to its service offering. You will need the broker's credentials set in the deployment manifest and the IP of the broker VM.

    ```
    cf create-service-broker kafka-broker broker password http://<REPLACE_WITH_BROKER_IP>:8080
    ```

    For more details on service brokers see [here](http://docs.cloudfoundry.org/services/api.html).

    Enable access to the broker's service plans:

    ```
    cf enable-service-access kafka-service-with-odb
    ```

    See the services offered by the broker in the marketplace:

    ```
    cf marketplace
    ```

    Sample output:

    ```
    Getting services from marketplace in org pcfdev-org / space pcfdev-space as admin...
    OK

    service                  plans        description
    kafka-service-with-odb   small        Kafka Service
    p-mysql                  512mb, 1gb   MySQL databases on demand
    p-rabbitmq               standard     RabbitMQ is a robust and scalable high-performance multi-protocol messaging broker.
    p-redis                  shared-vm    Redis service to provide a key-value store
    ```

1. Create a service instance using the Kafka on-demand service broker.

    ```
    cf create-service kafka-service-with-odb small k1
    ```

1. Check the status of your service. Initially, it should be `create in progress`. Eventually, it should be `create succeeded`.

    ```
    cf service k1
    ```

1. Check the BOSH deployment to see the on demand service provisioned by ODB.

    ```
    bosh deployments
    ```

    Sample output:

    ```
    +-------------------------------------------------------+---------------------------------------+--------------------------------------------------+--------------+
    | Name                                                  | Release(s)                            | Stemcell(s)                                      | Cloud Config |
    +-------------------------------------------------------+---------------------------------------+--------------------------------------------------+--------------+
    | kafka-on-demand-broker                                | kafka-example-service-adapter/0+dev.2 | bosh-warden-boshlite-ubuntu-trusty-go_agent/3147 | latest       |
    |                                                       | on-demand-service-broker/0.2.0+dev.1  |                                                  |              |
    +-------------------------------------------------------+---------------------------------------+--------------------------------------------------+--------------+
    | service-instance_2715262c-8564-4cd9-b629-0ae99e6aa4b9 | kafka-example-service/0+dev.2         | bosh-warden-boshlite-ubuntu-trusty-go_agent/3147 | latest       |
    +-------------------------------------------------------+---------------------------------------+--------------------------------------------------+--------------+
    ```

    Note the service instance has been provisioned with the service releases specified in the ODB deployment manifest.
