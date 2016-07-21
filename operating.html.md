---
title: On-demand Service Broker Documentation
owner: London Services Enablement
---

# Deploying an On-demand Service Broker

- [What are the responsibilities of the Operator?](#what-are-the-responsibilities-of-the-operator)
- [Setting up your BOSH director](#configure-bosh)
  - [SSL certificates](#ssl-certificates)
  - [BOSH teams](#bosh-teams)
  - [Cloud Controller](#cloud-controller)
- [Upload Required Releases](#upload-required-releases)
- [Write a Broker Manifest](#write-a-broker-manifest)
  - [Core Broker Configuration](#core-broker-configuration)
  - [Service catalog and Plan composition](#service-catalog-and-plan-composition)
- [Broker Management](#broker-management)
  - [register-broker](#register-broker)
  - [deregister-broker](#deregister-broker)
  - [Administering service instances](#administering-instances)
  - [Upgrading the broker](#upgrading-the-broker)
  - [Upgrading existing service instance](#upgrading-existing-service-instances)
  - [Deleting all service instances](#deleting-all-service-instances)
  - [Updating service plans](#updating-service-plans)
  - [Disabling service plans](#disabling-service-plans)
  - [Removing service plans](#removing-service-plans)
- [Security](#security)
  - [BOSH API Endpoints](#bosh-api-endpoints)
  - [BOSH UAA permissions](#bosh-uaa-permissions)
  - [PCF IPsec Add-On](#ipsec)
- [Troubleshooting](#troubleshooting)
  - [Logs](#logs)
  - [Identifying deployments in BOSH](#identifying-deployments)
  - [Identifying BOSH tasks](#identifying-tasks)
  - [Identifying issues with connecting to BOSH and/or UAA](#identifying-bosh-uaa-issues)
  - [Listing service instances](#listing-service-instances)

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

Dependencies for the On-Demand Service Broker:

- BOSH director v257 or later
- Cloud Foundry v238 or later

<a id="ssl-certificates"></a>
### SSL certificates

If the On-Demand Service Broker (ODB) is configured to communicate with BOSH on the director's private IP you can probably get away with insecure HTTP.

If ODB is configured to communicate with BOSH on the director's public IP you will probably be using a self-signed certificate unless you have a domain for your BOSH director. ODB does not ignore TLS certificate validation errors by default (as expected). You have two options to configure certificate-based authentication between the BOSH director and the ODB:

1. Add the BOSH director's root certificate to ODB's trusted pool (**recommended**):

    ```yaml
    bosh:
      root_ca_cert: <root-ca-cert>
    ```

1. Use BOSH's `trusted_certs` feature to add a self-signed CA certificate to each VM BOSH deploys. For more details on how to generate and use self-signed certificates for BOSH director and UAA, see [Director SSL Certificate Configuration](https://bosh.io/docs/director-certs.html).

You can also configure a separate root CA certificate that is used when ODB communicates with the Cloud Foundry API (Cloud Controller). This is done in a similar way to above. Please see [manifest snippets below](#core-broker-configuration) for details.

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

For more details on securing how ODB uses BOSH, see [Security](#security).

<aid="cloud-controller"></a>
### Cloud Controller

ODB used the Cloud Controller as a source of truth about service offerings, plans, and instances. To reach Cloud Controller, ODB needs to be configured with client credentials that can do this. As of Cloud Foundry v238, the UAA client must have authority `cloud_controller.admin`. Detailed broker configuration is covered [below](#core-broker-configuration).

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

The broker is stateless and does not need a persistent disk. The VM type can be quite small: a single CPU and 1 GB of memory should be sufficient in most cases.

An example snippet is shown below:

```yaml
instance_groups:
  - name: broker # this can be anything
    instances: 1
    jobs:
      - name: broker
        release: on-demand-service-broker
        properties:
          # choose a port and basic auth credentials for the broker
          port: <broker port>
          username: <broker username>
          password: <broker password>
          disable_ssl_cert_verification: <true|false> # optional, defaults to false. This should NOT be used in production
          cf_system_domain: <system domain> # required only if you want to access the broker from outside the BOSH private network
          cf_route: # required only if you want to access the broker from outside the BOSH private network
            subdomain: <subdomain>
            nats:
              host: <host>
              username: <username>
              password: <password>
          cf:
            url: <CF API URL>
            root_ca_cert: <ca cert for cloud controller> # optional, see SSL certificates
            authentication:
              uaa:
                url: <CF UAA URL>
                client_id: <UAA client id with cloud_controller.admin authority>
                client_secret: <UAA client secret>
          bosh:
            url: <director url>
            root_ca_cert: <ca cert for bosh director and associated UAA> # optional, see SSL certificates
            authentication: # either basic or uaa, not both as shown
              basic:
                username: <bosh username>
                password: <bosh password>
              uaa:
                url: <BOSH UAA URL> # often on the same host as the director, on a different port
                client_id: <bosh client id>
                client_secret: <bosh client secret>
          service_adapter:
            path: <path to service adapter binary> # provided by the Service Author
          # There are more properties here, that will be discussed below

      - name: <service adapter job name>
        release: <service adapter release>

    vm_type: <vm type>
    stemcell: <stemcell>
    networks:
      - name: <network>
```

This snippet is using the BOSH v2 syntax, and making use of global cloud config and job-level properties.

Please note that the `disable_ssl_cert_verification` option is dangerous and **should not be used in production**.

<a id="service-catalog-and-plan-composition"></a>
### Service catalog and Plan composition

The operator must:

1. Supply each release job specified by the Service Author exactly once. You can include releases that provide many jobs, as long as each required job is provided by exactly one release.
1. Supply one stemcell that is used on each VM in the service deployments. ODB does not currently support service instance deployments that use a different stemcell for different instance groups.
1. Create Cloud Foundry [service metadata](https://docs.pivotal.io/pivotalcf/services/catalog-metadata.html#services-metadata-fields) in the catalog for the service offering. This metadata will be aggregated in the Cloud Foundry marketplace and displayed in Apps Manager and the `cf` CLI.
1. Compose plans. In ODB, service authors do not define plans but instead expose plan properties. The operator's role is to compose combinations of these properties, along with IAAS resources and catalog metadata into as many plans as they like.
  1. Create Cloud Foundry [service plan metadata](https://docs.pivotal.io/pivotalcf/services/catalog-metadata.html#plan-metadata-fields) in the service catalog for each plan.
  1. Provide resource mapping for each instance group specified by the Service Author for each plan.
     The resource values must correspond to valid resource definitions in the BOSH director's global cloud config.
     In some cases Service Authors will recommend resource configuration: e.g. in single-node Redis deployments, an instance count greater than 1 does not make sense.
     Here the operator can configure the deployment to span multiple availability zones, by using the [BOSH multi-az feature](https://bosh.io/docs/azs.html). For example the [kafka multi az plan](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release/blob/master/docs/example-manifest.yml#L100). In some cases, service authors will provide errands for the service release. You can add an instance group of type errand by setting the lifecycle field. For example the [smoke_tests for the kafka deployment](https://github.com/pivotal-cf-experimental/kafka-example-service-adapter-release/blob/master/docs/example-manifest.yml#L93).
  1. Provide values for plan properties.
     Plan properties are key-value pairs defined by the Service Author. Some examples include a boolean to enable disk persistence for Redis, and a list of strings representing RabbitMQ plugins to load. The Service Author should document whether these properties are mandatory or optional, whether the use of one property precludes the use of another, and whether certain properties affect recommended instance group to resource mappings.
  1. Provide an (optional) update block for each plan.
     You may require plan-specific configuration for BOSH's update instance operation. The ODB passes the plan-specific update block to the service adapter. Plan-specific update blocks should have the same structure as [the update block in a BOSH manifest](https://bosh.io/docs/manifest-v2.html#update). The Service Author can define a default update block to be used when a plan-specific update block is not provided, and whether the service adapter supports their configuration in the manifest.

Add the snippet below to your broker job properties section:

```yaml
service_deployment:
  releases:
    - name: <service-release>
      version: <service-release-version>
      jobs: [<release-jobs-needed-for-deployment>] # Service Author will specify list of jobs required
  stemcell: # every instance group in the service deployment has the same stemcell
    os: <service-stemcell>
    version: <service-stemcell-version>
service_catalog:
  id: <CF marketplace ID>
  service_name: <CF marketplace service offering name>
  service_description: <CF marketplace description>
  bindable: <true|false>
  plan_updatable: <true|false>
  metadata: # optional
    display_name: <display name>
    image_url: <image url>
    long_description: <long description>
    provider_display_name: <provider display name>
    documentation_url: <documentation url>
    support_url: <support url>
  plans:
    - name: <CF marketplace plan name>
      plan_id: <CF marketplace plan id>
      description: <CF marketplace description>
      metadata: # optional
        display_name: <display name>
        bullets: [<bullet1>, <bullet2>]
        costs:
          - amount:
              <currency code>: <currency amount (float)>
            unit: <frequency of cost>
      quotas: # optional
        service_instance_limit: <instance limit>
      instance_groups: # resource mapping for the instance groups defined by the Service Author
        - name: <service author provided instance group name>
          vm_type: <vm type>
          instances: <instance count>
          networks: [<network>]
          azs: [<az>]
          persistent_disk: <disk> # optional
      properties: {} # valid property key-value pairs are defined by the Service Author
      update: # optional
        canaries: 1 # required
        max_in_flight: 2  # required
        canary_watch_time: 1000-30000 # required
        update_watch_time: 1000-30000 # required
        serial: true # optional
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
      properties:
        broker_name: <broker-name>      
        cf:
          api_url: <cf-api-url>
          admin_username: <cf-api-admin-username>
          admin_password: <cf-api-admin-password>
  vm_type: <vm-type>
  stemcell: <stemcell>
  networks: [{name: <network>}]
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
      properties:
        broker_name: <broker-name>      
        cf:
          api_url: <cf-api-url>
          admin_username: <cf-api-admin-username>
          admin_password: <cf-api-admin-password>
  vm_type: <vm-type>
  stemcell: <stemcell>
  networks: [{name: <service-network>}]
```

Run the errand with `bosh run errand deregister-broker`.

<a id="administering-instances" /></a>
### Administering service instances
We recommend using the [bosh cli gem](https://bosh.io/docs/bosh-cli.html) for administering the deployments created by ODB; for example for checking VMs, ssh, viewing logs.

We **recommend against** using the bosh cli for updating/deleting ODB service deployments as it might accidentally trigger a race condition with Cloud Controller-induced updates/deletes or result in ODB overriding your [snowflake](http://martinfowler.com/bliki/SnowflakeServer.html) changes at the next deploy. All updates to the service instances must be done using the [errand to upgrade existing service instances](#upgrading-existing-service-instances).

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
  jobs:
    - name: <delete-sub-deployments>
      release: *broker-release
      properties:
        timeout_minutes: <time to wait for all instances to be deleted> # defaults to 60
        cf:
          api_url: <cf-api-url>
          admin_username: <cf-api-admin-username>
          admin_password: <cf-api-admin-password>

  vm_type: small
  stemcell: trusty
  networks: [{name: redis}]
```

Run the errand with `bosh run errand delete-sub-deployments`.

<a id="updating-service-plans"></a>
### Updating service plans

Service plans can be updated by changing the plan properties in the `service_catalog` for the broker. All service plan properties except the `service_id` and `plan_id` are modifiable. After the changing the catalog, you should update the cf marketplace using the `cf update-service-broker` command. The updated plan properties would be applied to newly created instances. To apply the plan properties to already provisioned instances, the [update sub-deployments errand](#upgrading-existing-service-instances) has to be run.

<a id="disabling-service-plans"></a>
### Disabling service plans
Access to a service plan can be disabled by using the cloudfoundry api.

On the cli you can use
```
cf disable-service-access <service-name-from-catalog> -p <plan-name>
```

<a id="removing-service-plans"></a>
### Removing service plans
A service plans can be removed if there are no instances using the plan. To remove the a plan, remove it from the broker manifest and update the cf marketplace by using the `cf update-service-broker` command. If a plan with deployed service instances from the broker manifest, the broker will fail to startup.

<a id="security"></a>
## Security

<a id="bosh-api-endpoints"></a>
### BOSH API Endpoints

The ODB accesses the following [BOSH API](https://bosh.io/docs/director-api-v1.html) endpoints during the service instance lifecycle:

| API endpoint                                                     | Examples of usage in the ODB                                                                                                                                 |
|:-----------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `POST /deployments`                                              | create, or update a service instance                                                                                                                         |
| `POST /deployments/<deployment_name>/errands/<errand_name>/runs` | register, or de-register the on-demand broker with the Cloud Controller, run smoke tests                                                                     |
| `GET /deployments/<deployment_name>`                             | passed as argument to the service adapter for `generate-manifest` and `create-binding`                                                                       |
| `GET /deployments/<deployment_name>/vms?format=full`             | passed as argument to the service adapter for `create-binding`                                                                                               |
| `DELETE /deployments/<deployment_name>`                          | delete a service instance                                                                                                                                    |
| `GET /tasks/<task_ID>/output?type=result`                        | check a task was successful (i.e. the exit code was zero), get list of VMs                                                                                   |
| `GET /tasks/<task_ID>`                                           | poll the BOSH director until a task finishes, e.g. create, update, or delete a deployment                                                                    |
| `GET /tasks?deployment=<deployment_name>`                        | determine the last operation status and message for a service instance, e.g. 'create in progress' - used when creating, updating, deleting service instances |

<a id="bosh-uaa-permissions"></a>
### BOSH UAA permissions

The actions that the ODB needs to be able to perform are:

Modify:

- `bosh deploy`
- `bosh delete deployment`
- `bosh run errand`

Read only:

- `bosh deployments`
- `bosh vms`
- `bosh tasks`

The minimum UAA authority required by the BOSH Director to perform these actions is `bosh.teams.<team>.admin`. Note: a team admin cannot view or update the director's cloud config, nor upload releases or stemcells.

For more details on how to set up and use BOSH teams, see [Director teams and permissions configuration](https://bosh.io/docs/director-users-uaa-perms.html).

#### Unused BOSH permissions
The team admin authority also allows the following actions, which currently are not used by the ODB:

- `bosh start/stop/recreate`
- `bosh cck`
- `bosh ssh`
- `bosh logs`
- `bosh releases`
- `bosh stemcells`

<a id="ipsec"></a>
### PCF IPsec Add-On

The ODB has been tested with the [PCF IPsec Add-On](https://docs.pivotal.io/addon-ipsec/installing.html), and it appears to work. Note that we excluded the BOSH director itself from IPsec ranges, as the BOSH add-on cannot be applied to BOSH itself.

<a id="troubleshooting"></a>
## Troubleshooting

<a id="logs"></a>
### Logs

The on-demand service broker writes logs to a log file, and to syslog.

The broker log contains error messages and non-zero exit codes returned by the service adapter, as well as the stdout and stderr streams of the adapter.

The log file is located at `/var/vcap/sys/log/broker/broker.log`. In syslog, logging is written with the tag `on-demand-service-broker`, under the facility `user`, with priority `info`.

If you want to forward syslog to a syslog aggregator, we recommend co-locating [syslog release](https://github.com/cloudfoundry/syslog-release) with the broker.

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
    bosh task <task_ID>
    ```

<a id="identifying-bosh-uaa-issues"></a>
### Identifying issues with connecting to BOSH and/or UAA

The ODB interacts with the BOSH director to provision and deprovision instances, and is authenticated via the director's UAA. See [Core Broker Configuration](#core-broker-configuration) for an example configuration.

If BOSH and/or UAA are wrongly configured in the broker's manifest, then meaningful error messages will be displayed in the broker's log, indicating whether the issue is caused by an unreachable destination or bad credentials.

For example

```
on-demand-service-broker: [on-demand-service-broker] 2016/05/18 15:56:40 Error authenticating (401): {"error":"unauthorized","error_description":"Bad credentials"}, please ensure that properties.<broker-job>.bosh.authentication.uaa is correct and try again.
```

<a id="listing-service-instances"></a>
### Listing service instances

The ODB persists the list of ODB-deployed service instances and provides an endpoint to retrieve them. This endpoint requires basic authentication.

During disaster recovery this endpoint could be used to assess the situation.

**Request**

`GET http://username:password@<REPLACE_WITH_BROKER_IP>:8080/mgmt/service_instances`

**Response**

200 OK

Example JSON body:

  ```json
  [
    {
      "instance_id": "4d19462c-33cf-11e6-91cc-685b3585cc4e",
      "plan_id": "60476620-33cf-11e6-a841-685b3585cc4e",
      "bosh_deployment_name": "service-instance_4d19462c-33cf-11e6-91cc-685b3585cc4e"
    },
    {
      "instance_id": "57014734-33cf-11e6-ba8d-685b3585cc4e",
      "plan_id": "60476620-33cf-11e6-a841-685b3585cc4e",
      "bosh_deployment_name": "service-instance_57014734-33cf-11e6-ba8d-685b3585cc4e"
    }
  ]
  ```

**[Back to Contents Page](/on-demand-service-broker/index.html)**
