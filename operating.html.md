---
title: On-demand Service Broker Documentation
owner: London Services Enablement
---

# Deploying an On-demand Service Broker

- [What are the responsibilities of the Operator?](/on-demand-service-broker/operating.html#what-are-the-responsibilities-of-the-operator)
- [Setting up your BOSH director](/on-demand-service-broker/operating.html#configure-bosh)
- [Upload Required Releases](/on-demand-service-broker/operating.html#upload-required-releases)
- [Write a Broker Manifest](/on-demand-service-broker/operating.html#write-a-broker-manifest)
  - [Core Broker Configuration](/on-demand-service-broker/operating.html#core-broker-configuration)
  - [Service catalog and Plan composition](/on-demand-service-broker/operating.html#service-catalog-and-plan-composition)
- [Broker Management](/on-demand-service-broker/operating.html#broker-management)
  - [register-broker](/on-demand-service-broker/operating.html#register-broker)
  - [deregister-broker](/on-demand-service-broker/operating.html#deregister-broker)
  - [Upgrading the broker and existing service instances](/on-demand-service-broker/operating.html#upgrading-the-broker-and-existing-service-instances)
  - [Deleting all service instances](/on-demand-service-broker/operating.html#deleting-all-service-instances)

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
If the On-Demand Service Broker (ODB) is configured to communicate with BOSH on the director's private IP you can probably get away with insecure HTTP.

If ODB is configured to communicate with BOSH on the director's public IP you will probably be using a self-signed certificate unless you have a domain for your BOSH director. ODB does not ignore TLS certificate validation errors (as expected), and there is no configuration option to add root certificates to the trusted pool.

Instead, we recommend using BOSH's `trusted_certs` feature to add the self-signed CA certificate to each VM BOSH deploys. For more details on how to generate and use self-signed certificates for BOSH director and UAA, see [Director SSL Certificate Configuration](https://bosh.io/docs/director-certs.html).

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
    director_uuid: <director-uuid>
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

<a id="upgrading-the-broker-and-existing-service-instances" /></a>
### Upgrading the broker and existing service instances

The broker is upgraded in a similar manner to all BOSH releases:

* upload relevant releases (typically ODB and a Service Adapter)
* make any necessary manifest changes
* deploy the manifest

Often, a broker upgrade will involve an upgrading of the service release(s). In this case, upload the new version of the service release(s) and change the broker manifest properties to deploy these newer versions. Any new instances will use the new versions, but you must use an errand to upgrade existing service instances.

Note that if a developer runs `cf update-service` on an outdated instance, they will have their instance upgraded regardless of whether or not the operator ran the errand.

Add the following instance group to your manifest:

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

Add the following manifest properties (they overlap with the properties blocks described in previous sections):

```yaml
broker:
  port: <port>
  username: <username>
  password: <password>
```

Run the errand with `bosh run errand upgrade-sub-deployments`.

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

**[Back to Contents Page](/on-demand-service-broker/index.html)**
