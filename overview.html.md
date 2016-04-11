---
title: On-demand Service Broker Documentation
owner: London Services Enablement
---

# Overview

- [What is a Cloud Foundry service broker?](/on-demand-service-broker/overview.html#what-is-a-cloud-foundry-service-broker)
- [What is an on-demand service broker?](/on-demand-service-broker/overview.html#what-is-an-on-demand-service-broker)
- [What is a service adapter?](/on-demand-service-broker/overview.html#what-is-a-service-adapter)
- [Why provision IAAS resources on-demand?](/on-demand-service-broker/overview.html#why-provision-iaas-resources-on-demand)
- [Why use ODB to develop on-demand service offerings?](/on-demand-service-broker/overview.html#why-use-odb-to-develop-on-demand-service-offerings)
- [Prerequisites for deploying brokers that use ODB](/on-demand-service-broker/overview.html#prerequisites-for-deploying-brokers-that-use-odb)
  - [BOSH v2 Features we use](/on-demand-service-broker/overview.html#bosh-v2-features-we-use)
- [Steps required to use on-demand service broker](/on-demand-service-broker/overview.html#steps-required-to-use-on-demand-service-broker)

<a id="what-is-a-cloud-foundry-service-broker"></a>
## What is a Cloud Foundry service broker?
A Cloud Foundry service broker allows application developers to provision services to be used by their Cloud Foundry apps. They are implemented as HTTP servers that conform to the [service broker API](http://docs.cloudfoundry.org/services/api.html). These brokers are registered with Cloud Controller in order to populate a service marketplace.

<a id="what-is-an-on-demand-service-broker"></a>
## What is an on-demand service broker?
An on-demand Cloud Foundry service broker is a service broker that provisions IAAS resources at service instance creation time, as opposed to pre-provisioning a fixed quantity of these resources at broker deployment time. The **On-demand Service Broker (ODB)** is a generic on-demand service broker for single-tenant (dedicated service process/cluster per Cloud Foundry service instance) service offerings where one service instance corresponds to one BOSH deployment.

Service-specific functionality is plugged in by the service author via an executable called a **Service Adapter**. For more information about the responsibilities of Service Authors, please see [Creating the Service Author Deliverables](/on-demand-service-broker/creating.html).

<a id="what-is-a-service-adapter"></a>
## What is a service adapter?
A service adapter is a binary which would be called out by the ODB, when it wants to do service-specific tasks.
![responsibility-diagram](/on-demand-service-broker/img/responsibility-diagram.png)
The above diagram shows where responsibility lies for each aspect of the ODB workflow.

<a id="why-provision-iaas-resources-on-demand"></a>
## Why provision IAAS resources on-demand?
* Scale resource consumption linearly with need, without having to plan for pre-provisioning.
* Application developers get some control over resources, and do not have to do acquire them through the operator.

<a id="why-use-odb-to-develop-on-demand-service-offerings"></a>
## Why use ODB to develop on-demand service offerings?
* ODB reduces the amount of code service developers have to write by abstracting away functionality common to most single-tenant on-demand service brokers.
* ODB uses BOSH to deploy service instances, so anything that is BOSH-deployable can be integrated with Cloud Foundry's services marketplace.

<a id="prerequisites-for-deploying-brokers-that-use-odb"></a>
## Prerequisites for deploying brokers that use ODB
* BOSH director v246+

<a id="bosh-v2-features-we-use"></a>
### BOSH v2 Features we use
* Dynamic IP management
* Availability zones
* Globally-defined resources (**Cloud Config**). This results in manifests that are portable across BOSH CPIs, and are substantially smaller than old-style manifests.
* Links: deployed BOSH instances consuming information (e.g. IP address) of other instances.

<a id="steps-required-to-use-on-demand-service-broker"></a>
## Steps required to use on-demand service broker

The follow steps are required to create and maintain an ODB:

* [The Service Authors provide their deliverables](/on-demand-service-broker/creating.html)
* [The Operators upload their releases and write a manifest](/on-demand-service-broker/installing.html)

**[Back to Contents Page](/on-demand-service-broker/index.html)**
