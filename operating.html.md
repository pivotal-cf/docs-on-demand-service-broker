---
title: On-demand Service Broker Documentation
owner: London Services Enablement
---

# Deploying an On-demand Service Broker

- [What are the responsibilities of the Operator?](#what-are-the-responsibilities-of-the-operator)
- [Setting up your BOSH director](#configure-bosh)
  - [SSL certificates](#ssl-certificates)
  - [BOSH teams](#bosh-teams)
- [Upload Required Releases](#upload-required-releases)
- [Write a Broker Manifest](#write-a-broker-manifest)
  - [Core Broker Configuration](#core-broker-configuration)
  - [Service catalog and Plan composition](#service-catalog-and-plan-composition)
- [Broker Management](#broker-management)
  - [register-broker](#register-broker)
  - [deregister-broker](#deregister-broker)
  - [Upgrading the broker](#upgrading-the-broker)
  - [Upgrading existing service instance](#upgrading-existing-service-instances)
  - [Deleting all service instances](#deleting-all-service-instances)
- [Troubleshooting](#troubleshooting)
  - [Logs](#logs)
  - [Identifying deployments in BOSH](#identifying-deployments)
  - [Identifying BOSH tasks](#identifying-tasks)

<a id="what-are-the-responsibilities-of-the-operator"></a>
## What are the responsibilities of the Operator?
The operator is responsible for the following tasks:
- Configuring the BOSH director
- Uploading the required releases for the broker deployment and service instance deployments.
- Write a broker manifest
  - See [v2-style manifest docs](http://bosh.io/docs/manifest-v2.html) if unfamiliar with writing BOSH v2 manifests
  - Core broker Configuration
  - Service catalog and Plan composition
- Broker Management

For a list of deliverables provided by the Service Author, see [Required Deliverables](/on-demand-service-broker/creating.html#what-is-required-of-the-service-authors).

For an example manifest for a Redis service, see [redis-example-service-adapter-release](https://github.com/pivotal-cf-experimental/redis-example-service-adapter-release/blob/master/docs/example-manifest.yml).

For an example manifest for a Kafka service, see [kafka-example-service-adapter-release](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release/blob/master/docs/example-manifest.yml).


<a id="configure-bosh"></a>
## Setting up your BOSH director

<a id="ssl-certificates"></a>
### SSL certificates

If the On-Demand Service Broker (ODB) is configured to communicate with BOSH on the director's private IP you can probably get away with insecure HTTP.

If ODB is configured to communicate with BOSH on the director's public IP you will probably be using a self-signed certificate unless you have a domain for your BOSH director. ODB does not ignore TLS certificate validation errors (as expected), and there is no configuration option to add root certificates to the trusted pool.

Instead, we recommend using BOSH's `trusted_certs` feature to add the self-signed CA certificate to each VM BOSH deploys. For more details on how to generate and use self-signed certificates for BOSH director and UAA, see [Director SSL Certificate Configuration](https://bosh.io/docs/director-certs.html).

<a id="bosh-teams"></a>
### BOSH teams

BOSH has a teams feature that allows you to further control how BOSH operations are available to different clients. We recommend using it to ensure that your on-demand service broker client can only see deployments it is allowed to. For example, if you [use uaac](https://docs.cloudfoundry.org/adminguide/uaa-user-management.html) to create the client like this:

```bash
uaac client add <client-id> \
  --secret <client-secret> \
  --authorized_grant_types "refresh_token password client_credentials" \
  --authorities "bosh.teams.<team-name>.admin"
```

Then when you [configure the broker's BOSH authentication](#core-broker-configuration), you can use this client ID and secret. The broker will then only be able to perform BOSH operations on deployments it has created itself.

For more details on how to set up and use BOSH teams, see [Director teams and permissions configuration](https://bosh.io/docs/director-users-uaa-perms.html).

<a id="upload-required-releases"></a>
## Upload Required Releases

Upload the following releases to the BOSH director:

* on-demand-service-broker
* your service adapter
* your service release(s)

<a id="write-a-broker-manifest"></a>
## Write a broker manifest

<a id="core-broker-configuration"></a>
### Core Broker Configuration
Your manifest should contain one non-errand instance group, that co-locates both:

* the `broker` job from on-demand-service-broker
* your service adapter job from your service adapter release

The instance group should have a persistent disk, and only one instance. The VM type can be quite small: a single CPU and 1 GB of memory should be sufficient in most cases. The persistent disk can also be small; the broker stores a few hundred bytes per service instance.

An example snippet is shown below:

```yaml
instance_groups:
  - name: broker # this can be anything
    instances: 1
    jobs:
      - name: broker
        release: on-demand-service-broker
      - name: syslog-configurator # optional
        release: on-demand-service-broker
      - name: <service-adapter-job-name>
        release: <service-adapter-release>
    vm_type: <vm-type>
    persistent_disk_type: <persistent-disk-type>
    stemcell: <stemcell>
    networks:
      - name: <network>
```

Note that this snippet is using the BOSH v2 syntax, and making use of global cloud config.

Add the snippet below to your manifest's properties section:

```yaml
broker: # choose a port and basic auth credentials for the broker
  port: <broker-port>
  username: <broker-username>
  password: <broker-password>
  disable_ssl_cert_verification: <true|false> # optional, defaults to false. This should NOT be used in production
  syslog_aggregator: # required only if using syslog-configurator
    address: <address>
    port: <port>
    transport: <tcp|udp|relp>
  cf_route: # required only if you want to access the broker from outside the BOSH private network
    subdomain: <subdomain>
    nats:
      host: <host>
      username: <username>
      password: <password>
  bosh:
    url: <director-url>
    authentication: # either basic or uaa, not both as shown
      basic:
        username: <bosh-username>
        password: <bosh-password>
      uaa:
        url: <uaa-url> # often on the same host as the director, on a different port
        client_id: <bosh-client-id>
        client_secret: <bosh-client-secret>
  service_adapter:
    path: <path-to-service-adapter-binary> # provided by the Service Author
cf:
  system_domain: <system-domain> # required only if you want to access the broker from outside the BOSH private network
```

Please note that the `disable_ssl_cert_verification` option is dangerous and **should not be used in production**.

<a id="service-catalog-and-plan-composition"></a>
### Service catalog and Plan composition

The operator must:

1. Supply each release job specified by the Service Author exactly once. You can include releases that provide many jobs, as long as each required job is provided by exactly one release.
1. Supply one stemcell that is used on each VM in the service deployments. ODB does not currently support service instance deployments that use a different stemcell for different instance groups.
1. Create Cloud Foundry catalog metadata for the service offering.
1. Compose plans. In ODB, service authors do not define plans but instead expose plan properties. The operator's role is to compose combinations of these properties, along with IAAS resources and catalog metadata into as many plans as they like.
  1. Create Cloud Foundry catalog metadata for each plan.
  1. Provide resource mapping for each instance group specified by the Service Author for each plan.
     The resource values must correspond to valid resource definitions in the BOSH director's global cloud config.
     In some cases Service Authors will recommend resource configuration: e.g. in single-node Redis deployments, an instance count greater than 1 does not make sense.
     Here the operator can configure the deployment to span multiple availability zones, by using the [BOSH multi-az feature](https://bosh.io/docs/azs.html). For example the [kafka multi az plan](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release/blob/master/docs/example-manifest.yml#L74). In some cases, service authors will provide errands for the service release. You can add an instance group of type errand by setting the lifecycle field. For example the [smoke_tests for the kafka deployment](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release/blob/master/docs/example-manifest.yml#L84).
  1. Provide values for plan properties.
     Plan properties are key-value pairs defined by the Service Author. Some examples include a boolean to enable disk persistence for Redis, and a list of strings representing RabbitMQ plugins to load. The Service Author should document whether these properties are mandatory or optional, whether the use of one property precludes the use of another, and whether certain properties affect recommended instance group to resource mappings.

Add the snippet below to your manifest's properties section:

```yaml
broker:
  service_deployment:
    releases:
      - name: <service-release>
        version: <service-release-version> # does not support "latest"
        jobs: [<release-jobs-needed-for-deployment>] # Service Author will specify list of jobs required
    stemcell: # every instance group in the service deployment has the same stemcell
      os: <service-stemcell>
      version: <service-stemcell-version> # does not support "latest"
  service_catalog:
    id: <CF marketplace ID>
    service_name: <CF marketplace service offering name>
    service_description: <CF marketplace description>
    bindable: <true|false>
    plan_updatable: <true|false>
    metadata: # optional
      display_name: <display name>
    plans:
      - name: <CF marketplace plan name>
        plan_id: <CF marketplace plan id>
        description: <CF marketplace description>
        metadata: # optional
          display_name: <display name>
          bullets: [<bullet1>, <bullet2>]
        quotas: # optional
          service_instance_limit: <instance limit>
        instance_groups: # resource mapping for the instance groups defined by the Service Author
          - name: <service author provided instance group name>
            vm_type: <vm type>
            instances: <instance count>
            networks: [<network>]
            azs: [<az>] # optional
            persistent_disk: <disk> # optional
        properties: {} # valid property key-value pairs are defined by the Service Author
```

<a id="broker-management"></a>
## Broker Management

Management tasks on the broker are performed with BOSH errands.

<a id="register-broker"></a>
### register-broker
This errand registers the broker with Cloud Foundry and enables access for all orgs and spaces to the defined plans of the service. The errand should be run whenever the broker is re-deployed with new catalog metadata to update the Cloud Foundry catalog.

Add the following instance group to your manifest:

```yaml
- name: register-broker
  lifecycle: errand
  instances: 1
  jobs:
    - name: register-broker
      release: <odb-release-name>
  vm_type: <vm-type>
  stemcell: <stemcell>
  networks: [{name: <network>}]
```

Add the following manifest properties (they overlap with the properties blocks described in previous sections):

```yaml
broker:
  name: <broker-name>
  port:  <broker-port>
  username:  <broker-username>
  password:  <broker-password>
  cf_route: # required only if you want to access the broker from outside the BOSH private network
    subdomain: <broker-route>
  service_catalog:
    service_name: <broker-name>

cf:
  api_url: <cf-api-url>
  admin_username: <cf-api-admin-username>
  admin_password: <cf-api-admin-password>
  system_domain:  <cf-system-domain> # required only if you want to access the broker from outside the BOSH private network
```

Run the errand with `bosh run errand register-broker`.

<a id="deregister-broker"></a>
### deregister-broker

This errand deregisters a broker from Cloud Foundry. It requires that there are no existing service instances.

Add the following instance group to your manifest:

```yaml
- name: deregister-broker
  lifecycle: errand
  instances: 1
  jobs:
    - name: deregister-broker
      release: <odb-release-name>
  vm_type: <vm-type>
  stemcell: <stemcell>
  networks: [{name: <service-network>}]
```

Add the following manifest properties (they overlap with the properties blocks described in previous sections):

```yaml
broker:
  name: <broker-name>
cf:
  api_url: <cf-api-url>
  admin_username: <cf-api-admin-username>
  admin_password: <cf-api-admin-password>
  system_domain:  <cf-system-domain>
```

Run the errand with `bosh run errand deregister-broker`.

<a id="upgrading-the-broker" /></a>
### Upgrading the broker

The broker is upgraded in a similar manner to all BOSH releases:

* upload relevant releases (typically ODB and a Service Adapter)
* make any necessary manifest changes
* deploy the manifest

Often, a broker upgrade will involve an upgrading of the service release(s). In this case, upload the new version of the service release(s) and change the broker manifest properties to deploy these newer versions. Any new instances will use the new versions, but you must use an [errand to upgrade existing service instances](#upgrading-existing-service-instances).

<a id="upgrading-existing-service-instances" /></a>
### Upgrading existing service instances

1. Ensure you have the `upgrade-sub-deployments` errand instance group on the broker manifest

    ```yaml
    - name: upgrade-sub-deployments
      lifecycle: errand
      instances: 1
      jobs:
        - name: upgrade-sub-deployments
          release: <odb-release-name>
      vm_type: <vm>
      stemcell: <stemcell>
      networks: [{name: <network>}]
    ```
1. Ensure broker credentials are present in the manifest

    ```yaml
    broker:
      port: <port>
      username: <username>
      password: <password>
    ```
1. Update the broker properties under `service_deployment/releases` to the required service release versions and `service_deployment/stemcell` has the required stemcell version
1. Upload the releases and stem cells specified in the `service_deployment` section of properties to the bosh director
1. Ensure latest broker manifest is deployed.
1. Run the errand with `bosh run errand upgrade-sub-deployments`.

Note that if a developer runs `cf update-service` on an outdated instance, they will have their instance upgraded regardless of whether or not the operator ran the errand.


<a id="deleting-all-service-instances"></a>
### Deleting all service instances

This errand deletes all service instances of your broker's service offering in every org and space of Cloud Foundry. It uses the Cloud Controller API to do this, and therefore only deletes instances the Cloud Controller knows about. It will not help you terminate "rogue" BOSH deployments, those that don't correspond to a known instance (this *should* never happen, but in practice it might).

**This should only be done with extreme caution, when you want to totally destroy an environment.**

Add the following instance group to your manifest:

```yaml
- name: delete-sub-deployments
  lifecycle: errand
  instances: 1
  jobs: [{name: <delete-sub-deployments>, release: *broker-release}]
  vm_type: small
  stemcell: trusty
  networks: [{name: redis}]
```

Add the following manifest properties (they overlap with the properties blocks described in previous sections):

```yaml
broker:
  service_catalog:
    id: <CF marketplace service ID>
timeout_minutes: <time to wait for all instances to be deleted> # defaults to 60
cf:
  api_url: <cf-api-url>
  admin_username: <cf-api-admin-username>
  admin_password: <cf-api-admin-password>
```

Run the errand with `bosh run errand delete-sub-deployments`.

<a id="troubleshooting"></a>
## Troubleshooting

<a id="logs"></a>
### Logs

The on-demand service broker writes logs to a log file, and to syslog. The log file is located at `/var/vcap/sys/log/broker/broker.log`. In syslog, logging is written with the tag `on-demand-service-broker`, under the facility `user`, with priority `info`.

<a id="identifying-deployments"></a>
### Identifying deployments in BOSH

There is a one to one mapping between the service instance id from CF and the deployment name in BOSH. The convention is the bosh deployment name would be the service instance id prepended by `service-instance_`. To identify the bosh deployment for a service instance you can.

1. Determine the GUID of the service

    ```
    cf service --guid <service-name>
    ```

2. Identify deployment in `bosh deployments` by looking for `service-instance_`GUID

3. Get current tasks for the deployment by using

    ```
    bosh tasks --deployment service-instance_<GUID>
    ```

<a id="identifying-tasks"></a>
### Identifying tasks in BOSH

Most operations on the on demand service broker API are implemented by launching BOSH tasks. If an operation fails, it may be useful to investigate the corresponding BOSH task. To do this:

1. Determine the ID of the service for which an operation failed. You can do this using the Cloud Foundry CLI:

    ```
    cf service --guid <service name>
    ```

1. SSH on to the service broker VM:

    ```
    bosh deployment <path to broker manifest>
    bosh ssh
    ```

1. In the broker log, look for lines relating to the service, identified by the service ID. Lines recording the starting and finishing of BOSH tasks will also have the BOSH task ID:

    ```
    on-demand-service-broker: [on-demand-service-broker] 2016/04/13 09:01:50 Bosh task id for Create instance 30d4a67f-d220-4d06-9989-58a976b86b35 was 11470
    on-demand-service-broker: [on-demand-service-broker] 2016/04/13 09:06:55 task 11470 success creating deployment for instance 30d4a67f-d220-4d06-9989-58a976b86b35: create deployment

    on-demand-service-broker: [on-demand-service-broker] 2016/04/13 09:16:20 Bosh task id for Update instance 30d4a67f-d220-4d06-9989-58a976b86b35 was 11473
    on-demand-service-broker: [on-demand-service-broker] 2016/04/13 09:17:20 task 11473 success updating deployment for instance 30d4a67f-d220-4d06-9989-58a976b86b35: create deployment

    on-demand-service-broker: [on-demand-service-broker] 2016/04/13 09:17:52 Bosh task id for Delete instance 30d4a67f-d220-4d06-9989-58a976b86b35 was 11474
    on-demand-service-broker: [on-demand-service-broker] 2016/04/13 09:19:56 task 11474 success deleting deployment for instance 30d4a67f-d220-4d06-9989-58a976b86b35: delete deployment service-instance_30d4a67f-d220-4d06-9989-58a976b86b35
    ```

1. Use the task ID to obtain the task log from BOSH (adding flags such as `--debug` or `--cpi` as necessary):

    ```
    bosh task <task ID>
    ```

**[Back to Contents Page](/on-demand-service-broker/index.html)**
